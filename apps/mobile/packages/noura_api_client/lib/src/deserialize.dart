import 'package:noura_api_client/src/model/account_export.dart';
import 'package:noura_api_client/src/model/action_proposal.dart';
import 'package:noura_api_client/src/model/action_proposal_response.dart';
import 'package:noura_api_client/src/model/after_changes_scenario.dart';
import 'package:noura_api_client/src/model/analyzed_item.dart';
import 'package:noura_api_client/src/model/coach_card.dart';
import 'package:noura_api_client/src/model/coach_message.dart';
import 'package:noura_api_client/src/model/coach_message_accepted.dart';
import 'package:noura_api_client/src/model/coach_message_accepted_response.dart';
import 'package:noura_api_client/src/model/coach_message_list.dart';
import 'package:noura_api_client/src/model/coach_message_list_response.dart';
import 'package:noura_api_client/src/model/coach_thread.dart';
import 'package:noura_api_client/src/model/coach_thread_response.dart';
import 'package:noura_api_client/src/model/confirm_items_request.dart';
import 'package:noura_api_client/src/model/confirmed_item_input.dart';
import 'package:noura_api_client/src/model/consent_input.dart';
import 'package:noura_api_client/src/model/coverage.dart';
import 'package:noura_api_client/src/model/create_meal_log_request.dart';
import 'package:noura_api_client/src/model/create_meal_scan_request.dart';
import 'package:noura_api_client/src/model/create_progress_photo_request.dart';
import 'package:noura_api_client/src/model/create_weight_log_request.dart';
import 'package:noura_api_client/src/model/create_workout_log_request.dart';
import 'package:noura_api_client/src/model/delete_account_request.dart';
import 'package:noura_api_client/src/model/deleted.dart';
import 'package:noura_api_client/src/model/deleted_response.dart';
import 'package:noura_api_client/src/model/deletion_accepted.dart';
import 'package:noura_api_client/src/model/deletion_accepted_response.dart';
import 'package:noura_api_client/src/model/diet_plan.dart';
import 'package:noura_api_client/src/model/diet_plan_response.dart';
import 'package:noura_api_client/src/model/entitlement.dart';
import 'package:noura_api_client/src/model/entitlements.dart';
import 'package:noura_api_client/src/model/entitlements_response.dart';
import 'package:noura_api_client/src/model/error_body.dart';
import 'package:noura_api_client/src/model/error_response.dart';
import 'package:noura_api_client/src/model/exercise_ref.dart';
import 'package:noura_api_client/src/model/export_accepted.dart';
import 'package:noura_api_client/src/model/export_accepted_response.dart';
import 'package:noura_api_client/src/model/export_response.dart';
import 'package:noura_api_client/src/model/feature_usage.dart';
import 'package:noura_api_client/src/model/field_error.dart';
import 'package:noura_api_client/src/model/food.dart';
import 'package:noura_api_client/src/model/food_list.dart';
import 'package:noura_api_client/src/model/food_list_response.dart';
import 'package:noura_api_client/src/model/generate_plan_request.dart';
import 'package:noura_api_client/src/model/goal.dart';
import 'package:noura_api_client/src/model/goal_input.dart';
import 'package:noura_api_client/src/model/health_check.dart';
import 'package:noura_api_client/src/model/health_response.dart';
import 'package:noura_api_client/src/model/home.dart';
import 'package:noura_api_client/src/model/home_response.dart';
import 'package:noura_api_client/src/model/insight.dart';
import 'package:noura_api_client/src/model/insight_summary.dart';
import 'package:noura_api_client/src/model/insights.dart';
import 'package:noura_api_client/src/model/insights_response.dart';
import 'package:noura_api_client/src/model/int_range.dart';
import 'package:noura_api_client/src/model/job.dart';
import 'package:noura_api_client/src/model/job_accepted.dart';
import 'package:noura_api_client/src/model/job_accepted_response.dart';
import 'package:noura_api_client/src/model/job_response.dart';
import 'package:noura_api_client/src/model/macro_targets.dart';
import 'package:noura_api_client/src/model/me.dart';
import 'package:noura_api_client/src/model/me_response.dart';
import 'package:noura_api_client/src/model/meal_analysis.dart';
import 'package:noura_api_client/src/model/meal_analysis_response.dart';
import 'package:noura_api_client/src/model/meal_balance.dart';
import 'package:noura_api_client/src/model/meal_balance_component.dart';
import 'package:noura_api_client/src/model/meal_diary.dart';
import 'package:noura_api_client/src/model/meal_diary_response.dart';
import 'package:noura_api_client/src/model/meal_log.dart';
import 'package:noura_api_client/src/model/meal_log_response.dart';
import 'package:noura_api_client/src/model/meal_scan.dart';
import 'package:noura_api_client/src/model/meal_scan_accepted.dart';
import 'package:noura_api_client/src/model/meal_scan_accepted_response.dart';
import 'package:noura_api_client/src/model/meal_scan_response.dart';
import 'package:noura_api_client/src/model/media_asset.dart';
import 'package:noura_api_client/src/model/media_asset_response.dart';
import 'package:noura_api_client/src/model/media_download.dart';
import 'package:noura_api_client/src/model/media_download_response.dart';
import 'package:noura_api_client/src/model/meta.dart';
import 'package:noura_api_client/src/model/next_meal.dart';
import 'package:noura_api_client/src/model/next_meal_option.dart';
import 'package:noura_api_client/src/model/next_meal_response.dart';
import 'package:noura_api_client/src/model/number_range.dart';
import 'package:noura_api_client/src/model/nutrient_totals.dart';
import 'package:noura_api_client/src/model/nutrients.dart';
import 'package:noura_api_client/src/model/onboarding.dart';
import 'package:noura_api_client/src/model/onboarding_complete.dart';
import 'package:noura_api_client/src/model/onboarding_complete_request.dart';
import 'package:noura_api_client/src/model/onboarding_complete_response.dart';
import 'package:noura_api_client/src/model/patch_meal_log_request.dart';
import 'package:noura_api_client/src/model/patch_workout_log_request.dart';
import 'package:noura_api_client/src/model/plan_day.dart';
import 'package:noura_api_client/src/model/plan_meal.dart';
import 'package:noura_api_client/src/model/plan_meal_preview.dart';
import 'package:noura_api_client/src/model/plan_meal_response.dart';
import 'package:noura_api_client/src/model/planning.dart';
import 'package:noura_api_client/src/model/plate_action.dart';
import 'package:noura_api_client/src/model/plate_fixes.dart';
import 'package:noura_api_client/src/model/plate_fixes_response.dart';
import 'package:noura_api_client/src/model/portion_ref.dart';
import 'package:noura_api_client/src/model/preferences.dart';
import 'package:noura_api_client/src/model/preferences_input.dart';
import 'package:noura_api_client/src/model/preferences_response.dart';
import 'package:noura_api_client/src/model/preparation_input.dart';
import 'package:noura_api_client/src/model/prescribed_exercise.dart';
import 'package:noura_api_client/src/model/profile.dart';
import 'package:noura_api_client/src/model/profile_patch.dart';
import 'package:noura_api_client/src/model/progress.dart';
import 'package:noura_api_client/src/model/progress_photo.dart';
import 'package:noura_api_client/src/model/progress_photo_list.dart';
import 'package:noura_api_client/src/model/progress_photo_list_response.dart';
import 'package:noura_api_client/src/model/progress_photo_response.dart';
import 'package:noura_api_client/src/model/progress_response.dart';
import 'package:noura_api_client/src/model/projected_scenario.dart';
import 'package:noura_api_client/src/model/put_workout_sets_request.dart';
import 'package:noura_api_client/src/model/recipe.dart';
import 'package:noura_api_client/src/model/recipe_ingredient.dart';
import 'package:noura_api_client/src/model/recipe_ref.dart';
import 'package:noura_api_client/src/model/recipe_response.dart';
import 'package:noura_api_client/src/model/recognition.dart';
import 'package:noura_api_client/src/model/recognition_item.dart';
import 'package:noura_api_client/src/model/replace_plan_meal_request.dart';
import 'package:noura_api_client/src/model/revenue_cat_webhook_request.dart';
import 'package:noura_api_client/src/model/revenue_cat_webhook_request_event.dart';
import 'package:noura_api_client/src/model/revision_request.dart';
import 'package:noura_api_client/src/model/safe_error.dart';
import 'package:noura_api_client/src/model/screening_answers.dart';
import 'package:noura_api_client/src/model/send_coach_message_request.dart';
import 'package:noura_api_client/src/model/serving_conversion.dart';
import 'package:noura_api_client/src/model/serving_input.dart';
import 'package:noura_api_client/src/model/set_log_input.dart';
import 'package:noura_api_client/src/model/source_ref.dart';
import 'package:noura_api_client/src/model/substitution_candidate.dart';
import 'package:noura_api_client/src/model/substitutions.dart';
import 'package:noura_api_client/src/model/substitutions_response.dart';
import 'package:noura_api_client/src/model/swap_candidate.dart';
import 'package:noura_api_client/src/model/swap_options.dart';
import 'package:noura_api_client/src/model/swap_options_response.dart';
import 'package:noura_api_client/src/model/target_snapshot.dart';
import 'package:noura_api_client/src/model/target_snapshot_response.dart';
import 'package:noura_api_client/src/model/training_preferences.dart';
import 'package:noura_api_client/src/model/training_preferences_input.dart';
import 'package:noura_api_client/src/model/training_preferences_response.dart';
import 'package:noura_api_client/src/model/upload_slot.dart';
import 'package:noura_api_client/src/model/upload_slot_request.dart';
import 'package:noura_api_client/src/model/upload_slot_response.dart';
import 'package:noura_api_client/src/model/usage.dart';
import 'package:noura_api_client/src/model/usage_response.dart';
import 'package:noura_api_client/src/model/webhook_ack.dart';
import 'package:noura_api_client/src/model/webhook_ack_response.dart';
import 'package:noura_api_client/src/model/weight_log.dart';
import 'package:noura_api_client/src/model/weight_log_list.dart';
import 'package:noura_api_client/src/model/weight_log_list_response.dart';
import 'package:noura_api_client/src/model/weight_log_response.dart';
import 'package:noura_api_client/src/model/weight_point.dart';
import 'package:noura_api_client/src/model/workout_log.dart';
import 'package:noura_api_client/src/model/workout_log_response.dart';
import 'package:noura_api_client/src/model/workout_plan.dart';
import 'package:noura_api_client/src/model/workout_plan_response.dart';
import 'package:noura_api_client/src/model/workout_session.dart';
import 'package:noura_api_client/src/model/workout_session_preview.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'AccountExport':
      return AccountExport.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ActionProposal':
      return ActionProposal.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ActionProposalResponse':
      return ActionProposalResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ActivityBand':
    case 'AfterChangesScenario':
      return AfterChangesScenario.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'AllergyTag':
    case 'AnalyzedItem':
      return AnalyzedItem.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'BudgetBand':
    case 'CalculationSex':
    case 'CalculationSexInput':
    case 'CoachCard':
      return CoachCard.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'CoachMessage':
      return CoachMessage.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'CoachMessageAccepted':
      return CoachMessageAccepted.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CoachMessageAcceptedResponse':
      return CoachMessageAcceptedResponse.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'CoachMessageList':
      return CoachMessageList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CoachMessageListResponse':
      return CoachMessageListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CoachThread':
      return CoachThread.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'CoachThreadResponse':
      return CoachThreadResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ConfirmItemsRequest':
      return ConfirmItemsRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ConfirmedItemInput':
      return ConfirmedItemInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ConsentInput':
      return ConsentInput.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ConsentType':
    case 'CookingTime':
    case 'Coverage':
      return Coverage.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'CreateMealLogRequest':
      return CreateMealLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateMealScanRequest':
      return CreateMealScanRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateProgressPhotoRequest':
      return CreateProgressPhotoRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateWeightLogRequest':
      return CreateWeightLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CreateWorkoutLogRequest':
      return CreateWorkoutLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CuisineTag':
    case 'DeleteAccountRequest':
      return DeleteAccountRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Deleted':
      return Deleted.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'DeletedResponse':
      return DeletedResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DeletionAccepted':
      return DeletionAccepted.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DeletionAcceptedResponse':
      return DeletionAcceptedResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DietPlan':
      return DietPlan.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'DietPlanResponse':
      return DietPlanResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DietType':
    case 'EligibilityStatus':
    case 'Entitlement':
      return Entitlement.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Entitlements':
      return Entitlements.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'EntitlementsResponse':
      return EntitlementsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'EquipmentTag':
    case 'ErrorBody':
      return ErrorBody.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ErrorCode':
    case 'ErrorResponse':
      return ErrorResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExclusionTag':
    case 'ExerciseRef':
      return ExerciseRef.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ExperienceLevel':
    case 'ExportAccepted':
      return ExportAccepted.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExportAcceptedResponse':
      return ExportAcceptedResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ExportResponse':
      return ExportResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'FeatureUsage':
      return FeatureUsage.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'FieldError':
      return FieldError.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Food':
      return Food.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'FoodList':
      return FoodList.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'FoodListResponse':
      return FoodListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'GeneratePlanRequest':
      return GeneratePlanRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Goal':
      return Goal.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GoalInput':
      return GoalInput.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'GoalType':
    case 'HealthCheck':
      return HealthCheck.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'HealthResponse':
      return HealthResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Home':
      return Home.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'HomeResponse':
      return HomeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ImageMime':
    case 'Insight':
      return Insight.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'InsightSummary':
      return InsightSummary.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Insights':
      return Insights.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'InsightsResponse':
      return InsightsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'IntRange':
      return IntRange.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Job':
      return Job.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'JobAccepted':
      return JobAccepted.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'JobAcceptedResponse':
      return JobAcceptedResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'JobResponse':
      return JobResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'JobStatus':
    case 'JobType':
    case 'LimitationTag':
    case 'MacroTargets':
      return MacroTargets.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Me':
      return Me.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MeResponse':
      return MeResponse.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealAnalysis':
      return MealAnalysis.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealAnalysisResponse':
      return MealAnalysisResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealBalance':
      return MealBalance.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealBalanceComponent':
      return MealBalanceComponent.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealDiary':
      return MealDiary.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealDiaryResponse':
      return MealDiaryResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealLog':
      return MealLog.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealLogResponse':
      return MealLogResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealScan':
      return MealScan.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MealScanAccepted':
      return MealScanAccepted.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealScanAcceptedResponse':
      return MealScanAcceptedResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealScanResponse':
      return MealScanResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MealScanStatus':
    case 'MealSlot':
    case 'MediaAsset':
      return MediaAsset.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MediaAssetResponse':
      return MediaAssetResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MediaDownload':
      return MediaDownload.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MediaDownloadResponse':
      return MediaDownloadResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'MediaPurpose':
    case 'Meta':
      return Meta.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'NextMeal':
      return NextMeal.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'NextMealOption':
      return NextMealOption.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NextMealResponse':
      return NextMealResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'NumberRange':
      return NumberRange.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'NutrientTotals':
      return NutrientTotals.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Nutrients':
      return Nutrients.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'OilLevel':
    case 'Onboarding':
      return Onboarding.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'OnboardingComplete':
      return OnboardingComplete.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OnboardingCompleteRequest':
      return OnboardingCompleteRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OnboardingCompleteResponse':
      return OnboardingCompleteResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'OnboardingStatus':
    case 'OnboardingStep':
    case 'PatchMealLogRequest':
      return PatchMealLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PatchWorkoutLogRequest':
      return PatchWorkoutLogRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PhotoAngle':
    case 'PlanDay':
      return PlanDay.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PlanMeal':
      return PlanMeal.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PlanMealPreview':
      return PlanMealPreview.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PlanMealResponse':
      return PlanMealResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Planning':
      return Planning.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PlanningStatus':
    case 'PlateAction':
      return PlateAction.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PlateFixes':
      return PlateFixes.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PlateFixesResponse':
      return PlateFixesResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PortionRef':
      return PortionRef.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Preferences':
      return Preferences.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'PreferencesInput':
      return PreferencesInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PreferencesResponse':
      return PreferencesResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PreparationInput':
      return PreparationInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PrescribedExercise':
      return PrescribedExercise.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Profile':
      return Profile.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ProfilePatch':
      return ProfilePatch.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'Progress':
      return Progress.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ProgressPhoto':
      return ProgressPhoto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProgressPhotoList':
      return ProgressPhotoList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProgressPhotoListResponse':
      return ProgressPhotoListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProgressPhotoResponse':
      return ProgressPhotoResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProgressResponse':
      return ProgressResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ProjectedScenario':
      return ProjectedScenario.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'PutWorkoutSetsRequest':
      return PutWorkoutSetsRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Recipe':
      return Recipe.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RecipeIngredient':
      return RecipeIngredient.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RecipeRef':
      return RecipeRef.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RecipeResponse':
      return RecipeResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Recognition':
      return Recognition.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RecognitionItem':
      return RecognitionItem.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ReplacePlanMealRequest':
      return ReplacePlanMealRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RevenueCatWebhookRequest':
      return RevenueCatWebhookRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RevenueCatWebhookRequestEvent':
      return RevenueCatWebhookRequestEvent.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'RevisionRequest':
      return RevisionRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SafeError':
      return SafeError.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'ScreeningAnswer':
    case 'ScreeningAnswers':
      return ScreeningAnswers.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendCoachMessageRequest':
      return SendCoachMessageRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ServingConversion':
      return ServingConversion.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ServingInput':
      return ServingInput.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SetLogInput':
      return SetLogInput.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SourceRef':
      return SourceRef.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SubstitutionCandidate':
      return SubstitutionCandidate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Substitutions':
      return Substitutions.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SubstitutionsResponse':
      return SubstitutionsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SwapCandidate':
      return SwapCandidate.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SwapOptions':
      return SwapOptions.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'SwapOptionsResponse':
      return SwapOptionsResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TargetSnapshot':
      return TargetSnapshot.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TargetSnapshotResponse':
      return TargetSnapshotResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TrainingLocation':
    case 'TrainingPreferences':
      return TrainingPreferences.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TrainingPreferencesInput':
      return TrainingPreferencesInput.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TrainingPreferencesResponse':
      return TrainingPreferencesResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Uncertainty':
    case 'UnitSystem':
    case 'UploadSlot':
      return UploadSlot.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UploadSlotRequest':
      return UploadSlotRequest.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'UploadSlotResponse':
      return UploadSlotResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'Usage':
      return Usage.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UsageResponse':
      return UsageResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WebhookAck':
      return WebhookAck.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WebhookAckResponse':
      return WebhookAckResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeightLog':
      return WeightLog.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WeightLogList':
      return WeightLogList.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeightLogListResponse':
      return WeightLogListResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeightLogResponse':
      return WeightLogResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WeightPoint':
      return WeightPoint.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WorkoutLog':
      return WorkoutLog.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WorkoutLogResponse':
      return WorkoutLogResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutPlan':
      return WorkoutPlan.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'WorkoutPlanResponse':
      return WorkoutPlanResponse.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutSession':
      return WorkoutSession.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'WorkoutSessionPreview':
      return WorkoutSessionPreview.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}
