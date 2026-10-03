-- NOURA local seed.
--
-- Intentionally empty in M1. NOURA does not ship invented nutrition, recipe or exercise data.
-- Catalog content arrives with licensed, provenance-tracked imports (M3 foods/recipes, M7 exercises).
-- Any synthetic development rows added later must use quality_flag = 'test_fixture' and are
-- rejected for production use (blueprint §7, §17).
--
-- Test users are created through Supabase Auth (Studio, the sign-up flow, or the Admin API),
-- never by inserting into auth.users from this file.
select 1;
