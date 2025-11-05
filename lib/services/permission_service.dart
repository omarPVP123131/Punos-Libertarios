import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Método público para pedir todos los permisos
  static Future<void> requestAllPermissions(BuildContext context) async {
    final List<Permission> permissionsToRequest = [];

    // Permisos comunes
    permissionsToRequest.add(Permission.camera);
    permissionsToRequest.add(Permission.microphone);
    permissionsToRequest.add(Permission.contacts);
    permissionsToRequest.add(Permission.calendar);
    permissionsToRequest.add(Permission.phone); // llamadas
    permissionsToRequest.add(Permission.sms);

    // Ubicación
    permissionsToRequest.add(Permission.location);
    // Para background location se puede pedir después

    // Almacenamiento / archivos
    permissionsToRequest.add(Permission.storage);
    permissionsToRequest.add(Permission.manageExternalStorage);

    // Sensores
    permissionsToRequest.add(Permission.sensors);

    // Bluetooth
    permissionsToRequest.add(Permission.bluetooth);

    // iOS: fotos
    if (Platform.isIOS) {
      permissionsToRequest.add(Permission.photos);
    }

    // Solicitar permisos uno por uno para manejar casos especiales
    for (final p in permissionsToRequest.toSet()) {
      await _askPermission(context, p);
    }

    // Ejemplo: pedir locationAlways después de que location esté granted
    final locStatus = await Permission.location.status;
    if (locStatus.isGranted) {
      final shouldRequestBackground = await _showRationaleDialog(
        context,
        title: 'Ubicación en segundo plano',
        message:
            'Para funciones de seguimiento mientras la app está en segundo plano necesitamos permiso de ubicación siempre. ¿Deseas activarlo?',
      );
      if (shouldRequestBackground) {
        await _askPermission(context, Permission.locationAlways);
      }
    }
  }

  static Future<void> _askPermission(
      BuildContext context, Permission permission) async {
    try {
      final status = await permission.request();

      if (status.isGranted) return;

      if (status.isDenied) return; // temporalmente denegado

      if (status.isPermanentlyDenied) {
        final go = await _showRationaleDialog(
          context,
          title: 'Permiso requerido',
          message:
              'Este permiso es necesario para el correcto funcionamiento. ¿Deseas abrir ajustes para habilitarlo?',
          confirmLabel: 'Abrir ajustes',
          cancelLabel: 'Cancelar',
        );
        if (go == true) await openAppSettings();
      }
    } catch (e) {
      debugPrint('Error pidiendo permiso $permission: $e');
    }
  }

  static Future<bool> _showRationaleDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Aceptar',
    String cancelLabel = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
