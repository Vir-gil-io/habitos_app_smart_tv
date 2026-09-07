import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habitos_app_smart_tv/data/tv_session.dart';
import 'package:habitos_app_smart_tv/data/tv_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

class TvSessionNotifier extends StateNotifier<TvSession> {
  TvSessionNotifier(this._client) : super(TvSession.none) {
    _restore();
  }

  final SupabaseClient _client;
  static const _prefKey = 'device_secret';

  Future<void> _restore() async {
    if (_client.auth.currentUser != null) {
      state = const TvSession(type: TvSessionType.authenticated);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final savedSecret = prefs.getString(_prefKey);
    state = savedSecret != null
        ? TvSession(type: TvSessionType.paired, deviceSecret: savedSecret)
        : TvSession.none;
  }

  Future<void> setPaired(String deviceSecret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, deviceSecret);
    state = TvSession(type: TvSessionType.paired, deviceSecret: deviceSecret);
  }

  void setAuthenticated() {
    state = const TvSession(type: TvSessionType.authenticated);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    if (_client.auth.currentUser != null) {
      await _client.auth.signOut();
    }
    state = TvSession.none;
  }
}

final tvSessionProvider =
    StateNotifierProvider<TvSessionNotifier, TvSession>((ref) {
  return TvSessionNotifier(ref.watch(supabaseClientProvider));
});

final tvRepositoryProvider = Provider<TvRepository>((ref) {
  return TvRepository(ref.watch(supabaseClientProvider), ref.watch(tvSessionProvider));
});