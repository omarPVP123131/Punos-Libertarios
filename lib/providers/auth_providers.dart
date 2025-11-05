// lib/providers/auth_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// ============================================================================
// AUTH STATE PROVIDER
// ============================================================================

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authStateChanges;
});

// ============================================================================
// CURRENT USER PROVIDER
// ============================================================================

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenData((state) => state.session?.user).value;
});

// ============================================================================
// IS AUTHENTICATED PROVIDER
// ============================================================================

final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// ============================================================================
// USER ROLE PROVIDER
// ============================================================================

final userRoleProvider = FutureProvider<String>((ref) async {
  final isAuth = ref.watch(isAuthenticatedProvider);
  if (!isAuth) return 'guest';
  return await AuthService.getUserRole();
});

// ============================================================================
// IS ADMIN PROVIDER
// ============================================================================

final isAdminProvider = FutureProvider<bool>((ref) async {
  final role = await ref.watch(userRoleProvider.future);
  return role == 'admin';
});

// ============================================================================
// USER DISPLAY NAME PROVIDER
// ============================================================================

final userDisplayNameProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 'Invitado';
  
  // Prioridad: display_name > email > 'Usuario'
  final displayName = user.userMetadata?['display_name'] as String?;
  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }
  
  final email = user.email;
  if (email != null) {
    return email.split('@').first;
  }
  
  return 'Usuario';
});

// ============================================================================
// USER AVATAR PROVIDER
// ============================================================================

final userAvatarProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userMetadata?['avatar_url'] as String?;
});