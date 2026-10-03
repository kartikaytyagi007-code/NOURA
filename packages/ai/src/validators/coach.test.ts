import { randomUUID } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import {
  InvalidCoachProviderInput,
  InvalidCoachProviderOutput,
  validateCoachContextInput,
  validateCoachProviderOutput,
} from './coach.js';

const validContext = () => ({
  user_message: 'What should I eat next?',
  profile: { has_goals: true, diet_preference: 'vegetarian' },
  diet: { has_active_plan: true, today: null, today_logged_meal_count: 1 },
  workout: { has_active_plan: false, today_session_title: null, today_session_status: null },
});

describe('validateCoachContextInput', () => {
  it('accepts a well-formed context payload', () => {
    expect(() => validateCoachContextInput(validContext())).not.toThrow();
  });

  it('rejects an unrecognized extra field (strict schema)', () => {
    expect(() => validateCoachContextInput({ ...validContext(), extra_field: 'nope' })).toThrow(
      InvalidCoachProviderInput,
    );
  });

  it('rejects a missing required field', () => {
    const { profile: _profile, ...rest } = validContext();
    expect(() => validateCoachContextInput(rest)).toThrow(InvalidCoachProviderInput);
  });
});

describe('validateCoachProviderOutput', () => {
  it('accepts a minimal valid reply with no proposed action', () => {
    const output = validateCoachProviderOutput({
      answer_text: 'Here is an honest answer.',
      evidence_refs: ['diet.today'],
      proposed_action: null,
    });
    expect(output.answer_text).toBe('Here is an honest answer.');
    expect(output.proposed_action).toBeNull();
  });

  it('accepts a valid swap_meal proposed action', () => {
    const output = validateCoachProviderOutput({
      answer_text: 'I can swap this meal.',
      evidence_refs: [],
      proposed_action: {
        type: 'swap_meal',
        plan_meal_id: randomUUID(),
        candidate_recipe_id: randomUUID(),
        reason: 'A better fit for your goal.',
      },
    });
    expect(output.proposed_action?.type).toBe('swap_meal');
  });

  it('rejects a malformed/adversarial response missing answer_text', () => {
    expect(() => validateCoachProviderOutput({ evidence_refs: [], proposed_action: null })).toThrow(
      InvalidCoachProviderOutput,
    );
  });

  it('rejects an unknown proposed_action.type (e.g. regenerate_day) this milestone never applies', () => {
    expect(() =>
      validateCoachProviderOutput({
        answer_text: 'ok',
        evidence_refs: [],
        proposed_action: { type: 'regenerate_day', reason: 'x' },
      }),
    ).toThrow(InvalidCoachProviderOutput);
  });

  it('rejects extra/unexpected fields (adversarial provider output)', () => {
    expect(() =>
      validateCoachProviderOutput({
        answer_text: 'ok',
        evidence_refs: [],
        proposed_action: null,
        sql: 'DROP TABLE users;',
      }),
    ).toThrow(InvalidCoachProviderOutput);
  });

  it('rejects an answer_text that is far too long', () => {
    expect(() =>
      validateCoachProviderOutput({
        answer_text: 'x'.repeat(5000),
        evidence_refs: [],
        proposed_action: null,
      }),
    ).toThrow(InvalidCoachProviderOutput);
  });
});
