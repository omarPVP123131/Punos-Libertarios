// lib/services/call_state_manager.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muaythai_app/widgets/sound_player.dart';

/// Provider del estado de llamada (usa ref para acceder a soundPlayer)
final callStateProvider = StateNotifierProvider<CallStateNotifier, CallState>((
  ref,
) {
  return CallStateNotifier(ref);
});

enum CallState { idle, incomingCall, activeCall }

class CallStateNotifier extends StateNotifier<CallState> {
  final Ref ref;
  CallStateNotifier(this.ref) : super(CallState.idle) {
    _initializeCallStateListener();
  }

  static const MethodChannel _channel = MethodChannel('call_state_listener');
  bool _wasPlayingBeforeCall = false;
  String? _pausedSoundId;

  void _initializeCallStateListener() {
    // El handler recibe eventos nativos (Android/iOS) a través de MethodChannel.
    _channel.setMethodCallHandler(_handleCallStateChange);
  }

  Future<void> _handleCallStateChange(MethodCall call) async {
    // Esperamos un método 'onCallStateChanged' con argumento { state: 'CALL_STATE_RINGING' ... }
    if (call.method == 'onCallStateChanged') {
      final Map args = Map.from(call.arguments ?? {});
      final String callState = args['state'] ?? '';
      _updateCallState(callState);
    }
  }

  void _updateCallState(String callState) {
    switch (callState) {
      case 'CALL_STATE_IDLE':
        if (state == CallState.activeCall || state == CallState.incomingCall) {
          // llamada finalizada -> reanudar audio si estaba sonando antes
          if (_wasPlayingBeforeCall) {
            _resumeAudioAfterCall();
          }
        }
        state = CallState.idle;
        break;

      case 'CALL_STATE_RINGING':
        _wasPlayingBeforeCall = _isAudioCurrentlyPlaying();
        _pauseAudioForCall();
        state = CallState.incomingCall;
        break;

      case 'CALL_STATE_OFFHOOK':
        // en llamada
        _wasPlayingBeforeCall = _isAudioCurrentlyPlaying();
        _pauseAudioForCall();
        state = CallState.activeCall;
        break;

      default:
        break;
    }
  }

  bool _isAudioCurrentlyPlaying() {
    // Leemos tu provider que indica si el main player está reproduciendo
    try {
      return ref.read(isMainPlayerPlayingProvider);
    } catch (_) {
      return false;
    }
  }

  void _pauseAudioForCall() {
    try {
      // Pausa el main player (sarama)
      ref.read(soundPlayerProvider).pauseMain();
      // guardamos id del sonido pausado para poder reanudar el mismo
      _pausedSoundId = ref.read(currentlyPlayingSoundProvider);
    } catch (e) {
      // ignore
    }
  }

  void _resumeAudioAfterCall() {
    try {
      // reanudar main only si había uno pausado
      if (_pausedSoundId != null) {
        ref.read(soundPlayerProvider).resumeMain();
      }
      _pausedSoundId = null;
      _wasPlayingBeforeCall = false;
    } catch (e) {
      // ignore
    }
  }

  @override
  void dispose() {
    // cleanup si hace falta
    super.dispose();
  }
}
