import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:muaythai_app/screens/dojo_screen.dart';

/// Widget modular para previsualizar imágenes en modal
class ImagePreview {
  static Future<void> open(
    BuildContext context, {
    required List<String> images,
    int initialIndex = 0,
    required String heroTag, // Hacer required para forzar tags únicos
    bool showCloseButton = true,
    bool showShareButton = false,
    bool showDownloadButton = false,
    Function(String)? onShare,
    Function(String)? onDownload,
  }) {
    if (images.isEmpty) return Future.value();

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _ImagePreviewModal(
              images: images,
              initialIndex: initialIndex,
              heroTag: heroTag,
              showCloseButton: showCloseButton,
              showShareButton: showShareButton,
              showDownloadButton: showDownloadButton,
              onShare: onShare,
              onDownload: onDownload,
            ),
          );
        },
      ),
    );
  }
}

class _ImagePreviewModal extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String heroTag;
  final bool showCloseButton;
  final bool showShareButton;
  final bool showDownloadButton;
  final Function(String)? onShare;
  final Function(String)? onDownload;

  const _ImagePreviewModal({
    Key? key,
    required this.images,
    this.initialIndex = 0,
    required this.heroTag, // Hacer required
    this.showCloseButton = true,
    this.showShareButton = false,
    this.showDownloadButton = false,
    this.onShare,
    this.onDownload,
  }) : super(key: key);

  @override
  State<_ImagePreviewModal> createState() => _ImagePreviewModalState();
}

class _ImagePreviewModalState extends State<_ImagePreviewModal>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _uiController;
  late AnimationController _dismissController;
  bool _showUI = true;
  double _currentScale = 1.0;
  double _dragDistance = 0.0;
  bool _isDragging = false;

  final TransformationController _transformController =
      TransformationController();
  late AnimationController _zoomAnimController;
  Animation<Matrix4>? _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pageController = PageController(initialPage: _currentIndex);

    _uiController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward();

    _dismissController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _zoomAnimController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _startAutoHideTimer();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _startAutoHideTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _currentScale == 1.0 && !_isDragging) {
        setState(() => _showUI = false);
        _uiController.reverse();
      }
    });
  }

  void _toggleUI() {
    if (_currentScale > 1.0) return;
    setState(() => _showUI = !_showUI);
    if (_showUI) {
      _uiController.forward();
      _startAutoHideTimer();
    } else {
      _uiController.reverse();
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    HapticFeedback.mediumImpact();

    final position = details.localPosition;
    final currentMatrix = _transformController.value;
    final isZoomed = currentMatrix.getMaxScaleOnAxis() > 1.0;

    Matrix4 targetMatrix;

    if (isZoomed) {
      targetMatrix = Matrix4.identity();
    } else {
      const scale = 2.5;
      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);
      targetMatrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(scale);
    }

    _zoomAnimation = Matrix4Tween(begin: currentMatrix, end: targetMatrix)
        .animate(
          CurvedAnimation(parent: _zoomAnimController, curve: Curves.easeInOut),
        );

    _zoomAnimController.forward(from: 0).then((_) {
      setState(() {
        _currentScale = targetMatrix.getMaxScaleOnAxis();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiController.dispose();
    _dismissController.dispose();
    _zoomAnimController.dispose();
    _transformController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  Widget _buildImageWidget(String src, Color fallbackColor) {
    if (src.trim().isEmpty) return _fallbackWidget(fallbackColor);

    if (src.startsWith('http') || src.startsWith('https')) {
      return Image.network(
        src,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildSkeletonLoader(loadingProgress, fallbackColor);
        },
        errorBuilder: (_, __, ___) => _fallbackWidget(fallbackColor),
      );
    }

    return Image.asset(
      src,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _fallbackWidget(fallbackColor),
    );
  }

  Widget _buildSkeletonLoader(
    ImageChunkEvent loadingProgress,
    Color fallbackColor,
  ) {
    final progress = loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
              (loadingProgress.expectedTotalBytes ?? 1)
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white10,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _ShimmerEffect(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            fallbackColor,
                          ),
                          backgroundColor: Colors.white10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (progress != null)
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        loadingProgress.expectedTotalBytes != null
                            ? '${(loadingProgress.cumulativeBytesLoaded / 1024 / 1024).toStringAsFixed(1)} MB'
                            : 'Cargando...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
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
    );
  }

  Widget _fallbackWidget(Color fallbackColor) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: fallbackColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, color: fallbackColor, size: 80),
          const SizedBox(height: 12),
          const Text(
            'Imagen no disponible',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    if (widget.images.length <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.images.length, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white30,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (_currentScale > 1.0) return;

    setState(() {
      _isDragging = true;
      _dragDistance += details.delta.dy;
      _dismissController.value = (_dragDistance.abs() / 300).clamp(0.0, 1.0);
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_currentScale > 1.0) return;

    setState(() => _isDragging = false);

    if (_dragDistance.abs() > 150 ||
        details.velocity.pixelsPerSecond.dy.abs() > 500) {
      HapticFeedback.lightImpact();
      _dismissController.forward().then((_) => Navigator.of(context).pop());
    } else {
      _dismissController.reverse();
      setState(() => _dragDistance = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentImage = widget.images[_currentIndex];

    return AnimatedBuilder(
      animation: _dismissController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _dragDistance),
          child: Opacity(
            opacity: 1 - (_dismissController.value * 0.5),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Blur background
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  key: ValueKey(_currentIndex),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _getImageProvider(currentImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ),
            ),

            // Gesture detector para cerrar
            GestureDetector(
              onVerticalDragUpdate: _handleVerticalDragUpdate,
              onVerticalDragEnd: _handleVerticalDragEnd,
              onTap: _toggleUI,
              child: PageView.builder(
                controller: _pageController,
                physics: _currentScale > 1.0
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                itemCount: widget.images.length,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentIndex = i;
                    _currentScale = 1.0;
                    _transformController.value = Matrix4.identity();
                  });
                  if (_showUI) _startAutoHideTimer();
                },
                itemBuilder: (context, index) {
                  final src = widget.images[index];
                  // CORRECCIÓN: Usar tag único para cada imagen
                  final tag = '${widget.heroTag}_$index';
                  return Center(
                    child: Hero(
                      tag: tag, // Tag único por imagen
                      child: GestureDetector(
                        onDoubleTapDown: _handleDoubleTap,
                        child: AnimatedBuilder(
                          animation: _zoomAnimController,
                          builder: (context, child) {
                            if (_zoomAnimation != null) {
                              _transformController.value =
                                  _zoomAnimation!.value;
                            }
                            return InteractiveViewer(
                              transformationController: _transformController,
                              panEnabled: true,
                              minScale: 1.0,
                              maxScale: 5.0,
                              onInteractionStart: (_) {
                                if (_showUI) {
                                  setState(() => _showUI = false);
                                  _uiController.reverse();
                                }
                              },
                              onInteractionUpdate: (details) {
                                setState(() => _currentScale = details.scale);
                              },
                              onInteractionEnd: (details) {
                                if (_currentScale == 1.0 && !_showUI) {
                                  Future.delayed(
                                    const Duration(milliseconds: 100),
                                    () {
                                      if (mounted && _currentScale == 1.0) {
                                        setState(() => _showUI = true);
                                        _uiController.forward();
                                        _startAutoHideTimer();
                                      }
                                    },
                                  );
                                }
                              },
                              child: _buildImageWidget(
                                src,
                                Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Header
            AnimatedBuilder(
              animation: _uiController,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, -80 * (1 - _uiController.value)),
                    child: Opacity(
                      opacity: _uiController.value,
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${_currentIndex + 1} / ${widget.images.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (widget.showShareButton &&
                                    widget.onShare != null)
                                  _ActionButton(
                                    icon: Icons.share_rounded,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      widget.onShare!(currentImage);
                                    },
                                    tooltip: 'Compartir',
                                  ),
                                if (widget.showDownloadButton &&
                                    widget.onDownload != null)
                                  _ActionButton(
                                    icon: Icons.download_rounded,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      widget.onDownload!(currentImage);
                                    },
                                    tooltip: 'Descargar',
                                  ),
                                if (widget.showCloseButton)
                                  _ActionButton(
                                    icon: Icons.close_rounded,
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      Navigator.of(context).pop();
                                    },
                                    tooltip: 'Cerrar',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Footer con indicadores
            if (widget.images.length > 1)
              AnimatedBuilder(
                animation: _uiController,
                builder: (context, child) {
                  return Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Transform.translate(
                      offset: Offset(0, 60 * (1 - _uiController.value)),
                      child: Opacity(
                        opacity: _uiController.value,
                        child: Container(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 24,
                            top: 24,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Center(child: _buildPageIndicators()),
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Hint para swipe down
            if (_dragDistance.abs() < 50 && _isDragging)
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: Colors.white70,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Desliza para cerrar',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider _getImageProvider(String src) {
    if (src.startsWith('http') || src.startsWith('https')) {
      return NetworkImage(src);
    }
    return AssetImage(src);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24, width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _ShimmerEffect extends StatefulWidget {
  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((v) => v.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Thumbnail mejorado - CORREGIDO: Tags únicos
class PreviewThumbnail extends StatefulWidget {
  final String src;
  final double size;
  final Color borderColor;
  final String heroTag;
  final int index;
  final List<String>? gallery;
  final bool showBadge;
  final String? badgeText;

  const PreviewThumbnail({
    Key? key,
    required this.src,
    required this.heroTag,
    this.index = 0,
    this.gallery,
    this.size = 90,
    this.borderColor = Colors.black12,
    this.showBadge = false,
    this.badgeText,
  }) : super(key: key);

  @override
  State<PreviewThumbnail> createState() => _PreviewThumbnailState();
}

class _PreviewThumbnailState extends State<PreviewThumbnail> {
  bool _isPressed = false;

  Widget _buildImage(String src, Color fallbackColor) {
    if (src.trim().isEmpty) {
      return Container(
        color: fallbackColor.withOpacity(0.12),
        child: Icon(
          Icons.person,
          color: fallbackColor,
          size: widget.size * 0.5,
        ),
      );
    }

    if (src.startsWith('http') || src.startsWith('https')) {
      return Image.network(
        src,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(fallbackColor),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: fallbackColor.withOpacity(0.12),
          child: Icon(
            Icons.person,
            color: fallbackColor,
            size: widget.size * 0.5,
          ),
        ),
      );
    }

    return Image.asset(
      src,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: fallbackColor.withOpacity(0.12),
        child: Icon(
          Icons.person,
          color: fallbackColor,
          size: widget.size * 0.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN: Tag único que combine heroTag + index
    final tag = '${widget.heroTag}_${widget.index}';
    final fallbackColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        final images = widget.gallery ?? [widget.src];
        ImagePreview.open(
          context,
          images: images,
          initialIndex: widget.index,
          heroTag: widget.heroTag, // Mismo tag base para la galería
        );
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Stack(
          children: [
            // CORRECCIÓN: Hero con tag único
            Hero(
              tag: tag, // Tag único por thumbnail
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.borderColor, width: 2),
                  color: Colors.black12,
                  boxShadow: [
                    BoxShadow(
                      color: widget.borderColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: _buildImage(widget.src, fallbackColor),
              ),
            ),
            if (widget.showBadge && widget.badgeText != null)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: widget.borderColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Text(
                    widget.badgeText!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// CORRECCIÓN: Asegurar tags únicos en _InstructorCard
class _InstructorCard extends StatelessWidget {
  final Instructor instructor;
  final bool isDark;

  const _InstructorCard(this.instructor, this.isDark);

  @override
  Widget build(BuildContext context) {
    final gallery = DojoConfig.getGallery(instructor.id);
    final hasMultipleImages = gallery.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _buildCardDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            _buildBackgroundGradient(),
            _buildMainContent(gallery, hasMultipleImages),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: instructor.color.withOpacity(0.15), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: instructor.color.withOpacity(isDark ? 0.15 : 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _buildBackgroundGradient() {
    return Positioned(
      top: -50,
      right: -50,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              instructor.color.withOpacity(0.08),
              instructor.color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(List<String> gallery, bool hasMultipleImages) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnailSection(gallery, hasMultipleImages),
          const SizedBox(width: 18),
          Expanded(child: _buildInfoSection(gallery, hasMultipleImages)),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection(List<String> gallery, bool hasMultipleImages) {
    return Stack(
      children: [
        _buildMainThumbnail(gallery),
        if (hasMultipleImages) _buildImageCountBadge(gallery.length),
      ],
    );
  }

  Widget _buildMainThumbnail(List<String> gallery) {
    // CORRECCIÓN: Tag único para el thumbnail principal
    final mainTag = 'instructor_${instructor.id}_main_0';
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: instructor.color.withOpacity(0.9), width: 3),
        boxShadow: [
          BoxShadow(
            color: instructor.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: PreviewThumbnail(
          src: gallery.isNotEmpty ? gallery[0] : '',
          heroTag: mainTag, // Tag único para el thumbnail principal
          index: 0,
          gallery: gallery,
          size: 95,
          borderColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildImageCountBadge(int imageCount) {
    return Positioned(
      bottom: 4,
      right: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: instructor.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.photo_library, color: Colors.white, size: 12),
            const SizedBox(width: 3),
            Text(
              '$imageCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(List<String> gallery, bool hasMultipleImages) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameHeader(),
        const SizedBox(height: 10),
        _buildSpecialtyBadge(),
        if (instructor.description.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDescription(),
        ],
        if (instructor.trajectory.isNotEmpty) ...[
          const SizedBox(height: 10),
          _buildTrajectory(),
        ],
        if (hasMultipleImages) ...[
          const SizedBox(height: 12),
          _buildGalleryThumbnails(gallery),
        ],
      ],
    );
  }

  Widget _buildNameHeader() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: instructor.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            instructor.name,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            instructor.color.withOpacity(0.15),
            instructor.color.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: instructor.color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: instructor.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              instructor.specialty,
              style: TextStyle(
                color: instructor.color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      instructor.description,
      style: TextStyle(
        color: isDark ? Colors.white70 : Colors.black54,
        fontSize: 13,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTrajectory() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.stars_rounded,
          size: 14,
          color: instructor.color.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            instructor.trajectory,
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 11,
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildGalleryThumbnails(List<String> gallery) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: gallery.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildGalleryThumbnail(gallery, index),
          );
        },
      ),
    );
  }

  Widget _buildGalleryThumbnail(List<String> gallery, int index) {
    final isFirst = index == 0;
    // CORRECCIÓN: Tag único para cada thumbnail de galería
    final galleryTag = 'instructor_${instructor.id}_gallery_$index';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: instructor.color.withOpacity(isFirst ? 0.9 : 0.5),
          width: 2.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(9.5),
        child: PreviewThumbnail(
          src: gallery[index],
          heroTag: galleryTag, // Tag único por thumbnail de galería
          index: index,
          gallery: gallery,
          size: 50,
          borderColor: Colors.transparent,
        ),
      ),
    );
  }
}
