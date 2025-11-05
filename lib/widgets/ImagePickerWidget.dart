import 'package:flutter/material.dart';
import 'dart:io';

/// Widget para seleccionar y previsualizar una imagen
class ImagePickerWidget extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final VoidCallback onTap;
  final double height;
  final String placeholder;
  final Color? borderColor;
  final BoxFit fit;

  const ImagePickerWidget({
    Key? key,
    this.imageUrl,
    this.imageFile,
    required this.onTap,
    this.height = 200,
    this.placeholder = 'Toca para seleccionar imagen',
    this.borderColor,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBorderColor = borderColor ?? theme.colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: effectiveBorderColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: _buildContent(context, effectiveBorderColor),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color borderColor) {
    // Prioridad: archivo local > URL > placeholder
    if (imageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            imageFile!,
            fit: fit,
            errorBuilder: (_, __, ___) =>
                _buildPlaceholder(context, borderColor),
          ),
          _buildOverlay(context),
        ],
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl!,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingIndicator(context, loadingProgress);
            },
            errorBuilder: (_, __, ___) =>
                _buildPlaceholder(context, borderColor),
          ),
          _buildOverlay(context),
        ],
      );
    }

    return _buildPlaceholder(context, borderColor);
  }

  Widget _buildPlaceholder(BuildContext context, Color borderColor) {
    return Container(
      color: borderColor.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_rounded,
            size: 64,
            color: borderColor.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            placeholder,
            style: TextStyle(
              color: borderColor.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(
    BuildContext context,
    ImageChunkEvent progress,
  ) {
    final percentComplete = progress.expectedTotalBytes != null
        ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
        : null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(value: percentComplete, strokeWidth: 3),
          if (percentComplete != null) ...[
            const SizedBox(height: 12),
            Text(
              '${(percentComplete * 100).toInt()}%',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.edit, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'Toca para cambiar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
