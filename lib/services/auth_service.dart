// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_config.dart';

class AuthService {
  static final _supabase = SupabaseConfig.client;

  // ============================================================================
  // VERIFICAR ESTADO DE AUTENTICACIÓN
  // ============================================================================

  static User? get currentUser => _supabase.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  // ============================================================================
  // OBTENER ROL DEL USUARIO
  // ============================================================================

  static Future<String> getUserRole() async {
    if (!isAuthenticated) return 'guest';

    try {
      final response = await _supabase
          .from('user_roles')
          .select('role')
          .eq('user_id', currentUser!.id)
          .single();

      return response['role'] ?? 'user';
    } catch (e) {
      print('Error obteniendo rol: $e');
      return 'user';
    }
  }

  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  // ============================================================================
  // REGISTRO CON EMAIL
  // ============================================================================

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );

      if (response.user != null) {
        print('✅ Usuario registrado: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      print('❌ Error en registro: $e');
      rethrow;
    }
  }

  // ============================================================================
  // INICIO DE SESIÓN CON EMAIL
  // ============================================================================

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print('✅ Sesión iniciada: ${response.user!.email}');
      }

      return response;
    } catch (e) {
      print('❌ Error en inicio de sesión: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CERRAR SESIÓN
  // ============================================================================

  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      print('✅ Sesión cerrada');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
      rethrow;
    }
  }

  // ============================================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================================

  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      print('✅ Email de recuperación enviado a: $email');
    } catch (e) {
      print('❌ Error al enviar email de recuperación: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ACTUALIZAR PERFIL
  // ============================================================================

  static Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabase.auth.updateUser(UserAttributes(data: updates));

      print('✅ Perfil actualizado');
    } catch (e) {
      print('❌ Error al actualizar perfil: $e');
      rethrow;
    }
  }

  // ============================================================================
  // ELIMINAR CUENTA
  // ============================================================================

  static Future<void> deleteAccount() async {
    try {
      // Nota: Requiere configuración adicional en Supabase
      final userId = currentUser?.id;
      if (userId != null) {
        // Eliminar rol
        await _supabase.from('user_roles').delete().eq('user_id', userId);

        // Nota: La eliminación del usuario de auth.users requiere
        // una función en el backend o admin API
        print('⚠️ Cuenta marcada para eliminación');
      }
    } catch (e) {
      print('❌ Error al eliminar cuenta: $e');
      rethrow;
    }
  }

  // ============================================================================
  // VERIFICAR SI EL EMAIL EXISTE
  // ============================================================================

  static Future<bool> emailExists(String email) async {
    try {
      // Intenta iniciar sesión con una contraseña incorrecta
      // Si el email no existe, recibirás un error diferente
      await _supabase.auth.signInWithPassword(
        email: email,
        password: 'intentional_wrong_password',
      );
      return true;
    } on AuthException catch (e) {
      // Si el error es de credenciales inválidas, el email existe
      if (e.message.toLowerCase().contains('invalid')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
