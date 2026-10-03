-- NOURA M9 · Additive column for coach-message response cards (blueprint §16 "M9 Coach: ... grounded
-- responses/cards"). Cards are always built by the worker from already-loaded, real app data (never
-- from AI free text; docs/decisions.md D-031) and stored alongside the message they belong to.
alter table app.coach_messages
  add column cards jsonb not null default '[]'::jsonb check (jsonb_typeof(cards) = 'array');
