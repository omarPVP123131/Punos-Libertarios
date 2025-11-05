// lib/services/peleadores_service.dart
import '../core/supabase_config.dart';
import '../models/models.dart';

class PeleadoresService {
  static final _supabase = SupabaseConfig.client;

  // ============================================================================
  // OBTENER PELEADORES (Stream)
  // ============================================================================

  static Stream<List<Peleador>> getPeleadoresStream() {
    return _supabase
        .from('peleadores')
        .stream(primaryKey: ['id'])
        .eq('activo', true)
        .order('nombre', ascending: true)
        .map((data) => data.map((json) => Peleador.fromJson(json)).toList());
  }

  // ============================================================================
  // OBTENER PELEADORES (Future)
  // ============================================================================

  static Future<List<Peleador>> getPeleadores({bool soloActivos = true}) async {
    // ✅ Usar dynamic para permitir reasignación
    dynamic query = _supabase
        .from('peleadores')
        .select()
        .order('nombre', ascending: true);

    if (soloActivos) {
      query = query.eq('activo', true);
    }

    final response = await query;
    return (response as List).map((json) => Peleador.fromJson(json)).toList();
  }

  // ============================================================================
  // OBTENER PELEADOR POR ID
  // ============================================================================

  static Future<Peleador> getPeleadorById(String id) async {
    final response = await _supabase
        .from('peleadores')
        .select()
        .eq('id', id)
        .single();

    return Peleador.fromJson(response);
  }

  // ============================================================================
  // CREAR PELEADOR (Solo Admin)
  // ============================================================================

  static Future<Peleador> createPeleador(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('peleadores')
        .insert(data)
        .select()
        .single();

    return Peleador.fromJson(response);
  }

  // ============================================================================
  // ACTUALIZAR PELEADOR (Solo Admin)
  // ============================================================================

  static Future<Peleador> updatePeleador(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _supabase
        .from('peleadores')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Peleador.fromJson(response);
  }

  // ============================================================================
  // ELIMINAR PELEADOR (Solo Admin)
  // ============================================================================

  static Future<void> deletePeleador(String id) async {
    await _supabase.from('peleadores').delete().eq('id', id);
  }

  // ============================================================================
  // DESACTIVAR PELEADOR (Soft delete)
  // ============================================================================

  static Future<void> desactivarPeleador(String id) async {
    await _supabase.from('peleadores').update({'activo': false}).eq('id', id);
  }

  // ============================================================================
  // SOLICITUDES DE PELEADORES
  // ============================================================================

  // Crear solicitud
  static Future<PeleadorSolicitud> createSolicitud(
    Map<String, dynamic> data,
  ) async {
    final userId = SupabaseConfig.userId;
    if (userId == null) throw 'Usuario no autenticado';

    data['solicitante_id'] = userId;

    final response = await _supabase
        .from('peleador_solicitudes')
        .insert(data)
        .select()
        .single();

    return PeleadorSolicitud.fromJson(response);
  }

  // Obtener solicitudes (Admin ve todas, user ve solo las suyas)
  static Future<List<PeleadorSolicitud>> getSolicitudes({
    String? estado,
  }) async {
    // ✅ Usar dynamic para permitir reasignación
    dynamic query = _supabase
        .from('peleador_solicitudes')
        .select()
        .order('created_at', ascending: false);

    if (estado != null) {
      query = query.eq('estado_solicitud', estado);
    }

    final response = await query;
    return (response as List)
        .map((json) => PeleadorSolicitud.fromJson(json))
        .toList();
  }

  // Obtener mis solicitudes
  static Future<List<PeleadorSolicitud>> getMisSolicitudes() async {
    final userId = SupabaseConfig.userId;
    if (userId == null) return [];

    final response = await _supabase
        .from('peleador_solicitudes')
        .select()
        .eq('solicitante_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => PeleadorSolicitud.fromJson(json))
        .toList();
  }

  // Aprobar solicitud (Solo Admin)
  static Future<String> aprobarSolicitud(String solicitudId) async {
    final response = await _supabase.rpc(
      'aprobar_peleador_solicitud',
      params: {'solicitud_id': solicitudId},
    );

    return response as String;
  }

  // Rechazar solicitud (Solo Admin)
  static Future<void> rechazarSolicitud(
    String solicitudId,
    String razon,
  ) async {
    await _supabase.rpc(
      'rechazar_peleador_solicitud',
      params: {'solicitud_id': solicitudId, 'razon': razon},
    );
  }

  // Eliminar solicitud
  static Future<void> deleteSolicitud(String id) async {
    await _supabase.from('peleador_solicitudes').delete().eq('id', id);
  }

  // ============================================================================
  // ESTADÍSTICAS
  // ============================================================================

  static Future<Map<String, int>> getEstadisticas() async {
    final peleadores = await getPeleadores();

    int totalVictorias = 0;
    int totalKOs = 0;

    for (var peleador in peleadores) {
      totalVictorias += peleador.victorias;
      totalKOs += peleador.kos;
    }

    return {
      'total_peleadores': peleadores.length,
      'total_victorias': totalVictorias,
      'total_kos': totalKOs,
    };
  }
}
