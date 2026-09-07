import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:habitos_app_smart_tv/config/app_theme.dart';
import 'package:habitos_app_smart_tv/data/pairing_repository.dart';
import 'package:habitos_app_smart_tv/presentation/providers/tv_session_provider.dart';
import 'package:habitos_app_smart_tv/presentation/widgets/tv_focusable.dart';
import 'package:habitos_app_smart_tv/presentation/screens/tv_dashboard_screen.dart';

class TvPairingScreen extends ConsumerStatefulWidget {
  const TvPairingScreen({super.key});

  @override
  ConsumerState<TvPairingScreen> createState() => _TvPairingScreenState();
}

class _TvPairingScreenState extends ConsumerState<TvPairingScreen> {
  late final _repo = TvPairingRepository(ref.read(supabaseClientProvider));
  String? _deviceSecret;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final result = await _repo.requestPairing().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception('Tiempo de espera agotado — revisa la conexión a internet del emulador'),
      );
      setState(() => _deviceSecret = result.deviceSecret);
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    } catch (e) {
      setState(() => _error = 'Error: $e');
    }
  }

  Future<void> _poll() async {
    final secret = _deviceSecret;
    if (secret == null) return;
    try {
      final status = await _repo.checkStatus(secret);
      if (status.claimed) {
        _pollTimer?.cancel();
        await ref.read(tvSessionProvider.notifier).setPaired(secret);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const TvDashboardScreen()),
            (route) => false,
          );
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              const Text('HabitFlow',
                  style: TextStyle(color: AppTheme.primaryLight, fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: AppTheme.pending))
              else if (_deviceSecret == null)
                const CircularProgressIndicator(color: AppTheme.primary)
              else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: QrImageView(data: _deviceSecret!, size: 220, version: QrVersions.auto),
                ),
                const SizedBox(height: 16),
                const Text('Escanea con HabitFlow en tu teléfono',
                    style: TextStyle(color: AppTheme.textSecondaryDark, fontSize: 15)),
              ],
              const SizedBox(height: 32),
              TvFocusable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.divider),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Volver', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}