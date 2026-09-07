import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app_smart_tv/config/app_theme.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_data_providers.dart';
import 'package:habitos_app_smart_tv/presentation/widgets/tv_focusable.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_calendar_view.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_settings_screen.dart';
import 'package:habitos_app_smart_tv/data/tv_activity_summary.dart';

class TvDashboardScreen extends ConsumerStatefulWidget {
  const TvDashboardScreen({super.key});

  @override
  ConsumerState<TvDashboardScreen> createState() => _TvDashboardScreenState();
}

class _TvDashboardScreenState extends ConsumerState<TvDashboardScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _TvTopBar(
            currentTab: _tab,
            onTabChanged: (t) => setState(() => _tab = t),
            onSettings: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TvSettingsScreen()),
            ),
          ),
          Expanded(
            child: _tab == 0 ? const _TvDashboardBody() : const TvCalendarView(),
          ),
        ],
      ),
    );
  }
}

class _TvTopBar extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onSettings;

  const _TvTopBar({required this.currentTab, required this.onTabChanged, required this.onSettings});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: AppTheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          const Text('HabitFlow', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          TvFocusable(
            onTap: () => onTabChanged(0),
            child: _TabLabel(text: 'DASHBOARD', selected: currentTab == 0),
          ),
          const SizedBox(width: 24),
          TvFocusable(
            onTap: () => onTabChanged(1),
            child: _TabLabel(text: 'CALENDARIO', selected: currentTab == 1),
          ),
          const Spacer(),
          TvFocusable(
            onTap: onSettings,
            child: const Icon(Icons.settings_rounded, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String text;
  final bool selected;
  const _TabLabel({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: selected ? 1 : 0.6),
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 1,
      ),
    );
  }
}

class _TvDashboardBody extends ConsumerWidget {
  const _TvDashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(tvHabitsProvider);
    final profileAsync = ref.watch(tvProfileProvider);
    final activityAsync = ref.watch(tvActivityProvider);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileAsync.when(
                  data: (p) => _StatCard(
                    icon: '🔥',
                    title: 'RACHA',
                    value: '${p.globalStreakDays}',
                    subtitle: 'Días consecutivos',
                  ),
                  loading: () => const _LoadingCard(),
                  error: (_, __) =>
                      const _StatCard(icon: '🔥', title: 'RACHA', value: '—', subtitle: ''),
                ),
                const SizedBox(height: 24),
                habitsAsync.when(
                  data: (habits) {
                    final completed = habits.where((h) => h.isCompleted).length;
                    final total = habits.length;
                    final pct = total == 0 ? 0.0 : completed / total;
                    return _GaugeCard(
                      title: 'ACTIVIDADES COMPLETADAS',
                      percent: pct,
                      label: '$completed de $total hábitos',
                    );
                  },
                  loading: () => const _LoadingCard(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            flex: 3,
            child: activityAsync.when(
              data: (activity) => _StepsCard(activity: activity),
              loading: () => const _LoadingCard(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String title;
  final String value;
  final String subtitle;
  const _StatCard({required this.icon, required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.streak)),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String title;
  final double percent;
  final String label;
  const _GaugeCard({required this.title, required this.percent, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(alignment: Alignment.center, children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: AppTheme.divider,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.completed),
                  ),
                ),
                Text('${(percent * 100).toInt()}%', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _StepsCard extends StatelessWidget {
  final TvActivitySummary activity;
  const _StepsCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final maxSteps = activity.dailySteps.isEmpty
        ? 1
        : activity.dailySteps.map((d) => d.steps).reduce((a, b) => a > b ? a : b);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PASOS DE LA SEMANA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('${activity.weekSteps} pasos totales', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
          if (activity.dailySteps.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Sin datos del wearable esta semana', style: TextStyle(color: AppTheme.textSecondary)),
            )
          else
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: activity.dailySteps.map((d) {
                  final heightFactor = maxSteps == 0 ? 0.0 : d.steps / maxSteps;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('${d.steps}', style: const TextStyle(fontSize: 10)),
                      const SizedBox(height: 4),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: heightFactor),
                        duration: const Duration(milliseconds: 700),
                        builder: (context, value, _) => Container(
                          width: 24,
                          height: 90 * value,
                          decoration: BoxDecoration(color: AppTheme.completed, borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(_weekdayLabel(d.date.weekday), style: const TextStyle(fontSize: 10)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return labels[weekday - 1];
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
}