import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// THEME PROVIDER CON PERSISTENCIA
// ============================================================================

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';

  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeKey);

    if (themeModeIndex != null) {
      state = ThemeMode.values[themeModeIndex];
    }
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, themeMode.index);
  }

  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(newMode);
  }
}

// ============================================================================
// COLOR SCHEMES MEJORADOS
// ============================================================================

class AppColors {
  // Colores primarios Muay Thai - Mejorados con gradientes
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color primaryRedDark = Color(0xFFB71C1C);
  static const Color primaryRedLight = Color(0xFFEF5350);
  static const Color accentOrange = Color(0xFFFF5722);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color accentGoldDark = Color(0xFFFFB300);

  // Gradientes de marca
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryRed, primaryRedDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGold, accentGoldDark],
  );

  // Colores de disciplinas
  static const Color muayThaiRed = Color(0xFFFF4444);
  static const Color jiujitsuBlue = Color(0xFF4A90E2);
  static const Color mmaGreen = Color(0xFF50C878);
  static const Color boxingGold = Color(0xFFFFD700);
  static const Color karateOrange = Color(0xFFFF8C42);
  static const Color wrestlingPurple = Color(0xFF9B59B6);

  // Colores de estado - Mejorados
  static const Color success = Color(0xFF4CAF50);
  static const Color successDark = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningDark = Color(0xFFF57C00);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFC62828);
  static const Color info = Color(0xFF2196F3);
  static const Color infoDark = Color(0xFF1976D2);

  // Fondos modo claro - Mejorados
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightBackgroundSecondary = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFAFAFA);

  // Fondos modo oscuro - Mejorados
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkBackgroundSecondary = Color(0xFF252525);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkSurfaceVariant = Color(0xFF3D3D3D);
  static const Color darkCard = Color(0xFF353535);

  // Colores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF757575);

  // Overlays y sombras
  static Color get lightOverlay => Colors.black.withOpacity(0.05);
  static Color get darkOverlay => Colors.white.withOpacity(0.05);
  static Color get lightShadow => Colors.black.withOpacity(0.08);
  static Color get darkShadow => Colors.black.withOpacity(0.4);
}

// ============================================================================
// LIGHT THEME MEJORADO
// ============================================================================

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // Color Scheme Mejorado
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryRed,
    primaryContainer: AppColors.primaryRedLight,
    secondary: AppColors.accentOrange,
    secondaryContainer: AppColors.accentOrange.withOpacity(0.2),
    tertiary: AppColors.accentGold,
    surface: AppColors.lightSurface,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    onError: Colors.white,
    outline: Colors.grey[300]!,
    shadow: AppColors.lightShadow,
  ),

  // Scaffold
  scaffoldBackgroundColor: AppColors.lightBackground,

  // AppBar Mejorado
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 2,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.lightShadow,
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    titleTextStyle: const TextStyle(
      color: AppColors.textPrimary,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      height: 1.2,
    ),
  ),

  // Cards Mejorados
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.lightShadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.grey[200]!, width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Buttons Mejorados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 2,
      shadowColor: AppColors.primaryRed.withOpacity(0.3),
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryRed,
      side: const BorderSide(color: AppColors.primaryRed, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryRed,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  // Input Decoration Mejorado
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: TextStyle(color: AppColors.textSecondary),
  ),

  // Floating Action Button
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryRed,
    foregroundColor: Colors.white,
    elevation: 4,
    highlightElevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: Colors.grey[100]!,
    selectedColor: AppColors.primaryRed.withOpacity(0.15),
    labelStyle: const TextStyle(color: AppColors.textPrimary),
    side: BorderSide(color: Colors.grey[300]!),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // Divider
  dividerTheme: DividerThemeData(
    color: Colors.grey[300],
    thickness: 1,
    space: 1,
  ),

  // Icons
  iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),

  // Progress Indicators
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: AppColors.primaryRed,
    linearTrackColor: Colors.grey,
  ),

  // Text Theme Mejorado
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: -0.5,
      height: 1.15,
    ),
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.6,
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.4,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
  ),
);

// ============================================================================
// DARK THEME MEJORADO
// ============================================================================

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,

  // Color Scheme Mejorado
  colorScheme: ColorScheme.dark(
    primary: AppColors.primaryRed,
    primaryContainer: AppColors.primaryRedDark,
    secondary: AppColors.accentOrange,
    secondaryContainer: AppColors.accentOrange.withOpacity(0.2),
    tertiary: AppColors.accentGold,
    surface: AppColors.darkSurface,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    error: AppColors.error,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textPrimaryDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    onError: Colors.white,
    outline: Colors.white.withOpacity(0.1),
    shadow: AppColors.darkShadow,
  ),

  // Scaffold
  scaffoldBackgroundColor: AppColors.darkBackground,

  // AppBar Mejorado
  appBarTheme: AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 4,
    backgroundColor: Colors.transparent,
    foregroundColor: AppColors.textPrimaryDark,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.darkShadow,
    iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 24),
    titleTextStyle: const TextStyle(
      color: AppColors.textPrimaryDark,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      height: 1.2,
    ),
  ),

  // Cards Mejorados
  cardTheme: CardThemeData(
    elevation: 0,
    color: AppColors.darkCard,
    surfaceTintColor: Colors.transparent,
    shadowColor: AppColors.darkShadow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),

  // Buttons Mejorados
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 4,
      shadowColor: AppColors.primaryRed.withOpacity(0.4),
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primaryRed,
      side: const BorderSide(color: AppColors.primaryRed, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primaryRed,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryRed,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),

  // Input Decoration Mejorado
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkCard,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    hintStyle: TextStyle(color: AppColors.textSecondaryDark),
  ),

  // Floating Action Button
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryRed,
    foregroundColor: Colors.white,
    elevation: 6,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
  ),

  // Chip Theme
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.darkCard,
    selectedColor: AppColors.primaryRed.withOpacity(0.2),
    labelStyle: const TextStyle(color: AppColors.textPrimaryDark),
    side: BorderSide(color: Colors.white.withOpacity(0.1)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),

  // Divider
  dividerTheme: DividerThemeData(
    color: Colors.white.withOpacity(0.1),
    thickness: 1,
    space: 1,
  ),

  // Icons
  iconTheme: const IconThemeData(color: AppColors.textPrimaryDark, size: 24),

  // Progress Indicators
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.primaryRed,
    linearTrackColor: Colors.white.withOpacity(0.1),
  ),

  // Text Theme Mejorado (mismo que light pero con colores oscuros)
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimaryDark,
      letterSpacing: -0.5,
      height: 1.15,
    ),
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark,
      letterSpacing: -0.3,
      height: 1.2,
    ),
    displaySmall: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark,
      height: 1.25,
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimaryDark,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      letterSpacing: 0.15,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      letterSpacing: 0.15,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimaryDark,
      height: 1.6,
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondaryDark,
      height: 1.5,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondaryDark,
      height: 1.4,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      letterSpacing: 0.5,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimaryDark,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondaryDark,
      letterSpacing: 0.5,
    ),
  ),
);

// ============================================================================
// WIDGETS PERSONALIZADOS CON TEMA MEJORADO
// ============================================================================

class MuayThaiCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool elevated;
  final Gradient? gradient;

  const MuayThaiCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevated = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      elevation: elevated ? (isDark ? 6 : 3) : 0,
      shadowColor: isDark ? Colors.black54 : Colors.black12,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null
              ? (color ??
                    (isDark ? AppColors.darkCard : AppColors.lightSurface))
              : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
          boxShadow: !elevated
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class WarriorBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool outlined;

  const WarriorBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: !outlined
            ? LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              )
            : null,
        color: outlined ? Colors.transparent : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(outlined ? 0.6 : 0.3),
          width: outlined ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeToggleButton extends ConsumerWidget {
  final bool showLabel;

  const ThemeToggleButton({super.key, this.showLabel = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark =
        themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    if (showLabel) {
      return FilledButton.icon(
        onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
        label: Text(isDark ? 'Modo Claro' : 'Modo Oscuro'),
      );
    }

    return IconButton(
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
      tooltip: isDark ? 'Modo Claro' : 'Modo Oscuro',
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

// Widget para mostrar gradient de disciplina
class DisciplineGradientBanner extends StatelessWidget {
  final String discipline;
  final IconData icon;
  final String description;

  const DisciplineGradientBanner({
    super.key,
    required this.discipline,
    required this.icon,
    required this.description,
  });

  LinearGradient _getGradient() {
    switch (discipline.toLowerCase()) {
      case 'muay thai':
        return const LinearGradient(
          colors: [Color(0xFFFF4444), Color(0xFFD32F2F)],
        );
      case 'jiu jitsu':
        return const LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF1976D2)],
        );
      case 'mma':
        return const LinearGradient(
          colors: [Color(0xFF50C878), Color(0xFF388E3C)],
        );
      case 'boxing':
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discipline.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget animado para estadísticas
class AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPercentage;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.isPercentage = false,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return MuayThaiCard(
          elevated: true,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withOpacity(0.15 * _animation.value),
              widget.color.withOpacity(0.05 * _animation.value),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 24),
                  ),
                  Transform.scale(
                    scale: _animation.value,
                    child: Icon(
                      Icons.trending_up_rounded,
                      color: widget.color.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.label,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget de progreso circular mejorado
class CircularProgressCard extends StatelessWidget {
  final String label;
  final double progress;
  final Color color;
  final IconData icon;

  const CircularProgressCard({
    super.key,
    required this.label,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MuayThaiCard(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// Botón de acción flotante personalizado
class MuayThaiFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? label;
  final Color? backgroundColor;

  const MuayThaiFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.label,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: backgroundColor ?? AppColors.primaryRed,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.primaryRed,
      child: Icon(icon),
    );
  }
}

// Widget de header de sección
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onActionTap;
  final String? actionLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onActionTap,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryRed, size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(actionLabel ?? 'Ver más'),
            ),
        ],
      ),
    );
  }
}

// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: isDark
                  ? [
                      AppColors.darkCard,
                      AppColors.darkSurfaceVariant,
                      AppColors.darkCard,
                    ]
                  : [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
            ),
          ),
        );
      },
    );
  }
}
