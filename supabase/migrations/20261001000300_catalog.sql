-- NOURA M1 · Catalog structure (foods, recipes, exercises) with provenance.
-- Structure only. No nutrition, recipe or exercise data is seeded in M1: catalog content requires
-- licensed sources and review (blueprint §7, M3/M7). Unknown nutrient values stay NULL, never 0.

create table app.food_sources (
  id uuid primary key default gen_random_uuid(),
  source_name text not null check (char_length(source_name) between 1 and 200),
  source_version text not null check (char_length(source_version) between 1 and 64),
  license_notes text not null,
  usage_notes text,
  acquired_at date not null,
  created_at timestamptz not null default now(),
  constraint food_sources_name_version_unique unique (source_name, source_version)
);

create table app.foods (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references app.food_sources (id),
  name text not null check (char_length(name) between 1 and 200),
  aliases text[] not null default '{}',
  nutrient_basis text not null check (nutrient_basis in ('raw', 'cooked', 'as_sold')),
  energy_kcal_per_100g numeric(7, 2) check (energy_kcal_per_100g >= 0),
  protein_g_per_100g numeric(6, 2) check (protein_g_per_100g >= 0),
  carbohydrate_g_per_100g numeric(6, 2) check (carbohydrate_g_per_100g >= 0),
  fat_g_per_100g numeric(6, 2) check (fat_g_per_100g >= 0),
  fibre_g_per_100g numeric(6, 2) check (fibre_g_per_100g >= 0),
  micronutrients_per_100g jsonb check (micronutrients_per_100g is null or jsonb_typeof(micronutrients_per_100g) = 'object'),
  diet_tags text[] not null default '{}',
  allergen_tags text[] not null default '{}',
  allergen_coverage text not null default 'unknown' check (allergen_coverage in ('complete', 'partial', 'unknown')),
  food_group_tags text[] not null default '{}',
  serving_conversions jsonb not null default '[]'::jsonb check (jsonb_typeof(serving_conversions) = 'array'),
  quality_flag text not null check (quality_flag in ('verified', 'reviewed', 'provisional', 'test_fixture')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
comment on column app.foods.allergen_coverage is
  'unknown/partial coverage means the food cannot be treated as safe for an allergy-constrained plan.';
comment on column app.foods.quality_flag is
  'test_fixture rows are synthetic development data and must never be used in production.';
create index foods_lower_name on app.foods (lower(name));
create index foods_source on app.foods (source_id);
select app.add_touch_trigger('app.foods');

create table app.recipes (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name text not null check (char_length(name) between 1 and 200),
  cuisine text,
  tags text[] not null default '{}',
  diet_tags text[] not null default '{}',
  instructions jsonb not null check (jsonb_typeof(instructions) = 'array'),
  cooked_yield_g numeric(8, 2) check (cooked_yield_g > 0),
  servings smallint check (servings between 1 and 50),
  cooking_minutes smallint check (cooking_minutes between 0 and 600),
  budget_band text check (budget_band in ('low', 'medium', 'high')),
  quality_flag text not null check (quality_flag in ('verified', 'reviewed', 'provisional', 'test_fixture')),
  source_notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
select app.add_touch_trigger('app.recipes');

create table app.recipe_ingredients (
  id uuid primary key default gen_random_uuid(),
  recipe_id uuid not null references app.recipes (id) on delete cascade,
  food_id uuid not null references app.foods (id),
  ordinal smallint not null check (ordinal >= 1),
  edible_grams numeric(8, 2) not null check (edible_grams > 0),
  preparation_note text,
  constraint recipe_ingredients_ordinal_unique unique (recipe_id, ordinal)
);
create index recipe_ingredients_food on app.recipe_ingredients (food_id);

create table app.exercises (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
  name text not null check (char_length(name) between 1 and 200),
  movement_pattern text not null,
  muscle_tags text[] not null default '{}',
  equipment_tags text[] not null default '{}',
  level text not null check (level in ('beginner', 'intermediate', 'advanced')),
  contraindication_tags text[] not null default '{}',
  instructions jsonb not null check (jsonb_typeof(instructions) = 'array'),
  licensed_demo_ref text,
  demo_license_notes text,
  quality_flag text not null check (quality_flag in ('verified', 'reviewed', 'provisional', 'test_fixture')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint exercises_demo_requires_license check (licensed_demo_ref is null or demo_license_notes is not null)
);
select app.add_touch_trigger('app.exercises');

create table app.exercise_substitutions (
  exercise_id uuid not null references app.exercises (id) on delete cascade,
  substitute_id uuid not null references app.exercises (id) on delete cascade,
  primary key (exercise_id, substitute_id),
  constraint exercise_substitutions_not_self check (exercise_id <> substitute_id)
);

-- Catalog tables are read-only for server roles; writes happen through reviewed data imports.
do $$
declare
  t text;
begin
  foreach t in array array[
    'app.food_sources', 'app.foods', 'app.recipes', 'app.recipe_ingredients',
    'app.exercises', 'app.exercise_substitutions'
  ]
  loop
    execute format('alter table %s enable row level security', t);
    execute format(
      'create policy catalog_read on %s as permissive for select to noura_api, noura_worker using (true)', t
    );
  end loop;
end
$$;
