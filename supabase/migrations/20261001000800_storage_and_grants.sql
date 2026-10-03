-- NOURA M1 · Private Storage buckets and final grant hardening.

-- Private buckets (blueprint §14). Size/MIME limits are enforced by Storage and re-verified by the
-- API/worker from actual bytes. No public URLs; access is only via short-lived server-signed links.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('meal-images', 'meal-images', false, 10485760, array['image/jpeg', 'image/png', 'image/webp']),
  ('progress-photos', 'progress-photos', false, 10485760, array['image/jpeg', 'image/png', 'image/webp']),
  ('exports', 'exports', false, 52428800, array['application/zip', 'application/json'])
on conflict (id) do update
  set public = false,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

-- storage.objects has RLS enabled by Supabase. NOURA deliberately creates NO policies for the anon or
-- authenticated roles: mobile never lists/reads/writes objects directly. Uploads/downloads use signed
-- URLs minted by the API after an ownership check (M4). supabase/tests verifies no such policy exists.

-- ---------------------------------------------------------------------------------------------
-- Grants. Mobile roles get nothing in schema app. Server roles get the minimum per table.
-- ---------------------------------------------------------------------------------------------
revoke all on all tables in schema app from public, anon, authenticated;
revoke all on all functions in schema app from public, anon, authenticated;
revoke all on schema app from anon, authenticated;
grant execute on function app.request_user_id() to noura_api, noura_worker;

-- Catalog: read-only for both server roles.
grant select on
  app.food_sources, app.foods, app.recipes, app.recipe_ingredients, app.exercises, app.exercise_substitutions
to noura_api, noura_worker;

-- User-owned tables with full CRUD for the API (RLS + explicit owner filters still apply).
grant select, insert, update, delete on
  app.profiles, app.user_preferences, app.training_preferences, app.goals,
  app.generation_requests, app.diet_plans, app.diet_plan_meals,
  app.workout_plans, app.workout_plan_sessions, app.workout_plan_exercises,
  app.media_assets, app.meal_scans, app.meal_logs, app.meal_log_items,
  app.workout_logs, app.workout_set_logs, app.weight_logs, app.progress_photos,
  app.daily_summaries, app.weekly_insights, app.coach_threads, app.coach_messages,
  app.action_proposals, app.usage_reservations, app.idempotency_records, app.export_requests
to noura_api;

-- Audit-like records: the API may append and update state, never delete.
grant select, insert, update on app.consent_records, app.target_snapshots, app.entitlements, app.billing_events
to noura_api;
grant select, insert on app.deletion_requests to noura_api;

-- Worker: full CRUD on owner-scoped tables (generation, retention cleanup, account deletion),
-- still constrained by RLS to the user context it sets per job.
grant select, insert, update, delete on
  app.profiles, app.user_preferences, app.training_preferences, app.goals, app.consent_records,
  app.target_snapshots, app.generation_requests, app.diet_plans, app.diet_plan_meals,
  app.workout_plans, app.workout_plan_sessions, app.workout_plan_exercises,
  app.media_assets, app.meal_scans, app.meal_logs, app.meal_log_items,
  app.workout_logs, app.workout_set_logs, app.weight_logs, app.progress_photos,
  app.daily_summaries, app.weekly_insights, app.coach_threads, app.coach_messages,
  app.action_proposals, app.entitlements, app.usage_reservations, app.idempotency_records,
  app.deletion_requests, app.export_requests, app.billing_events
to noura_worker;

-- Future tables in schema app start with no access for anyone; each migration grants explicitly.
alter default privileges in schema app revoke all on tables from public;
alter default privileges in schema app revoke all on functions from public;
