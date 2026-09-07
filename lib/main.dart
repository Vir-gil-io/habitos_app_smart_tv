import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habitos_app_smart_tv/config/app_theme.dart';
import 'package:habitos_app_smart_tv/config/supabase_constants.dart';
import 'package:habitos_app_smart_tv/data/tv_session.dart';
import 'package:habitos_app_smart_tv/presentation/providers/theme_provider.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_session_provider.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_start_screen.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConstants.url,
    publishableKey: SupabaseConstants.publishableKey,
  );

  runApp(const ProviderScope(child: HabitFlowTvApp()));
}

class HabitFlowTvApp extends ConsumerWidget {
  const HabitFlowTvApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final session = ref.watch(tvSessionProvider);

    return MaterialApp(
      title: 'HabitFlow TV',
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      darkTheme: AppTheme().getDarkTheme(),
      themeMode: themeMode,
      home: session.type == TvSessionType.none
          ? const TvStartScreen()
          : const TvDashboardScreen(),
    );
  }
}