import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'dart:math' as math;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  late AnimationController _fireController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  late Animation<double> _glowAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // Main entrance animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _fireController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    _fireController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await AuthService.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await AuthService.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _nameController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getErrorMessage(e.toString())),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email o contraseña incorrectos';
    } else if (error.contains('User already registered')) {
      return 'Este email ya está registrado';
    } else if (error.contains('Password should be at least 6 characters')) {
      return 'La contraseña debe tener al menos 6 caracteres';
    } else if (error.contains('Invalid email')) {
      return 'Email inválido';
    }
    return 'Error: ${error.substring(0, error.length > 50 ? 50 : error.length)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLargeScreen = size.width > 900;

    final heroSize = isLargeScreen
        ? size.width * 0.22
        : isTablet
        ? size.width * 0.35
        : size.width * 0.50;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0A0E27),
                    Color(0xFF1a1a2e),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ]
                : const [
                    Color(0xFFFFF8F0),
                    Color(0xFFFFE8D6),
                    Color(0xFFFFF5E1),
                    Color(0xFFFFEEE0),
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 56 : 40,
                                horizontal: isLargeScreen
                                    ? size.width * 0.08
                                    : 24,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFFD32F2F).withOpacity(0.15),
                                    const Color(0xFFD32F2F).withOpacity(0.08),
                                    const Color(0xFFFF6B6B).withOpacity(0.04),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: RepaintBoundary(
                                      child: AnimatedBuilder(
                                        animation: _fireController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            painter: WaveBackgroundPainter(
                                              animation: _fireController.value,
                                              color: const Color(
                                                0xFFD32F2F,
                                              ).withOpacity(0.1),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  Positioned.fill(
                                    child: AnimatedBuilder(
                                      animation: _glowController,
                                      builder: (context, child) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: RadialGradient(
                                              center: Alignment.center,
                                              radius:
                                                  0.8 +
                                                  (_glowAnimation.value * 0.3),
                                              colors: [
                                                const Color(
                                                  0xFFFF6B6B,
                                                ).withOpacity(
                                                  0.12 * _glowAnimation.value,
                                                ),
                                                const Color(
                                                  0xFFFFAB40,
                                                ).withOpacity(
                                                  0.08 * _glowAnimation.value,
                                                ),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: EpicPatternPainter(
                                        color: const Color(
                                          0xFFD32F2F,
                                        ).withOpacity(0.05),
                                      ),
                                    ),
                                  ),

                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                const Color(0xFFD32F2F),
                                                const Color(0xFFFF6B6B),
                                                const Color(0xFFFF8A80),
                                                const Color(0xFFFFAB40),
                                              ],
                                            ).createShader(bounds),
                                        child: Text(
                                          'PUÑOS LIBERTARIOS',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: isLargeScreen
                                                ? 42
                                                : isTablet
                                                ? 36
                                                : 28,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: 3.5,
                                            height: 1.1,
                                            shadows: [
                                              Shadow(
                                                color: const Color(
                                                  0xFFD32F2F,
                                                ).withOpacity(0.5),
                                                blurRadius: 20,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 40 : 28),

                                      RepaintBoundary(
                                        child: SizedBox(
                                          width: heroSize + 120,
                                          height: heroSize + 120,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              AnimatedBuilder(
                                                animation: _fireController,
                                                builder: (context, child) {
                                                  return CustomPaint(
                                                    size: Size(
                                                      heroSize + 120,
                                                      heroSize + 120,
                                                    ),
                                                    painter:
                                                        FireParticlesPainter(
                                                          animation:
                                                              _fireController
                                                                  .value,
                                                          particleCount: 45,
                                                        ),
                                                  );
                                                },
                                              ),

                                              AnimatedBuilder(
                                                animation: _glowAnimation,
                                                builder: (context, child) {
                                                  return Container(
                                                    width: heroSize,
                                                    height: heroSize,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFFD32F2F,
                                                              ).withOpacity(
                                                                0.5 *
                                                                    _glowAnimation
                                                                        .value,
                                                              ),
                                                          blurRadius:
                                                              80 *
                                                              _glowAnimation
                                                                  .value,
                                                          spreadRadius:
                                                              15 *
                                                              _glowAnimation
                                                                  .value,
                                                        ),
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFFFF6B6B,
                                                              ).withOpacity(
                                                                0.4 *
                                                                    _glowAnimation
                                                                        .value,
                                                              ),
                                                          blurRadius:
                                                              60 *
                                                              _glowAnimation
                                                                  .value,
                                                          spreadRadius:
                                                              20 *
                                                              _glowAnimation
                                                                  .value,
                                                        ),
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFFFFAB40,
                                                              ).withOpacity(
                                                                0.3 *
                                                                    _glowAnimation
                                                                        .value,
                                                              ),
                                                          blurRadius:
                                                              100 *
                                                              _glowAnimation
                                                                  .value,
                                                          spreadRadius:
                                                              10 *
                                                              _glowAnimation
                                                                  .value,
                                                        ),
                                                        BoxShadow(
                                                          color:
                                                              const Color(
                                                                0xFFFFD54F,
                                                              ).withOpacity(
                                                                0.2 *
                                                                    _glowAnimation
                                                                        .value,
                                                              ),
                                                          blurRadius:
                                                              120 *
                                                              _glowAnimation
                                                                  .value,
                                                          spreadRadius:
                                                              5 *
                                                              _glowAnimation
                                                                  .value,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),

                                              AnimatedBuilder(
                                                animation: _floatAnimation,
                                                builder: (context, child) {
                                                  return Transform.translate(
                                                    offset: Offset(
                                                      0,
                                                      _floatAnimation.value,
                                                    ),
                                                    child: Container(
                                                      width: heroSize,
                                                      height: heroSize,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(
                                                          color: const Color(
                                                            0xFFFFAB40,
                                                          ).withOpacity(0.3),
                                                          width: 3,
                                                        ),
                                                      ),
                                                      child: ClipOval(
                                                        child: Image.asset(
                                                          'assets/images/muayboran.png',
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stack) => Container(
                                                            decoration: const BoxDecoration(
                                                              gradient: LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Color(
                                                                    0xFFD32F2F,
                                                                  ),
                                                                  Color(
                                                                    0xFFB71C1C,
                                                                  ),
                                                                  Color(
                                                                    0xFF7B1113,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons
                                                                    .sports_martial_arts,
                                                                size:
                                                                    heroSize *
                                                                    0.35,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isTablet ? 32 : 24),

                                      AnimatedBuilder(
                                        animation: _glowAnimation,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale:
                                                0.98 +
                                                (0.04 * _glowAnimation.value),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isLargeScreen
                                                    ? 48
                                                    : isTablet
                                                    ? 40
                                                    : 28,
                                                vertical: isTablet ? 16 : 14,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFD32F2F),
                                                    Color(0xFFB71C1C),
                                                    Color(0xFF7B1113),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFD32F2F,
                                                    ).withOpacity(0.6),
                                                    blurRadius: 25,
                                                    offset: const Offset(0, 10),
                                                    spreadRadius: 2,
                                                  ),
                                                  BoxShadow(
                                                    color:
                                                        const Color(
                                                          0xFFFF6B6B,
                                                        ).withOpacity(
                                                          0.4 *
                                                              _glowAnimation
                                                                  .value,
                                                        ),
                                                    blurRadius: 35,
                                                    spreadRadius: 5,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                _isLogin
                                                    ? '🏆 BIENVENIDO DE VUELTA 🏆'
                                                    : '⚡ ÚNETE A LA LUCHA ⚡',
                                                style: TextStyle(
                                                  fontSize: isLargeScreen
                                                      ? 18
                                                      : isTablet
                                                      ? 17
                                                      : 14,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  letterSpacing: 2.2,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Flexible(
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: Container(
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                  horizontal: isLargeScreen
                                      ? size.width * 0.15
                                      : isTablet
                                      ? 64
                                      : 24,
                                  vertical: isTablet ? 40 : 24,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(
                                          0xFF1a1a2e,
                                        ).withOpacity(0.95)
                                      : Colors.white.withOpacity(0.98),
                                  borderRadius: BorderRadius.circular(36),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFD32F2F,
                                      ).withOpacity(0.2),
                                      blurRadius: 50,
                                      offset: const Offset(0, 20),
                                      spreadRadius: 8,
                                    ),
                                    BoxShadow(
                                      color: const Color(
                                        0xFFFF6B6B,
                                      ).withOpacity(0.15),
                                      blurRadius: 35,
                                      offset: const Offset(0, 12),
                                      spreadRadius: 4,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.6 : 0.1,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color(
                                      0xFFD32F2F,
                                    ).withOpacity(0.15),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(36),
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.all(
                                      isLargeScreen
                                          ? 48
                                          : isTablet
                                          ? 40
                                          : 32,
                                    ),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            curve: Curves.easeInOut,
                                            child: Column(
                                              children: [
                                                if (!_isLogin) ...[
                                                  _buildTextField(
                                                    controller: _nameController,
                                                    label: 'Nombre Completo',
                                                    icon: Icons.person_outline,
                                                    isDark: isDark,
                                                    isTablet: isTablet,
                                                    isLargeScreen:
                                                        isLargeScreen,
                                                    validator: (v) =>
                                                        v?.isEmpty ?? true
                                                        ? 'Requerido'
                                                        : null,
                                                  ),
                                                  SizedBox(
                                                    height: isTablet ? 24 : 20,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          _buildTextField(
                                            controller: _emailController,
                                            label: 'Email',
                                            icon: Icons.email_outlined,
                                            isDark: isDark,
                                            isTablet: isTablet,
                                            isLargeScreen: isLargeScreen,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator: (v) {
                                              if (v?.isEmpty ?? true) {
                                                return 'Requerido';
                                              }
                                              if (!v!.contains('@')) {
                                                return 'Email inválido';
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: isTablet ? 24 : 20),

                                          _buildTextField(
                                            controller: _passwordController,
                                            label: 'Contraseña',
                                            icon: Icons.lock_outline,
                                            isDark: isDark,
                                            isTablet: isTablet,
                                            isLargeScreen: isLargeScreen,
                                            obscureText: _obscurePassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: const Color(0xFFD32F2F),
                                                size: isTablet ? 24 : 22,
                                              ),
                                              onPressed: () => setState(
                                                () => _obscurePassword =
                                                    !_obscurePassword,
                                              ),
                                            ),
                                            validator: (v) {
                                              if (v?.isEmpty ?? true) {
                                                return 'Requerido';
                                              }
                                              if (v!.length < 6) {
                                                return 'Mínimo 6 caracteres';
                                              }
                                              return null;
                                            },
                                          ),

                                          SizedBox(height: isTablet ? 44 : 32),

                                          AnimatedBuilder(
                                            animation: _glowAnimation,
                                            builder: (context, child) {
                                              return Container(
                                                height: isLargeScreen
                                                    ? 72
                                                    : isTablet
                                                    ? 70
                                                    : 64,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                        colors: [
                                                          Color(0xFFD32F2F),
                                                          Color(0xFFB71C1C),
                                                          Color(0xFF7B1113),
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const Color(
                                                        0xFFD32F2F,
                                                      ).withOpacity(0.6),
                                                      blurRadius: 25,
                                                      offset: const Offset(
                                                        0,
                                                        10,
                                                      ),
                                                      spreadRadius: 3,
                                                    ),
                                                    BoxShadow(
                                                      color:
                                                          const Color(
                                                            0xFFFF6B6B,
                                                          ).withOpacity(
                                                            0.4 *
                                                                _glowAnimation
                                                                    .value,
                                                          ),
                                                      blurRadius: 40,
                                                      spreadRadius: 6,
                                                    ),
                                                  ],
                                                ),
                                                child: Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: _isLoading
                                                        ? null
                                                        : _handleEmailAuth,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                    child: Center(
                                                      child: _isLoading
                                                          ? SizedBox(
                                                              width: 32,
                                                              height: 32,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        3.5,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                            )
                                                          : Text(
                                                              _isLogin
                                                                  ? '🔥 INICIAR SESIÓN 🔥'
                                                                  : '⚡ REGISTRARSE ⚡',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    isLargeScreen
                                                                    ? 20
                                                                    : isTablet
                                                                    ? 19
                                                                    : 17,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Colors
                                                                    .white,
                                                                letterSpacing:
                                                                    2.2,
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          SizedBox(height: isTablet ? 32 : 28),

                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _isLogin
                                                    ? '¿No tienes cuenta?'
                                                    : '¿Ya tienes cuenta?',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.grey[400]
                                                      : Colors.grey[600],
                                                  fontSize: isLargeScreen
                                                      ? 16
                                                      : isTablet
                                                      ? 15
                                                      : 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              TextButton(
                                                onPressed: () {
                                                  setState(
                                                    () => _isLogin = !_isLogin,
                                                  );
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                                ),
                                                child: Text(
                                                  _isLogin
                                                      ? 'Regístrate'
                                                      : 'Inicia sesión',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                    color: const Color(
                                                      0xFFD32F2F,
                                                    ),
                                                    fontSize: isLargeScreen
                                                        ? 16
                                                        : isTablet
                                                        ? 15
                                                        : 14,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required bool isTablet,
    required bool isLargeScreen,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD32F2F).withOpacity(0.3),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: isLargeScreen
              ? 18
              : isTablet
              ? 17
              : 16,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w700,
            fontSize: isLargeScreen
                ? 17
                : isTablet
                ? 16
                : 15,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD32F2F),
                  Color(0xFFB71C1C),
                  Color(0xFF7B1113),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isLargeScreen
                  ? 24
                  : isTablet
                  ? 22
                  : 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 22,
            vertical: isLargeScreen
                ? 26
                : isTablet
                ? 24
                : 22,
          ),
          errorStyle: TextStyle(
            fontSize: isTablet ? 13 : 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        validator: validator,
      ),
    );
  }
}

class FireParticlesPainter extends CustomPainter {
  final double animation;
  final int particleCount;
  final math.Random _random = math.Random(42); // Fixed seed for consistency

  FireParticlesPainter({required this.animation, this.particleCount = 30});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.35;

    for (int i = 0; i < particleCount; i++) {
      final particleProgress = (animation + (i / particleCount)) % 1.0;
      final angle = (i / particleCount) * 2 * math.pi;

      // Particles rise up and fade out
      final x =
          centerX +
          math.cos(angle) * radius * (0.5 + _random.nextDouble() * 0.5);
      final y =
          centerY +
          math.sin(angle) * radius * 0.3 -
          (particleProgress * size.height * 0.4);

      // Particle size decreases as it rises
      final particleSize =
          (1 - particleProgress) * (4 + _random.nextDouble() * 6);

      // Opacity fades out
      final opacity = (1 - particleProgress) * 0.8;

      // Fire colors: red -> orange -> yellow
      final colorProgress = particleProgress;
      final color = Color.lerp(
        const Color(0xFFFF6B6B),
        colorProgress < 0.5 ? const Color(0xFFFFAB40) : const Color(0xFFFFD54F),
        colorProgress,
      )!.withOpacity(opacity);

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(FireParticlesPainter oldDelegate) => true;
}

class WaveBackgroundPainter extends CustomPainter {
  final double animation;
  final Color color;

  WaveBackgroundPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create multiple wave layers
    for (int layer = 0; layer < 3; layer++) {
      final layerOffset = layer * 0.3;
      final waveHeight = 30.0 + (layer * 10);

      path.reset();
      path.moveTo(0, size.height * 0.5);

      for (double x = 0; x <= size.width; x += 5) {
        final y =
            size.height * 0.5 +
            math.sin(
                  (x / size.width * 4 * math.pi) +
                      (animation * 2 * math.pi) +
                      layerOffset,
                ) *
                waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveBackgroundPainter oldDelegate) => true;
}

class EpicPatternPainter extends CustomPainter {
  final Color color;

  const EpicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const spacing = 50.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 18, paint);
        canvas.drawLine(Offset(x - 12, y), Offset(x + 12, y), paint);
        canvas.drawLine(Offset(x, y - 12), Offset(x, y + 12), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
