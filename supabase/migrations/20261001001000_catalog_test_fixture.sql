-- NOURA M3 · Synthetic test-fixture catalog (blueprint §7, docs/decisions.md D-025).
--
-- No licensed nutrition dataset is available in this environment (data/foods, data/recipes,
-- data/exercises and data/provenance are empty beyond their README placeholders). This migration
-- seeds a small, explicitly labelled `quality_flag = 'test_fixture'` catalog so the M3 diet-plan
-- pipeline (filtering, portion scaling, nutrition totals, swaps, regeneration) can be built and
-- exercised end to end in development and test.
--
-- These rows are SYNTHETIC DEVELOPMENT DATA ONLY. The macro values are deliberately round
-- placeholder numbers, not a nutrition claim, not reviewed, and not sourced from any licensed
-- database. `app.foods.quality_flag` already documents that `test_fixture` rows must never be used
-- in production (M1 comment); the application-level catalog planning gate added in M3
-- (packages/domain/src/catalog/gate.ts) additionally refuses automated plan generation in a deployed
-- environment when the catalog has no verified/reviewed data, so this seed can never silently power a
-- real user's plan.

insert into app.food_sources (id, source_name, source_version, license_notes, usage_notes, acquired_at)
values (
  '00000000-0000-4000-a000-000000000001',
  'NOURA synthetic test fixture',
  'v0-dev',
  'NOT A LICENSED NUTRITION SOURCE. These values are synthetic development placeholders invented to '
    || 'exercise the diet-plan pipeline (filtering, portions, nutrition totals). They must never be '
    || 'used in staging or production and must never be presented to a user as real nutrition data.',
  'Development and automated tests only. See docs/decisions.md D-025.',
  '2026-10-02'
);

-- Foods -----------------------------------------------------------------------------------------
-- diet_tags record which diets a food is SAFE for: vegan foods are safe for every diet; dairy and
-- egg are layered on top per blueprint §7 (vegetarian excludes meat/fish/eggs; eggatarian permits
-- eggs/dairy but excludes meat/fish; vegan excludes all animal products).
insert into app.foods (
  id, source_id, name, nutrient_basis, energy_kcal_per_100g, protein_g_per_100g,
  carbohydrate_g_per_100g, fat_g_per_100g, fibre_g_per_100g, diet_tags, allergen_tags,
  allergen_coverage, food_group_tags, quality_flag
)
values
  ('00000000-0000-4000-a001-000000000001', '00000000-0000-4000-a000-000000000001', 'White rice', 'raw', 130, 2.7, 28, 0.3, 0.4, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000002', '00000000-0000-4000-a000-000000000001', 'Brown rice', 'raw', 112, 2.3, 24, 0.9, 1.8, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000003', '00000000-0000-4000-a000-000000000001', 'Moong dal', 'raw', 340, 24, 60, 1.2, 16, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000004', '00000000-0000-4000-a000-000000000001', 'Mixed vegetables', 'raw', 50, 2, 10, 0.3, 3, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000005', '00000000-0000-4000-a000-000000000001', 'Olive oil', 'raw', 884, 0, 0, 100, 0, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000006', '00000000-0000-4000-a000-000000000001', 'Onion', 'raw', 40, 1.1, 9, 0.1, 1.7, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', array['onion_garlic'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000007', '00000000-0000-4000-a000-000000000001', 'Garlic', 'raw', 149, 6.4, 33, 0.5, 2.1, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', array['onion_garlic'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000008', '00000000-0000-4000-a000-000000000001', 'Spinach', 'raw', 23, 2.9, 3.6, 0.4, 2.2, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000009', '00000000-0000-4000-a000-000000000001', 'Tomato', 'raw', 18, 0.9, 3.9, 0.2, 1.2, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000010', '00000000-0000-4000-a000-000000000001', 'Potato', 'raw', 77, 2, 17, 0.1, 2.2, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', array['root_vegetables'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000011', '00000000-0000-4000-a000-000000000001', 'Banana', 'raw', 89, 1.1, 23, 0.3, 2.6, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000012', '00000000-0000-4000-a000-000000000001', 'Apple', 'raw', 52, 0.3, 14, 0.2, 2.4, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000013', '00000000-0000-4000-a000-000000000001', 'Quinoa', 'raw', 120, 4.4, 21, 1.9, 2.8, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000014', '00000000-0000-4000-a000-000000000001', 'Soy sauce', 'raw', 60, 10, 6, 0, 1, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['soy'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000015', '00000000-0000-4000-a000-000000000001', 'Tofu', 'raw', 76, 8, 1.9, 4.8, 0.3, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['soy'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000016', '00000000-0000-4000-a000-000000000001', 'Peanuts', 'raw', 567, 25, 16, 49, 8.5, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['peanut'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000017', '00000000-0000-4000-a000-000000000001', 'Almonds', 'raw', 579, 21, 22, 50, 12.5, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['tree_nut'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000018', '00000000-0000-4000-a000-000000000001', 'Oats', 'raw', 389, 17, 66, 7, 10, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['gluten'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000019', '00000000-0000-4000-a000-000000000001', 'Soy milk', 'raw', 54, 3.3, 6, 1.8, 0.6, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['soy'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000020', '00000000-0000-4000-a000-000000000001', 'Whole wheat flour', 'raw', 340, 13, 72, 2.5, 11, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['gluten'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000021', '00000000-0000-4000-a000-000000000001', 'Tahini', 'raw', 595, 17, 21, 53, 9.3, array['vegan','vegetarian','eggatarian','non_vegetarian'], array['sesame'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000022', '00000000-0000-4000-a000-000000000001', 'Mushroom', 'raw', 22, 3.1, 3.3, 0.3, 1, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'complete', array['mushroom'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000023', '00000000-0000-4000-a000-000000000001', 'Paneer', 'raw', 265, 18, 1.2, 21, 0, array['vegetarian','eggatarian','non_vegetarian'], array['milk'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000024', '00000000-0000-4000-a000-000000000001', 'Yogurt', 'raw', 61, 3.5, 4.7, 3.3, 0, array['vegetarian','eggatarian','non_vegetarian'], array['milk'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000025', '00000000-0000-4000-a000-000000000001', 'Egg', 'raw', 143, 13, 1.1, 9.5, 0, array['eggatarian','non_vegetarian'], array['egg'], 'complete', '{}', 'test_fixture'),
  ('00000000-0000-4000-a001-000000000026', '00000000-0000-4000-a000-000000000001', 'Chicken breast', 'raw', 165, 31, 0, 3.6, 0, array['non_vegetarian'], '{}', 'complete', array['chicken'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000027', '00000000-0000-4000-a000-000000000001', 'Mutton', 'raw', 294, 25, 0, 21, 0, array['non_vegetarian'], '{}', 'complete', array['mutton'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000028', '00000000-0000-4000-a000-000000000001', 'Salmon', 'raw', 208, 20, 0, 13, 0, array['non_vegetarian'], array['fish'], 'complete', array['seafood'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000029', '00000000-0000-4000-a000-000000000001', 'Shrimp', 'raw', 99, 24, 0.2, 0.3, 0, array['non_vegetarian'], array['crustacean'], 'complete', array['seafood'], 'test_fixture'),
  ('00000000-0000-4000-a001-000000000030', '00000000-0000-4000-a000-000000000001', 'Mixed spice blend', 'raw', 300, 10, 50, 5, 8, array['vegan','vegetarian','eggatarian','non_vegetarian'], '{}', 'unknown', '{}', 'test_fixture');
comment on column app.foods.allergen_coverage is
  'unknown/partial coverage means the food cannot be treated as safe for an allergy-constrained plan.';

-- Recipes -----------------------------------------------------------------------------------------
-- tags carries the meal slot(s) the recipe is suitable for (breakfast/lunch/dinner/snack), read by
-- the M3 planning algorithm (packages/domain/src/planning). diet_tags mirrors the intersection of
-- its ingredients' diet_tags and is also recomputed from ingredients at generation time so a
-- mismatch here can never relax a constraint.
insert into app.recipes (
  id, slug, name, cuisine, tags, diet_tags, instructions, cooked_yield_g, servings,
  cooking_minutes, budget_band, quality_flag, source_notes
)
values
  ('00000000-0000-4000-a002-000000000001', 'moong-dal-khichdi', 'Moong dal khichdi', 'north_indian', array['lunch','dinner'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Rinse rice and dal.", "Pressure-cook with vegetables, onion and garlic until soft.", "Finish with olive oil."]'::jsonb, 420, 1, 30, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000002', 'paneer-tikka-bowl', 'Paneer tikka bowl', 'north_indian', array['lunch','dinner'], array['vegetarian','eggatarian','non_vegetarian'], '["Pan-sear paneer with onion in olive oil.", "Serve over brown rice with mixed vegetables."]'::jsonb, 380, 1, 25, 'medium', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000003', 'masala-egg-bhurji', 'Masala egg bhurji', 'north_indian', array['breakfast'], array['eggatarian','non_vegetarian'], '["Saute onion and tomato in olive oil.", "Scramble in eggs until just set."]'::jsonb, 220, 1, 15, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000004', 'chicken-tikka-quinoa-bowl', 'Chicken tikka quinoa bowl', 'continental', array['lunch','dinner'], array['non_vegetarian'], '["Grill chicken breast.", "Toss with cooked quinoa, mixed vegetables and olive oil."]'::jsonb, 400, 1, 30, 'medium', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000005', 'grilled-salmon-salad', 'Grilled salmon salad', 'continental', array['lunch','dinner'], array['non_vegetarian'], '["Grill salmon.", "Toss spinach and tomato with olive oil.", "Top with the salmon."]'::jsonb, 320, 1, 20, 'high', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000006', 'mutton-curry-rice', 'Mutton curry with rice', 'north_indian', array['dinner'], array['non_vegetarian'], '["Brown mutton with onion, garlic and tomato.", "Simmer until tender.", "Serve over brown rice."]'::jsonb, 450, 1, 60, 'high', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000007', 'shrimp-stir-fry', 'Shrimp stir fry', 'indo_chinese', array['dinner'], array['non_vegetarian'], '["Stir-fry shrimp and mixed vegetables in olive oil.", "Finish with soy sauce."]'::jsonb, 350, 1, 20, 'medium', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000008', 'tofu-soy-stir-fry', 'Tofu soy stir fry', 'indo_chinese', array['lunch','dinner'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Pan-fry tofu.", "Stir-fry with mixed vegetables and soy sauce.", "Serve over brown rice."]'::jsonb, 400, 1, 20, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000009', 'peanut-veggie-rice-bowl', 'Peanut veggie rice bowl', 'indo_chinese', array['lunch','dinner'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Toast peanuts.", "Toss with brown rice, mixed vegetables and olive oil."]'::jsonb, 380, 1, 15, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000010', 'almond-oat-porridge', 'Almond oat porridge', 'continental', array['breakfast'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Simmer oats in soy milk.", "Top with sliced almonds and banana."]'::jsonb, 320, 1, 10, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000011', 'greek-yogurt-parfait', 'Yogurt parfait', 'continental', array['breakfast','snack'], array['vegetarian','eggatarian','non_vegetarian'], '["Layer yogurt with banana, apple and almonds."]'::jsonb, 260, 1, 5, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000012', 'whole-wheat-veggie-wrap', 'Whole wheat veggie wrap', 'continental', array['lunch','snack'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Make a whole-wheat flatbread.", "Fill with mixed vegetables and spinach dressed in olive oil."]'::jsonb, 260, 1, 15, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000013', 'sesame-tofu-bowl', 'Sesame tofu bowl', 'indo_chinese', array['lunch','dinner'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Pan-fry tofu.", "Toss with brown rice and mixed vegetables.", "Finish with tahini."]'::jsonb, 400, 1, 20, 'medium', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000014', 'mushroom-masala-rice', 'Mushroom masala rice', 'north_indian', array['lunch','dinner'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Saute mushroom with onion, garlic and tomato.", "Serve over white rice."]'::jsonb, 400, 1, 25, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.'),
  ('00000000-0000-4000-a002-000000000015', 'mystery-spice-rice', 'Mystery spice rice', 'north_indian', array['lunch','dinner'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Toss white rice with the mixed spice blend and olive oil."]'::jsonb, 300, 1, 10, 'low', 'test_fixture', 'Synthetic test fixture with one unknown-allergen-coverage ingredient, kept to exercise the allergen-safety rule (D-025).'),
  ('00000000-0000-4000-a002-000000000016', 'fruit-salad-snack', 'Fruit salad', 'continental', array['snack'], array['vegan','vegetarian','eggatarian','non_vegetarian'], '["Dice banana and apple together."]'::jsonb, 180, 1, 5, 'low', 'test_fixture', 'Synthetic test fixture (D-025). Not a real recipe source.');

-- Recipe ingredients --------------------------------------------------------------------------------
insert into app.recipe_ingredients (recipe_id, food_id, ordinal, edible_grams) values
  ('00000000-0000-4000-a002-000000000001', '00000000-0000-4000-a001-000000000001', 1, 100),
  ('00000000-0000-4000-a002-000000000001', '00000000-0000-4000-a001-000000000003', 2, 60),
  ('00000000-0000-4000-a002-000000000001', '00000000-0000-4000-a001-000000000004', 3, 120),
  ('00000000-0000-4000-a002-000000000001', '00000000-0000-4000-a001-000000000006', 4, 30),
  ('00000000-0000-4000-a002-000000000001', '00000000-0000-4000-a001-000000000007', 5, 5),
  ('00000000-0000-4000-a002-000000000001', '00000000-0000-4000-a001-000000000005', 6, 10),

  ('00000000-0000-4000-a002-000000000002', '00000000-0000-4000-a001-000000000023', 1, 120),
  ('00000000-0000-4000-a002-000000000002', '00000000-0000-4000-a001-000000000002', 2, 120),
  ('00000000-0000-4000-a002-000000000002', '00000000-0000-4000-a001-000000000004', 3, 100),
  ('00000000-0000-4000-a002-000000000002', '00000000-0000-4000-a001-000000000006', 4, 30),
  ('00000000-0000-4000-a002-000000000002', '00000000-0000-4000-a001-000000000005', 5, 10),

  ('00000000-0000-4000-a002-000000000003', '00000000-0000-4000-a001-000000000025', 1, 120),
  ('00000000-0000-4000-a002-000000000003', '00000000-0000-4000-a001-000000000006', 2, 40),
  ('00000000-0000-4000-a002-000000000003', '00000000-0000-4000-a001-000000000009', 3, 50),
  ('00000000-0000-4000-a002-000000000003', '00000000-0000-4000-a001-000000000005', 4, 10),

  ('00000000-0000-4000-a002-000000000004', '00000000-0000-4000-a001-000000000026', 1, 150),
  ('00000000-0000-4000-a002-000000000004', '00000000-0000-4000-a001-000000000013', 2, 120),
  ('00000000-0000-4000-a002-000000000004', '00000000-0000-4000-a001-000000000004', 3, 100),
  ('00000000-0000-4000-a002-000000000004', '00000000-0000-4000-a001-000000000005', 4, 10),

  ('00000000-0000-4000-a002-000000000005', '00000000-0000-4000-a001-000000000028', 1, 150),
  ('00000000-0000-4000-a002-000000000005', '00000000-0000-4000-a001-000000000008', 2, 80),
  ('00000000-0000-4000-a002-000000000005', '00000000-0000-4000-a001-000000000009', 3, 60),
  ('00000000-0000-4000-a002-000000000005', '00000000-0000-4000-a001-000000000005', 4, 15),

  ('00000000-0000-4000-a002-000000000006', '00000000-0000-4000-a001-000000000027', 1, 180),
  ('00000000-0000-4000-a002-000000000006', '00000000-0000-4000-a001-000000000002', 2, 150),
  ('00000000-0000-4000-a002-000000000006', '00000000-0000-4000-a001-000000000006', 3, 40),
  ('00000000-0000-4000-a002-000000000006', '00000000-0000-4000-a001-000000000007', 4, 8),
  ('00000000-0000-4000-a002-000000000006', '00000000-0000-4000-a001-000000000009', 5, 60),

  ('00000000-0000-4000-a002-000000000007', '00000000-0000-4000-a001-000000000029', 1, 160),
  ('00000000-0000-4000-a002-000000000007', '00000000-0000-4000-a001-000000000004', 2, 120),
  ('00000000-0000-4000-a002-000000000007', '00000000-0000-4000-a001-000000000014', 3, 15),
  ('00000000-0000-4000-a002-000000000007', '00000000-0000-4000-a001-000000000005', 4, 10),

  ('00000000-0000-4000-a002-000000000008', '00000000-0000-4000-a001-000000000015', 1, 150),
  ('00000000-0000-4000-a002-000000000008', '00000000-0000-4000-a001-000000000004', 2, 100),
  ('00000000-0000-4000-a002-000000000008', '00000000-0000-4000-a001-000000000014', 3, 15),
  ('00000000-0000-4000-a002-000000000008', '00000000-0000-4000-a001-000000000002', 4, 120),

  ('00000000-0000-4000-a002-000000000009', '00000000-0000-4000-a001-000000000016', 1, 40),
  ('00000000-0000-4000-a002-000000000009', '00000000-0000-4000-a001-000000000002', 2, 150),
  ('00000000-0000-4000-a002-000000000009', '00000000-0000-4000-a001-000000000004', 3, 100),
  ('00000000-0000-4000-a002-000000000009', '00000000-0000-4000-a001-000000000005', 4, 10),

  ('00000000-0000-4000-a002-000000000010', '00000000-0000-4000-a001-000000000018', 1, 60),
  ('00000000-0000-4000-a002-000000000010', '00000000-0000-4000-a001-000000000019', 2, 200),
  ('00000000-0000-4000-a002-000000000010', '00000000-0000-4000-a001-000000000017', 3, 15),
  ('00000000-0000-4000-a002-000000000010', '00000000-0000-4000-a001-000000000011', 4, 60),

  ('00000000-0000-4000-a002-000000000011', '00000000-0000-4000-a001-000000000024', 1, 180),
  ('00000000-0000-4000-a002-000000000011', '00000000-0000-4000-a001-000000000011', 2, 60),
  ('00000000-0000-4000-a002-000000000011', '00000000-0000-4000-a001-000000000012', 3, 60),
  ('00000000-0000-4000-a002-000000000011', '00000000-0000-4000-a001-000000000017', 4, 15),

  ('00000000-0000-4000-a002-000000000012', '00000000-0000-4000-a001-000000000020', 1, 80),
  ('00000000-0000-4000-a002-000000000012', '00000000-0000-4000-a001-000000000004', 2, 100),
  ('00000000-0000-4000-a002-000000000012', '00000000-0000-4000-a001-000000000008', 3, 40),
  ('00000000-0000-4000-a002-000000000012', '00000000-0000-4000-a001-000000000005', 4, 10),

  ('00000000-0000-4000-a002-000000000013', '00000000-0000-4000-a001-000000000015', 1, 150),
  ('00000000-0000-4000-a002-000000000013', '00000000-0000-4000-a001-000000000002', 2, 150),
  ('00000000-0000-4000-a002-000000000013', '00000000-0000-4000-a001-000000000004', 3, 80),
  ('00000000-0000-4000-a002-000000000013', '00000000-0000-4000-a001-000000000021', 4, 15),

  ('00000000-0000-4000-a002-000000000014', '00000000-0000-4000-a001-000000000022', 1, 150),
  ('00000000-0000-4000-a002-000000000014', '00000000-0000-4000-a001-000000000001', 2, 150),
  ('00000000-0000-4000-a002-000000000014', '00000000-0000-4000-a001-000000000006', 3, 30),
  ('00000000-0000-4000-a002-000000000014', '00000000-0000-4000-a001-000000000007', 4, 6),
  ('00000000-0000-4000-a002-000000000014', '00000000-0000-4000-a001-000000000009', 5, 60),

  ('00000000-0000-4000-a002-000000000015', '00000000-0000-4000-a001-000000000001', 1, 180),
  ('00000000-0000-4000-a002-000000000015', '00000000-0000-4000-a001-000000000030', 2, 10),
  ('00000000-0000-4000-a002-000000000015', '00000000-0000-4000-a001-000000000005', 3, 10),

  ('00000000-0000-4000-a002-000000000016', '00000000-0000-4000-a001-000000000011', 1, 100),
  ('00000000-0000-4000-a002-000000000016', '00000000-0000-4000-a001-000000000012', 2, 100);
