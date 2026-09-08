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
            child: SingleChildScrollView(
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
                  const SizedBox(height: 16),
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
              width: 160,
              height: 160,
              child: Stack(alignment: Alignment.center, children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent),
                  duration: const Duration(milliseconds: 700),
                  builder: (context, value, _) => SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 12,
                      backgroundColor: AppTheme.divider,
                      valueColor: const AlwaysStoppedAnimation(AppTheme.completed),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${(percent * 100).toInt()}%',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
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
  static const int dailyGoal = 5000; // meta diaria de referencia

  const _StepsCard({required this.activity});

  /// Completa los 7 días de la semana (lunes a domingo) con 0 pasos
  /// en los días sin registro, para que la gráfica siempre muestre
  /// la semana completa en vez de solo los días con datos.
  List<TvDailyActivity> _fullWeek() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final byDate = {
      for (final d in activity.dailySteps)
        DateTime(d.date.year, d.date.month, d.date.day): d.steps,
    };

    return List.generate(7, (i) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      return TvDailyActivity(date: day, steps: byDate[day] ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final week = _fullWeek();
    final stepsValues = week.map((d) => d.steps).toList();
    final maxRecorded = stepsValues.isEmpty
        ? 0
        : stepsValues.reduce((a, b) => a > b ? a : b);
    final chartMax = maxRecorded > dailyGoal ? maxRecorded : dailyGoal;

    final daysWithData = stepsValues.where((s) => s > 0).length;
    final average = daysWithData == 0
        ? 0
        : (stepsValues.reduce((a, b) => a + b) / daysWithData).round();
    final bestDayIndex = stepsValues.isEmpty
        ? -1
        : stepsValues.indexOf(maxRecorded);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PASOS DE LA SEMANA',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text('${activity.weekSteps} pasos totales',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
              if (activity.weekSteps > 0)
                Row(
                  children: [
                    _MiniMetric(label: 'Promedio/día', value: '$average'),
                    const SizedBox(width: 16),
                    _MiniMetric(
                      label: 'Mejor día',
                      value: bestDayIndex >= 0 ? _weekdayFullLabel(week[bestDayIndex].date.weekday) : '—',
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (activity.weekSteps == 0)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text('Sin datos del wearable esta semana',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: week.map((d) {
                  final heightFactor = chartMax == 0 ? 0.0 : d.steps / chartMax;
                  final now = DateTime.now();
                  final isToday = d.date.year == now.year &&
                      d.date.month == now.month &&
                      d.date.day == now.day;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        d.steps > 0 ? '${d.steps}' : '',
                        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Marca de referencia de la meta diaria
                          Container(
                            width: 28,
                            height: 130,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.divider,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: heightFactor.clamp(0.0, 1.0)),
                            duration: const Duration(milliseconds: 700),
                            builder: (context, value, _) => Container(
                              width: 24,
                              height: 128 * value,
                              margin: const EdgeInsets.only(bottom: 1),
                              decoration: BoxDecoration(
                                color: d.steps >= dailyGoal
                                    ? AppTheme.completed
                                    : (isToday ? AppTheme.primary : AppTheme.primaryLight),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _weekdayLabel(d.date.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday ? AppTheme.primary : null,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              _LegendDot(color: AppTheme.primaryLight, label: 'Bajo la meta'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.completed, label: 'Meta alcanzada (${dailyGoal ~/ 1000}k)'),
            ],
          ),
        ],
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return labels[weekday - 1];
  }

  String _weekdayFullLabel(int weekday) {
    const labels = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return labels[weekday - 1];
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  const _MiniMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
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