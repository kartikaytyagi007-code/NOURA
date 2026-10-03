-- NOURA M7 · Synthetic test-fixture exercise catalog (blueprint §11, docs/decisions.md D-025, D-029).
--
-- No licensed exercise dataset is available in this environment (data/exercises has no content
-- beyond its README placeholder). This migration seeds a small, explicitly labelled
-- `quality_flag = 'test_fixture'` exercise catalog, mirroring M3's food/recipe seed exactly, so the
-- M7 workout-plan generation pipeline (equipment/location/limitation filtering, movement-pattern
-- coverage, substitutions) can be built and exercised end to end in development and test.
--
-- These rows are SYNTHETIC DEVELOPMENT DATA ONLY. Names, equipment tags and set/rep/rest
-- prescriptions used by the generator are deliberately simple placeholders, not reviewed exercise
-- science and not sourced from any licensed database. The catalog planning gate
-- (packages/domain/src/catalog/gate.ts, reused unchanged for workouts per D-029) refuses automated
-- workout-plan generation in a deployed environment when the exercise catalog has no
-- verified/reviewed data, exactly like the M3 diet-plan gate, so this seed can never silently power a
-- real user's plan.

insert into app.exercises (
  id, slug, name, movement_pattern, muscle_tags, equipment_tags, level, contraindication_tags,
  instructions, quality_flag
)
values
  ('00000000-0000-4000-b001-000000000001', 'bodyweight-squat', 'Bodyweight squat', 'squat', array['quadriceps','glutes'], '{}', 'beginner', array['knee'], '["Stand with feet shoulder-width apart.", "Lower hips back and down, keeping chest tall.", "Drive through the heels to stand."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000002', 'goblet-squat', 'Goblet squat', 'squat', array['quadriceps','glutes'], array['dumbbell'], 'beginner', array['knee'], '["Hold a dumbbell at chest height.", "Squat down keeping the dumbbell close.", "Stand back up through the heels."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000003', 'barbell-back-squat', 'Barbell back squat', 'squat', array['quadriceps','glutes'], array['barbell','squat_rack'], 'advanced', array['knee','lower_back'], '["Set the bar on the upper back.", "Squat to depth with a braced core.", "Drive up through the floor."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000004', 'walking-lunge', 'Walking lunge', 'squat', array['quadriceps','glutes'], '{}', 'beginner', array['knee'], '["Step forward into a lunge.", "Lower the back knee toward the floor.", "Push off to bring the feet together and repeat on the other side."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000005', 'bulgarian-split-squat', 'Bulgarian split squat', 'squat', array['quadriceps','glutes'], array['bench'], 'intermediate', array['knee'], '["Rest the rear foot on a bench behind you.", "Lower the front knee under control.", "Press back up through the front heel."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000006', 'glute-bridge', 'Glute bridge', 'hinge', array['glutes','hamstrings'], '{}', 'beginner', array['lower_back'], '["Lie on your back with knees bent.", "Drive the hips up, squeezing the glutes.", "Lower under control and repeat."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000007', 'kettlebell-deadlift', 'Kettlebell deadlift', 'hinge', array['hamstrings','glutes'], array['kettlebell'], 'beginner', array['lower_back'], '["Stand over the kettlebell with a flat back.", "Hinge at the hips to grip it.", "Stand tall by driving the hips forward."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000008', 'dumbbell-romanian-deadlift', 'Dumbbell Romanian deadlift', 'hinge', array['hamstrings','glutes'], array['dumbbell'], 'intermediate', array['lower_back'], '["Hold dumbbells in front of the thighs.", "Hinge back with a soft knee bend, keeping the back flat.", "Return to standing by squeezing the glutes."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000009', 'barbell-deadlift', 'Barbell deadlift', 'hinge', array['hamstrings','glutes','back'], array['barbell'], 'advanced', array['lower_back'], '["Grip the bar just outside the legs.", "Brace and lift by extending the hips and knees together.", "Lower the bar under control."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000010', 'push-up', 'Push-up', 'horizontal_push', array['chest','triceps'], '{}', 'beginner', array['wrist','shoulder'], '["Start in a plank with hands under the shoulders.", "Lower the chest toward the floor.", "Press back up to the start."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000011', 'incline-push-up', 'Incline push-up', 'horizontal_push', array['chest','triceps'], array['bench'], 'beginner', array['wrist'], '["Place hands on a bench, body in a straight line.", "Lower the chest to the bench.", "Press back up."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000012', 'dumbbell-bench-press', 'Dumbbell bench press', 'horizontal_push', array['chest','triceps'], array['dumbbell','bench'], 'intermediate', array['shoulder'], '["Lie on a bench holding dumbbells over the chest.", "Lower with control to chest level.", "Press back up to lockout."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000013', 'barbell-bench-press', 'Barbell bench press', 'horizontal_push', array['chest','triceps'], array['barbell','bench'], 'advanced', array['shoulder'], '["Unrack the bar over the chest.", "Lower to the chest under control.", "Press back to lockout."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000014', 'pike-push-up', 'Pike push-up', 'vertical_push', array['shoulders','triceps'], '{}', 'intermediate', array['shoulder','wrist'], '["From a downward-dog position, bend the elbows.", "Lower the crown of the head toward the floor.", "Press back up."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000015', 'overhead-dumbbell-press', 'Overhead dumbbell press', 'vertical_push', array['shoulders','triceps'], array['dumbbell'], 'intermediate', array['shoulder'], '["Hold dumbbells at shoulder height.", "Press overhead to lockout.", "Lower back to the shoulders."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000016', 'overhead-barbell-press', 'Overhead barbell press', 'vertical_push', array['shoulders','triceps'], array['barbell'], 'advanced', array['shoulder'], '["Hold the bar at the collarbone.", "Press overhead, keeping the core braced.", "Lower back under control."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000017', 'resistance-band-row', 'Resistance band row', 'horizontal_pull', array['back','biceps'], array['resistance_band'], 'beginner', array['shoulder'], '["Anchor the band at chest height.", "Pull the handles to the ribs, squeezing the shoulder blades.", "Return under control."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000018', 'dumbbell-row', 'Dumbbell row', 'horizontal_pull', array['back','biceps'], array['dumbbell','bench'], 'beginner', array['lower_back'], '["Support one hand and knee on a bench.", "Row the dumbbell to the hip.", "Lower under control."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000019', 'inverted-row', 'Inverted row', 'horizontal_pull', array['back','biceps'], array['pull_up_bar'], 'intermediate', array['shoulder'], '["Hang under a low bar with body straight.", "Pull the chest to the bar.", "Lower under control."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000020', 'barbell-bent-over-row', 'Barbell bent-over row', 'horizontal_pull', array['back','biceps'], array['barbell'], 'advanced', array['lower_back'], '["Hinge forward holding the bar.", "Row the bar to the lower ribs.", "Lower under control."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000021', 'lat-pulldown-machine', 'Lat pulldown (machine)', 'vertical_pull', array['back','biceps'], array['gym_machine'], 'beginner', array['shoulder'], '["Sit under the bar with thighs secured.", "Pull the bar to the upper chest.", "Return under control."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000022', 'pull-up', 'Pull-up', 'vertical_pull', array['back','biceps'], array['pull_up_bar'], 'advanced', array['shoulder'], '["Hang from the bar with hands slightly wider than shoulders.", "Pull the chin over the bar.", "Lower under control."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000023', 'plank', 'Plank', 'core', array['core'], '{}', 'beginner', array['lower_back','wrist'], '["Support the body on forearms and toes.", "Keep a straight line from head to heels.", "Hold while breathing steadily."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000024', 'dead-bug', 'Dead bug', 'core', array['core'], '{}', 'beginner', array['lower_back'], '["Lie on your back with arms and knees raised.", "Extend one arm and the opposite leg while keeping the low back flat.", "Return and repeat on the other side."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000025', 'side-plank', 'Side plank', 'core', array['core'], '{}', 'intermediate', array['shoulder'], '["Support the body on one forearm, stacked feet.", "Lift the hips to a straight line.", "Hold, then repeat on the other side."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000026', 'farmers-carry', 'Farmer''s carry', 'carry', array['forearms','core'], array['dumbbell'], 'beginner', array['lower_back','wrist'], '["Hold a dumbbell in each hand at the sides.", "Walk a set distance with tall posture.", "Set down with control."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000027', 'kettlebell-swing', 'Kettlebell swing', 'carry', array['glutes','hamstrings','core'], array['kettlebell'], 'intermediate', array['lower_back'], '["Hinge and hike the kettlebell back.", "Drive the hips forward to swing it to chest height.", "Let it swing back and repeat."]'::jsonb, 'test_fixture'),

  ('00000000-0000-4000-b001-000000000028', 'jumping-jacks', 'Jumping jacks', 'conditioning', array['full_body'], '{}', 'beginner', array['knee'], '["Jump the feet out while raising the arms overhead.", "Jump back to the start.", "Repeat at a steady pace."]'::jsonb, 'test_fixture'),
  ('00000000-0000-4000-b001-000000000029', 'stationary-bike-intervals', 'Stationary bike intervals', 'conditioning', array['quadriceps','cardio'], array['bike'], 'beginner', array['knee'], '["Pedal at an easy pace to warm up.", "Alternate higher-effort intervals with easy recovery.", "Cool down at an easy pace."]'::jsonb, 'test_fixture');

comment on column app.exercises.quality_flag is
  'test_fixture rows above are SYNTHETIC DEVELOPMENT DATA, not a reviewed exercise-science source. See D-029.';

-- Substitutions -------------------------------------------------------------------------------------
-- Symmetric relationships (both directions inserted) between exercises that train the same movement
-- pattern at a similar or adjacent difficulty, so a user missing one piece of equipment, or working
-- around a recorded limitation, can be offered a genuinely comparable alternative rather than an
-- arbitrary one (blueprint §11).
insert into app.exercise_substitutions (exercise_id, substitute_id)
values
  ('00000000-0000-4000-b001-000000000001', '00000000-0000-4000-b001-000000000002'),
  ('00000000-0000-4000-b001-000000000002', '00000000-0000-4000-b001-000000000001'),
  ('00000000-0000-4000-b001-000000000002', '00000000-0000-4000-b001-000000000003'),
  ('00000000-0000-4000-b001-000000000003', '00000000-0000-4000-b001-000000000002'),
  ('00000000-0000-4000-b001-000000000001', '00000000-0000-4000-b001-000000000004'),
  ('00000000-0000-4000-b001-000000000004', '00000000-0000-4000-b001-000000000001'),
  ('00000000-0000-4000-b001-000000000004', '00000000-0000-4000-b001-000000000005'),
  ('00000000-0000-4000-b001-000000000005', '00000000-0000-4000-b001-000000000004'),

  ('00000000-0000-4000-b001-000000000006', '00000000-0000-4000-b001-000000000007'),
  ('00000000-0000-4000-b001-000000000007', '00000000-0000-4000-b001-000000000006'),
  ('00000000-0000-4000-b001-000000000007', '00000000-0000-4000-b001-000000000008'),
  ('00000000-0000-4000-b001-000000000008', '00000000-0000-4000-b001-000000000007'),
  ('00000000-0000-4000-b001-000000000008', '00000000-0000-4000-b001-000000000009'),
  ('00000000-0000-4000-b001-000000000009', '00000000-0000-4000-b001-000000000008'),

  ('00000000-0000-4000-b001-000000000010', '00000000-0000-4000-b001-000000000011'),
  ('00000000-0000-4000-b001-000000000011', '00000000-0000-4000-b001-000000000010'),
  ('00000000-0000-4000-b001-000000000010', '00000000-0000-4000-b001-000000000012'),
  ('00000000-0000-4000-b001-000000000012', '00000000-0000-4000-b001-000000000010'),
  ('00000000-0000-4000-b001-000000000012', '00000000-0000-4000-b001-000000000013'),
  ('00000000-0000-4000-b001-000000000013', '00000000-0000-4000-b001-000000000012'),

  ('00000000-0000-4000-b001-000000000014', '00000000-0000-4000-b001-000000000015'),
  ('00000000-0000-4000-b001-000000000015', '00000000-0000-4000-b001-000000000014'),
  ('00000000-0000-4000-b001-000000000015', '00000000-0000-4000-b001-000000000016'),
  ('00000000-0000-4000-b001-000000000016', '00000000-0000-4000-b001-000000000015'),

  ('00000000-0000-4000-b001-000000000017', '00000000-0000-4000-b001-000000000019'),
  ('00000000-0000-4000-b001-000000000019', '00000000-0000-4000-b001-000000000017'),
  ('00000000-0000-4000-b001-000000000017', '00000000-0000-4000-b001-000000000018'),
  ('00000000-0000-4000-b001-000000000018', '00000000-0000-4000-b001-000000000017'),
  ('00000000-0000-4000-b001-000000000018', '00000000-0000-4000-b001-000000000020'),
  ('00000000-0000-4000-b001-000000000020', '00000000-0000-4000-b001-000000000018'),

  ('00000000-0000-4000-b001-000000000021', '00000000-0000-4000-b001-000000000019'),
  ('00000000-0000-4000-b001-000000000019', '00000000-0000-4000-b001-000000000021'),
  ('00000000-0000-4000-b001-000000000021', '00000000-0000-4000-b001-000000000022'),
  ('00000000-0000-4000-b001-000000000022', '00000000-0000-4000-b001-000000000021'),

  ('00000000-0000-4000-b001-000000000023', '00000000-0000-4000-b001-000000000024'),
  ('00000000-0000-4000-b001-000000000024', '00000000-0000-4000-b001-000000000023'),
  ('00000000-0000-4000-b001-000000000024', '00000000-0000-4000-b001-000000000025'),
  ('00000000-0000-4000-b001-000000000025', '00000000-0000-4000-b001-000000000024'),

  ('00000000-0000-4000-b001-000000000026', '00000000-0000-4000-b001-000000000027'),
  ('00000000-0000-4000-b001-000000000027', '00000000-0000-4000-b001-000000000026'),

  ('00000000-0000-4000-b001-000000000028', '00000000-0000-4000-b001-000000000029'),
  ('00000000-0000-4000-b001-000000000029', '00000000-0000-4000-b001-000000000028');
