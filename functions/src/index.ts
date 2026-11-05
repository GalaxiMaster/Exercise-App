// firebase deploy --only functions
import {
  onDocumentWritten,
  onDocumentCreated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, QueryDocumentSnapshot, Timestamp, WriteBatch } from "firebase-admin/firestore";
import { Query } from "firebase-admin/firestore";

initializeApp();
setGlobalOptions({ region: "australia-southeast1" });
const db = getFirestore();

const USERS = "User Data";
const BACKFILL_LIMIT = 1000; // max workouts copied per person
const BACKFILL_PAGE = 300;

const pretty = (key: string) =>
  key.split("_").filter(Boolean).map((w) => w[0].toUpperCase() + w.slice(1)).join(" ");

// "2024-05-21 11:04" -> Date (treated as UTC; only used for ordering)
const parseTime = (s?: string) => {
  if (!s) return null;
  const d = new Date(s.replace(" ", "T") + "Z");
  return isNaN(d.getTime()) ? null : d;
};

function summarize(authorId: string, workoutId: string, w: any) {
  let volume = 0, setCount = 0, prCount = 0;
  for (const list of Object.values(w.sets ?? {}) as any[][]) {
    for (const s of list) {
      setCount++;
      if (s.PR === "yes") prCount++;
      if (s.type === "Warmup") continue;
      volume += (Number(s.weight) || 0) * (Number(s.reps) || 0);
    }
  }

  const { startTime, endTime, exerciseOrder, ...otherStats } = w.stats ?? {};
  const start = parseTime(startTime);
  const end = parseTime(endTime);

  const sets = w.sets ?? {};
  const order: string[] = exerciseOrder ?? [];
  const ordered = [
    ...order.filter((k) => k in sets),
    ...Object.keys(sets).filter((k) => !order.includes(k)), // fallback for old docs
  ];

  return {
    authorId,
    workoutId,
    startTime: start ? Timestamp.fromDate(start) : Timestamp.now(),
    durationMin: start && end ? Math.round((end.getTime() - start.getTime()) / 60000) : null,
    volume: Math.round(volume),
    setCount,
    prCount,
    data: otherStats,
    exercises: ordered.map(pretty),
  };
}

// Feed doc IDs combine author + workout, because workout IDs are only unique per user
const feedRef = (viewer: string, author: string, workoutId: string) =>
  db.doc(`feeds/${viewer}/items/${author}_${workoutId}`);

async function commit(ops: Array<(b: WriteBatch) => void>) {
  for (let i = 0; i < ops.length; i += 450) {
    const batch = db.batch();
    ops.slice(i, i + 450).forEach((op) => op(batch));
    await batch.commit();
  }
}

async function friendsOf(uid: string): Promise<string[]> {
  const snap = await db.collection("friendships").where("members", "array-contains", uid).get();
  return snap.docs.map((d) => (d.data().members as string[]).find((m) => m !== uid)!);
}

// Workout created / edited / deleted -> keep every friend's feed in sync
export const syncWorkout = onDocumentWritten(
  "{col}/{uid}/workouts/{workoutId}",
  async (event) => {
    const { col, uid, workoutId } = event.params;
    if (col !== USERS) return;

    const after = event.data?.after;
    const friends = await friendsOf(uid);
    if (friends.length === 0) return;

    if (!after || !after.exists) {
      await commit(friends.map((f) => (b: WriteBatch) => b.delete(feedRef(f, uid, workoutId))));
      return;
    }
    const post = summarize(uid, workoutId, after.data());
    await commit(friends.map((f) => (b: WriteBatch) => b.set(feedRef(f, uid, workoutId), post)));
  }
);

// New friendship -> copy each person's recent workouts to the other
async function backfill(author: string, viewer: string) {
  let last: QueryDocumentSnapshot | undefined;
  let copied = 0;

  while (copied < BACKFILL_LIMIT) {
    let q: Query = db
      .collection(USERS).doc(author).collection("workouts")
      .orderBy("stats.startTime", "desc")
      .limit(BACKFILL_PAGE);
    if (last) q = q.startAfter(last);

    const snap = await q.get();
    if (snap.empty) break;

    await commit(snap.docs.map((d) => (b: WriteBatch) =>
      b.set(feedRef(viewer, author, d.id), summarize(author, d.id, d.data()))));

    copied += snap.size;
    last = snap.docs[snap.docs.length - 1];
    if (snap.size < BACKFILL_PAGE) break;
  }
}

export const onFriendshipCreated = onDocumentCreated(
  { document: "friendships/{pid}", timeoutSeconds: 540, memory: "512MiB" },
  async (event) => {
    const members = event.data?.data()?.members as string[] | undefined;
    if (!members || members.length !== 2) return;
    const [a, b] = members;
    await Promise.all([backfill(a, b), backfill(b, a)]);
  }
);

// Unfriend -> remove each person's posts from the other's feed
export const onUnfriend = onDocumentDeleted("friendships/{pid}", async (event) => {
  const members = event.data?.data()?.members as string[] | undefined;
  if (!members || members.length !== 2) return;
  const [a, b] = members;

  for (const [owner, author] of [[a, b], [b, a]]) {
    const snap = await db.collection(`feeds/${owner}/items`).where("authorId", "==", author).get();
    await commit(snap.docs.map((d) => (batch: WriteBatch) => batch.delete(d.ref)));
  }
});