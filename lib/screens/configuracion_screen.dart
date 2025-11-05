import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:muaythai_app/providers/auth_providers.dart';
import 'package:muaythai_app/screens/auth_screen.dart';
import 'package:muaythai_app/services/auth_service.dart';
import 'package:muaythai_app/widgets/sound_player.dart';
import '../core/theme.dart';
import '../providers/timer_providers.dart';
import '../providers/sound_providers.dart';
import 'package:file_picker/file_picker.dart';

class ConfiguracionScreen extends ConsumerStatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  ConsumerState<ConfiguracionScreen> createState() =>
      _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends ConsumerState<ConfiguracionScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fabController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fabAnimation;

  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    _slideController.forward();
    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(isDark),

              _buildTabNavigation(isDark),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                  children: [
                    _buildAppearanceTab(themeMode, isDark),
                    _buildTimerTab(),
                    _buildSoundTab(),
                    _buildAboutTab(),
                    _buildAccountTab(isDark), // New account tab
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedTabIndex == 1
          ? AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showCreateCustomTimerDialog(),
                    backgroundColor: Color(0xFFD32F2F),
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Crear Personalizado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            )
          : _selectedTabIndex == 2
          ? AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: FloatingActionButton(
                    onPressed: () => _showAddCustomSoundDialog(),
                    backgroundColor: Color(0xFFD32F2F),
                    child: Icon(Icons.library_music, color: Colors.white),
                  ),
                );
              },
            )
          : null,
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF2D2D2D), Color(0xFF1F1F1F)]
              : [Colors.white, Color(0xFFF8F8F8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD32F2F).withOpacity(0.15),
                    Color(0xFFB71C1C).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Color(0xFFD32F2F).withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD32F2F).withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFD32F2F),
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Personaliza tu experiencia',
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD32F2F).withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text('🥊', style: TextStyle(fontSize: 28)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation(bool isDark) {
    final tabs = [
      {'icon': Icons.palette_rounded, 'label': 'Tema'},
      {'icon': Icons.timer_rounded, 'label': 'Timer'},
      {'icon': Icons.volume_up_rounded, 'label': 'Sonidos'},
      {'icon': Icons.info_outline_rounded, 'label': 'Acerca'},
      {'icon': Icons.person_rounded, 'label': 'Cuenta'}, // New tab
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2D2D2D) : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> tab = entry.value;
          bool isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Color(0xFFD32F2F).withOpacity(0.4),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'],
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 22,
                    ),
                    SizedBox(height: 6),
                    Text(
                      tab['label'],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAppearanceTab(ThemeMode themeMode, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Tema de la Aplicación',
            subtitle: 'Elige tu modo preferido',

            icon: Icons.palette_rounded,
            children: [_buildThemeSelector(ref, themeMode, isDark)],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerTab() {
    final timerConfig = ref.watch(timerConfigProvider);
    final allConfigs = ref.watch(allTimerConfigsProvider);
    final customConfigs = ref.watch(customTimerConfigsProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Configuraciones Predefinidas',
            subtitle: 'Personaliza tus entrenamientos',

            icon: Icons.access_time_rounded,
            children: [
              _buildTimerPresets(
                allConfigs.where((c) => !c.isCustom).toList(),
                timerConfig,
              ),
            ],
          ),
          if (customConfigs.isNotEmpty) ...[
            SizedBox(height: 16),
            _buildSectionCard(
              title: 'Configuraciones Personalizadas',
              subtitle: 'Personaliza el audio',

              icon: Icons.settings_rounded,
              children: [_buildCustomTimerConfigs(customConfigs, timerConfig)],
            ),
          ],
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'Configuración Actual',
            subtitle: 'Esta Es tu configuración Actual',

            icon: Icons.tune_rounded,
            children: [_buildCurrentTimerInfo(timerConfig)],
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSoundTab() {
    final soundConfig = ref.watch(soundConfigProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Control General',
            subtitle: 'Gestiona los sonidos de la aplicación',
            icon: Icons.volume_up_rounded,
            children: [
              _buildMasterVolumeControl(soundConfig),
              SizedBox(height: 16),
              _buildGeneralSoundToggles(soundConfig),
            ],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'Sonidos de Sarama',
            subtitle: 'Configura los sonidos de Sarama',
            icon: Icons.play_circle_outline_rounded,
            children: [_buildSoundCollection('sarama', soundConfig)],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'Sonidos de Advertencia',
            subtitle: 'Configura los sonidos de advertencia',
            icon: Icons.warning_rounded,
            children: [_buildSoundCollection('warning', soundConfig)],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'Sonidos de Campana',
            subtitle: 'Configura los sonidos de campana',
            icon: Icons.notifications_rounded,
            children: [_buildSoundCollection('bell', soundConfig)],
          ),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSectionCard(
            title: 'Información de la Aplicación',
            subtitle: 'Detalles y versión',
            icon: Icons.info_outline_rounded,
            children: [_buildAboutInfo()],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'Créditos y Reconocimientos',
            subtitle: 'Agradecimientos especiales',
            icon: Icons.favorite_rounded,
            children: [_buildCredits()],
          ),
          SizedBox(height: 16),
          _buildSectionCard(
            title: 'Soporte y Contacto',
            subtitle: '¿Necesitas ayuda?',
            icon: Icons.support_rounded,
            children: [_buildSupport()],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTab(bool isDark) {
    final isAuth = ref.watch(isAuthenticatedProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (isAuth)
            _buildSectionCard(
              title: 'Mi Cuenta',
              subtitle: 'Gestiona tu perfil',
              icon: Icons.account_circle_rounded,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD32F2F).withOpacity(0.1),
                        const Color(0xFFD32F2F).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 48,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sesión Activa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // TODO: Implementar logout
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            _buildSectionCard(
              title: 'No Autenticado',
              subtitle: 'Inicia sesión para más funciones',
              icon: Icons.security_rounded,

              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD32F2F).withOpacity(0.1),
                        const Color(0xFFD32F2F).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD32F2F).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 48,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Inicia Sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Accede a funciones exclusivas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AuthScreen(), // Sin redirectMessage
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(
                          Icons.login_rounded,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Ir a Autenticación',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle, // ahora opcional
    required IconData icon,
    required List<Widget> children,
    Color? headerColor, // ahora aceptado
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accent = headerColor ?? const Color(0xFFD32F2F);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withOpacity(0.15),
                        accent.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: accent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: accent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (subtitle != null && subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector(WidgetRef ref, ThemeMode themeMode, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildThemeOption(
            'Claro',
            Icons.light_mode_rounded,
            ThemeMode.light,
            themeMode == ThemeMode.light,
            () => ref.read(themeProvider.notifier).setTheme(ThemeMode.light),
            isDark,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            'Oscuro',
            Icons.dark_mode_rounded,
            ThemeMode.dark,
            themeMode == ThemeMode.dark,
            () => ref.read(themeProvider.notifier).setTheme(ThemeMode.dark),
            isDark,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildThemeOption(
            'Sistema',
            Icons.settings_system_daydream_rounded,
            ThemeMode.system,
            themeMode == ThemeMode.system,
            () => ref.read(themeProvider.notifier).setTheme(ThemeMode.system),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    String label,
    IconData icon,
    ThemeMode mode,
    bool isSelected,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: !isSelected
              ? (isDark ? Color(0xFF1a1a1a) : Color(0xFFF8F8F8))
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Color(0xFF404040) : Color(0xFFE0E0E0)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFD32F2F).withOpacity(0.4),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 32,
            ),
            SizedBox(height: 14),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerPresets(
    List<TimerConfig> presets,
    TimerConfig currentConfig,
  ) {
    return Column(
      children: presets.map((preset) {
        final isSelected = preset.id == currentConfig.id;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: _buildTimerConfigCard(preset, isSelected, false),
        );
      }).toList(),
    );
  }

  Widget _buildCustomTimerConfigs(
    List<TimerConfig> customConfigs,
    TimerConfig currentConfig,
  ) {
    return Column(
      children: customConfigs.map((config) {
        final isSelected = config.id == currentConfig.id;
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: _buildTimerConfigCard(config, isSelected, true),
        );
      }).toList(),
    );
  }

  Widget _buildTimerConfigCard(
    TimerConfig config,
    bool isSelected,
    bool isCustom,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        ref.read(timerConfigProvider.notifier).setConfig(config);
        ref.read(timerSecondsProvider.notifier).reset(config.roundDuration);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Color(0xFFD32F2F).withOpacity(0.15),
                    Color(0xFFB71C1C).withOpacity(0.08),
                  ],
                )
              : null,
          color: !isSelected
              ? (isDark ? Color(0xFF1a1a1a) : Color(0xFFF8F8F8))
              : null,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? Color(0xFFD32F2F)
                : (isDark ? Color(0xFF404040) : Color(0xFFE0E0E0)),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFD32F2F).withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                      )
                    : null,
                color: !isSelected ? Color(0xFFD32F2F).withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0xFFD32F2F).withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isCustom ? Icons.edit_rounded : Icons.access_time_rounded,
                color: isSelected ? Colors.white : Color(0xFFD32F2F),
                size: 26,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          config.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: isSelected ? Color(0xFFD32F2F) : null,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      if (isCustom) ...[
                        IconButton(
                          icon: Icon(Icons.edit, size: 20, color: Colors.grey),
                          onPressed: () => _showEditCustomTimerDialog(config),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, size: 20, color: Colors.red),
                          onPressed: () => _showDeleteConfirmation(config),
                          padding: EdgeInsets.all(8),
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${config.roundDuration ~/ 60}:${(config.roundDuration % 60).toString().padLeft(2, '0')} × ${config.totalRounds} rounds',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (config.warningTime > 0) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Advertencia: ${config.warningTime}s',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (config.hasRestPeriod
                                      ? Colors.green
                                      : Colors.blue)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          config.hasRestPeriod ? 'Con descanso' : 'Seguido',
                          style: TextStyle(
                            color: config.hasRestPeriod
                                ? Colors.green
                                : Colors.blue,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD32F2F).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'Activo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTimerInfo(TimerConfig config) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        const int itemCount = 5;
        const double desiredItemWidth = 140;
        const double minItemWidth = 80;

        double calculatedItemWidth = (maxWidth / itemCount).clamp(
          minItemWidth,
          desiredItemWidth,
        );

        final bool useWrap = maxWidth < (desiredItemWidth * itemCount);

        if (useWrap) {
          final double twoColWidth = (maxWidth / 2) - 16;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoItem(
                    'Duración',
                    '${config.roundDuration ~/ 60}:${(config.roundDuration % 60).toString().padLeft(2, '0')}',
                    width: twoColWidth,
                  ),
                  _buildInfoItem(
                    'Rounds',
                    '${config.totalRounds}',
                    width: twoColWidth,
                  ),
                  _buildInfoItem(
                    'Descanso',
                    '${config.restDuration}s',
                    width: twoColWidth,
                  ),
                  _buildInfoItem(
                    'Advertencia',
                    '${config.warningTime}s',
                    width: twoColWidth,
                  ),
                  _buildInfoItem(
                    'Modo',
                    config.hasRestPeriod ? 'Con descanso' : 'Seguido',
                    width: calculatedItemWidth,
                  ),
                ],
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                'Duración',
                '${config.roundDuration ~/ 60}:${(config.roundDuration % 60).toString().padLeft(2, '0')}',
                width: calculatedItemWidth,
              ),
              _buildInfoItem(
                'Rounds',
                '${config.totalRounds}',
                width: calculatedItemWidth,
              ),
              _buildInfoItem(
                'Descanso',
                '${config.restDuration}s',
                width: calculatedItemWidth,
              ),
              _buildInfoItem(
                'Advertencia',
                '${config.warningTime}s',
                width: calculatedItemWidth,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildInfoItem(String title, String value, {double? width}) {
    final item = Container(
      width: width,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFD32F2F).withOpacity(0.08),
            Color(0xFFD32F2F).withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFD32F2F).withOpacity(0.2), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFD32F2F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD32F2F).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFFD32F2F),
              letterSpacing: -0.3,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (width == null) return item;
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 0, maxWidth: width),
      child: item,
    );
  }

  Widget _buildMasterVolumeControl(SoundConfig soundConfig) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.volume_up, color: Color(0xFFD32F2F), size: 20),
            ),
            SizedBox(width: 12),
            Text(
              'Volumen Principal',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFD32F2F).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${(soundConfig.masterVolume * 100).round()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFD32F2F),
            inactiveTrackColor: Color(0xFFD32F2F).withOpacity(0.2),
            thumbColor: Color(0xFFD32F2F),
            overlayColor: Color(0xFFD32F2F).withOpacity(0.2),
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: soundConfig.masterVolume,
            onChanged: (value) {
              ref.read(soundConfigProvider.notifier).setMasterVolume(value);
              ref.read(soundPlayerProvider).updateMainVolumeFromConfig();
            },
            min: 0.0,
            max: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSoundToggles(SoundConfig soundConfig) {
    final toggles = [
      {
        'title': 'Sonidos de Sarama',
        'subtitle': 'Al iniciar cada round',
        'icon': Icons.play_circle_outline_rounded,
        'value': soundConfig.saramaEnabled,
        'onChanged': (bool value) =>
            ref.read(soundConfigProvider.notifier).toggleSarama(value),
      },
      {
        'title': 'Sonidos de Advertencia',
        'subtitle': 'Segundos antes del final',
        'icon': Icons.warning_rounded,
        'value': soundConfig.warningEnabled,
        'onChanged': (bool value) =>
            ref.read(soundConfigProvider.notifier).toggleWarning(value),
      },
      {
        'title': 'Sonidos de Campana',
        'subtitle': 'Al finalizar cada round',
        'icon': Icons.notifications_rounded,
        'value': soundConfig.bellEnabled,
        'onChanged': (bool value) =>
            ref.read(soundConfigProvider.notifier).toggleBell(value),
      },
      {
        'title': 'Vibración',
        'subtitle': 'Feedback háptico',
        'icon': Icons.vibration_rounded,
        'value': soundConfig.vibrationEnabled,
        'onChanged': (bool value) =>
            ref.read(soundConfigProvider.notifier).toggleVibration(value),
      },
    ];

    return Column(
      children: toggles.map((toggle) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: _buildSoundToggle(
            toggle['title'] as String,
            toggle['subtitle'] as String,
            toggle['icon'] as IconData,
            toggle['value'] as bool,
            toggle['onChanged'] as Function(bool),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSoundToggle(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1a1a1a) : Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? Color(0xFFD32F2F).withOpacity(0.3)
              : (isDark ? Color(0xFF404040) : Color(0xFFE0E0E0)),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: value
                  ? LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                    )
                  : null,
              color: !value ? Color(0xFFD32F2F).withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: value ? Colors.white : Color(0xFFD32F2F),
              size: 22,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundCollection(String type, SoundConfig soundConfig) {
    final collection = soundConfig.soundCollections[type];
    if (collection == null) return SizedBox.shrink();

    return Column(
      children: collection.sounds.map((sound) {
        final isSelected = sound.id == collection.selectedSoundId;
        final canDelete = !sound.isDefault;

        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: _buildSoundItem(sound, isSelected, canDelete, type),
        );
      }).toList(),
    );
  }

  final currentlyPlayingSoundProvider = StateProvider<String?>((ref) => null);

  Widget _buildSoundItem(
    SoundItem sound,
    bool isSelected,
    bool canDelete,
    String type,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentlyPlayingId = ref.watch(currentlyPlayingSoundProvider);

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected
            ? Color(0xFFD32F2F).withOpacity(0.1)
            : (isDark ? Color(0xFF1a1a1a) : Color(0xFFF8F8F8)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? Color(0xFFD32F2F)
              : (isDark ? Color(0xFF404040) : Color(0xFFE0E0E0)),
          width: isSelected ? 2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              ref
                  .read(soundConfigProvider.notifier)
                  .selectSound(type, sound.id);
              HapticFeedback.lightImpact();
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                      )
                    : null,
                color: !isSelected ? Color(0xFFD32F2F).withOpacity(0.1) : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? Colors.white : Color(0xFFD32F2F),
                size: 22,
              ),
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sound.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isSelected ? Color(0xFFD32F2F) : null,
                        ),
                      ),
                    ),
                    if (sound.isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Por defecto',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  sound.fileName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              currentlyPlayingId == sound.id ? Icons.pause : Icons.play_arrow,
              color: Color(0xFFD32F2F),
            ),
            onPressed: () async {
              final player = ref.read(soundPlayerProvider);

              if (currentlyPlayingId == sound.id) {
                await player.stopAll();
                ref.read(currentlyPlayingSoundProvider.notifier).state = null;
              } else {
                await player.playSound(sound);
                ref.read(currentlyPlayingSoundProvider.notifier).state =
                    sound.id;
              }
              HapticFeedback.lightImpact();
            },
            tooltip: currentlyPlayingId == sound.id ? 'Pausar' : 'Reproducir',
          ),
          if (canDelete)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteSoundConfirmation(type, sound.id),
              tooltip: 'Eliminar',
            ),
        ],
      ),
    );
  }

  Widget _buildAboutInfo() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD32F2F).withOpacity(0.15),
                Color(0xFFD32F2F).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Color(0xFFD32F2F).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFD32F2F).withOpacity(0.4),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text('🥊', style: TextStyle(fontSize: 40)),
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puños Libertarios',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD32F2F),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'El arte de las ocho extremidades',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCredits() {
    final credits = [
      {'title': 'Desarrollador', 'value': 'Omar Palomares Velasco'},
      {'title': 'Diseño UI/UX', 'value': 'Omar Palomares Velasco'},
      {'title': 'Sonidos', 'value': 'Biblioteca de Sonidos'},
      {'title': 'Framework', 'value': 'Flutter & Riverpod'},
    ];

    return Column(
      children: credits.map((credit) {
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFD32F2F).withOpacity(0.08),
                Color(0xFFD32F2F).withOpacity(0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Color(0xFFD32F2F).withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                credit['title']!,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                credit['value']!,
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupport() {
    return Column(
      children: [
        _buildSupportOption(
          'Reportar un Error',
          'Ayúdanos a mejorar la aplicación',
          Icons.bug_report_rounded,
          () {},
        ),
        SizedBox(height: 10),
        _buildSupportOption(
          'Sugerir Funcionalidad',
          'Comparte tus ideas con nosotros',
          Icons.lightbulb_rounded,
          () {},
        ),
        SizedBox(height: 10),
        _buildSupportOption(
          'Calificar la App',
          'Danos 5 estrellas si te gusta',
          Icons.star_rounded,
          () {},
        ),
      ],
    );
  }

  Widget _buildSupportOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        onTap();
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1a1a1a) : Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Color(0xFF404040) : Color(0xFFE0E0E0),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Color(0xFFD32F2F), size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    final user = ref.watch(currentUserProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (user != null)
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFD32F2F).withOpacity(0.15),
                  Color(0xFFD32F2F).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFD32F2F).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD32F2F), Color(0xFFB71C1C)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD32F2F).withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      user.email?[0].toUpperCase() ?? '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.email ?? 'Usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Cuenta activa',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: 20),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () {
        _showLogoutConfirmation();
        HapticFeedback.lightImpact();
      },
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.red.withOpacity(0.15),
              Colors.red.withOpacity(0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout, color: Colors.red, size: 22),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.red,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Salir de tu cuenta',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.red),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.logout, color: Colors.red),
            ),
            SizedBox(width: 12),
            Text(
              'Cerrar Sesión',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión? Podrás volver a iniciar sesión en cualquier momento.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await AuthService.signOut();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sesión cerrada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateCustomTimerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomTimerDialog(),
    );
  }

  void _showEditCustomTimerDialog(TimerConfig config) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomTimerDialog(editingConfig: config),
    );
  }

  void _showDeleteConfirmation(TimerConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning, color: Colors.orange),
            ),
            SizedBox(width: 12),
            Text(
              'Confirmar Eliminación',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${config.name}"?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(customTimerConfigsProvider.notifier)
                  .removeCustomConfig(config.id);
              Navigator.pop(context);

              if (ref.read(timerConfigProvider).id == config.id) {
                ref
                    .read(timerConfigProvider.notifier)
                    .setConfig(defaultTimerConfigs[1]);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddCustomSoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddCustomSoundDialog(),
    );
  }

  void _showDeleteSoundConfirmation(String type, String soundId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.warning, color: Colors.orange),
            ),
            SizedBox(width: 12),
            Text(
              'Confirmar Eliminación',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar este sonido?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(soundConfigProvider.notifier)
                  .removeCustomSound(type, soundId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class CustomTimerDialog extends ConsumerStatefulWidget {
  final TimerConfig? editingConfig;

  const CustomTimerDialog({Key? key, this.editingConfig}) : super(key: key);

  @override
  ConsumerState<CustomTimerDialog> createState() => _CustomTimerDialogState();
}

class _CustomTimerDialogState extends ConsumerState<CustomTimerDialog> {
  final _nameController = TextEditingController();
  int _roundMinutes = 3;
  int _roundSeconds = 0;
  int _totalRounds = 5;
  int _restDuration = 60;
  int _warningTime = 10;
  bool _hasRestPeriod = true;

  @override
  void initState() {
    super.initState();
    if (widget.editingConfig != null) {
      final config = widget.editingConfig!;
      _nameController.text = config.name;
      _roundMinutes = config.roundDuration ~/ 60;
      _roundSeconds = config.roundDuration % 60;
      _totalRounds = config.totalRounds;
      _restDuration = config.restDuration;
      _warningTime = config.warningTime;
      _hasRestPeriod = config.hasRestPeriod;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFD32F2F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.timer_rounded, color: Color(0xFFD32F2F)),
          ),
          SizedBox(width: 12),
          Text(
            widget.editingConfig != null
                ? 'Editar Configuración'
                : 'Nueva Configuración',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la configuración',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.label),
              ),
            ),
            SizedBox(height: 16),
            _buildTimeSelector(
              'Duración del Round',
              Icons.access_time_rounded,
              _roundMinutes,
              _roundSeconds,
              (minutes, seconds) {
                setState(() {
                  _roundMinutes = minutes;
                  _roundSeconds = seconds;
                });
              },
            ),
            SizedBox(height: 16),
            _buildSliderSelector(
              'Número de Rounds',
              Icons.repeat_rounded,
              _totalRounds,
              1,
              15,
              (value) => setState(() => _totalRounds = value),
            ),
            SizedBox(height: 16),
            _buildSliderSelector(
              'Descanso (segundos)',
              Icons.pause_rounded,
              _restDuration,
              15,
              180,
              (value) => setState(() => _restDuration = value),
            ),
            SizedBox(height: 16),
            _buildSliderSelector(
              'Tiempo de Advertencia',
              Icons.warning_rounded,
              _warningTime,
              0,
              60,
              (value) => setState(() => _warningTime = value),
            ),
            SizedBox(height: 16),
            _buildRestPeriodToggle(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveConfiguration,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD32F2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            widget.editingConfig != null ? 'Guardar' : 'Crear',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRestPeriodToggle() {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFD32F2F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.pause_rounded,
              color: Color(0xFFD32F2F),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Período de descanso',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  'Incluir descanso entre rounds',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: _hasRestPeriod,
            onChanged: (value) => setState(() => _hasRestPeriod = value),
            activeColor: Color(0xFFD32F2F),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String title,
    IconData icon,
    int minutes,
    int seconds,
    Function(int, int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: minutes,
                decoration: InputDecoration(
                  labelText: 'Minutos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: List.generate(10, (i) => i).map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value min'),
                  );
                }).toList(),
                onChanged: (value) => onChanged(value!, seconds),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: seconds,
                decoration: InputDecoration(
                  labelText: 'Segundos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: [0, 15, 30, 45].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text('$value seg'),
                  );
                }).toList(),
                onChanged: (value) => onChanged(minutes, value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSliderSelector(
    String title,
    IconData icon,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Color(0xFFD32F2F)),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color(0xFFD32F2F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Color(0xFFD32F2F),
            inactiveTrackColor: Color(0xFFD32F2F).withOpacity(0.2),
            thumbColor: Color(0xFFD32F2F),
            overlayColor: Color(0xFFD32F2F).withOpacity(0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (newValue) => onChanged(newValue.round()),
          ),
        ),
      ],
    );
  }

  void _saveConfiguration() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Por favor ingresa un nombre')));
      return;
    }

    final config = TimerConfig(
      id:
          widget.editingConfig?.id ??
          'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      roundDuration: (_roundMinutes * 60) + _roundSeconds,
      totalRounds: _totalRounds,
      restDuration: _restDuration,
      warningTime: _warningTime,
      isCustom: true,
      hasRestPeriod: _hasRestPeriod,
    );

    if (widget.editingConfig != null) {
      ref
          .read(customTimerConfigsProvider.notifier)
          .updateCustomConfig(config.id, config);
    } else {
      ref.read(customTimerConfigsProvider.notifier).addCustomConfig(config);
    }

    Navigator.pop(context);
  }
}

class AddCustomSoundDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<AddCustomSoundDialog> createState() =>
      _AddCustomSoundDialogState();
}

class _AddCustomSoundDialogState extends ConsumerState<AddCustomSoundDialog> {
  final _nameController = TextEditingController();
  String _selectedType = 'sarama';
  String _fileName = '';
  String? _filePath;

  final List<Map<String, String>> soundTypes = [
    {'key': 'sarama', 'label': 'Sarama', 'icon': 'play_circle_outline'},
    {'key': 'warning', 'label': 'Advertencia', 'icon': 'warning'},
    {'key': 'bell', 'label': 'Campana', 'icon': 'notifications'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFD32F2F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.library_music, color: Color(0xFFD32F2F)),
          ),
          SizedBox(width: 12),
          Text('Agregar Sonido Personalizado', style: TextStyle(fontSize: 16)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre del sonido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.label),
            ),
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Tipo de sonido',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.category),
            ),
            items: soundTypes.map((type) {
              return DropdownMenuItem(
                value: type['key'],
                child: Text(type['label']!),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedType = value!),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickAudioFile,
            icon: Icon(Icons.file_upload),
            label: Text(_fileName.isEmpty ? 'Seleccionar Archivo' : _fileName),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFD32F2F).withOpacity(0.1),
              foregroundColor: Color(0xFFD32F2F),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _canSave() ? _saveSound : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFD32F2F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Agregar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  bool _canSave() {
    return _nameController.text.isNotEmpty && _fileName.isNotEmpty;
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'ogg'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        _fileName = file.name;
        _filePath = file.path;
      });
    }
  }

  void _saveSound() {
    final sound = SoundItem(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text,
      fileName: _fileName,
      path: _filePath,
      isDefault: false,
    );

    ref.read(soundConfigProvider.notifier).addCustomSound(_selectedType, sound);
    Navigator.pop(context);
  }
}
