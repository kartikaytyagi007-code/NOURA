import type { FieldError } from '../errors.js';
import type { GoalType } from '../nutrition/policy.js';

/**
 * Semantic validation that JSON Schema cannot express (blueprint §5). Ranges are plausibility checks,
 * not medical thresholds. Field paths are relative to the request body; the API prefixes "body.".
 */

const TIMEZONE_SHAPE = /^[A-Za-z][A-Za-z0-9_+-]*(\/[A-Za-z0-9_+-]+)*$/;

/** True for names the runtime's IANA tz database knows (e.g. "Asia/Kolkata", "UTC"). */
export function isValidTimezone(value: string): boolean {
  if (!TIMEZONE_SHAPE.test(value)) return false;
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: value });
    return true;
  } catch {
    return false;
  }
}

/** Trims and collapses inner whitespace. Returns null when nothing printable remains. */
export function normalizeDisplayName(raw: string): string | null {
  // Replace control characters (code points below 0x20 and DEL) with spaces, then collapse.
  const printable = Array.from(raw, (ch) => {
    const code = ch.codePointAt(0) ?? 0;
    return code < 0x20 || code === 0x7f ? ' ' : ch;
  }).join('');
  const cleaned = printable.replace(/\s+/g, ' ').trim();
  return cleaned.length > 0 ? cleaned.slice(0, 80) : null;
}

export function validateGoal(
  goal: { goal_type: GoalType; target_weight_kg: number | null },
  currentWeightKg: number | null,
): FieldError[] {
  if (goal.target_weight_kg === null || currentWeightKg === null) return [];
  if (goal.goal_type === 'lose_fat' && goal.target_weight_kg >= currentWeightKg) {
    return [
      {
        field: 'primary_goal.target_weight_kg',
        code: 'target_not_below_current',
        message: 'For a fat-loss goal, the target weight must be below your current weight.',
      },
    ];
  }
  if (goal.goal_type === 'gain_muscle' && goal.target_weight_kg <= currentWeightKg) {
    return [
      {
        field: 'primary_goal.target_weight_kg',
        code: 'target_not_above_current',
        message: 'For a muscle-gain goal, the target weight must be above your current weight.',
      },
    ];
  }
  return [];
}

export interface TrainingShape {
  location: 'home' | 'gym' | 'both';
  equipment_ids: readonly string[];
  weekdays: readonly number[];
  days_per_week: number;
}

export function validateTraining(training: TrainingShape): FieldError[] {
  const errors: FieldError[] = [];
  if (training.weekdays.length < training.days_per_week) {
    errors.push({
      field: 'weekdays',
      code: 'fewer_than_days_per_week',
      message: `Select at least ${training.days_per_week} available weekdays to train ${training.days_per_week} days a week.`,
    });
  }
  if (training.location !== 'gym' && training.equipment_ids.length === 0) {
    errors.push({
      field: 'equipment_ids',
      code: 'equipment_required',
      message: 'Choose the equipment you have at home (or "bodyweight" if you have none).',
    });
  }
  return errors;
}
