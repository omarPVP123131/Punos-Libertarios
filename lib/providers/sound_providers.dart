import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SoundItem {
  final String id;
  final String name;
  final String fileName; // nombre del archivo (para assets)
  final String? path; // ruta local si el usuario seleccionó un archivo
  final bool isDefault;
  final bool isEnabled;
  final double volume;

  const SoundItem({
    required this.id,
    required this.name,
    required this.fileName,
    this.path,
    this.isDefault = false,
    this.isEnabled = true,
    this.volume = 1.0,
  });

  SoundItem copyWith({
    String? id,
    String? name,
    String? fileName,
    String? path,
    bool? isDefault,
    bool? isEnabled,
    double? volume,
  }) {
    return SoundItem(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      path: path ?? this.path,
      isDefault: isDefault ?? this.isDefault,
      isEnabled: isEnabled ?? this.isEnabled,
      volume: volume ?? this.volume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileName': fileName,
      'path': path,
      'isDefault': isDefault,
      'isEnabled': isEnabled,
      'volume': volume,
    };
  }

  factory SoundItem.fromJson(Map<String, dynamic> json) {
    return SoundItem(
      id: json['id'],
      name: json['name'],
      fileName: json['fileName'] ?? '',
      path: json['path'],
      isDefault: json['isDefault'] ?? false,
      isEnabled: json['isEnabled'] ?? true,
      volume: (json['volume'] != null)
          ? (json['volume'] as num).toDouble()
          : 1.0,
    );
  }
}

// Sound Collection Model
class SoundCollection {
  final String type; // 'sarama', 'warning', 'bell'
  final List<SoundItem> sounds;
  final String selectedSoundId;

  const SoundCollection({
    required this.type,
    required this.sounds,
    required this.selectedSoundId,
  });

  SoundCollection copyWith({
    String? type,
    List<SoundItem>? sounds,
    String? selectedSoundId,
  }) {
    return SoundCollection(
      type: type ?? this.type,
      sounds: sounds ?? this.sounds,
      selectedSoundId: selectedSoundId ?? this.selectedSoundId,
    );
  }

  SoundItem? get selectedSound {
    try {
      return sounds.firstWhere((sound) => sound.id == selectedSoundId);
    } catch (e) {
      return sounds.isNotEmpty ? sounds.first : null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sounds': sounds.map((s) => s.toJson()).toList(),
      'selectedSoundId': selectedSoundId,
    };
  }

  factory SoundCollection.fromJson(Map<String, dynamic> json) {
    return SoundCollection(
      type: json['type'],
      sounds: (json['sounds'] as List)
          .map((s) => SoundItem.fromJson(s))
          .toList(),
      selectedSoundId: json['selectedSoundId'],
    );
  }
}

// Sound Configuration Model
class SoundConfig {
  final bool saramaEnabled;
  final bool warningEnabled;
  final bool bellEnabled;
  final bool vibrationEnabled;
  final double masterVolume;
  final Map<String, SoundCollection> soundCollections;

  const SoundConfig({
    this.saramaEnabled = true,
    this.warningEnabled = true,
    this.bellEnabled = true,
    this.vibrationEnabled = false,
    this.masterVolume = 0.8,
    required this.soundCollections,
  });

  SoundConfig copyWith({
    bool? saramaEnabled,
    bool? warningEnabled,
    bool? bellEnabled,
    bool? vibrationEnabled,
    double? masterVolume,
    Map<String, SoundCollection>? soundCollections,
  }) {
    return SoundConfig(
      saramaEnabled: saramaEnabled ?? this.saramaEnabled,
      warningEnabled: warningEnabled ?? this.warningEnabled,
      bellEnabled: bellEnabled ?? this.bellEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      masterVolume: masterVolume ?? this.masterVolume,
      soundCollections: soundCollections ?? this.soundCollections,
    );
  }

  SoundItem? getSelectedSound(String type) {
    return soundCollections[type]?.selectedSound;
  }

  Map<String, dynamic> toJson() {
    return {
      'saramaEnabled': saramaEnabled,
      'warningEnabled': warningEnabled,
      'bellEnabled': bellEnabled,
      'vibrationEnabled': vibrationEnabled,
      'masterVolume': masterVolume,
      'soundCollections': soundCollections.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  factory SoundConfig.fromJson(Map<String, dynamic> json) {
    final collectionsMap = <String, SoundCollection>{};
    if (json['soundCollections'] != null) {
      (json['soundCollections'] as Map<String, dynamic>).forEach((key, value) {
        collectionsMap[key] = SoundCollection.fromJson(value);
      });
    }

    return SoundConfig(
      saramaEnabled: json['saramaEnabled'] ?? true,
      warningEnabled: json['warningEnabled'] ?? true,
      bellEnabled: json['bellEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? false,
      masterVolume: json['masterVolume']?.toDouble() ?? 0.8,
      soundCollections: collectionsMap,
    );
  }
}

// Default Sound Collections
final Map<String, SoundCollection> defaultSoundCollections = {
  'sarama': SoundCollection(
    type: 'sarama',
    selectedSoundId: 'sarama_classic',
    sounds: [
      SoundItem(
        id: 'sarama_classic',
        name: 'Sarama Antigua',
        fileName: 'Muay Thai - Wai Kru Ram Muay.mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'sarama_traditional',
        name: 'Sarama Tradicional',
        fileName: 'Muay Thai Music - Wai Khru Ram Muay.mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'sarama_modern',
        name: 'Sarama IFMA',
        fileName: '[IFMA] Muaythai Sarama.mp3',
        isDefault: true,
      ),
    ],
  ),
  'warning': SoundCollection(
    type: 'warning',
    selectedSoundId: 'warning_beep',
    sounds: [
      SoundItem(
        id: 'warning_beep',
        name: 'Aplausos de Advertencia',
        fileName: 'EFECTOS DE SONIDO _ aplausos de poca gente.mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'warning_bell',
        name: 'Aplausos de Advertencia',
        fileName:
            'Sonido De Aplausos[Ovación][Aplauso Fuerte][Applause][Aplaudir Duro][Palmadas][Irritar].mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'warning_whistle',
        name: 'Silbato',
        fileName: '🧿efecto de sonido SILBATO🧿 [whistle sound effect].mp3',
        isDefault: true,
      ),
    ],
  ),
  'bell': SoundCollection(
    type: 'bell',
    selectedSoundId: 'bell_classic',
    sounds: [
      SoundItem(
        id: 'bell_classic',
        name: 'Campana Clásica',
        fileName: 'campana de Box _ Efecto de sonido.mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'bell_boxing',
        name: 'Campana de Boxeo',
        fileName: 'Campana de Box - Efecto de Sonido.mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'bell_modern',
        name: 'Campana De Boxeo Moderna',
        fileName: 'Boxing Bell Sound Effect.mp3',
        isDefault: true,
      ),
      SoundItem(
        id: 'bell_gong',
        name: 'Gong Tailandés',
        fileName: 'Gong Sound Effect.mp3',
        isDefault: true,
      ),
    ],
  ),
};

// Sound Configuration Notifier
class SoundConfigNotifier extends StateNotifier<SoundConfig> {
  SoundConfigNotifier()
    : super(SoundConfig(soundCollections: defaultSoundCollections)) {
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('sound_config');
      if (configJson != null) {
        final configMap = jsonDecode(configJson);

        // Merge with default collections to ensure we have all default sounds
        final loadedConfig = SoundConfig.fromJson(configMap);
        final mergedCollections = <String, SoundCollection>{};

        // Start with default collections
        defaultSoundCollections.forEach((key, defaultCollection) {
          if (loadedConfig.soundCollections.containsKey(key)) {
            final loadedCollection = loadedConfig.soundCollections[key]!;
            // Merge default sounds with custom sounds
            final allSounds = <SoundItem>[];

            // Add all default sounds
            allSounds.addAll(defaultCollection.sounds);

            // Add custom sounds (non-default)
            for (final sound in loadedCollection.sounds) {
              if (!sound.isDefault) {
                allSounds.add(sound);
              }
            }

            mergedCollections[key] = SoundCollection(
              type: key,
              sounds: allSounds,
              selectedSoundId: loadedCollection.selectedSoundId,
            );
          } else {
            mergedCollections[key] = defaultCollection;
          }
        });

        state = loadedConfig.copyWith(soundCollections: mergedCollections);
      }
    } catch (e) {
      print('Error loading sound config: $e');
    }
  }

  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sound_config', jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving sound config: $e');
    }
  }

  // Toggle sound types
  void toggleSarama(bool enabled) {
    state = state.copyWith(saramaEnabled: enabled);
    _saveConfig();
  }

  void toggleWarning(bool enabled) {
    state = state.copyWith(warningEnabled: enabled);
    _saveConfig();
  }

  void toggleBell(bool enabled) {
    state = state.copyWith(bellEnabled: enabled);
    _saveConfig();
  }

  void toggleVibration(bool enabled) {
    state = state.copyWith(vibrationEnabled: enabled);
    _saveConfig();
  }

  // Volume control
  void setMasterVolume(double volume) {
    state = state.copyWith(masterVolume: volume);
    _saveConfig();
  }

  // Sound selection
  void selectSound(String type, String soundId) {
    final collections = Map<String, SoundCollection>.from(
      state.soundCollections,
    );
    if (collections.containsKey(type)) {
      collections[type] = collections[type]!.copyWith(selectedSoundId: soundId);
      state = state.copyWith(soundCollections: collections);
      _saveConfig();
    }
  }

  // Custom sound management
  void addCustomSound(String type, SoundItem sound) {
    final collections = Map<String, SoundCollection>.from(
      state.soundCollections,
    );
    if (collections.containsKey(type)) {
      final currentSounds = List<SoundItem>.from(collections[type]!.sounds);
      currentSounds.add(sound.copyWith(isDefault: false));

      collections[type] = collections[type]!.copyWith(sounds: currentSounds);
      state = state.copyWith(soundCollections: collections);
      _saveConfig();
    }
  }

  void removeCustomSound(String type, String soundId) {
    final collections = Map<String, SoundCollection>.from(
      state.soundCollections,
    );
    if (collections.containsKey(type)) {
      final currentSounds = collections[type]!.sounds
          .where((sound) => !(sound.id == soundId && !sound.isDefault))
          .toList();

      // If we're removing the selected sound, select the first available
      String selectedId = collections[type]!.selectedSoundId;
      if (selectedId == soundId && currentSounds.isNotEmpty) {
        selectedId = currentSounds.first.id;
      }

      collections[type] = SoundCollection(
        type: type,
        sounds: currentSounds,
        selectedSoundId: selectedId,
      );

      state = state.copyWith(soundCollections: collections);
      _saveConfig();
    }
  }

  void updateSoundVolume(String type, String soundId, double volume) {
    final collections = Map<String, SoundCollection>.from(
      state.soundCollections,
    );
    if (collections.containsKey(type)) {
      final updatedSounds = collections[type]!.sounds.map((sound) {
        if (sound.id == soundId) {
          return sound.copyWith(volume: volume);
        }
        return sound;
      }).toList();

      collections[type] = collections[type]!.copyWith(sounds: updatedSounds);
      state = state.copyWith(soundCollections: collections);
      _saveConfig();
    }
  }

  void toggleSoundEnabled(String type, String soundId, bool enabled) {
    final collections = Map<String, SoundCollection>.from(
      state.soundCollections,
    );
    if (collections.containsKey(type)) {
      final updatedSounds = collections[type]!.sounds.map((sound) {
        if (sound.id == soundId) {
          return sound.copyWith(isEnabled: enabled);
        }
        return sound;
      }).toList();

      collections[type] = collections[type]!.copyWith(sounds: updatedSounds);
      state = state.copyWith(soundCollections: collections);
      _saveConfig();
    }
  }
}

// Provider
final soundConfigProvider =
    StateNotifierProvider<SoundConfigNotifier, SoundConfig>((ref) {
      return SoundConfigNotifier();
    });
