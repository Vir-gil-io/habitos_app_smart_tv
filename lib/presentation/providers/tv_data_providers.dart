import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app_smart_tv/data/tv_habit.dart';
import 'package:habitos_app_smart_tv/data/tv_reminder.dart';
import 'package:habitos_app_smart_tv/data/tv_activity_summary.dart';
import 'package:habitos_app_smart_tv/data/tv_profile.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_session_provider.dart';

final tvHabitsProvider = FutureProvider.autoDispose<List<TvHabit>>((ref) {
  return ref.watch(tvRepositoryProvider).getHabits();
});

final tvProfileProvider = FutureProvider.autoDispose<TvProfile>((ref) {
  return ref.watch(tvRepositoryProvider).getProfile();
});

final tvRemindersProvider = FutureProvider.autoDispose<List<TvReminder>>((ref) {
  return ref.watch(tvRepositoryProvider).getAllReminders();
});

final tvActivityProvider = FutureProvider.autoDispose<TvActivitySummary>((ref) {
  return ref.watch(tvRepositoryProvider).getActivitySummary();
});