import { Timestamp } from "firebase-admin/firestore";

// Set types that never count toward records. Add others here (e.g. "Drop").
export const EXCLUDED_TYPES = new Set(["Warmup"]);
// 1RM estimates from high-rep sets are unreliable, so only sets up to this many reps count.
export const MAX_1RM_REPS = 12;

export type SetData = { weight?: number; reps?: number; type?: string; PR?: string };

// One small summary per workout, per exercise. Stored in the owner-only doc.
export type Session = {
  date: Timestamp;
  setCount: number;
  sessionVolume: number;
  bestWeight: number | null;
  bestWeightReps: number;
  best1RM: number; // only from sets with positive weight
  best1RMWeight: number;
  best1RMReps: number;
  bestSetVolume: number;
  bestSetVolumeWeight: number;
  bestSetVolumeReps: number;
  bestReps: number; // most reps in one set
};

// Derived doc that friends can read.
export type PublicStats = {
  exerciseKey: string;
  bestWeight: number | null;
  bestWeightReps: number;
  bestWeightDate: Timestamp | null;
  bestWeightWorkoutId: string | null;
  best1RM: number;
  best1RMWeight: number;
  best1RMReps: number;
  best1RMDate: Timestamp | null;
  best1RMWorkoutId: string | null;
  bestSetVolume: number;
  bestSetVolumeWeight: number;
  bestSetVolumeReps: number;
  bestSetVolumeDate: Timestamp | null;
  bestSetVolumeWorkoutId: string | null;
  bestSessionVolume: number;
  bestSessionVolumeDate: Timestamp | null;
  bestSessionVolumeWorkoutId: string | null;
  bestReps: number;
  bestRepsDate: Timestamp | null;
  bestRepsWorkoutId: string | null;
  totalVolume: number;
  totalSets: number;
  totalSessions: number;
  firstPerformed: Timestamp | null;
  lastPerformed: Timestamp | null;
  lastWorkoutId: string | null;
  updatedAt: Timestamp;
};

const round = (n: number) => Math.round(n * 100) / 100;

// Epley estimate; a single rep is just the weight itself.
export const epley = (weight: number, reps: number) =>
  reps <= 1 ? weight : weight * (1 + reps / 30);

// "2024-05-21 11:04" -> Date (treated as UTC; only used for ordering)
export function parseTime(s?: string): Date | null {
  if (!s) return null;
  const d = new Date(s.replace(" ", "T") + "Z");
  return isNaN(d.getTime()) ? null : d;
}

// Uses the workout's own start time, falling back to a stable timestamp (e.g. createTime)
// so that re-running the function always produces the same value.
export function workoutDate(w: any, fallback: Timestamp): Timestamp {
  const d = parseTime(w?.stats?.startTime);
  return d ? Timestamp.fromDate(d) : fallback;
}

// Is weight `a` (with reps) a better best-weight than the current one?
const beatsWeight = (
  a: number,
  aReps: number,
  cur: number | null,
  curReps: number
) => cur === null || a > cur || (a === cur && aReps > curReps);

// Reduce one workout's sets for one exercise into a Session.
// Returns null when nothing in it counts (so the session gets removed).
export function summarizeSession(sets: SetData[], date: Timestamp): Session | null {
  const s: Session = {
    date,
    setCount: 0,
    sessionVolume: 0,
    bestWeight: null,
    bestWeightReps: 0,
    best1RM: 0,
    best1RMWeight: 0,
    best1RMReps: 0,
    bestSetVolume: 0,
    bestSetVolumeWeight: 0,
    bestSetVolumeReps: 0,
    bestReps: 0,
  };

  for (const set of sets ?? []) {
    if (EXCLUDED_TYPES.has(set.type ?? "")) continue;
    const weight = Number(set.weight) || 0;
    const reps = Number(set.reps) || 0;
    if (reps <= 0) continue;

    s.setCount++;
    s.bestReps = Math.max(s.bestReps, reps);

    // Signed maximum: assisted < bodyweight < weighted.
    if (beatsWeight(weight, reps, s.bestWeight, s.bestWeightReps)) {
      s.bestWeight = weight;
      s.bestWeightReps = reps;
    }

    // Volume uses |weight| to match the feed's volume calculation.
    const volume = Math.abs(weight) * reps;
    s.sessionVolume += volume;
    if (volume > s.bestSetVolume) {
      s.bestSetVolume = volume;
      s.bestSetVolumeWeight = weight;
      s.bestSetVolumeReps = reps;
    }

    // 1RM only makes sense for added load.
    if (weight > 0 && reps <= MAX_1RM_REPS) {
      const e = epley(weight, reps);
      if (e > s.best1RM) {
        s.best1RM = e;
        s.best1RMWeight = weight;
        s.best1RMReps = reps;
      }
    }
  }

  if (s.setCount === 0) return null;

  s.sessionVolume = round(s.sessionVolume);
  s.bestWeight = s.bestWeight === null ? null : round(s.bestWeight);
  s.best1RM = round(s.best1RM);
  s.bestSetVolume = round(s.bestSetVolume);
  return s;
}

// Combine every session into the public stats doc. Earliest achievement wins ties.
// Each record also stores the workout id it came from, so friends can open that workout
// at User Data/{uid}/workouts/{workoutId}.
export function aggregate(sessions: Record<string, Session>, exerciseKey: string): PublicStats {
  const list = Object.entries(sessions)
    .map(([id, s]) => ({ id, s }))
    .sort((a, b) => a.s.date.toMillis() - b.s.date.toMillis() || a.id.localeCompare(b.id));

  const out: PublicStats = {
    exerciseKey,
    bestWeight: null, bestWeightReps: 0, bestWeightDate: null, bestWeightWorkoutId: null,
    best1RM: 0, best1RMWeight: 0, best1RMReps: 0, best1RMDate: null, best1RMWorkoutId: null,
    bestSetVolume: 0, bestSetVolumeWeight: 0, bestSetVolumeReps: 0,
    bestSetVolumeDate: null, bestSetVolumeWorkoutId: null,
    bestSessionVolume: 0, bestSessionVolumeDate: null, bestSessionVolumeWorkoutId: null,
    bestReps: 0, bestRepsDate: null, bestRepsWorkoutId: null,
    totalVolume: 0,
    totalSets: 0,
    totalSessions: list.length,
    firstPerformed: list[0]?.s.date ?? null,
    lastPerformed: list[list.length - 1]?.s.date ?? null,
    lastWorkoutId: list[list.length - 1]?.id ?? null,
    updatedAt: Timestamp.now(),
  };

  for (const { id, s } of list) {
    out.totalVolume += s.sessionVolume;
    out.totalSets += s.setCount;

    if (s.bestWeight !== null &&
        beatsWeight(s.bestWeight, s.bestWeightReps, out.bestWeight, out.bestWeightReps)) {
      out.bestWeight = s.bestWeight;
      out.bestWeightReps = s.bestWeightReps;
      out.bestWeightDate = s.date;
      out.bestWeightWorkoutId = id;
    }
    if (s.best1RM > out.best1RM) {
      out.best1RM = s.best1RM;
      out.best1RMWeight = s.best1RMWeight;
      out.best1RMReps = s.best1RMReps;
      out.best1RMDate = s.date;
      out.best1RMWorkoutId = id;
    }
    if (s.bestSetVolume > out.bestSetVolume) {
      out.bestSetVolume = s.bestSetVolume;
      out.bestSetVolumeWeight = s.bestSetVolumeWeight;
      out.bestSetVolumeReps = s.bestSetVolumeReps;
      out.bestSetVolumeDate = s.date;
      out.bestSetVolumeWorkoutId = id;
    }
    if (s.sessionVolume > out.bestSessionVolume) {
      out.bestSessionVolume = s.sessionVolume;
      out.bestSessionVolumeDate = s.date;
      out.bestSessionVolumeWorkoutId = id;
    }
    if (s.bestReps > out.bestReps) {
      out.bestReps = s.bestReps;
      out.bestRepsDate = s.date;
      out.bestRepsWorkoutId = id;
    }
  }

  out.totalVolume = round(out.totalVolume);
  return out;
}

// Firestore doc IDs can't contain "/".
export const statsDocId = (exerciseKey: string) => exerciseKey.replace(/\//g, "_");