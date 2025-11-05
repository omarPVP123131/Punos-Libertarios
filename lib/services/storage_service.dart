// lib/services/storage_service.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class StorageService {
  static final _supabase = SupabaseConfig.client;
  static final ImagePicker _picker = ImagePicker();

  // ============================================================================
  // UPLOAD DE IMÁGENES
  // ============================================================================

  static Future<String?> uploadEventoImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'evento_$timestamp.jpg';

      final path = await _supabase.storage
          .from('eventos-imagenes')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage
          .from('eventos-imagenes')
          .getPublicUrl(fileName);

      print('✅ Imagen de evento subida: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error subiendo imagen de evento: $e');
      return null;
    }
  }

  static Future<String?> uploadPeleadorImage(File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'peleador_$timestamp.jpg';

      final path = await _supabase.storage
          .from('peleadores-imagenes')
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage
          .from('peleadores-imagenes')
          .getPublicUrl(fileName);

      print('✅ Imagen de peleador subida: $imageUrl');
      return imageUrl;
    } catch (e) {
      print('❌ Error subiendo imagen de peleador: $e');
      return null;
    }
  }

  // ============================================================================
  // DELETE DE IMÁGENES
  // ============================================================================

  static Future<bool> deleteImageByUrl(
    String imageUrl, {
    required String bucket,
  }) async {
    if (imageUrl.isEmpty) return false;

    try {
      final uri = Uri.parse(imageUrl);
      final fileName = uri.pathSegments.last;

      await _supabase.storage.from(bucket).remove([fileName]);

      print('✅ Imagen eliminada: $fileName');
      return true;
    } catch (e) {
      print('❌ Error eliminando imagen: $e');
      return false;
    }
  }

  static Future<bool> deleteEventoImage(String imageUrl) async {
    return deleteImageByUrl(imageUrl, bucket: 'eventos-imagenes');
  }

  static Future<bool> deletePeleadorImage(String imageUrl) async {
    return deleteImageByUrl(imageUrl, bucket: 'peleadores-imagenes');
  }

  // ============================================================================
  // SELECCIÓN DE IMÁGENES
  // ============================================================================

  static Future<File?> pickImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Error seleccionando imagen: $e');
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Error tomando foto: $e');
      return null;
    }
  }

  static Future<File?> showImageSourceDialog(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('❌ Error seleccionando imagen: $e');
      return null;
    }
  }
}
