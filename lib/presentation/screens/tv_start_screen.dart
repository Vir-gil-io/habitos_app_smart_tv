import 'package:flutter/material.dart';
import 'package:habitos_app_smart_tv/presentation/widgets/tv_focusable.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_pairing_screen.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_login_screen.dart';

class TvStartScreen extends StatelessWidget {
  const TvStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4A3AB5), Color(0xFF6C5CE7), Color(0xFF9D8DF1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                const Text('HabitFlow',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Tu rutina, en la pantalla grande',
                    style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TvFocusable(
                      autofocus: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TvPairingScreen()),
                      ),
                      child: const _StartCard(
                        icon: Icons.qr_code_2_rounded,
                        label: 'Vincular con\ncódigo QR',
                      ),
                    ),
                    const SizedBox(width: 32),
                    TvFocusable(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TvLoginScreen()),
                      ),
                      child: const _StartCard(
                        icon: Icons.login_rounded,
                        label: 'Iniciar sesión\nmanualmente',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StartCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }
}