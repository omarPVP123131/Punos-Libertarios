// lib/services/preferences_manager.dart
// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muaythai_app/providers/timer_providers.dart';
import 'package:muaythai_app/providers/sound_providers.dart';

final preferencesManagerProvider = Provider<PreferencesManager>(
  (ref) => PreferencesManager(ref),
);

class PreferencesManager {
  final Ref ref;
  PreferencesManager(this.ref);

  static const String _timerConfigKey = 'timer_config';
  static const String _soundConfigKey = 'sound_config';
  static const String _firstLaunchKey = 'first_launch';

  // Guarda TimerConfig actual (usa el provider)
  Future<void> saveTimerConfigFromProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final timerConfig = ref.read(timerConfigProvider);
    await prefs.setString(_timerConfigKey, jsonEncode(timerConfig.toJson()));
  }

  // Cargar TimerConfig desde prefs y aplicarlo al provider
  Future<void> loadTimerConfigToProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_timerConfigKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final config = TimerConfig.fromJson(map);
        ref.read(timerConfigProvider.notifier).setConfig(config);
        // además reiniciar timerSeconds con la duración cargada
        ref.read(timerSecondsProvider.notifier).reset(config.roundDuration);
      } catch (e) {
        print('Error parsing timer config: $e');
      }
    }
  }

  // Guarda SoundConfig actual (usa el provider)
  Future<void> saveSoundConfigFromProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final soundConfig = ref.read(soundConfigProvider);
    await prefs.setString(_soundConfigKey, jsonEncode(soundConfig.toJson()));
  }

  // Carga SoundConfig desde prefs y lo aplica (fusionando con defaults)
  Future<void> loadSoundConfigToProviders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_soundConfigKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final loaded = SoundConfig.fromJson(map);

        // Merge con defaultSoundCollections (tu SoundConfigNotifier ya hace merge al cargar)
        // Aquí simplemente reemplazamos el state del notifier
        ref.read(soundConfigProvider.notifier).state = ref
            .read(soundConfigProvider.notifier)
            .state
            .copyWith(
              saramaEnabled: loaded.saramaEnabled,
              warningEnabled: loaded.warningEnabled,
              bellEnabled: loaded.bellEnabled,
              vibrationEnabled: loaded.vibrationEnabled,
              masterVolume: loaded.masterVolume,
              soundCollections: loaded.soundCollections,
            );

        // Guardar para mantener consistencia
        await saveSoundConfigFromProviders();
      } catch (e) {
        print('Error parsing sound config: $e');
      }
    }
  }

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(_firstLaunchKey) ?? true;
    if (isFirst) {
      await prefs.setBool(_firstLaunchKey, false);
    }
    return isFirst;
  }
}
