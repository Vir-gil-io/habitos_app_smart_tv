import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app_smart_tv/data/tv_habit.dart';
import 'package:habitos_app_smart_tv/data/tv_reminder.dart';
import 'package:habitos_app_smart_tv/data/tv_activity_summary.dart';
import 'package:habitos_app_smart_tv/data/tv_profile.dart';
import 'package:habitos_app_smart_tv/data/tv_session.dart';

class TvRepository {
  final SupabaseClient _client;
  final TvSession session;

  TvRepository(this._client, this.session);

  bool get _isPaired => session.type == TvSessionType.paired;
  String? get _uid => _client.auth.currentUser?.id;

  Future<List<TvHabit>> getHabits() async {
    try {
      if (_isPaired) {
        final rows = await _client.rpc('watch_get_habits', params: {
          'p_device_secret': session.deviceSecret,
        });
        return (rows as List)
            .map((r) => TvHabit.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      final uid = _uid;
      if (uid == null) return [];
      final rows = await _client
          .from('habits')
          .select()
          .eq('user_id', uid)
          .order('scheduled_time', ascending: true);
      return (rows as List)
          .map((r) => TvHabit.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<TvProfile> getProfile() async {
    try {
      if (_isPaired) {
        final rows = await _client.rpc('watch_get_profile', params: {
          'p_device_secret': session.deviceSecret,
        });
        final list = rows as List;
        if (list.isEmpty) return const TvProfile(name: 'Usuario');
        return TvProfile.fromJson(list.first as Map<String, dynamic>);
      }
      final uid = _uid;
      if (uid == null) return const TvProfile(name: 'Usuario');
      final row = await _client.from('profiles').select().eq('id', uid).single();
      return TvProfile.fromJson(row);
    } catch (_) {
      return const TvProfile(name: 'Usuario');
    }
  }

  Future<List<TvReminder>> getAllReminders() async {
    try {
      if (_isPaired) {
        final rows = await _client.rpc('watch_get_all_reminders', params: {
          'p_device_secret': session.deviceSecret,
        });
        return (rows as List)
            .map((r) => TvReminder.fromJson(r as Map<String, dynamic>))
            .toList();
      }
      final uid = _uid;
      if (uid == null) return [];
      final rows = await _client
          .from('reminders')
          .select()
          .eq('user_id', uid)
          .order('date', ascending: true);
      return (rows as List)
          .map((r) => TvReminder.fromJson(r as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<TvActivitySummary> getActivitySummary() async {
    try {
      List<Map<String, dynamic>> rows;

      if (_isPaired) {
        final result = await _client.rpc('watch_get_activity_week', params: {
          'p_device_secret': session.deviceSecret,
        });
        rows = (result as List).cast<Map<String, dynamic>>();
      } else {
        final uid = _uid;
        if (uid == null) return TvActivitySummary.empty();
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final mondayStr = _fmt(monday);
        final result = await _client
            .from('wearable_activity')
            .select()
            .eq('user_id', uid)
            .gte('date', mondayStr)
            .order('date', ascending: true);
        rows = (result as List).cast<Map<String, dynamic>>();
      }

      int weekSteps = 0;
      double weekCalories = 0, weekDistanceKm = 0;
      final daily = <TvDailyActivity>[];

      for (final row in rows) {
        final steps = row['steps'] as int? ?? 0;
        weekSteps += steps;
        weekCalories += (row['calories'] as num?)?.toDouble() ?? 0;
        weekDistanceKm += (row['distance_km'] as num?)?.toDouble() ?? 0;
        daily.add(TvDailyActivity(
          date: DateTime.parse(row['date'] as String),
          steps: steps,
        ));
      }

      return TvActivitySummary(
        weekSteps: weekSteps,
        weekCalories: weekCalories,
        weekDistanceKm: weekDistanceKm,
        dailySteps: daily,
      );
    } catch (_) {
      return TvActivitySummary.empty();
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}