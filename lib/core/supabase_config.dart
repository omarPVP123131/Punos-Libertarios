import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // 🔑 REEMPLAZA ESTOS VALORES CON LOS DE TU PROYECTO
  static const String supabaseUrl = 'https://cvcaepnxbocadwrxybhh.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN2Y2FlcG54Ym9jYWR3cnh5YmhoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyOTI0ODEsImV4cCI6MjA3Nzg2ODQ4MX0.sd7OBiZsqQ5VNe7aPtsf2vUbDQoH1iv98pPqkHNd18g';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      // Opciones de storage
      storageOptions: const StorageClientOptions(retryAttempts: 3),
    );
  }

  // Getter para acceso rápido al cliente
  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static String? get userId => currentUser?.id;
}

