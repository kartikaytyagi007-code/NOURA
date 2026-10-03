import 'package:noura_api_client/noura_api_client.dart';

/// User-facing labels for the closed value sets. The tag vocabularies (allergies, exclusions,
/// cuisines, equipment, limitations) are PROVISIONAL (docs/decisions.md D-020): they are not a
/// medical allergy list and are revised together with the food and exercise catalogs.

String activityLabel(ActivityBand v) => switch (v) {
  ActivityBand.sedentary => 'Sedentary',
  ActivityBand.light => 'Lightly active',
  ActivityBand.moderate => 'Moderately active',
  ActivityBand.active => 'Active',
  ActivityBand.veryActive => 'Very active',
};

String activityHint(ActivityBand v) => switch (v) {
  ActivityBand.sedentary => 'Mostly sitting, little exercise',
  ActivityBand.light => 'Light exercise 1 to 3 days a week',
  ActivityBand.moderate => 'Moderate exercise 3 to 5 days a week',
  ActivityBand.active => 'Hard exercise 6 to 7 days a week',
  ActivityBand.veryActive => 'Very hard exercise or a physical job',
};

String goalLabel(GoalType v) => switch (v) {
  GoalType.loseFat => 'Lose fat',
  GoalType.maintain => 'Maintain weight',
  GoalType.gainMuscle => 'Build muscle',
  GoalType.generalHealth => 'General health',
};

String dietLabel(DietType v) => switch (v) {
  DietType.vegetarian => 'Vegetarian',
  DietType.eggatarian => 'Eggetarian',
  DietType.vegan => 'Vegan',
  DietType.nonVegetarian => 'Non-vegetarian',
};

String budgetLabel(BudgetBand v) => switch (v) {
  BudgetBand.low => 'Low',
  BudgetBand.medium => 'Medium',
  BudgetBand.high => 'High',
};

String cookingLabel(CookingTime v) => switch (v) {
  CookingTime.minimal => 'Minimal',
  CookingTime.moderate => 'Moderate',
  CookingTime.flexible => 'Flexible',
};

String experienceLabel(ExperienceLevel v) => switch (v) {
  ExperienceLevel.beginner => 'Beginner',
  ExperienceLevel.intermediate => 'Intermediate',
  ExperienceLevel.advanced => 'Advanced',
};

String locationLabel(TrainingLocation v) => switch (v) {
  TrainingLocation.home => 'At home',
  TrainingLocation.gym => 'At a gym',
  TrainingLocation.both => 'Both',
};

String allergyLabel(AllergyTag v) => switch (v) {
  AllergyTag.gluten => 'Gluten',
  AllergyTag.crustacean => 'Crustaceans',
  AllergyTag.milk => 'Milk',
  AllergyTag.egg => 'Egg',
  AllergyTag.fish => 'Fish',
  AllergyTag.peanut => 'Peanut',
  AllergyTag.treeNut => 'Tree nuts',
  AllergyTag.soy => 'Soy',
  AllergyTag.sesame => 'Sesame',
};

String exclusionLabel(ExclusionTag v) => switch (v) {
  ExclusionTag.beef => 'Beef',
  ExclusionTag.pork => 'Pork',
  ExclusionTag.mutton => 'Mutton',
  ExclusionTag.chicken => 'Chicken',
  ExclusionTag.seafood => 'Seafood',
  ExclusionTag.onionGarlic => 'Onion and garlic',
  ExclusionTag.rootVegetables => 'Root vegetables',
  ExclusionTag.mushroom => 'Mushroom',
  ExclusionTag.alcohol => 'Alcohol',
};

String cuisineLabel(CuisineTag v) => switch (v) {
  CuisineTag.northIndian => 'North Indian',
  CuisineTag.southIndian => 'South Indian',
  CuisineTag.eastIndian => 'East Indian',
  CuisineTag.westIndian => 'West Indian',
  CuisineTag.indoChinese => 'Indo-Chinese',
  CuisineTag.continental => 'Continental',
};

String equipmentLabel(EquipmentTag v) => switch (v) {
  EquipmentTag.bodyweight => 'Bodyweight only',
  EquipmentTag.dumbbells => 'Dumbbells',
  EquipmentTag.barbell => 'Barbell',
  EquipmentTag.kettlebell => 'Kettlebell',
  EquipmentTag.resistanceBands => 'Resistance bands',
  EquipmentTag.bench => 'Bench',
  EquipmentTag.pullUpBar => 'Pull-up bar',
  EquipmentTag.machines => 'Gym machines',
};

String limitationLabel(LimitationTag v) => switch (v) {
  LimitationTag.knee => 'Knee',
  LimitationTag.lowerBack => 'Lower back',
  LimitationTag.shoulder => 'Shoulder',
  LimitationTag.neck => 'Neck',
  LimitationTag.wristElbow => 'Wrist or elbow',
  LimitationTag.hip => 'Hip',
  LimitationTag.ankleFoot => 'Ankle or foot',
};

const weekdayShortNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Tolerant parsing of response tag strings: values this build does not know are dropped, never an
/// error, so a newer server vocabulary cannot break an older app.
Set<T> knownTags<T>(Iterable<String> values, Iterable<T> all, String Function(T) wire) {
  final byWire = {for (final t in all) wire(t): t};
  return {
    for (final v in values)
      if (byWire[v] != null) byWire[v] as T,
  };
}
