import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

// Providers
import 'package:muaythai_app/providers/timer_providers.dart';
import 'package:muaythai_app/providers/sound_providers.dart';

// Services
import 'package:muaythai_app/services/preferences_manager.dart';
import 'package:muaythai_app/widgets/sound_player.dart';

// ============================================================================
// TIMER SCREEN - Pantalla principal del cronómetro de entrenamiento
// ============================================================================

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with TickerProviderStateMixin {
  // -------------------------------------------------------------------------
  // Estado del Timer
  // -------------------------------------------------------------------------

  Timer? _mainTimer;
  Timer? _warningTimer;
  Timer? _bellTimer;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isRestPeriod = false;
  bool _isTransitioning = false;

  int _currentRound = 1;
  int _restSeconds = 0;

  bool _warningPlayed = false;
  bool _showWarningColor = false;

  // Modo continuo (sin descansos)
  bool _isContinuousMode = false;
  int _totalSecondsInContinuousMode = 0;

  // -------------------------------------------------------------------------
  // Controladores de Animación
  // -------------------------------------------------------------------------

  late final AnimationController _progressController;
  late final AnimationController _pulseController;
  late final AnimationController _glowController;
  late final AnimationController _scaleController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Color?> _glowColorAnimation;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initializeAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedPreferences();
    });
  }

  @override
  void dispose() {
    _cleanupTimers();
    _cleanupAnimations();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Inicialización
  // -------------------------------------------------------------------------

  void _initializeAnimations() {
    // Controlador principal de progreso
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Controlador de pulso (para advertencias)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Controlador de brillo (efecto de fondo)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Controlador de escala (para transiciones)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Configuración de animaciones
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _glowColorAnimation = ColorTween(
      begin: const Color(0xFFD32F2F).withOpacity(0.1),
      end: const Color(0xFFD32F2F).withOpacity(0.3),
    ).animate(_glowController);

    _scaleController.forward();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefsManager = ref.read(preferencesManagerProvider);
      await prefsManager.loadTimerConfigToProviders();
      await prefsManager.loadSoundConfigToProviders();

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Limpieza
  // -------------------------------------------------------------------------

  void _cleanupTimers() {
    _mainTimer?.cancel();
    _warningTimer?.cancel();
    _bellTimer?.cancel();
  }

  void _cleanupAnimations() {
    _progressController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
  }

  void _safeResetGlowController() {
    try {
      _glowController.reset();
    } catch (_) {
      // Ignorar errores en dispose
    }
  }

  // -------------------------------------------------------------------------
  // Control del Timer - Start
  // -------------------------------------------------------------------------

  void _startTimer() {
    _cleanupTimers();

    final timerConfig = ref.read(timerConfigProvider);
    final soundConfig = ref.read(soundConfigProvider);

    // Determinar modo de entrenamiento
    _isContinuousMode = !timerConfig.hasRestPeriod;

    if (_isContinuousMode) {
      _setupContinuousMode(timerConfig);
    } else {
      _setupNormalMode(timerConfig);
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    // Reproducir sonidos y LUEGO iniciar el timer
    _playInitialSoundsAndStart(soundConfig);
  }

  void _setupContinuousMode(TimerConfig config) {
    _totalSecondsInContinuousMode = config.roundDuration * config.totalRounds;
    ref
        .read(timerSecondsProvider.notifier)
        .reset(_totalSecondsInContinuousMode);
  }

  void _setupNormalMode(TimerConfig config) {
    ref.read(timerSecondsProvider.notifier).reset(config.roundDuration);
  }

  void _playInitialSoundsAndStart(SoundConfig soundConfig) {
    if (_isContinuousMode) {
      // En modo continuo: campana + espera + sarama + timer
      _playBellIfEnabled(soundConfig);

      Timer(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        _playSaramaIfEnabled(soundConfig, loop: true);
        _startAnimationsAndTimer();
      });
    } else {
      if (!_isRestPeriod) {
        // Round normal: campana + espera + sarama + timer
        _playBellIfEnabled(soundConfig);

        Timer(const Duration(milliseconds: 2200), () {
          if (!mounted) return;
          _playSaramaIfEnabled(soundConfig, loop: true);
          _startAnimationsAndTimer();
        });
      } else {
        // Descanso: SIN sonido, solo inicia timer
        _startAnimationsAndTimer();
      }
    }
  }

  void _startAnimationsAndTimer() {
    _progressController.forward();
    _glowController.repeat();
    _startTimerTick();
  }

  // -------------------------------------------------------------------------
  // Control del Timer - Tick
  // -------------------------------------------------------------------------

  void _startTimerTick() {
    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final currentSeconds = ref.read(timerSecondsProvider);

      if (currentSeconds <= 0) {
        timer.cancel();
        _handleTimerComplete();
        return;
      }

      _handleTimerTick(currentSeconds);
      ref.read(timerSecondsProvider.notifier).decrement();
    });
  }

  void _handleTimerComplete() {
    if (_isTransitioning) return;

    _isTransitioning = true;

    if (_isContinuousMode) {
      _finishTraining();
    } else if (_isRestPeriod) {
      _endRestPeriod();
    } else {
      _endRound();
    }
  }

  void _handleTimerTick(int currentSeconds) {
    final timerConfig = ref.read(timerConfigProvider);

    // Actualizar round en modo continuo
    if (_isContinuousMode) {
      _updateContinuousRound(currentSeconds, timerConfig);
    }

    // Manejar advertencias
    if (!_isRestPeriod && !_warningPlayed) {
      _checkWarningTime(currentSeconds, timerConfig);
    }

    // Advertencia de descanso
    if (_isRestPeriod && currentSeconds <= 3 && !_warningPlayed) {
      _handleRestWarning();
    }
  }

  void _updateContinuousRound(int currentSeconds, TimerConfig config) {
    final elapsedSeconds = _totalSecondsInContinuousMode - currentSeconds;
    final newRound = (elapsedSeconds ~/ config.roundDuration) + 1;

    if (newRound != _currentRound && newRound <= config.totalRounds) {
      setState(() => _currentRound = newRound);
    }
  }

  void _checkWarningTime(int currentSeconds, TimerConfig config) {
    if (currentSeconds > config.warningTime || config.warningTime == 0) return;

    _warningPlayed = true;
    _showWarningColor = true;

    _playWarningSound();
    _scheduleWarningEnd();
  }

  void _handleRestWarning() {
    _warningPlayed = true;
    final soundConfig = ref.read(soundConfigProvider);

    if (soundConfig.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  // -------------------------------------------------------------------------
  // Control del Timer - Pause/Reset
  // -------------------------------------------------------------------------

  void _pauseTimer() {
    _cleanupTimers();

    _progressController.stop();
    _glowController.stop();
    _pulseController.reset();

    try {
      ref.read(soundPlayerProvider).stopMain();
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }

    setState(() {
      _isRunning = false;
      _isPaused = true;
      _showWarningColor = false;
      _isTransitioning = false;
    });
  }

  void _resetTimer() {
    _cleanupTimers();

    _progressController.reset();
    _pulseController.reset();
    _safeResetGlowController();

    final timerConfig = ref.read(timerConfigProvider);

    // Resetear segundos según el modo
    if (!timerConfig.hasRestPeriod) {
      _totalSecondsInContinuousMode =
          timerConfig.roundDuration * timerConfig.totalRounds;
      ref
          .read(timerSecondsProvider.notifier)
          .reset(_totalSecondsInContinuousMode);
    } else {
      ref.read(timerSecondsProvider.notifier).reset(timerConfig.roundDuration);
    }

    try {
      ref.read(soundPlayerProvider).stopAll();
    } catch (e) {
      debugPrint('Error stopping all sounds: $e');
    }

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isRestPeriod = false;
      _currentRound = 1;
      _warningPlayed = false;
      _showWarningColor = false;
      _isTransitioning = false;
      _isContinuousMode = false;
      _totalSecondsInContinuousMode = 0;
    });
  }

  // -------------------------------------------------------------------------
  // Gestión de Rounds
  // -------------------------------------------------------------------------

  void _endRound() {
    final timerConfig = ref.read(timerConfigProvider);
    final soundConfig = ref.read(soundConfigProvider);

    ref.read(soundPlayerProvider).stopMain();
    _playBellIfEnabled(soundConfig);

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;

      if (_currentRound < timerConfig.totalRounds) {
        if (timerConfig.hasRestPeriod) {
          // Iniciar descanso SIN música
          _startRestPeriodSilent(timerConfig);
        } else {
          // Modo continuo: siguiente round
          _continueToNextRoundDirect(timerConfig);
        }
      } else {
        _finishTraining();
      }
    });
  }

  void _startRestPeriodSilent(TimerConfig config) {
    setState(() {
      _isRestPeriod = true;
      _restSeconds = config.restDuration;
      _warningPlayed = false;
      _showWarningColor = false;
      _isTransitioning = false;
    });

    _cleanupTimers();
    _progressController.reset();
    _pulseController.reset();

    ref.read(timerSecondsProvider.notifier).reset(_restSeconds);
    _updateProgressControllerDuration();

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    // Descanso: NO reproducir ningún sonido, solo iniciar timer
    _progressController.forward();
    _startTimerTick();
  }

  void _endRestPeriod() {
    ref.read(soundPlayerProvider).stopMain();

    setState(() {
      _isRestPeriod = false;
      _warningPlayed = false;
      _isTransitioning = false;
    });

    // Tocar campana y LUEGO iniciar nuevo round
    _startNewRound();
  }

  void _startNewRound() {
    final timerConfig = ref.read(timerConfigProvider);
    final soundConfig = ref.read(soundConfigProvider);

    setState(() {
      _currentRound++;
      _warningPlayed = false;
      _showWarningColor = false;
      _isTransitioning = false;
    });

    ref.read(timerSecondsProvider.notifier).reset(timerConfig.roundDuration);
    _updateProgressControllerDuration();
    _progressController.reset();

    // Campana + espera + sarama + timer
    _playBellIfEnabled(soundConfig);

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _playSaramaIfEnabled(soundConfig, loop: true);
      _progressController.forward();
      _startTimerTick();
    });
  }

  void _continueToNextRoundDirect(TimerConfig config) {
    final soundConfig = ref.read(soundConfigProvider);

    setState(() {
      _currentRound++;
      _warningPlayed = false;
      _showWarningColor = false;
      _isTransitioning = false;
    });

    ref.read(timerSecondsProvider.notifier).reset(config.roundDuration);
    _updateProgressControllerDuration();
    _progressController.reset();

    // Campana + espera + sarama + timer
    _playBellIfEnabled(soundConfig);

    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _playSaramaIfEnabled(soundConfig, loop: true);
      _progressController.forward();
      _startTimerTick();
    });
  }

  void _continueToNextRound() {
    final soundConfig = ref.read(soundConfigProvider);

    _playBellIfEnabled(soundConfig);

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _playSaramaIfEnabled(soundConfig, loop: true);
        _progressController.forward();
        _startTimerTick();
      }
    });
  }

  void _finishTraining() {
    _cleanupTimers();
    _progressController.reset();
    _pulseController.reset();
    _safeResetGlowController();

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isRestPeriod = false;
      _isTransitioning = false;
      _isContinuousMode = false;
      _totalSecondsInContinuousMode = 0;
    });

    _playFinishSound();

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) _showWorkoutCompleteDialog();
    });
  }

  void _skipCurrent() {
    if (_isTransitioning) return;

    _cleanupTimers();

    if (_isRestPeriod) {
      _endRestPeriod();
    } else {
      _endRound();
    }
  }

  // -------------------------------------------------------------------------
  // Reproducción de Sonidos
  // -------------------------------------------------------------------------

  void _playBellIfEnabled(SoundConfig config) {
    if (!config.bellEnabled) return;

    final bellSound = config.getSelectedSound('bell');
    if (bellSound != null) {
      ref.read(soundPlayerProvider).playSound(bellSound, isEffect: true);
    }
  }

  void _playSaramaIfEnabled(SoundConfig config, {bool loop = false}) {
    if (!config.saramaEnabled) return;

    final saramaSound = config.getSelectedSound('sarama');
    if (saramaSound != null) {
      ref.read(soundPlayerProvider).playSound(saramaSound, loop: loop);
    }
  }

  void _playWarningSound() {
    final soundConfig = ref.read(soundConfigProvider);

    if (!soundConfig.warningEnabled) return;

    final warningSound = soundConfig.getSelectedSound('warning');
    if (warningSound != null) {
      ref.read(soundPlayerProvider).pauseMain();
      ref.read(soundPlayerProvider).playSound(warningSound, isEffect: true);
    }

    if (soundConfig.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  void _scheduleWarningEnd() {
    _warningTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() => _showWarningColor = false);

      final soundConfig = ref.read(soundConfigProvider);
      if (_isRunning && !_isRestPeriod && soundConfig.saramaEnabled) {
        _playSaramaIfEnabled(soundConfig, loop: true);
      }
    });
  }

  void _playFinishSound() {
    try {
      ref.read(soundPlayerProvider).stopMain();

      final soundConfig = ref.read(soundConfigProvider);
      if (soundConfig.bellEnabled) {
        final bellSound = soundConfig.getSelectedSound('bell');
        if (bellSound != null) {
          ref.read(soundPlayerProvider).playSound(bellSound, isEffect: true);
        }
      }
    } catch (e) {
      debugPrint('Error playing finish sound: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Utilidades
  // -------------------------------------------------------------------------

  void _updateProgressControllerDuration() {
    final timerConfig = ref.read(timerConfigProvider);
    final duration = _isRestPeriod
        ? timerConfig.restDuration
        : timerConfig.roundDuration;
    _progressController.duration = Duration(seconds: duration);
  }

  void _showWorkoutCompleteDialog() {
    if (!mounted) return;

    try {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.scale,
        title: '¡Entrenamiento Completo!',
        desc: '🥊 Has completado $_currentRound rounds de entrenamiento.',
        btnCancelText: 'Nuevo Entrenamiento',
        btnCancelOnPress: () {
          if (mounted) _resetTimer();
        },
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD32F2F),
        ),
        descTextStyle: TextStyle(fontSize: 18, color: Colors.grey[800]),
        padding: const EdgeInsets.all(24),
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
      ).show();
    } catch (e) {
      debugPrint('Error showing dialog: $e');
      if (mounted) _resetTimer();
    }
  }

  String _getStatusText() {
    if (_isRestPeriod) return 'En descanso';
    if (!_isRunning && !_isPaused) return 'Listo';
    if (_isPaused) return 'Pausado';
    if (_isRunning) return 'Entrenando';
    return 'Detenido';
  }

  Color _getStatusColor() {
    if (_isRestPeriod) return Colors.green;
    if (!_isRunning && !_isPaused) return Colors.blue;
    if (_isPaused) return Colors.orange;
    if (_isRunning) return Colors.green;
    return Colors.grey;
  }

  // -------------------------------------------------------------------------
  // Build UI
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timerConfig = ref.watch(timerConfigProvider);
    final currentSeconds = ref.watch(timerSecondsProvider);

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? const [Color(0xFF1a1a1a), Color(0xFF2D2D2D)]
                  : const [Color(0xFFFAFAFA), Color(0xFFFFFFFF)],
            ),
          ),
          child: Stack(
            children: [
              _buildGlowEffect(),
              _buildMainContent(context, isDark, timerConfig, currentSeconds),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffect() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0 + (_glowAnimation.value * 0.5),
                colors: [
                  _glowColorAnimation.value ?? Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    bool isDark,
    TimerConfig timerConfig,
    int currentSeconds,
  ) {
    return Column(
      children: [
        _buildStatusHeader(isDark, timerConfig),
        Expanded(
          child: _buildTimerDisplay(
            context,
            isDark,
            timerConfig,
            currentSeconds,
          ),
        ),
        _buildControls(),
        _buildProgressIndicator(isDark, timerConfig),
        const SizedBox(height: 20),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // UI Components - Header
  // -------------------------------------------------------------------------

  Widget _buildStatusHeader(bool isDark, TimerConfig config) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildRoundInfo(config)),
          _buildConfigInfo(isDark, config),
        ],
      ),
    );
  }

  Widget _buildRoundInfo(TimerConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isRestPeriod
              ? '💤 DESCANSO'
              : '🥊 ROUND $_currentRound/${config.totalRounds}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isRestPeriod ? Colors.green : const Color(0xFFD32F2F),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigInfo(bool isDark, TimerConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          config.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: config.hasRestPeriod
                ? Colors.blue.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            config.hasRestPeriod ? 'Con descansos' : 'Continuo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: config.hasRestPeriod ? Colors.blue : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // UI Components - Timer Display
  // -------------------------------------------------------------------------

  Widget _buildTimerDisplay(
    BuildContext context,
    bool isDark,
    TimerConfig config,
    int currentSeconds,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth * 0.75;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildOuterGlow(size, isDark),
              _buildTimerCircle(size, isDark),
              _buildProgressRing(size, config, currentSeconds),
              _buildCenterContent(size, isDark, currentSeconds, config),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOuterGlow(double size, bool isDark) {
    return Container(
      width: size * 1.1,
      height: size * 1.1,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (_isRestPeriod ? Colors.green : const Color(0xFFD32F2F))
                .withOpacity(0.15),
            blurRadius: 50,
            spreadRadius: 15,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
          if (!isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 10,
              offset: const Offset(-5, -5),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(
    double size,
    TimerConfig config,
    int currentSeconds,
  ) {
    final progressSize = size * 0.93;

    double progressValue;
    if (_isContinuousMode) {
      progressValue = 1.0 - (currentSeconds / _totalSecondsInContinuousMode);
    } else if (_isRestPeriod) {
      progressValue = 1.0 - (currentSeconds / config.restDuration);
    } else {
      progressValue = 1.0 - (currentSeconds / config.roundDuration);
    }

    return SizedBox(
      width: progressSize,
      height: progressSize,
      child: CircularProgressIndicator(
        value: progressValue,
        strokeWidth: size * 0.04,
        backgroundColor: _isRestPeriod
            ? Colors.green.withOpacity(0.1)
            : const Color(0xFFD32F2F).withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation(
          _isRestPeriod
              ? Colors.green
              : (_showWarningColor ? Colors.orange : const Color(0xFFD32F2F)),
        ),
        strokeCap: StrokeCap.round,
      ),
    );
  }

  Widget _buildCenterContent(
    double size,
    bool isDark,
    int currentSeconds,
    TimerConfig config,
  ) {
    final isWarningTime =
        !_isRestPeriod && currentSeconds <= config.warningTime;
    final minutes = currentSeconds ~/ 60;
    final secs = currentSeconds % 60;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isWarningTime ? _pulseAnimation.value : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLogo(size),
              const SizedBox(height: 16),
              _buildTimeDisplay(size, minutes, secs, isWarningTime, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo(double size) {
    final logoSize = size * 0.22;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        'assets/images/muaythai.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.sports_martial_arts, color: Colors.amber);
        },
      ),
    );
  }

  Widget _buildTimeDisplay(
    double size,
    int minutes,
    int secs,
    bool isWarningTime,
    bool isDark,
  ) {
    return Text(
      '$minutes:${secs.toString().padLeft(2, '0')}',
      style: TextStyle(
        fontSize: size * 0.20,
        fontWeight: FontWeight.w900,
        color: isWarningTime
            ? Colors.orange
            : (isDark ? Colors.white : Colors.black87),
        letterSpacing: -2,
        height: 0.9,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // UI Components - Controls
  // -------------------------------------------------------------------------

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(
            icon: Icons.refresh_rounded,
            onPressed: _resetTimer,
            isPrimary: false,
            size: 68,
            tooltip: 'Reiniciar',
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
            onPressed: _isRunning ? _pauseTimer : _startTimer,
            isPrimary: true,
            size: 88,
            tooltip: _isRunning ? 'Pausar' : 'Iniciar',
          ),
          const SizedBox(width: 20),
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            onPressed: (_isRunning || _isPaused) && !_isTransitioning
                ? _skipCurrent
                : null,
            isPrimary: false,
            size: 68,
            tooltip: 'Saltar',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isPrimary,
    required double size,
    required String tooltip,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isPrimary && isEnabled
              ? const LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isPrimary
              ? (isDark ? const Color(0xFF2D2D2D) : Colors.white)
              : (isEnabled ? null : Colors.grey),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? (isEnabled
                        ? const Color(0xFFD32F2F).withOpacity(0.4)
                        : Colors.grey.withOpacity(0.2))
                  : Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: isPrimary ? 20 : 15,
              offset: Offset(0, isPrimary ? 8 : 5),
              spreadRadius: isPrimary ? 2 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(size / 2),
            child: Center(
              child: Icon(
                icon,
                color: isPrimary
                    ? Colors.white
                    : (isEnabled
                          ? (isDark ? Colors.grey[300] : Colors.grey[700])
                          : Colors.grey[400]),
                size: isPrimary ? 40 : 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // UI Components - Progress Indicator
  // -------------------------------------------------------------------------

  Widget _buildProgressIndicator(bool isDark, TimerConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            'Progreso del Entrenamiento',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          _buildRoundDots(config),
        ],
      ),
    );
  }

  Widget _buildRoundDots(TimerConfig config) {
    final currentRoundForDisplay = _isContinuousMode
        ? ((_totalSecondsInContinuousMode - ref.watch(timerSecondsProvider)) ~/
                  config.roundDuration) +
              1
        : _currentRound;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(config.totalRounds, (index) {
        final isCompleted = index < currentRoundForDisplay - 1;
        final isCurrent = index == currentRoundForDisplay - 1;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 18 : 12,
          height: isCurrent ? 18 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFFD32F2F)
                : (isCurrent
                      ? const Color(0xFFD32F2F).withOpacity(0.7)
                      : const Color(0xFFD32F2F).withOpacity(0.2)),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: const Color(0xFFD32F2F).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: isCurrent
              ? Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : null,
        );
      }),
    );
  }
}
