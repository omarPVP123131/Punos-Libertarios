import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// DB
import 'core/supabase_config.dart';

// Screens
import 'package:muaythai_app/screens/dojo_screen.dart';
import 'package:muaythai_app/screens/configuracion_screen.dart';
import 'package:muaythai_app/screens/glosario_screen.dart';
import 'package:muaythai_app/screens/timer_screen.dart';
import 'package:muaythai_app/screens/eventos_screen.dart';
import 'package:muaythai_app/screens/peleadores_screen.dart';

// Core
import 'core/theme.dart';

// Widgets
import 'widgets/app_header.dart';
import 'widgets/modern_bottom_nav.dart';

// ============================================================================
// CONFIGURACIÓN DE LA APP
// ============================================================================

/// Habilita/deshabilita la navegación entre pantallas
const bool kNavigationEnabled = true;

/// Información del equipo
const String kTeamName = 'PUÑOS LIBERTARIOS';
const String kTeamNumber = 'TEAM 16-12';

/// Imágenes de la galería del header
const List<String> kHeaderGallery = [
  'assets/images/muayboran.png',
  'assets/images/team1.jpg',
  'assets/images/evento1.jpg',
];

// ============================================================================
// PROVIDERS
// ============================================================================

/// Provider para el índice actual de navegación
final currentIndexProvider = StateProvider<int>((ref) => 1);

/// Provider para notificaciones badge
final badgeProvider = StateProvider.family<int, int>((ref, index) => 0);

// Ejemplos de cómo actualizar badges:
// ref.read(badgeProvider(2).notifier).state = 5; // 5 notificaciones en Eventos
// ref.read(badgeProvider(3).notifier).state = 3; // 3 en Peleadores

// ============================================================================
// MAIN APP
// ============================================================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: MuayThaiApp()));
}

class MuayThaiApp extends ConsumerWidget {
  const MuayThaiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: kTeamName,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============================================================================
// HOME SCREEN CON TODAS LAS MEJORAS
// ============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  // -------------------------------------------------------------------------
  // Variables de Estado
  // -------------------------------------------------------------------------

  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  /// Lista de pantallas con Hero tags
  final List<Widget> _screens = const [
    _HeroScreen(heroTag: 'screen_0', child: GlosarioScreen()),
    _HeroScreen(heroTag: 'screen_1', child: TimerScreen()),
    _HeroScreen(heroTag: 'screen_2', child: EventosScreen()),
    _HeroScreen(heroTag: 'screen_3', child: PeleadoresScreen()),
  ];

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initializeWakelock();
    _initializeNavigation();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _disposeControllers();
    _disableWakelock();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Inicialización
  // -------------------------------------------------------------------------

  void _initializeWakelock() {
    WakelockPlus.enable();
  }

  void _initializeNavigation() {
    final initialIndex = ref.read(currentIndexProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic),
    );

    _fadeController.forward();
  }

  // -------------------------------------------------------------------------
  // Limpieza
  // -------------------------------------------------------------------------

  void _disposeControllers() {
    _pageController.dispose();
    _fadeController.dispose();
  }

  void _disableWakelock() {
    WakelockPlus.disable();
  }

  // -------------------------------------------------------------------------
  // Navegación con Animaciones
  // -------------------------------------------------------------------------

  void _onItemTapped(int index) {
    final currentIndex = ref.read(currentIndexProvider);

    if (!kNavigationEnabled || index == currentIndex) return;

    // Actualizar provider
    ref.read(currentIndexProvider.notifier).state = index;

    // Animación de fade
    _fadeController.reset();
    _fadeController.forward();

    // Animación de página con curve suave
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  void _onPageChanged(int index) {
    ref.read(currentIndexProvider.notifier).state = index;
  }

  // -------------------------------------------------------------------------
  // Navegación a Pantallas Especiales
  // -------------------------------------------------------------------------

  void _openDojoInfo() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const DojoScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ConfiguracionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOutCubicEmphasized,
                  ),
                ),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // UI Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentIndexProvider);

    return Scaffold(
      appBar: AppHeader(
        title: 'PUÑOS',
        subtitle: 'LIBERTARIOS',
        onInfo: _openDojoInfo,
        onSettings: _openSettings,
        galleryImages: kHeaderGallery,
        heroTag: 'app_header_gallery',
        avatarAssetPath: 'assets/images/muayboran.png',
      ),
      body: _buildBody(currentIndex),
      bottomNavigationBar: _buildBottomNav(currentIndex),
    );
  }

  Widget _buildBody(int currentIndex) {
    return Stack(
      children: [_buildGradientBackground(), _buildContent(currentIndex)],
    );
  }

  Widget _buildGradientBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1a1a1a),
                  const Color(0xFF2d2d2d),
                  const Color(0xFFD32F2F).withOpacity(0.03),
                ]
              : [
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8E8E8),
                  const Color(0xFFD32F2F).withOpacity(0.02),
                ],
        ),
      ),
    );
  }

  Widget _buildContent(int currentIndex) {
    if (!kNavigationEnabled) {
      return const _HeroScreen(
        heroTag: 'screen_timer_only',
        child: TimerScreen(),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: _screens.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) => _screens[index],
      ),
    );
  }

  Widget? _buildBottomNav(int currentIndex) {
    if (!kNavigationEnabled) return null;

    // Obtener badges
    final badge0 = ref.watch(badgeProvider(0));
    final badge1 = ref.watch(badgeProvider(1));
    final badge2 = ref.watch(badgeProvider(2));
    final badge3 = ref.watch(badgeProvider(3));

    return ModernBottomNav(
      currentIndex: currentIndex,
      onTap: _onItemTapped,
      items: [
        NavItem(
          icon: Icons.auto_stories_outlined,
          activeIcon: Icons.auto_stories_rounded,
          label: 'Glosario',
          badgeCount: badge0,
        ),
        NavItem(
          icon: Icons.timer_outlined,
          activeIcon: Icons.timer_rounded,
          label: 'Timer',
          showDot: badge1 > 0,
        ),
        NavItem(
          icon: Icons.sports_martial_arts_outlined,
          activeIcon: Icons.sports_martial_arts_rounded,
          label: 'Eventos',
          badgeCount: badge2,
        ),
        NavItem(
          icon: Icons.people_outline_rounded,
          activeIcon: Icons.people_alt_rounded,
          label: 'Peleadores',
          badgeCount: badge3,
        ),
      ],
      config: const NavBarConfig(
        enableHaptics: true,
        accentColor: Colors.red, // Color de acento

        compactMode: false,
        showLabels: true,
        animationCurve: Curves.easeInOutCubicEmphasized,
        animationDuration: Duration(milliseconds: 350),
      ),
    );
  }
}

// ============================================================================
// HERO SCREEN WRAPPER
// ============================================================================

class _HeroScreen extends StatelessWidget {
  final Widget child;
  final String heroTag;

  const _HeroScreen({required this.child, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

// ============================================================================
// EJEMPLO: Cómo actualizar badges desde cualquier pantalla
// ============================================================================

/*
// En cualquier ConsumerWidget:

class EventosScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Actualizar badge al cargar eventos
    useEffect(() {
      Future.microtask(() {
        ref.read(badgeProvider(2).notifier).state = 5; // 5 eventos nuevos
      });
      return null;
    }, []);

    return Scaffold(...);
  }
}

// O al recibir notificación:
void onEventNotification(WidgetRef ref, int count) {
  ref.read(badgeProvider(2).notifier).state = count;
}

// Limpiar badge al abrir la pantalla:
void onScreenOpened(WidgetRef ref, int screenIndex) {
  ref.read(badgeProvider(screenIndex).notifier).state = 0;
}
*/
