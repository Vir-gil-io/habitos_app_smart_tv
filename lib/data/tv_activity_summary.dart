class TvDailyActivity {
  final DateTime date;
  final int steps;
  const TvDailyActivity({required this.date, required this.steps});
}

class TvActivitySummary {
  final int weekSteps;
  final double weekCalories;
  final double weekDistanceKm;
  final List<TvDailyActivity> dailySteps;

  const TvActivitySummary({
    required this.weekSteps,
    required this.weekCalories,
    required this.weekDistanceKm,
    required this.dailySteps,
  });

  factory TvActivitySummary.empty() => const TvActivitySummary(
        weekSteps: 0, weekCalories: 0, weekDistanceKm: 0, dailySteps: [],
      );
}