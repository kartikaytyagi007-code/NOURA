import { randomUUID } from 'node:crypto';
import { describe, expect, it } from 'vitest';
import { MockAiProvider } from './mock.js';
import { validateCoachProviderOutput } from '../validators/coach.js';

describe('MockAiProvider.coachReply', () => {
  const provider = new MockAiProvider();

  it('honestly states no active diet/workout plan when none exists', async () => {
    const result = await provider.coachReply({
      user_message: 'How am I doing today?',
      diet: { has_active_plan: false, today: null, today_logged_meal_count: 0 },
      workout: { has_active_plan: false, today_session_title: null, today_session_status: null },
    });
    const output = validateCoachProviderOutput(result.output);
    expect(output.answer_text).toMatch(/don't have an active diet plan/i);
    expect(output.answer_text).toMatch(/don't have an active workout plan/i);
    expect(output.proposed_action).toBeNull();
    expect(result.meta.mock).toBe(true);
  });

  it('references real logged-meal counts and today’s workout session when present', async () => {
    const result = await provider.coachReply({
      user_message: 'What is my day looking like?',
      diet: {
        has_active_plan: true,
        today_logged_meal_count: 2,
        today: {
          slot: 'lunch',
          plan_meal_id: randomUUID(),
          plan_meal_revision: 1,
          recipe_name: 'Dal and rice',
          alternate_candidate_id: null,
          alternate_candidate_name: null,
        },
      },
      workout: {
        has_active_plan: true,
        today_session_title: 'Upper body strength',
        today_session_status: 'scheduled',
      },
    });
    const output = validateCoachProviderOutput(result.output);
    expect(output.answer_text).toContain('2 meal');
    expect(output.answer_text).toContain('Upper body strength');
    expect(output.evidence_refs).toEqual(expect.arrayContaining(['diet.today', 'workout.today']));
  });

  it('only proposes swap_meal when the user asked to swap and a real alternate exists', async () => {
    const planMealId = randomUUID();
    const altId = randomUUID();
    const result = await provider.coachReply({
      user_message: 'Can you swap my lunch today?',
      diet: {
        has_active_plan: true,
        today_logged_meal_count: 0,
        today: {
          slot: 'lunch',
          plan_meal_id: planMealId,
          plan_meal_revision: 1,
          recipe_name: 'Dal and rice',
          alternate_candidate_id: altId,
          alternate_candidate_name: 'Chole',
        },
      },
      workout: { has_active_plan: false, today_session_title: null, today_session_status: null },
    });
    const output = validateCoachProviderOutput(result.output);
    expect(output.proposed_action).toEqual({
      type: 'swap_meal',
      plan_meal_id: planMealId,
      candidate_recipe_id: altId,
      reason: expect.any(String),
    });
  });

  it('never proposes an action when the user did not ask for a swap', async () => {
    const result = await provider.coachReply({
      user_message: 'What is my protein target?',
      diet: {
        has_active_plan: true,
        today_logged_meal_count: 1,
        today: {
          slot: 'lunch',
          plan_meal_id: randomUUID(),
          plan_meal_revision: 1,
          recipe_name: 'Dal and rice',
          alternate_candidate_id: randomUUID(),
          alternate_candidate_name: 'Chole',
        },
      },
      workout: { has_active_plan: false, today_session_title: null, today_session_status: null },
    });
    const output = validateCoachProviderOutput(result.output);
    expect(output.proposed_action).toBeNull();
  });
});
