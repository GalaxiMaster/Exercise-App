import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { getFirestore } from "firebase-admin/firestore";
import {
  Session,
  aggregate,
  statsDocId,
  summarizeSession,
  workoutDate,
} from "./statsLogic";

const USERS = "User Data";

// Order-independent signature, so we can skip writes when nothing changed.
const sig = (s: Session) =>
  JSON.stringify(Object.entries({ ...s, date: s.date.toMillis() }).sort());

// Update one exercise's private sessions map and derived public doc in a transaction.
// summary === null means "this workout no longer has counted sets for this exercise".
async function applyExercise(
  uid: string,
  workoutId: string,
  exerciseKey: string,
  summary: Session | null
) {
  const db = getFirestore();
  const base = db.collection(USERS).doc(uid);
  const docId = statsDocId(exerciseKey);
  const privRef = base.collection("exerciseStatsPrivate").doc(docId);
  const pubRef = base.collection("exerciseStats").doc(docId);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(privRef);
    const sessions: Record<string, Session> = { ...(snap.data()?.sessions ?? {}) };
    const current = sessions[workoutId];

    if (!summary && !current) return;
    if (summary && current && sig(current) === sig(summary)) return;

    if (summary) sessions[workoutId] = summary;
    else delete sessions[workoutId];

    if (Object.keys(sessions).length === 0) {
      tx.delete(privRef);
      tx.delete(pubRef);
      return;
    }
    tx.set(privRef, { sessions });
    tx.set(pubRef, aggregate(sessions, exerciseKey));
  });
}

// Workout created / edited / deleted -> keep that user's exercise stats in sync.
// Independent of syncWorkout (feed fan-out): separate failures, separate retries.
export const syncExerciseStats = onDocumentWritten(
  { document: "{col}/{uid}/workouts/{workoutId}", region: "australia-southeast1" },
  async (event) => {
    const { col, uid, workoutId } = event.params;
    if (col !== USERS) return;

    const before = event.data?.before;
    const after = event.data?.after;
    const beforeData = before?.exists ? before.data() : undefined;
    const afterData = after?.exists ? after.data() : undefined;

    const beforeSets: Record<string, any[]> = beforeData?.sets ?? {};
    const afterSets: Record<string, any[]> = afterData?.sets ?? {};

    const beforeDate = beforeData && before ? workoutDate(beforeData, before.createTime!) : null;
    const afterDate = afterData && after ? workoutDate(afterData, after.createTime!) : null;

    // If the workout's date moved, every exercise's session date is stale.
    const dateChanged = beforeDate?.toMillis() !== afterDate?.toMillis();

    const keys = new Set([...Object.keys(beforeSets), ...Object.keys(afterSets)]);
    const changed = [...keys].filter(
      (k) => dateChanged || JSON.stringify(beforeSets[k]) !== JSON.stringify(afterSets[k])
    );
    if (changed.length === 0) return;

    await Promise.all(
      changed.map((k) =>
        applyExercise(
          uid,
          workoutId,
          k,
          afterDate && afterSets[k] ? summarizeSession(afterSets[k], afterDate) : null
        )
      )
    );
  }
);