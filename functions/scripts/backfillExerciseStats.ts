// One-off backfill: builds exerciseStats + exerciseStatsPrivate from existing workouts.
//
// Run from the functions/ folder (after `gcloud auth application-default login`):
//   GOOGLE_CLOUD_PROJECT=<your-project-id> npx tsx scripts/backfillExerciseStats.ts --dry
//   GOOGLE_CLOUD_PROJECT=<your-project-id> npx tsx scripts/backfillExerciseStats.ts
//
// Safe to re-run any time (e.g. after changing a formula): it overwrites the derived docs.
import { initializeApp } from "firebase-admin/app";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import {
  Session,
  aggregate,
  statsDocId,
  summarizeSession,
  workoutDate,
} from "../src/statsLogic";

initializeApp();
const db = getFirestore();
const USERS = "User Data";
const DRY = process.argv.includes("--dry");

async function main() {
  const writer = db.bulkWriter();
  let users = 0, exercises = 0, workouts = 0;

  for (const userRef of await db.collection(USERS).listDocuments()) {
    const snap = await userRef.collection("workouts").get();
    if (snap.empty) continue;

    // exerciseKey -> { workoutId -> Session }
    const byExercise = new Map<string, Record<string, Session>>();

    for (const doc of snap.docs) {
      workouts++;
      const data = doc.data();
      const date = workoutDate(data, doc.createTime ?? Timestamp.now());
      for (const [key, sets] of Object.entries<any[]>(data.sets ?? {})) {
        const summary = summarizeSession(sets, date);
        if (!summary) continue;
        if (!byExercise.has(key)) byExercise.set(key, {});
        byExercise.get(key)![doc.id] = summary;
      }
    }

    for (const [key, sessions] of byExercise) {
      exercises++;
      if (DRY) continue;
      const docId = statsDocId(key);
      writer.set(userRef.collection("exerciseStatsPrivate").doc(docId), { sessions });
      writer.set(userRef.collection("exerciseStats").doc(docId), aggregate(sessions, key));
    }
    users++;
  }

  await writer.close();
  console.log(
    `${DRY ? "[dry run] " : ""}${users} users, ${workouts} workouts, ${exercises} exercise docs`
  );
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});