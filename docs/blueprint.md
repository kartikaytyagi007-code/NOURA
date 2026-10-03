# NOURA — V1 Master Development Blueprint

Version 1.0 • 1 October 2026 • Working brand: NOURA

Audience: owner, developer, Claude coding assistant, and Stitch designer.
Status: V1 scope and implementation baseline. Specific model IDs, provider account configuration, nutrition-data rights, clinical thresholds, and store pricing require the release checks below. This document specifies a build; it does not claim that code or infrastructure already exists.

## 1. Product and frozen scope

An Indian-first nutrition and fitness coach. Its primary value is helping users improve the food they already eat and connect meals with a practical training plan. Calories are supporting information.

Core loop: onboarding → personal targets → diet/workout plans → scan meal → confirm foods/portions → Meal Balance → Fix My Plate → log actual meal → next-meal guidance → workout logging → weekly patterns/progress → coach.

V1 includes:
- Email/password, password recovery, Google and Apple authentication.
- Resumable onboarding; body profile, goals, diet preferences, allergies, food exclusions, budget, cuisine, activity and training preferences.
- Seven-day diet plan, portions, curated recipe instructions, individual meal swaps and user-requested regeneration.
- Meal camera/upload, editable recognition, preparation and portion confirmation, approximate nutrition, Meal Balance and concrete plate improvements.
- Manual meal entry and searchable foods as a fallback.
- Three next-meal options based on confirmed logs and preferences.
- Daily summaries and seven-day nutrition-pattern insights.
- Weekly gym/home workout plan, substitutions, sets/reps/rest, completed/skipped sessions and set logs.
- Weight trends, meal/workout consistency and private progress-photo comparison.
- Context-aware coach chat with proposed plan changes that require a user action to apply.
- Free/premium entitlements, restore purchases, reminders, analytics, crash reporting, export and account deletion.

Deferred: physique analysis, photo-based body-fat estimates, measurement-based composition estimates, automatic weekly diet changes, automated progressive overload, wearables, sleep/readiness scoring, restaurant/menu scanning, social features, food-image generation, grocery planning and user recipe generation. Chat may rearrange an existing workout week after confirmation; it does not introduce an adaptive training engine.

V1 serves adults seeking general wellness. Automated nutrition/training plans for minors, pregnancy/breastfeeding, active eating-disorder concerns, or conditions requiring individualized medical diets are outside this release. Collect only the screening information needed to determine eligibility. These users can receive neutral tracking features with an explicit explanation; do not generate a treatment plan.

## 2. Architecture decisions

| Layer | Frozen choice | Responsibility |
|---|---|---|
| Mobile | Flutter/Dart | Android/iOS UI, camera, authentication session, local draft/cache, purchases |
| State/routing | Riverpod, go_router | Feature state, dependency injection, route guards |
| Mobile API | Dio and generated typed DTOs | Auth headers, timeouts, standardized error mapping |
| API | Node.js/TypeScript, Fastify | Auth, business rules, all domain writes, OpenAPI |
| Database | Supabase PostgreSQL, SQL migrations | Ownership, transactions, versioned plans and logs |
| Auth/storage | Supabase Auth and private Storage | Identity, signed uploads/downloads |
| Jobs | PostgreSQL-backed queue using pg-boss | Generation, scans, summaries, deletion, reconciliation |
| AI | Provider adapter; Gemini first candidate | Recognition and grounded language generation |
| Billing | RevenueCat + store billing | Mobile purchase lifecycle and backend entitlements |
| Telemetry | Firebase Analytics/Crashlytics mobile; structured backend logs | Redacted failures and aggregate events |
| Hosting | Containerized API and worker on managed container host; Supabase managed DB | Separate staging/production environments |

Dependency versions: select current compatible stable releases during M1, pin them and commit lockfiles. Do not blindly install latest packages in later tickets. Verify queue compatibility with the selected database connection mode. Hosting vendor selection is an operational release decision, not a reason to alter the architecture.

Flutter communicates directly with Supabase only for authentication and approved signed media transfer. All domain reads/writes use the API. API verifies Supabase tokens with supported verification/JWKS, issuer, audience, expiry and subject checks. Never trust a submitted user_id. Domain database access uses a restricted server role with explicit owner filtering; mobile has no table-write grants. Enable RLS for user tables and Storage. Any privileged server operation bypassing RLS must explicitly enforce ownership and have negative tests. Never ship a service-role key to mobile.

One backend codebase, one PostgreSQL database and two process roles: API and worker. No microservices, Redis or vector database needed for V1. Deploy processes independently from the same container image. Job payloads contain IDs, not images or chat histories.

## 3. Repository layout and contracts

```text
apps/mobile/lib/{app,core,features}
apps/mobile/lib/features/{auth,onboarding,home,meals,diet,workouts,progress,coach,billing,settings}
apps/api/src/{modules,plugins,server.ts}
apps/worker/src/{handlers,worker.ts}
packages/contracts/{openapi.yaml,json-schema}
packages/domain/{nutrition,scoring,planning,eligibility}
packages/ai/{providers,prompts,validators}
supabase/{migrations,seed.sql,tests}
data/{foods,recipes,exercises,provenance}
docs/{blueprint.md,decisions.md,milestones.md,runbooks}
```

Feature UI → repository → typed API client. Business rules stay out of widgets. Shared TypeScript domain modules are used by API and worker; Flutter uses generated contracts, not reimplemented scoring. SQL is the schema authority. Generate Dart DTO/client artifacts from OpenAPI; document any unsupported generator constructs. CI fails on contract drift. One commit can update contract, backend and client together.

## 4. Navigation and screens

Cold start → restore auth → unauthenticated welcome; authenticated unfinished onboarding → resume saved step; completed eligible profile → Home; plan processing → Home with generation status/retry. An unavailable plan must not trap a user in onboarding. Paywall is never a mandatory onboarding step.

Five tabs: Home, Meals, Coach, Workout, Progress. Scan is a prominent Home/Meals action. Settings opens from the profile icon.

| Surface | Required behavior |
|---|---|
| Auth | Welcome, sign-in/up, verification, recovery, Google/Apple, cancellation/error states |
| Onboarding | Basics → goals → diet/preferences → training → eligibility/consent → review → submit |
| Home | Next meal, nutrition summary, today's workout, one insight, scan action |
| Meals | Diary date selection, daily/weekly plan, manual entry, scan, seven-day patterns |
| Scan | Permission, camera/upload, quality check, upload/generation status, retry |
| Analysis | Recognized items, edit/resolve items, portion/preparation inputs, estimated nutrition/score |
| Fix My Plate | Keep/reduce/add actions, preview, accept suggestion or log unchanged |
| Next meal | Three validated choices, explanation, swap/add to plan; not automatically logged |
| Workout | Week, session detail, demonstrations/instructions, active session, set log, substitutions |
| Progress | Weight trend, consistency, private front/side/back photo comparison |
| Coach | Messages, contextual suggestion chips, proposal cards, confirm/cancel plan change |
| Settings | Profile/preferences, regeneration preview, reminders, purchases/restore, export, deletion |

Every data screen needs loading, empty, partial data, offline and retry states. Cache readable plans/diary. Offline users may save local workout/weight/meal drafts, but AI requires connection. Sync drafts with stable client UUIDs and idempotency; show pending status until server acceptance. No silent optimistic purchase or AI success.

## 5. Onboarding contract

Store metric canonical values; display kg/lb and cm/ft according to preference. Use an IANA timezone, initially device timezone. Save each step with a profile revision.

Required inputs: display name, adult age in years (avoid collecting full DOB), height_cm, weight_kg, calculation sex parameter with an explanation, activity band, primary goal, diet type, meals/day, cuisine preferences, allergies/exclusions, budget band, cooking availability, experience, home/gym/both, equipment, days/week, available weekdays, session duration and relevant exercise limitations.

Optional: target weight, disliked foods and reminder times. If a user declines the sex parameter, offer a target range or manually supplied targets; do not secretly infer it from a photo. Gender identity is not required for energy calculations.

Validate plausible input ranges without claiming they are medical thresholds. Inconsistent units, unrealistic target dates and unsupported preferences produce actionable validation errors. Server owns all validation. Eligibility result: eligible, tracking_only or needs_review. Persist only minimal screening flags and consent versions.

Completing onboarding transactionally creates profile_revision, goal version, target snapshot and plan jobs. Job failure does not lose profile inputs. Profile edits invalidate relevant future recommendations; past logged nutrition snapshots remain unchanged.

## 6. Database specification

UUID primary keys; UTC timestamptz; decimal for grams/weight; integer calories where displayed; UTC created_at/updated_at. User-owned rows have user_id referencing auth.users. Child writes verify same ownership as parent. List endpoints are indexed on (user_id, date/time). Migrations include enum/check constraints and RLS/grants.

| Table | Important fields and constraints |
|---|---|
| profiles | user_id PK, name, age, calculation_sex nullable, height_cm, timezone, units, onboarding_step/status, revision |
| user_preferences | user_id PK, diet_type, allergy_ids[], exclusion_ids[], dislikes[], cuisines[], budget, cooking_time, meals_per_day, reminder settings |
| training_preferences | user_id PK, experience, location, equipment_ids[], weekdays[], duration_minutes, limitation_tags[], revision |
| goals | id, user_id, type, optional target_weight, active_from/to; one active per user |
| consent_records | id, user_id, type, version, granted_at/revoked_at |
| target_snapshots | id, user_id, profile_revision, policy_version, estimated_energy_range, selected targets, method, eligibility, valid_from/to |
| food_sources | id, source_name, source_version, license/usage_notes, acquired_at |
| foods | id, source_id, name, aliases, raw/cooked basis, per_100g nutrients, diet/allergen tags, serving conversions, quality flag |
| recipes / recipe_ingredients | recipe ID/name/tags/instructions/yield; ingredient food_id and edible grams; compute nutrition from ingredients and yield |
| exercises | id, name, movement_pattern, muscle_tags, equipment, level, contraindication_tags, instructions, licensed_demo reference, substitutions |
| diet_plans | id, user_id, version, profile_revision, target_snapshot_id, starts_on, status, supersedes_id; one active plan per start period |
| diet_plan_meals | id, user_id, plan_id, date, slot, recipe/food portions snapshot, calculated nutrition, revision, status |
| workout_plans / workout_plan_sessions | plan version/profile_revision; session date/order/title/status |
| workout_plan_exercises | session_id, exercise_id, order, sets, reps range, rest_sec, optional effort cue, prescription snapshot |
| media_assets | id, user_id, purpose, bucket/path unique, verified type/bytes, status, expires_at, deleted_at |
| meal_scans | id, user_id, media_asset_id, status, recognition JSON, model/prompt_version, revision, expires_at |
| meal_logs | id, user_id, consumed_at, local_date/timezone snapshot, slot, scan_id nullable, plan_meal_id nullable, client_id unique per user, totals snapshot, score/policy_version, revision |
| meal_log_items | id, user_id, meal_log_id, food/recipe ID nullable, label, grams/range, preparation, nutrients nullable, provenance, uncertainty |
| workout_logs / workout_set_logs | user_id, session_id, started/completed_at, status, client_id; exercise, set ordinal, reps, load_kg, skipped flag |
| weight_logs | id, user_id, measured_at, weight_kg, client_id unique per user |
| progress_photos | id, user_id, media_asset_id, captured_at, angle enum front/side/back; no AI analysis columns |
| daily_summaries | user_id + local_date unique, confirmed nutrient totals, coverage flags, meal/workout counts, revision |
| weekly_insights | user_id, period, aggregate revision, policy_version, evidence JSON, explanation |
| coach_threads / coach_messages | user_id, thread_id, role, content, status, created_at, model/prompt version; failed messages explicit |
| action_proposals | user_id, type, payload, expected_plan_revision, status, expires_at, applied_at; apply once |
| entitlements | user_id + entitlement key, provider status, expires_at, last_verified_at |
| billing_events | provider event_id unique, minimal payload, processed_at, status |
| usage_reservations | user_id, feature, quota period, request_id unique, reserved/consumed/released state |
| idempotency_records | user_id, route, key unique, request_hash, response/job_id, expires_at |
| generation_requests | id, user_id, type, status, input_revision, result IDs, safe error, timestamps; queue delivery ID |
| deletion_requests / export_requests | user_id, state, result media ID nullable, requested/completed_at |

Use relational columns for searchable fields; JSONB only for validated snapshots, recognition and flexible proposal payloads. Do not put the entire app in one JSON column. Foreign keys, owner checks and transactions prevent orphan or cross-user child rows. Data provenance survives updates to food catalog values.

## 7. Nutrition and targets

Create a curated Indian-food/recipe catalog plus appropriately licensed reference nutrition data. Track source, version, edible/cooked basis, unit conversions and recipe yield. Do not copy a database without checking redistribution/API rights. Launch coverage target: approximately 150 common Indian foods/variants and 50 curated recipes; this is an operational seed target, not a completeness claim.

AI proposes names, visible components, preparation questions and portion ranges. Backend resolves catalog candidates. User confirms grams or supported serving units. A household unit maps to documented gram ranges; it must not be treated as universally fixed. Oil, ghee, gravy and cooked/raw weight are explicit uncertainty inputs. Nutrients = validated source values × edible portion / 100; recipes use ingredient quantities and cooked yield. Unknown items retain null nutrition and require search/manual entry. Never replace unknown with zero or invented numbers.

Targets engine: deterministic, versioned and reviewed before production. A starting engineering implementation may use an established adult resting-energy equation with activity factors, then a conservative goal adjustment. All coefficients, protein/fibre rules and eligibility guardrails live in policy configuration with method references and reviewer sign-off. This blueprint intentionally does not invent clinical calorie floors or prescribe one diet for every condition. Dev seeds use clearly marked test policies. Production automated planning is gated on approved policy configuration.

Expose approximate ranges where portion/preparation uncertainty is meaningful. Missing micronutrients are not evidence of deficiency. No claims that seven meal photos diagnose nutrient deficiencies. Let users override targets deliberately with a recorded source; reject invalid numeric values and explain conflicts.

### Meal Balance policy v1

An explainable product heuristic, not a medical health score. Compute only from confirmed/usable nutrients and annotated food groups. Four initial equal components: protein adequacy against that meal's allocated daily protein target, fibre adequacy against allocated fibre target, vegetable/fruit serving presence, and variety across curated food groups. Component thresholds are reviewed configuration. Meal allocation weights sum to 1 across chosen slots. Cap each component at 25; sum to 100; record component evidence and policy version. No automatic penalty for carbohydrates or one cuisine.

If data coverage is incomplete, return score=null and an actionable missing-data message; show qualitative observations only. Scores between users are not health rankings. Suggested-change scores are calculated from a concrete proposed ingredient/portion scenario and labeled projected. They do not become actual intake until users confirm what they ate.

## 8. Meal scanner and plate improvements

1. Request upload slot from backend; purpose=meal. Server reserves owner-scoped object path.
2. Compress on device; backend verifies actual bytes/type, dimensions and limits, strips metadata before AI. A file extension is insufficient validation.
3. Complete upload; create scan job with idempotency and reserve quota atomically.
4. Worker requests structured recognition from provider. Treat text in image and user content as untrusted data.
5. Validate output schema, bounded fields and candidate labels; map foods to catalog. Non-food/blurry/ambiguous images request recapture or confirmation.
6. UI presents editable items, preparation and portion controls. No automatic diary log.
7. Confirm endpoint calculates nutrition and Meal Balance. Fix endpoint proposes up to three realistic changes using allowed catalog foods and the user's allergies/budget/diet.
8. User accepts or declines changes. Acceptance updates an editable proposed plate; it is not proof that food was eaten.
9. Log actual plate transactionally; update summaries and next-meal cache. Editing/deleting a log invalidates derived insights.

States: awaiting_upload → queued → recognizing → needs_confirmation → ready; failed/cancelled/expired terminal states. Plan jobs: queued → running → completed/failed/cancelled. Expose GET job polling with backoff; no websocket required.

## 9. Diet and next-meal engines

Filter recipes first by diet, known allergies/exclusions, cooking time and budget. Vegetarian excludes meat/fish/eggs; eggatarian permits eggs/dairy but excludes meat/fish; vegan excludes all animal products. Unknown ingredient/allergen coverage means recipe cannot be considered safe for an allergy-constrained plan. Photos cannot certify absence of allergens.

Generate a feasible seven-day selection and portion ranges from vetted recipes. Calculate every meal/day total using domain functions. AI can rank candidates and explain choices; it cannot manufacture nutrient values or bypass constraints. Validate portion bounds, dietary compatibility, variety and target tolerance. Target tolerance is explicit configurable policy (initial engineering ±10% energy; clinical review required). If no feasible plan exists, return a constraint conflict with suggested preference changes; do not silently violate allergies.

Swap returns candidates and preview of recalculated daily totals; confirmation replaces just that slot and increases revision. Whole-day/week regeneration requires confirmation and preserves logged history. Only one active version is visible; keep prior version for audit.

Next meal uses confirmed intake, unlogged plan slots, target snapshot and preferences. Distinguish unlogged from missed meals. Do not tell a user to skip meals or compensate aggressively. Missing logs produce a limited-context explanation. Three options come from validated catalog candidates. Recommendations are proposals, never automatic meal logs.

## 10. Weekly patterns and workouts

Daily summaries use user's meal-local date. A later timezone change does not silently move historical entries. Recompute only affected days and seven-day windows after edits. Show coverage: for example, 'Based on 11 logged meals across 5 days.' Call low protein a pattern in logged intake, not a proven daily deficit when meals are missing. Vegetable patterns use food-group annotations. Show at most three insights plus one actionable focus. Deterministic evidence first; AI optionally explains it. Seven-day view only in V1.

Workout generation uses vetted templates by goal, experience, equipment, time and limitation filters. The system validates days, recovery spacing, exercise compatibility and session length. No exercises invented by AI. Demo media must have usage rights. Log weights/reps as user input, with zero load allowed for bodyweight. Completed sessions and skipped exercises are separate. Workout consistency denominator is scheduled sessions elapsed, excluding future sessions and intentional rest days.

Substitutions match movement/equipment and limitations. Coach rescheduling proposes a new calendar and checks spacing; user confirms before applying. V1 displays previous performance but does not automatically increase loads. Pain or alarming symptoms route to stop/seek appropriate help, not an AI diagnosis. Progress-photo uploads are never sent to vision services in V1.

## 11. API contracts

Base /v1; JSON snake_case; Bearer auth except health and authenticated provider webhook. UUID identifiers, ISO timestamps, metric units. Every owner resource lookup filters user_id. Missing/non-owned resources both return 404. Pagination uses cursor/limit with maximum 100. Mutations use Idempotency-Key; edits also use expected_revision and return 409 on stale data.

Success: {"data": {...}, "meta": {"request_id":"..."}}.
Error: {"error":{"code":"...","message":"...","field_errors":[],"retryable":false},"meta":{"request_id":"..."}}.
Codes: VALIDATION_ERROR, UNAUTHENTICATED, NOT_FOUND, REVISION_CONFLICT, QUOTA_EXCEEDED, PROVIDER_UNAVAILABLE, UNSUPPORTED_INPUT, CONSTRAINT_CONFLICT. 422 invalid content, 401 auth, 404 owner-safe lookup, 409 conflict, 429 rate/quota, 503 provider unavailability.

| Method and route | Input → output |
|---|---|
| GET /me | Profile, preference, eligibility, revision and onboarding status |
| PATCH /me | Partial validated profile + expected_revision → new revision |
| PUT /me/preferences; PUT /me/training-preferences | Validated preferences + revision → saved preferences |
| POST /onboarding/complete | revision, consent versions → profile + plan job IDs |
| GET /targets | Current target snapshot and calculation method |
| GET /home?date= | Summary, next meal, workout and supported insight |
| POST /media/upload-slots | purpose, mime, size → media_id, signed upload, expiry |
| POST /media/{id}/complete | Upload confirmation → verified media/job status |
| GET /media/{id}/download | Ownership → short-lived signed download |
| DELETE /media/{id} | Owner request → deletion status |
| POST /meal-scans | media_id → 202 job_id, scan_id |
| GET /meal-scans/{id} | State and recognition candidates |
| PUT /meal-scans/{id}/confirmed-items | items, portions, preparation, revision → calculated analysis |
| POST /meal-scans/{id}/plate-fixes | revision → validated fixes/projected scenarios |
| GET /foods?q=; GET /recipes/{id} | Paginated catalog/curated instructions |
| POST /meal-logs | consumed_at, slot, confirmed items, client_id → log snapshot |
| GET /meal-logs?date= | Diary, coverage and totals |
| PATCH /meal-logs/{id}; DELETE /meal-logs/{id} | revision → changed log/invalidation |
| POST /diet-plans/generate | start_date, profile_revision → 202 job |
| GET /diet-plans/current?date= | Active weekly plan |
| POST /diet-plan-meals/{id}/swap-options | revision → candidates and preview |
| PUT /diet-plan-meals/{id} | candidate/portion + revision → updated slot |
| GET /recommendations/next-meal?date=&slot= | Three grounded options |
| GET /insights?period=7d | Evidence, coverage, explanations |
| POST /workout-plans/generate | profile_revision, start_date → 202 job |
| GET /workout-plans/current | Week/session prescriptions |
| GET /exercises/{id}/substitutions | Compatible candidates |
| POST /workout-logs | session_id, client_id → log |
| PUT /workout-logs/{id}/sets | set rows + revision → saved log |
| PATCH /workout-logs/{id} | completed/skipped status + revision |
| GET/POST /weight-logs; DELETE /weight-logs/{id} | Weight history/mutations |
| GET/POST /progress-photos; DELETE /progress-photos/{id} | Private photo references; no analysis |
| GET /progress?period=30d | Weight and consistency trends |
| POST /coach/threads; GET /coach/threads/{id}/messages | Create/read owner thread |
| POST /coach/threads/{id}/messages | message + client_id → 202 job/message |
| POST /action-proposals/{id}/apply | expected_revision → applied once or 409 |
| POST /action-proposals/{id}/cancel | Cancel proposal |
| GET /jobs/{id} | User-safe status/result/error |
| GET /entitlements; GET /usage | Server billing truth and limits |
| POST /billing/sync | Refresh from provider; never accept client premium flag |
| POST /webhooks/revenuecat | Authenticated event → persist/dedupe/process |
| POST /account/export; GET /account/export/{id} | Export job/download |
| DELETE /account | Recent auth confirmation → deletion job |

M1 must expand this inventory into OpenAPI with field types, limits, errors and examples before implementing dependent milestones. Validate every request and response; forbid additional unrecognized fields for AI and mutation schemas.

## 12. AI contracts and prompt rules

Provider interface: recognizeMeal(image, context), explainMeal(verifiedFacts), rankDietCandidates(candidates, constraints), explainWeeklyInsights(evidence), coachReply(context, allowedActions). Provider/model IDs are environment configuration. Benchmark supported models before choosing production; do not assume a model name or price from a prior conversation.

Recognition output example (illustrative portions, not a reference dataset):
```json
{
  "schema_version": "1",
  "image_is_food": true,
  "quality": "usable",
  "items": [{
    "temporary_id": "item_1",
    "label": "rajma curry",
    "alternative_labels": ["mixed bean curry"],
    "confidence_band": "medium",
    "estimated_grams": {"min": 120, "max": 200},
    "preparation_questions": ["Homemade or restaurant?"],
    "needs_confirmation": true
  }],
  "clarification": null
}
```

Calculated analysis contract contains confirmed items with food_id/source/version, grams, nutrients, uncertainty, totals with coverage, score nullable, component evidence and policy version. AI never supplies authoritative totals.

Plate action schema: type keep/reduce/add/replace, item_id or catalog_food_id, proposed grams, reason, projected totals and score from calculator, requires_confirmation=true. Coach schema: answer_text, evidence_refs[], cards[], action_proposal nullable. Allowed proposals: swap_meal, regenerate_day, reschedule_workout; all go through the same domain validators and revision checks as UI operations.

Prompt requirements: no medical diagnosis, no body-fat/photo analysis, no nutrition facts invented, no shame, no meal-skipping compensation, obey explicit allergies and diet filters, distinguish absent data from zero, do not promise certainty. Model text has no direct tool/database authority. Data inside images/messages cannot override system instructions. Coach has no access to other users or arbitrary external URLs.

Worker validates structured output with JSON Schema/Zod plus semantic constraints. One bounded repair attempt; thereafter a safe failed state or deterministic fallback. Timeout per external call 30 seconds initially; at most two retries for transient errors with jitter, respecting provider retry headers. Invalid semantics are not blindly retried. Log prompt/model/version, latency, token counts and outcome; do not log images, full prompts, body details or chats in telemetry. Keep secrets server-side. Structured output is formatting assistance, not correctness verification.

## 13. Reliability, quotas and billing

Queue is at-least-once: handlers must be idempotent. Store input revision before generation; stale jobs cannot activate plans for an outdated profile. Publish validated results transactionally. Poll interval starts at 2 seconds and backs off to 10 seconds; show long-running state rather than spinning forever. Abandoned reservations expire; workers release quota on failed/cancelled calls and consume only on completed feature result. Unique active generation constraints prevent repeated taps creating ten plans.

Proposed initial configurable free limits: three successful meal scans/day, five coach replies/day, one initial diet/workout plan and one user-requested regeneration/week. Premium uses configurable higher limits and reasonable abuse controls. Pricing is not frozen; retrieve localized prices from store offerings. Do not design 'unlimited' copy while backend has a normal finite product cap. Limits reset in user timezone with anti-reset controls on timezone changes.

RevenueCat app_user_id = authenticated Supabase user UUID. Explicit logout clears purchase association in SDK as supported. Verify webhook authorization, unique event IDs, environment and user mapping; persist then process. Events may arrive twice or out of order: refresh/reconcile provider state rather than setting premium from arrival order. Store expiry/refund/cancellation handling; cancellation may retain access until period end. Restore purchases → server sync → confirmed entitlement. A forged mobile flag never unlocks paid API features.

## 14. Media, privacy and retention

Private buckets: meal-images, progress-photos, exports. Paths generated by server under owner UUID/media UUID. Initial limits: meal/progress JPEG/PNG/WebP up to 10 MB after client compression; validate server-side and normalize orientation. Reject unsupported files. Short-lived signed links; never persistent public URLs. Strip EXIF/location. Worker can access only media required for its job. Request consent before sending meal imagery/profile context to third-party AI. Progress photos need separate clear storage consent and are excluded from model requests.

Proposed retention: uncompleted uploads 24 hours; failed/unlogged scans 7 days; logged meal images 90 days unless deleted sooner; nutrition logs/plans until user deletion; progress photos until user deletion; coach history 90 days; exports 24 hours. Expose these choices clearly and validate privacy/provider retention requirements before launch. Cleanup jobs are required, including objects whose database transaction failed.

Account deletion revokes app access, cancels queued jobs, removes Storage objects and owned domain rows, then deletes auth identity; retries incomplete steps. Billing records retain only minimal nonidentifying fields where legitimately required. Explain that store subscriptions must also be managed through store controls; deleting an account is not a promise to cancel external billing. Export includes profile, plans, meal/workout/weight logs and photo files/manifest, excluding secrets/provider internals. Production backups have a documented expiry and restoration procedure that respects deletion tombstones.

## 15. Stitch alignment instructions

Keep the approved light theme, typography, food imagery and five-tab layout. Mock values are design samples, not validated nutrition.

Correct the earlier design prompt for V1:
- Replace 'Daily Readiness' with 'Today's progress'; no readiness/sleep algorithm.
- Remove water tracking and streaks from the required build unless separately added to scope.
- Nutrition patterns: seven days only; hide 30/90-day advanced analysis.
- Replace 'Adjust my plan' automatic adaptation with a previewed, user-confirmed meal swap/regeneration.
- 'View recipe' means a curated catalog recipe; no generated recipe engine.
- Progress photos are comparison/storage only; hide physique/body-fat analysis.
- Projected improved Meal Balance is marked estimated; 'Use changes' opens confirmation of actual portions.
- Paywall benefits must match actual entitlements; avoid unlimited-scan promises until limits are finalized.
- Include unknown-food/portion confirmation, incomplete-score state, camera permission denial, quota, provider failure, empty history and pending offline drafts.

Do not let design-only controls silently become new backend requirements. Export Stitch assets/screens when ready; use a screen-to-feature mapping and component tokens before Flutter implementation. Text scales, accessible contrast, semantic labels and at least 44–48 logical-pixel tap targets are acceptance requirements.

## 16. Implementation milestones for Claude

| Milestone | Deliverable | Acceptance gate |
|---|---|---|
| M1 Foundation | Repo, Flutter shell/navigation, API/worker health, SQL schema/migrations, contract scaffolding, auth/recovery, CI, environment templates | Fresh local setup works; sign-in/out/refresh; owner isolation; no secrets in app; API contract smoke tests |
| M2 Profile | Resumable onboarding, eligibility, preferences, deterministic target-policy framework | Resume after restart; unit/timezone validation; edits increment revisions; unsupported planning gated |
| M3 Diet | Provenance catalog/recipes, targets calculator, plan job, daily/weekly UI, swap/regeneration | Allergy/diet exclusions enforced; exact totals reconcile; infeasible constraints explicit; duplicate jobs safe |
| M4 Scanner | Private uploads, recognition adapter, status UI, catalog mapping, editable foods/portions, manual logs | Non-food/unknown/provider failure handled; no log before confirmation; cross-owner media denied |
| M5 Plate | Versioned Meal Balance, evidence, keep/reduce/add, scenario calculator | Incomplete data yields null score; projected changes don't modify actual logs; recalculation stable |
| M6 Guidance | Next-meal options, daily summaries, seven-day patterns | Edited/deleted meals invalidate aggregates; missing logs disclosed; allergy-compatible options |
| M7 Training | Vetted exercise catalog/templates, week/session UI, set logging, substitutions | Equipment/limitations respected; offline duplicates safe; completed/skipped/rest distinguishable |
| M8 Progress | Weight charts, consistency, private photos, comparison | Correct dates/denominators; deletion removes media; photos never invoke AI |
| M9 Coach | Context retrieval, grounded responses/cards, limited action proposals | No cross-user data; malicious text cannot invoke tools; stale proposals fail; apply once |
| M10 Release | Billing/quotas, reminders, telemetry, export/deletion, sandbox stores, hardening | Purchases/restore/refunds tested; replay-safe events; deletion/export work; release gates below pass |

Integrate Stitch designs into each milestone rather than leaving all UI until M10. Billing interfaces/usage reservation hooks start in M1 and generation milestones; real stores are completed in M10. M1 tables may precede features but no feature is declared complete from schema alone. This is a substantial V1: do not promise a two-week production release without estimating actual implementation, data review and store testing.

## 17. Meaningful verification and release gates

Each milestone: relevant unit/domain tests, API integration tests with PostgreSQL and Flutter flow checks. Test behavior, not snapshots of implementation. Required cases:
- User A cannot read/write/download/delete user B's resources through API or direct Storage access.
- Mixed cooked/raw conversions and recipe yield produce consistent nutrition; unknown nutrients stay null.
- Vegan/eggatarian rules and all known allergy tags survive every plan/swap/coach path.
- Concurrent retries create one log/job and never exceed quota; failed jobs release reservations.
- Profile edits during generation do not activate stale plans; stale swaps/proposals return conflict.
- Diary edits/deletes update affected summaries; timezone transitions preserve historical dates.
- Webhook duplication/out-of-order/refund/expiry plus restore and account switching are handled.
- Private media cleanup/account deletion/export retries work across interrupted processes.
- Scan/AI failure retains user input; offline drafts don't duplicate after reconnect.

AI evaluation fixture target: at least 60 representative Indian meal images with consent/rights, annotated foods and uncertainty (thali, curry, mixed dishes, oil ambiguity, poor light, non-food). Report recognition accuracy, correction frequency, unknown rate, latency and cost. Initial launch targets: at least 85% correct visible food labels on supported catalog fixtures after alias matching, no fabricated authoritative nutrition, and 100% enforcement of explicit exclusions in adversarial plan tests. These are proposed engineering thresholds, not accuracy claims. Include at least 40 diet/coach scenarios covering vegan, eggatarian, budget, allergies and missing logs. Approve model based on benchmark results, not reputation.

Before production: nutrition/exercise policy review, food/demo licensing, privacy consent and provider settings, app store purchase sandbox, physical Android/iOS camera tests, accessibility/text scaling, monitoring alert test, DB restore rehearsal, cost/load test with a declared target cohort, API rate limits and account deletion review. Record costs per successful scan, coach reply and plan; no unsupported fixed monthly AI budget. Production must not run test nutrition policies or synthetic catalog facts. Human correction/manual logging stays available at launch.

## 18. Environment and operations

Public/mobile configuration: API base URL, Supabase URL/public key, RevenueCat public platform keys, Firebase config. Secret server configuration: DB connection, Supabase privileged credentials if required, AI API keys/model IDs, RevenueCat secret API/webhook authorization, signing/admin secrets. Use .env.example placeholders and host secret manager; never commit .env or print secrets. Different accounts/projects/keys for staging and production.

CI: formatting/static analysis, domain/integration tests, migrations against temporary DB, OpenAPI/client generation drift check, Flutter analyze/tests and Android build. iOS builds/signing need macOS and owner-provided Apple configuration. Startup fails on missing required config. Liveness and readiness separate. Apply reviewed migrations as a release step; worker/API compatible with old and new schema during rollout. Back up before destructive migrations and prefer additive changes.

Monitor queue age, provider failures, p95 request/generation latency, quota reservation leaks, webhook lag, database errors and per-feature spend. Alerts contain IDs/error codes only. Runbooks: provider outage/fallback, worker retry, purchase reconciliation, restore, deletion backlog and rollback. User reminders initially use local device notifications after opt-in; reschedule when plans/timezone change. No push infrastructure needed for V1.

## 19. Claude kickoff prompt

Copy this after attaching this complete file and, if available, Stitch designs:

> You are implementing NOURA V1 from the attached NOURA_V1_Development_Blueprint.md. Treat it as the scope and architecture authority. NOURA is a working brand. Start with M1 only. Inspect the existing repository and any AGENTS.md first; if the repo is empty, initialize the specified monorepo. Identify genuine blockers and proceed with documented reversible defaults for routine choices. Do not implement M2–M10, change the stack, add deferred features, invent nutrition data or claim unimplemented services work. Create docs/blueprint.md from the supplied file, docs/decisions.md, docs/milestones.md and setup instructions. Define typed OpenAPI foundations and migrations with ownership constraints and security policies. Implement Flutter auth/navigation shell, Fastify API, PostgreSQL worker skeleton, configuration validation and CI. Provide explicit mock adapters for paid services in development, fail closed in production when unconfigured, and never place AI/server secrets in Flutter. Do not apply migrations to production or publish releases. Run the M1 acceptance checks. At completion report files changed, setup commands, actual checks/results, remaining account/configuration requirements, and the exact next M2 ticket. Stop after M1 for review.

For each later milestone: attach the same blueprint plus the current code, latest decision log, relevant Stitch screens and milestone ticket. Ask Claude to run the previous relevant checks and the new acceptance gate. Do not repeatedly reset architecture in fresh chats. Keep changes and schema versions in Git.

## 20. Source and decision notes

The stack choices and product rules in this document are engineering recommendations. Provider integration behavior should be rechecked during implementation using primary documentation:
- Supabase JWT verification: https://supabase.com/docs/guides/auth/jwts
- Supabase private Storage and restrictions: https://supabase.com/docs/guides/storage/buckets/fundamentals
- Supabase Storage access policies: https://supabase.com/docs/guides/storage/security/access-control
- RevenueCat webhook authentication/event processing: https://www.revenuecat.com/docs/integrations/webhooks
- Gemini structured outputs: https://ai.google.dev/gemini-api/docs/structured-output

Freeze changes through docs/decisions.md with reason, affected contracts/migrations, test implications and owner-visible scope impact. Model selection, licensed seed dataset, reviewed nutrition policy, production host and store price remain named implementation/release decisions; they do not authorize silent feature expansion.
