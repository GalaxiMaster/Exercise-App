import {
  onDocumentCreated,
  onDocumentDeleted,
} from "firebase-functions/v2/firestore";
import { initializeApp } from "firebase-admin/app";
import {
  getFirestore,
  FieldValue,
  DocumentData,
  WriteBatch,
} from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

const USER_COLLECTION = "User Data";
const WORKOUT_SUBCOLLECTION = "workouts";
const BACKFILL_COUNT = 10;

// Helpers

/** Build the denormalized feed item from a workout doc + author profile. */
function buildPost(
  authorId: string,
  workoutId: string,
  w: DocumentData,
  profile: DocumentData | undefined
) {
  return {
    authorId,
    authorName: profile?.displayName ?? profile?.username ?? "",
    authorPhoto: profile?.photoUrl ?? null,
    workoutId,
    // Adjust these field names to match your workout documents:
    title: w.title ?? "Workout",
    durationSec: w.durationSec ?? null,
    totalVolume: w.totalVolume ?? null,
    exercises: (w.exercises ?? []).slice(0, 5).map((e: any) => e.name),
    createdAt: w.completedAt ?? FieldValue.serverTimestamp(),
  };
}

/** Commit writes in chunks to stay under Firestore's 500-op batch limit. */
async function commitInChunks(
  ops: Array<(batch: WriteBatch) => void>,
  chunkSize = 450
) {
  for (let i = 0; i < ops.length; i += chunkSize) {
    const batch = db.batch();
    ops.slice(i, i + chunkSize).forEach((op) => op(batch));
    await batch.commit();
  }
}

// Fan out a new workout to every friend's feed

export const fanOutWorkout = onDocumentCreated(
  `{col}/{uid}/${WORKOUT_SUBCOLLECTION}/{workoutId}`,
  async (event) => {
    const { col, uid, workoutId } = event.params;
    if (col !== USER_COLLECTION) return;

    const w = event.data?.data();
    if (!w) return;

    // Optional: let users opt out per workout
    if (w.shareToFeed === false) return;

    const profile = (await db.doc(`profiles/${uid}`).get()).data();

    const friendships = await db
      .collection("friendships")
      .where("members", "array-contains", uid)
      .get();

    if (friendships.empty) return;

    const post = buildPost(uid, workoutId, w, profile);

    const ops = friendships.docs.map((f) => {
      const friendId = (f.data().members as string[]).find((m) => m !== uid)!;
      return (batch: WriteBatch) =>
        batch.set(db.doc(`feeds/${friendId}/items/${workoutId}`), post);
    });

    await commitInChunks(ops);
  }
);

// Backfill recent workouts when two people become friends

export const onFriendshipCreated = onDocumentCreated(
  "friendships/{pid}",
  async (event) => {
    const members = event.data?.data()?.members as string[] | undefined;
    if (!members || members.length !== 2) return;

    const [a, b] = members;

    // Copy each person's recent workouts into the other's feed
    for (const [author, viewer] of [
      [a, b],
      [b, a],
    ]) {
      const profile = (await db.doc(`profiles/${author}`).get()).data();

      const recent = await db
        .collection(USER_COLLECTION)
        .doc(author)
        .collection(WORKOUT_SUBCOLLECTION)
        .orderBy("completedAt", "desc")
        .limit(BACKFILL_COUNT)
        .get();

      const ops = recent.docs
        .filter((d) => d.data().shareToFeed !== false)
        .map((d) => (batch: WriteBatch) =>
          batch.set(
            db.doc(`feeds/${viewer}/items/${d.id}`),
            buildPost(author, d.id, d.data(), profile)
          )
        );

      await commitInChunks(ops);
    }
  }
);

// Unfriend cleanup: remove each person's posts from the other's feed

export const onUnfriend = onDocumentDeleted(
  "friendships/{pid}",
  async (event) => {
    const members = event.data?.data()?.members as string[] | undefined;
    if (!members || members.length !== 2) return;

    const [a, b] = members;

    for (const [owner, author] of [
      [a, b],
      [b, a],
    ]) {
      const snap = await db
        .collection(`feeds/${owner}/items`)
        .where("authorId", "==", author)
        .get();

      const ops = snap.docs.map(
        (d) => (batch: WriteBatch) => batch.delete(d.ref)
      );

      await commitInChunks(ops);
    }
  }
);