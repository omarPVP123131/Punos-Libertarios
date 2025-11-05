// lib/services/eventos_service.dart
import '../core/supabase_config.dart';
import '../models/models.dart';

class EventosService {
  static final _supabase = SupabaseConfig.client;

  // ============================================================================
  // OBTENER EVENTOS (Stream)
  // ============================================================================

  static Stream<List<Evento>> getEventosStream() {
    return _supabase
        .from('eventos')
        .stream(primaryKey: ['id'])
        .order('fecha', ascending: true)
        .map((data) => data.map((json) => Evento.fromJson(json)).toList());
  }

  // ============================================================================
  // OBTENER EVENTOS (Future)
  // ============================================================================

  static Future<List<Evento>> getEventos() async {
    final response = await _supabase
        .from('eventos')
        .select()
        .order('fecha', ascending: true);

    return (response as List).map((json) => Evento.fromJson(json)).toList();
  }

  // ============================================================================
  // CREAR EVENTO (Solo Admin)
  // ============================================================================

  static Future<Evento> createEvento(Map<String, dynamic> data) async {
    final response = await _supabase
        .from('eventos')
        .insert(data)
        .select()
        .single();

    return Evento.fromJson(response);
  }

  // ============================================================================
  // ACTUALIZAR EVENTO (Solo Admin)
  // ============================================================================

  static Future<Evento> updateEvento(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _supabase
        .from('eventos')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Evento.fromJson(response);
  }

  // ============================================================================
  // ELIMINAR EVENTO (Solo Admin)
  // ============================================================================

  static Future<void> deleteEvento(String id) async {
    await _supabase.from('eventos').delete().eq('id', id);
  }

  // ============================================================================
  // SOLICITUDES DE EVENTOS
  // ============================================================================

  // Crear solicitud
  static Future<EventoSolicitud> createSolicitud(
    Map<String, dynamic> data,
  ) async {
    final userId = SupabaseConfig.userId;
    if (userId == null) throw 'Usuario no autenticado';

    data['solicitante_id'] = userId;

    final response = await _supabase
        .from('evento_solicitudes')
        .insert(data)
        .select()
        .single();

    return EventoSolicitud.fromJson(response);
  }

  // Obtener solicitudes (Admin ve todas, user ve solo las suyas)
  static Future<List<EventoSolicitud>> getSolicitudes({String? estado}) async {
    // ✅ Construir query condicionalmente con dynamic
    dynamic query = _supabase
        .from('evento_solicitudes')
        .select()
        .order('created_at', ascending: false);

    // Aplicar filtro de estado si existe
    if (estado != null) {
      query = query.eq('estado_solicitud', estado);
    }

    final response = await query;
    return (response as List)
        .map((json) => EventoSolicitud.fromJson(json))
        .toList();
  }

  // Obtener mis solicitudes
  static Future<List<EventoSolicitud>> getMisSolicitudes() async {
    final userId = SupabaseConfig.userId;
    if (userId == null) return [];

    final response = await _supabase
        .from('evento_solicitudes')
        .select()
        .eq('solicitante_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => EventoSolicitud.fromJson(json))
        .toList();
  }

  // Aprobar solicitud (Solo Admin)
  static Future<String> aprobarSolicitud(String solicitudId) async {
    final response = await _supabase.rpc(
      'aprobar_evento_solicitud',
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
      'rechazar_evento_solicitud',
      params: {'solicitud_id': solicitudId, 'razon': razon},
    );
  }

  // Eliminar solicitud
  static Future<void> deleteSolicitud(String id) async {
    await _supabase.from('evento_solicitudes').delete().eq('id', id);
  }
}
