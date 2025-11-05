// lib/services/background_timer_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muaythai_app/providers/timer_providers.dart';

class BackgroundTimerService {
  static const String _isRunningKey = 'timer_is_running';
  static const String _currentSecondsKey = 'timer_current_seconds';
  static const String _currentRoundKey = 'timer_current_round';
  static const String _roundDurationKey = 'timer_round_duration';
  static const String _totalRoundsKey = 'timer_total_rounds';
  static const String _backgroundStartTimeKey = 'timer_background_start';

  /// Guardar estado del timer cuando la app entra en background
  static Future<void> startBackgroundTimer({
    required int currentSeconds,
    required int currentRound,
    required int roundDuration,
    required int totalRounds,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isRunningKey, true);
    await prefs.setInt(_currentSecondsKey, currentSeconds);
    await prefs.setInt(_currentRoundKey, currentRound);
    await prefs.setInt(_roundDurationKey, roundDuration);
    await prefs.setInt(_totalRoundsKey, totalRounds);
    await prefs.setInt(
      _backgroundStartTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Parar background timer (cuando detienes o reseteas)
  static Future<void> stopBackgroundTimer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isRunningKey, false);
    await prefs.remove(_backgroundStartTimeKey);
  }

  /// Obtener estado guardado (útil para mostrar notificación o restaurar)
  static Future<Map<String, dynamic>?> getBackgroundTimerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(_isRunningKey) ?? false;
    if (!isRunning) return null;

    final backgroundStart = prefs.getInt(_backgroundStartTimeKey);
    final currentSeconds = prefs.getInt(_currentSecondsKey) ?? 0;
    final currentRound = prefs.getInt(_currentRoundKey) ?? 1;
    final roundDuration = prefs.getInt(_roundDurationKey) ?? 180;
    final totalRounds = prefs.getInt(_totalRoundsKey) ?? 3;

    final elapsedSeconds = backgroundStart != null
        ? ((DateTime.now().millisecondsSinceEpoch - backgroundStart) ~/ 1000)
        : 0;

    return {
      'currentSeconds': currentSeconds,
      'currentRound': currentRound,
      'roundDuration': roundDuration,
      'totalRounds': totalRounds,
      'elapsedSeconds': elapsedSeconds,
    };
  }

  /// Restaurar datos guardados en SharedPreferences a tus providers.
  /// Llamar desde el widget que reconstruye al reanudar (ej. en initState o onResume).
  static Future<void> restoreToProviders(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool(_isRunningKey) ?? false;

    final roundDuration = prefs.getInt(_roundDurationKey);
    final totalRounds = prefs.getInt(_totalRoundsKey);
    final currentSeconds = prefs.getInt(_currentSecondsKey);
    final currentRound = prefs.getInt(_currentRoundKey);

    if (roundDuration != null) {
      // Aseguramos que el timerConfigProvider tenga la duración guardada
      final currentTimer = ref.read(timerConfigProvider);
      if (currentTimer.roundDuration != roundDuration) {
        // Intentamos actualizar el config manteniendo el resto
        ref
            .read(timerConfigProvider.notifier)
            .updateConfig(
              roundDuration: roundDuration,
              totalRounds: totalRounds ?? currentTimer.totalRounds,
              warningTime: currentTimer.warningTime,
              name: currentTimer.name,
            );
      }
    }

    if (currentSeconds != null) {
      ref.read(timerSecondsProvider.notifier).set(currentSeconds);
    }

    if (currentRound != null) {
      // No hay provider para currentRound en tu código original; si lo necesitas crea uno.
      // Aquí suponemos que la pantalla mantiene su propio _currentRound — puedes sincronizarlo leyendo prefs desde la pantalla.
      // Para conveniencia, guardamos también currentRound en prefs y la pantalla puede leerla.
    }

    // Si estaba corriendo en background, el resto de lógica (re-crear Timer) la hace la pantalla al detectar isRunning:
    if (!isRunning) {
      // limpiar estado background
      await stopBackgroundTimer();
    }
  }
}
