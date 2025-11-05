import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuración de navegación para cada ítem
class NavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String? semanticLabel;
  final int? badgeCount;
  final bool showDot;

  const NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.semanticLabel,
    this.badgeCount,
    this.showDot = false,
  });
}

/// Configuración de diseño del bottom nav
class NavBarConfig {
  final double? height;
  final double? iconSize;
  final double? iconSizeSelected;
  final double? textSize;
  final double? textSizeSelected;
  final double? margin;
  final double? borderRadius;
  final Color? accentColor;
  final bool enableHaptics;
  final bool compactMode;
  final bool showLabels;
  final Curve animationCurve;
  final Duration animationDuration;

  const NavBarConfig({
    this.height,
    this.iconSize,
    this.iconSizeSelected,
    this.textSize,
    this.textSizeSelected,
    this.margin,
    this.borderRadius,
    this.accentColor,
    this.enableHaptics = true,
    this.compactMode = false,
    this.showLabels = true,
    this.animationCurve = Curves.easeInOutCubic,
    this.animationDuration = const Duration(milliseconds: 300),
  });
}

class ModernBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final NavBarConfig? config;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.config,
  });

  // Items por defecto para compatibilidad
  static const List<NavItem> defaultItems = [
    NavItem(
      icon: Icons.auto_stories_rounded,
      activeIcon: Icons.auto_stories,
      label: 'Glosario',
    ),
    NavItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer_rounded,
      label: 'Timer',
    ),
    NavItem(
      icon: Icons.sports_martial_arts_outlined,
      activeIcon: Icons.sports_martial_arts_rounded,
      label: 'Eventos',
    ),
    NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_alt_rounded,
      label: 'Peleadores',
    ),
  ];

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final deviceType = _getDeviceType(screenWidth, screenHeight);
    final dimensions = _calculateDimensions(deviceType, widget.config);
    final accentColor = widget.config?.accentColor ?? const Color(0xFFD32F2F);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: dimensions.navHeight,
        margin: EdgeInsets.only(
          left: dimensions.margin,
          right: dimensions.margin,
          bottom: dimensions.margin,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(dimensions.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: _buildDecoration(
                isDark,
                dimensions.borderRadius,
                accentColor,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  widget.items.length,
                  (index) => _buildNavItem(
                    index,
                    widget.items[index],
                    context,
                    dimensions,
                    accentColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _DeviceType _getDeviceType(double width, double height) {
    if (height < 650) return _DeviceType.verySmall;
    if (width < 360 || height < 700) return _DeviceType.small;
    if (width > 600) return _DeviceType.tablet;
    return _DeviceType.normal;
  }

  _NavDimensions _calculateDimensions(_DeviceType type, NavBarConfig? config) {
    final compactMode = config?.compactMode ?? false;

    switch (type) {
      case _DeviceType.verySmall:
        return _NavDimensions(
          navHeight: compactMode ? 55.0 : (config?.height ?? 58.0),
          iconSize: config?.iconSize ?? 18.0,
          iconSizeSelected: config?.iconSizeSelected ?? 22.0,
          textSize: config?.textSize ?? 9.0,
          textSizeSelected: config?.textSizeSelected ?? 10.0,
          margin: config?.margin ?? 10.0,
          borderRadius: config?.borderRadius ?? 20.0,
          verticalPadding: 5.0,
        );
      case _DeviceType.small:
        return _NavDimensions(
          navHeight: compactMode ? 60.0 : (config?.height ?? 65.0),
          iconSize: config?.iconSize ?? 19.0,
          iconSizeSelected: config?.iconSizeSelected ?? 23.0,
          textSize: config?.textSize ?? 9.0,
          textSizeSelected: config?.textSizeSelected ?? 10.0,
          margin: config?.margin ?? 10.0,
          borderRadius: config?.borderRadius ?? 20.0,
          verticalPadding: 6.0,
        );
      case _DeviceType.tablet:
        return _NavDimensions(
          navHeight: compactMode ? 70.0 : (config?.height ?? 80.0),
          iconSize: config?.iconSize ?? 24.0,
          iconSizeSelected: config?.iconSizeSelected ?? 28.0,
          textSize: config?.textSize ?? 11.0,
          textSizeSelected: config?.textSizeSelected ?? 13.0,
          margin: config?.margin ?? 16.0,
          borderRadius: config?.borderRadius ?? 32.0,
          verticalPadding: 10.0,
        );
      case _DeviceType.normal:
        return _NavDimensions(
          navHeight: compactMode
              ? 60.0
              : (config?.height ?? 70.0), // menos altura
          iconSize: config?.iconSize ?? 18.0, // iconos más pequeños
          iconSizeSelected:
              config?.iconSizeSelected ??
              22.0, // icono seleccionado más compacto
          textSize: config?.textSize ?? 9.0, // texto más pequeño
          textSizeSelected:
              config?.textSizeSelected ??
              10.0, // texto seleccionado más pequeño
          margin: config?.margin ?? 8.0, // menos margen
          borderRadius:
              config?.borderRadius ?? 20.0, // bordes menos redondeados
          verticalPadding: 6.0, // padding vertical reducido
        );
    }
  }

  BoxDecoration _buildDecoration(
    bool isDark,
    double borderRadius,
    Color accentColor,
  ) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0xFF3D3D3D).withOpacity(0.75),
                const Color(0xFF2D2D2D).withOpacity(0.65),
                accentColor.withOpacity(0.12),
              ]
            : [
                Colors.white.withOpacity(0.6),
                Colors.white.withOpacity(0.4),
                accentColor.withOpacity(0.05),
              ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.08),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.4)
              : Colors.black.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
        if (isDark)
          BoxShadow(
            color: accentColor.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
      ],
    );
  }

  Widget _buildNavItem(
    int index,
    NavItem item,
    BuildContext context,
    _NavDimensions dimensions,
    Color accentColor,
  ) {
    final isSelected = widget.currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final showLabels =
        (widget.config?.showLabels ?? true) &&
        !(widget.config?.compactMode ?? false);

    final reservedForText = showLabels ? dimensions.textSizeSelected + 4.0 : 0;
    final maxIconArea =
        dimensions.navHeight -
        (dimensions.verticalPadding * 2) -
        reservedForText;
    final effectiveIconSize = math.min(
      isSelected ? dimensions.iconSizeSelected : dimensions.iconSize,
      math.max(16.0, maxIconArea),
    );

    return Expanded(
      child: Semantics(
        label: item.semanticLabel ?? item.label,
        selected: isSelected,
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (widget.config?.enableHaptics ?? true) {
                HapticFeedback.selectionClick();
              }
              widget.onTap(index);
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: accentColor.withOpacity(0.15),
            highlightColor: accentColor.withOpacity(0.08),
            child: Hero(
              tag: 'nav_item_$index',
              child: AnimatedContainer(
                duration:
                    widget.config?.animationDuration ??
                    const Duration(milliseconds: 300),
                curve: widget.config?.animationCurve ?? Curves.easeInOutCubic,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 14 : 8,
                  vertical: dimensions.verticalPadding,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accentColor.withOpacity(0.15),
                            accentColor.withOpacity(0.08),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(
                          color: accentColor.withOpacity(0.3),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: accentColor.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AnimatedIcon(
                      icon: isSelected && item.activeIcon != null
                          ? item.activeIcon!
                          : item.icon,
                      isSelected: isSelected,
                      color: isSelected
                          ? accentColor
                          : (isDark ? Colors.grey[300]! : Colors.grey[700]!),
                      size: effectiveIconSize,
                      maxIconArea: maxIconArea,
                      accentColor: accentColor,
                      badgeCount: item.badgeCount,
                      showDot: item.showDot,
                    ),
                    if (showLabels) ...[
                      SizedBox(height: dimensions.verticalPadding / 2),
                      Flexible(
                        fit: FlexFit.loose,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: isSelected
                                ? dimensions.textSizeSelected
                                : dimensions.textSize,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? accentColor
                                : (isDark
                                      ? Colors.grey[300]
                                      : Colors.grey[700]),
                            letterSpacing: isSelected ? 0.3 : 0.1,
                            height: 1.0,
                          ),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;
  final double size;
  final double maxIconArea;
  final Color accentColor;
  final int? badgeCount;
  final bool showDot;

  const _AnimatedIcon({
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.size,
    required this.maxIconArea,
    required this.accentColor,
    this.badgeCount,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      tween: Tween(
        begin: isSelected ? 0.95 : 1.0,
        end: isSelected ? 1.05 : 1.0,
      ),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: math.max(0, maxIconArea),
              minHeight: math.min(32.0, math.max(24.0, size)),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: isSelected
                      ? BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              accentColor.withOpacity(0.2),
                              accentColor.withOpacity(0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        )
                      : null,
                  child: Icon(icon, color: color, size: size),
                ),
                // Badge de notificaciones
                if (badgeCount != null && badgeCount! > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount! > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                // Dot indicator
                if (showDot && (badgeCount == null || badgeCount == 0))
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _DeviceType { verySmall, small, normal, tablet }

class _NavDimensions {
  final double navHeight;
  final double iconSize;
  final double iconSizeSelected;
  final double textSize;
  final double textSizeSelected;
  final double margin;
  final double borderRadius;
  final double verticalPadding;

  const _NavDimensions({
    required this.navHeight,
    required this.iconSize,
    required this.iconSizeSelected,
    required this.textSize,
    required this.textSizeSelected,
    required this.margin,
    required this.borderRadius,
    required this.verticalPadding,
  });
}

/// SafeArea adaptativo
class AdaptiveSafeArea extends StatelessWidget {
  final Widget child;
  final bool hasBottomNav;
  final double? customBottomPadding;

  const AdaptiveSafeArea({
    super.key,
    required this.child,
    this.hasBottomNav = true,
    this.customBottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallDevice = screenHeight < 700;
    final isVerySmallDevice = screenHeight < 650;

    final bottomPadding =
        customBottomPadding ??
        (hasBottomNav
            ? (isVerySmallDevice ? 70.0 : (isSmallDevice ? 80.0 : 90.0))
            : MediaQuery.of(context).padding.bottom);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: child,
    );
  }
}

/// Wrapper con navegación y animaciones
class ScreenWithBottomNav extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavTap;
  final List<NavItem>? items;
  final NavBarConfig? config;

  const ScreenWithBottomNav({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavTap,
    this.items,
    this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AdaptiveSafeArea(hasBottomNav: true, child: child),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: ModernBottomNav(
              currentIndex: currentIndex,
              onTap: onNavTap,
              items: items ?? ModernBottomNav.defaultItems,
              config: config,
            ),
          ),
        ),
      ],
    );
  }
}
