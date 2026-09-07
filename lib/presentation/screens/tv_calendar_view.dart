import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app_smart_tv/config/app_theme.dart';
import 'package:habitos_app_smart_tv/data/tv_reminder.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_data_providers.dart';
import 'package:habitos_app_smart_tv/presentation/widgets/tv_focusable.dart';

class TvCalendarView extends ConsumerStatefulWidget {
  const TvCalendarView({super.key});

  @override
  ConsumerState<TvCalendarView> createState() => _TvCalendarViewState();
}

class _TvCalendarViewState extends ConsumerState<TvCalendarView> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;

  static const _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  List<DateTime?> _buildDays() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final offset = (first.weekday - 1) % 7;
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final cells = <DateTime?>[];
    for (int i = 0; i < offset; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  String _monthLabel() {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  String _fullDateLabel(DateTime d) {
    const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    const months = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${days[d.weekday - 1]} ${d.day} de ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(tvRemindersProvider);

    return remindersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('No se pudieron cargar los recordatorios')),
      data: (reminders) {
        final days = _buildDays();
        final markedDays = reminders
            .where((r) => r.date.year == _focusedMonth.year && r.date.month == _focusedMonth.month)
            .map((r) => r.date.day)
            .toSet();

        final selectedReminders = _selectedDay == null
            ? <TvReminder>[]
            : reminders
                .where((r) =>
                    r.date.year == _selectedDay!.year &&
                    r.date.month == _selectedDay!.month &&
                    r.date.day == _selectedDay!.day)
                .toList();

        return Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TvFocusable(
                            onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
                            child: const Icon(Icons.chevron_left_rounded, size: 32),
                          ),
                          Text(_monthLabel(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          TvFocusable(
                            onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
                            child: const Icon(Icons.chevron_right_rounded, size: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: _weekDays
                            .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)))))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                          itemCount: days.length,
                          itemBuilder: (context, i) {
                            final day = days[i];
                            if (day == null) return const SizedBox.shrink();
                            final now = DateTime.now();
                            final isToday = day.year == now.year && day.month == now.month && day.day == now.day;
                            final isSelected = _selectedDay != null &&
                                day.year == _selectedDay!.year &&
                                day.month == _selectedDay!.month &&
                                day.day == _selectedDay!.day;
                            final hasReminder = markedDays.contains(day.day);

                            return TvFocusable(
                              onTap: () => setState(() => _selectedDay = day),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : isToday
                                          ? AppTheme.primary.withValues(alpha: 0.15)
                                          : Colors.transparent,
                                  shape: BoxShape.circle,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('${day.day}',
                                        style: TextStyle(
                                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                                          color: isSelected ? Colors.white : (isToday ? AppTheme.primary : null),
                                        )),
                                    if (hasReminder)
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        width: 5,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected ? Colors.white : AppTheme.streak,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedDay == null ? 'Selecciona un día' : _fullDateLabel(_selectedDay!),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: selectedReminders.isEmpty
                            ? const Center(child: Text('Sin recordatorios para este día', style: TextStyle(color: AppTheme.textSecondary)))
                            : ListView.builder(
                                itemCount: selectedReminders.length,
                                itemBuilder: (context, i) {
                                  final r = selectedReminders[i];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (r.timeOfDay != null)
                                          Text(r.timeOfDay!, style: const TextStyle(color: AppTheme.primary)),
                                        if (r.description != null && r.description!.isNotEmpty)
                                          Text(r.description!, style: Theme.of(context).textTheme.bodyMedium),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}