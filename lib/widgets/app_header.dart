import 'package:flutter/material.dart';
import 'package:muaythai_app/widgets/image_preview.dart'; // Ajusta la ruta según tu proyecto

// ============================================================================
// APP HEADER - Header personalizado con ImagePreview integrado
// ============================================================================

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  // -------------------------------------------------------------------------
  // Propiedades
  // -------------------------------------------------------------------------

  /// Altura total del header
  final double height;

  /// Título principal (ej: "PUÑOS")
  final String title;

  /// Subtítulo (ej: "LIBERTARIOS" o "TEAM 16-12")
  final String subtitle;

  /// Callback para el botón de configuración
  final VoidCallback? onSettings;

  /// Callback para el botón de información
  final VoidCallback? onInfo;

  /// Muestra botón de retroceso
  final bool showBackButton;

  /// Callback personalizado para el botón de retroceso
  final VoidCallback? onBack;

  /// Acciones adicionales en el header
  final List<Widget>? extraActions;

  /// Colores del gradiente (por defecto: negro a rojo)
  final List<Color>? gradientColors;

  /// Ruta del logo/avatar
  final String? avatarAssetPath;

  /// Color del borde del avatar
  final Color avatarBorderColor;

  /// Ancho del borde del avatar
  final double avatarBorderWidth;

  /// Tamaño del avatar
  final double avatarSize;

  /// Lista de imágenes para ver en el preview (opcional)
  /// Si no se proporciona, solo usará el avatarAssetPath
  final List<String>? galleryImages;

  /// Tag para Hero animation
  final String heroTag;

  // -------------------------------------------------------------------------
  // Constructor
  // -------------------------------------------------------------------------

  const AppHeader({
    super.key,
    this.height = 96,
    this.title = 'PUÑOS',
    this.subtitle = 'LIBERTARIOS',
    this.onSettings,
    this.onInfo,
    this.showBackButton = false,
    this.onBack,
    this.extraActions,
    this.gradientColors,
    this.avatarAssetPath = 'assets/images/muayboran.png',
    this.avatarBorderColor = Colors.amber,
    this.avatarBorderWidth = 2.0,
    this.avatarSize = 48,
    this.galleryImages,
    this.heroTag = 'header_avatar',
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  // -------------------------------------------------------------------------
  // Constantes de Estilo
  // -------------------------------------------------------------------------

  static const double _kButtonSize = 40;
  static const double _kIconSize = 20;
  static const double _kBorderRadius = 3;
  static const double _kSpacingSmall = 8;
  static const double _kSpacingMedium = 10;
  static const double _kSpacingLarge = 12;
  static const double _kHorizontalPadding = 16;
  static const double _kVerticalPadding = 12;

  // -------------------------------------------------------------------------
  // Build Methods
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(
          horizontal: _kHorizontalPadding,
          vertical: _kVerticalPadding,
        ),
        decoration: _buildHeaderDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [_buildLeadingSection(context), _buildActionsSection()],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Decoración
  // -------------------------------------------------------------------------

  BoxDecoration _buildHeaderDecoration() {
    final gradient = gradientColors ?? _defaultGradientColors;

    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(_kBorderRadius),
        bottomRight: Radius.circular(_kBorderRadius),
      ),
    );
  }

  static const List<Color> _defaultGradientColors = [
    Color(0xFF1E1E1E),
    Color(0xFFB71C1C),
  ];

  // -------------------------------------------------------------------------
  // Sección Leading (Logo y Título)
  // -------------------------------------------------------------------------

  Widget _buildLeadingSection(BuildContext context) {
    if (showBackButton) {
      return Row(
        children: [
          _buildBackButton(context),
          const SizedBox(width: _kSpacingLarge),
          _buildBrandIdentity(context),
        ],
      );
    }

    return _buildBrandIdentity(context);
  }

  Widget _buildBackButton(BuildContext context) {
    return _circleIconButton(
      icon: Icons.arrow_back,
      onTap: onBack ?? () => Navigator.maybePop(context),
    );
  }

  Widget _buildBrandIdentity(BuildContext context) {
    return Row(
      children: [
        _buildAvatar(context),
        const SizedBox(width: _kSpacingMedium),
        _buildTitleColumn(),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Avatar con ImagePreview
  // -------------------------------------------------------------------------

  Widget _buildAvatar(BuildContext context) {
    // Si hay galleryImages usa esa lista, si no, crea una lista con el avatar
    final images =
        galleryImages ??
        (avatarAssetPath != null ? [avatarAssetPath!] : <String>[]);
    final hasImages = images.isNotEmpty;

    return GestureDetector(
      onTap: hasImages
          ? () {
              ImagePreview.open(
                context,
                images: images,
                initialIndex: 0,
                heroTag: heroTag,
                showCloseButton: true,
                showShareButton: false,
                showDownloadButton: false,
              );
            }
          : null,
      child: Hero(
        tag: '${heroTag}_0',
        child: Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: avatarBorderColor,
              width: avatarBorderWidth,
            ),
          ),
          child: ClipOval(
            child: avatarAssetPath != null
                ? _buildImage(avatarAssetPath!, context)
                : _buildAvatarFallback(),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String src, BuildContext context) {
    if (src.startsWith('http') || src.startsWith('https')) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildAvatarFallback();
        },
      );
    }

    return Image.asset(
      src,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildAvatarFallback();
      },
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: Colors.black26,
      child: Icon(
        Icons.sports_martial_arts,
        color: Colors.amber.withOpacity(0.6),
        size: avatarSize * 0.6,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Título y Subtítulo
  // -------------------------------------------------------------------------

  Widget _buildTitleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [_buildTitle(), const SizedBox(height: 2), _buildSubtitle()],
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.amber, Colors.orange, Colors.amberAccent],
      ).createShader(bounds),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white.withOpacity(0.92),
        letterSpacing: 0.3,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sección de Acciones
  // -------------------------------------------------------------------------

  Widget _buildActionsSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onInfo != null) ...[
          _circleIconButton(icon: Icons.info_outline, onTap: onInfo!),
          const SizedBox(width: _kSpacingMedium),
        ],
        if (onSettings != null) ...[
          _circleIconButton(icon: Icons.settings_outlined, onTap: onSettings!),
        ],
        if (extraActions != null && extraActions!.isNotEmpty) ...[
          const SizedBox(width: _kSpacingSmall),
          ...extraActions!,
        ],
      ],
    );
  }

  // -------------------------------------------------------------------------
  // Botón Circular
  // -------------------------------------------------------------------------

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    double? size,
  }) {
    final buttonSize = size ?? _kButtonSize;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(buttonSize / 2),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.04),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.6,
            ),
          ),
          child: Icon(icon, size: _kIconSize, color: Colors.white),
        ),
      ),
    );
  }
}

// ============================================================================
// VARIANTES DEL HEADER
// ============================================================================

/// Header con información del equipo
class TeamAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String teamName;
  final String teamNumber;
  final VoidCallback? onSettings;
  final VoidCallback? onInfo;
  final List<String>? galleryImages;

  const TeamAppHeader({
    super.key,
    this.teamName = 'PUÑOS LIBERTARIOS',
    this.teamNumber = 'TEAM 16-12',
    this.onSettings,
    this.onInfo,
    this.galleryImages,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: teamName,
      subtitle: teamNumber,
      onSettings: onSettings,
      onInfo: onInfo,
      galleryImages: galleryImages,
      gradientColors: const [
        Color(0xFF1E1E1E),
        Color(0xFFB71C1C),
        Color(0xFF8B0000),
      ],
    );
  }
}

/// Header simple sin acciones
class SimpleAppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final List<String>? galleryImages;

  const SimpleAppHeader({
    super.key,
    this.title = 'PUÑOS',
    this.subtitle = 'LIBERTARIOS',
    this.showBackButton = false,
    this.galleryImages,
  });

  @override
  Size get preferredSize => const Size.fromHeight(96);

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: title,
      subtitle: subtitle,
      showBackButton: showBackButton,
      galleryImages: galleryImages,
    );
  }
}
