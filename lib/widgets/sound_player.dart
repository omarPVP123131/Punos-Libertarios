// lib/providers/sound_player.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muaythai_app/providers/sound_providers.dart'; // ajusta ruta si hace falta

final soundPlayerProvider = Provider<SoundPlayer>((ref) {
  final player = SoundPlayer(ref);
  ref.onDispose(() => player.dispose());
  return player;
});

// Id del sonido actualmente “controlado” por el player principal (sarama, por ejemplo)
final currentlyPlayingSoundProvider = StateProvider<String?>((ref) => null);
// Indica si el main player está reproduciendo (true) o está en pausa (false)
final isMainPlayerPlayingProvider = StateProvider<bool>((ref) => false);

class SoundPlayer {
  final Ref ref;
  final AudioPlayer _main =
      AudioPlayer(); // para sarama u otros sonidos que puedan loop
  final AudioPlayer _effect = AudioPlayer(); // para warning/bell (one-shot)

  SoundPlayer(this.ref) {
    // Aseguramos que _effect no haga loop por defecto
    _effect.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> _setVolumeForPlayer(AudioPlayer p, double vol) async {
    try {
      await p.setVolume(vol);
    } catch (e) {
      // algunos backends ignoran setVolume antes de play, no crítico
      print('setVolume error: $e');
    }
  }

  /// Reproduce un sonido.
  /// - [loop] -> si true usa _main con ReleaseMode.loop
  /// - [isEffect] -> si true usa _effect (no modifica provider de currentlyPlaying)
  Future<void> playSound(
    SoundItem sound, {
    bool loop = false,
    bool isEffect = false,
  }) async {
    if (!sound.isEnabled) return;

    final soundConfig = ref.read(soundConfigProvider);
    final master = soundConfig.masterVolume;
    final vol = (sound.volume * master).clamp(0.0, 1.0);

    final player = isEffect ? _effect : _main;

    try {
      // stop/resume logic: always stop effect player before playing new effect
      if (isEffect) {
        await _effect.stop();
        await _setVolumeForPlayer(_effect, vol);
        if (sound.path != null && sound.path!.isNotEmpty) {
          await _effect.play(DeviceFileSource(sound.path!));
        } else {
          await _effect.play(AssetSource('sounds/${sound.fileName}'));
        }
        return;
      }

      // MAIN player behavior
      // Si ya hay otro sonido principal reproduciéndose, lo detenemos
      final currentlyPlayingId = ref.read(currentlyPlayingSoundProvider);
      if (currentlyPlayingId != null && currentlyPlayingId != sound.id) {
        await _main.stop();
        ref.read(currentlyPlayingSoundProvider.notifier).state = null;
        ref.read(isMainPlayerPlayingProvider.notifier).state = false;
      }

      // Configurar modo de release
      await _main.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);
      await _setVolumeForPlayer(_main, vol);

      // Play from path or asset
      if (sound.path != null && sound.path!.isNotEmpty) {
        await _main.play(DeviceFileSource(sound.path!));
      } else {
        await _main.play(AssetSource('sounds/${sound.fileName}'));
      }

      // Mark as playing
      ref.read(currentlyPlayingSoundProvider.notifier).state = sound.id;
      ref.read(isMainPlayerPlayingProvider.notifier).state = true;
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  /// Pausa el player principal (no afecta a efectos)
  Future<void> pauseMain() async {
    try {
      await _main.pause();
      ref.read(isMainPlayerPlayingProvider.notifier).state = false;
    } catch (e) {
      print('pauseMain error: $e');
    }
  }

  /// Resume el player principal
  Future<void> resumeMain() async {
    try {
      await _main.resume();
      ref.read(isMainPlayerPlayingProvider.notifier).state = true;
    } catch (e) {
      print('resumeMain error: $e');
    }
  }

  /// Detiene totalmente el player principal y limpia el estado
  Future<void> stopMain() async {
    try {
      await _main.stop();
    } catch (e) {
      print('stopMain error: $e');
    }
    ref.read(currentlyPlayingSoundProvider.notifier).state = null;
    ref.read(isMainPlayerPlayingProvider.notifier).state = false;
  }

  /// Detiene el efecto también
  Future<void> stopAll() async {
    try {
      await _main.stop();
      await _effect.stop();
    } catch (e) {
      print('stopAll error: $e');
    }
    ref.read(currentlyPlayingSoundProvider.notifier).state = null;
    ref.read(isMainPlayerPlayingProvider.notifier).state = false;
  }

  Future<void> updateMainVolumeFromConfig() async {
    final soundConfig = ref.read(soundConfigProvider);
    final master = soundConfig.masterVolume;
    // si hay currentlyPlayingSoundId, obten su propio volumen:
    final curId = ref.read(currentlyPlayingSoundProvider);
    SoundItem? curSound;
    if (curId != null) {
      // buscar el soundItem en las colecciones
      final collections = ref.read(soundConfigProvider).soundCollections;
      for (final col in collections.values) {
        try {
          curSound = col.sounds.firstWhere((s) => s.id == curId);
          break;
        } catch (_) {}
      }
    }
    final baseVol = curSound?.volume ?? 1.0;
    final vol = (baseVol * master).clamp(0.0, 1.0);
    await _main.setVolume(vol);
  }

  void dispose() {
    _main.dispose();
    _effect.dispose();
  }
}
