import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Timer Configuration Model
class TimerConfig {
  final String id;
  final String name;
  final int roundDuration; // in seconds
  final int totalRounds;
  final bool hasRestPeriod; // Nuevo campo
  final int restDuration; // Ya existe pero ahora se usará
  final int warningTime; // seconds before round ends to show warning
  final bool isCustom;

  const TimerConfig({
    required this.id,
    required this.name,
    required this.roundDuration,
    required this.totalRounds,
    required this.hasRestPeriod,
    required this.restDuration,
    required this.warningTime,
    this.isCustom = false,
  });

  TimerConfig copyWith({
    String? id,
    String? name,
    int? roundDuration,
    int? totalRounds,
    int? restDuration,
    int? warningTime,
    bool? isCustom,
    bool? hasRestPeriod,
  }) {
    return TimerConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      roundDuration: roundDuration ?? this.roundDuration,
      totalRounds: totalRounds ?? this.totalRounds,
      restDuration: restDuration ?? this.restDuration,
      warningTime: warningTime ?? this.warningTime,
      isCustom: isCustom ?? this.isCustom,
      hasRestPeriod: hasRestPeriod ?? this.hasRestPeriod,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roundDuration': roundDuration,
      'totalRounds': totalRounds,
      'restDuration': restDuration,
      'warningTime': warningTime,
      'isCustom': isCustom,
      'hasRestPeriod': hasRestPeriod,
    };
  }

  factory TimerConfig.fromJson(Map<String, dynamic> json) {
    return TimerConfig(
      id: json['id'],
      name: json['name'],
      roundDuration: json['roundDuration'],
      totalRounds: json['totalRounds'],
      restDuration: json['restDuration'],
      warningTime: json['warningTime'],
      isCustom: json['isCustom'] ?? false,
      hasRestPeriod: json['hasRestPeriod'] ?? true,
    );
  }
}

// Predefined timer configurations
final List<TimerConfig> defaultTimerConfigs = [
  TimerConfig(
    id: 'beginner',
    name: 'Principiante',
    roundDuration: 120, // 2 minutes
    totalRounds: 3,
    restDuration: 60,
    warningTime: 10,
    hasRestPeriod: true,
  ),
  TimerConfig(
    id: 'intermediate',
    name: 'Intermedio',
    roundDuration: 180, // 3 minutes
    totalRounds: 5,
    restDuration: 60,
    warningTime: 10,
    hasRestPeriod: true,
  ),
  TimerConfig(
    id: 'advanced',
    name: 'Avanzado',
    roundDuration: 180, // 3 minutes
    totalRounds: 7,
    restDuration: 45,
    warningTime: 15,
    hasRestPeriod: true,
  ),
  TimerConfig(
    id: 'professional',
    name: 'Profesional',
    roundDuration: 300, // 5 minutes
    totalRounds: 5,
    restDuration: 60,
    warningTime: 30,
    hasRestPeriod: true,
  ),
  TimerConfig(
    id: 'beginner_consecutive',
    name: 'Principiante Seguido',
    roundDuration: 120, // 2 minutes
    totalRounds: 3,
    restDuration: 0,
    warningTime: 10,
    hasRestPeriod: false,
  ),
  TimerConfig(
    id: 'intermediate_consecutive',
    name: 'Intermedio Seguido',
    roundDuration: 180, // 3 minutes
    totalRounds: 5,
    restDuration: 0,
    warningTime: 10,
    hasRestPeriod: false,
  ),
  TimerConfig(
    id: 'advanced_consecutive',
    name: 'Avanzado Seguido',
    roundDuration: 180, // 3 minutes
    totalRounds: 7,
    restDuration: 0,
    warningTime: 15,
    hasRestPeriod: false,
  ),
];

// Timer Configuration Notifier
class TimerConfigNotifier extends StateNotifier<TimerConfig> {
  TimerConfigNotifier() : super(defaultTimerConfigs[1]) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('timer_config');
      if (configJson != null) {
        final configMap = jsonDecode(configJson);
        state = TimerConfig.fromJson(configMap);
      }
    } catch (e) {
      print('Error loading timer config: $e');
    }
  }

  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('timer_config', jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving timer config: $e');
    }
  }

  void setConfig(TimerConfig config) {
    state = config;
    _saveConfig();
  }

  void updateConfig({
    String? name,
    int? roundDuration,
    int? totalRounds,
    int? restDuration,
    int? warningTime,
  }) {
    state = state.copyWith(
      name: name,
      roundDuration: roundDuration,
      totalRounds: totalRounds,
      restDuration: restDuration,
      warningTime: warningTime,
    );
    _saveConfig();
  }
}

// Custom Timer Configs Notifier
class CustomTimerConfigsNotifier extends StateNotifier<List<TimerConfig>> {
  CustomTimerConfigsNotifier() : super([]) {
    _loadCustomConfigs();
  }

  Future<void> _loadCustomConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = prefs.getStringList('custom_timer_configs') ?? [];
      final configs = configsJson
          .map((json) => TimerConfig.fromJson(jsonDecode(json)))
          .toList();
      state = configs;
    } catch (e) {
      print('Error loading custom timer configs: $e');
    }
  }

  Future<void> _saveCustomConfigs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsJson = state
          .map((config) => jsonEncode(config.toJson()))
          .toList();
      await prefs.setStringList('custom_timer_configs', configsJson);
    } catch (e) {
      print('Error saving custom timer configs: $e');
    }
  }

  void addCustomConfig(TimerConfig config) {
    state = [...state, config.copyWith(isCustom: true)];
    _saveCustomConfigs();
  }

  void updateCustomConfig(String id, TimerConfig updatedConfig) {
    state = state.map((config) {
      if (config.id == id) {
        return updatedConfig.copyWith(isCustom: true);
      }
      return config;
    }).toList();
    _saveCustomConfigs();
  }

  void removeCustomConfig(String id) {
    state = state.where((config) => config.id != id).toList();
    _saveCustomConfigs();
  }
}

// Timer Seconds Notifier (for current countdown)
class TimerSecondsNotifier extends StateNotifier<int> {
  TimerSecondsNotifier() : super(180); // default 3 minutes

  void decrement() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void reset(int seconds) {
    state = seconds;
  }

  void set(int seconds) {
    state = seconds;
  }
}

// Providers
final timerConfigProvider =
    StateNotifierProvider<TimerConfigNotifier, TimerConfig>((ref) {
      return TimerConfigNotifier();
    });

final customTimerConfigsProvider =
    StateNotifierProvider<CustomTimerConfigsNotifier, List<TimerConfig>>((ref) {
      return CustomTimerConfigsNotifier();
    });

final timerSecondsProvider = StateNotifierProvider<TimerSecondsNotifier, int>((
  ref,
) {
  return TimerSecondsNotifier();
});

// Combined provider for all timer configs (default + custom)
final allTimerConfigsProvider = Provider<List<TimerConfig>>((ref) {
  final customConfigs = ref.watch(customTimerConfigsProvider);
  return [...defaultTimerConfigs, ...customConfigs];
});
