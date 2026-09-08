import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habitos_app_smart_tv/config/app_theme.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_session_provider.dart';
import 'package:habitos_app_smart_tv/presentation/widgets/tv_focusable.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_dashboard_screen.dart';
import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class TvLoginScreen extends ConsumerStatefulWidget {
  const TvLoginScreen({super.key});

  @override
  ConsumerState<TvLoginScreen> createState() => _TvLoginScreenState();
}

class _TvLoginScreenState extends ConsumerState<TvLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(supabaseClientProvider).auth.signInWithPassword(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ).timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw const SocketException('timeout'),
          );
      ref.read(tvSessionProvider.notifier).setAuthenticated();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TvDashboardScreen()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      // Error real de credenciales, devuelto por Supabase
      setState(() => _error = _translateAuthError(e.message));
    } on SocketException {
      // Sin conexión a internet o el request no llegó al servidor
      setState(() => _error = 'Sin conexión a internet. Verifica tu red e intenta de nuevo.');
    } on TimeoutException {
      setState(() => _error = 'La conexión tardó demasiado. Verifica tu internet e intenta de nuevo.');
    } catch (_) {
      // Cualquier otro error (DNS, certificado, etc.) — tampoco es
      // culpa de las credenciales, así que no se debe decir eso.
      setState(() => _error = 'No se pudo conectar al servidor. Verifica tu conexión.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translateAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Debes confirmar tu correo electrónico antes de iniciar sesión.';
    }
    return 'Ocurrió un error al iniciar sesión. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                const Text('Iniciar sesión',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailCtrl,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: AppTheme.textSecondaryDark),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.dividerDark)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(color: AppTheme.textSecondaryDark),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.dividerDark)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.primary)),
                  ),
                ),
                const SizedBox(height: 16),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: AppTheme.pending)),
                  ),
                TvFocusable(
                  onTap: _loading ? null : _login,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Entrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}