import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app_smart_tv/config/app_theme.dart';
import 'package:habitos_app_smart_tv/presentation/providers/theme_provider.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_data_providers.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_session_provider.dart';
import 'package:habitos_app_smart_tv/presentation/widgets/tv_focusable.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_start_screen.dart';

class TvSettingsScreen extends ConsumerWidget {
  const TvSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(tvProfileProvider);
    final currentTheme = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: profileAsync.when(
                data: (p) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CUENTA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const SizedBox(height: 16),
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppTheme.primary.withValues(alpha: 0.15),
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(p.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        p.heightCm != null && p.weightKg != null && p.ageYears != null
                            ? '${p.heightCm!.toStringAsFixed(0)} cm · ${p.weightKg!.toStringAsFixed(0)} kg · ${p.ageYears} años'
                            : 'Datos físicos no completados',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      TvFocusable(
                        onTap: () => _confirmLogout(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.pending.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.logout_rounded, color: AppTheme.pending, size: 18),
                            SizedBox(width: 8),
                            Text('Cerrar sesión en este dispositivo', style: TextStyle(color: AppTheme.pending)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('TEMA DE LA APP', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    _ThemeOption(
                      icon: Icons.brightness_auto_rounded,
                      label: 'Predeterminado del sistema',
                      selected: currentTheme == ThemeMode.system,
                      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                    ),
                    _ThemeOption(
                      icon: Icons.light_mode_rounded,
                      label: 'Claro',
                      selected: currentTheme == ThemeMode.light,
                      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                    ),
                    _ThemeOption(
                      icon: Icons.dark_mode_rounded,
                      label: 'Oscuro',
                      selected: currentTheme == ThemeMode.dark,
                      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Cerrar sesión en este Smart TV? Deberás vincular o iniciar sesión de nuevo.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.pending),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(tvSessionProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const TvStartScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(icon, color: selected ? AppTheme.primary : AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppTheme.primary : null,
                )),
          ),
          if (selected) const Icon(Icons.check_rounded, color: AppTheme.primary),
        ]),
      ),
    );
  }
}