class TvProfile {
  final String name;
  final double? heightCm;
  final double? weightKg;
  final int? ageYears;
  final int globalStreakDays;

  const TvProfile({
    required this.name,
    this.heightCm,
    this.weightKg,
    this.ageYears,
    this.globalStreakDays = 0,
  });

  factory TvProfile.fromJson(Map<String, dynamic> json) => TvProfile(
        name: json['name'] as String? ?? 'Usuario',
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        ageYears: json['age_years'] as int?,
        globalStreakDays: json['global_streak_days'] as int? ?? 0,
      );
}