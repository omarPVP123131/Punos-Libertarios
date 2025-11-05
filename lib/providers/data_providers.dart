// lib/providers/data_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/eventos_service.dart';
import '../services/peleadores_service.dart';

// ============================================================================
// EVENTOS PROVIDERS
// ============================================================================

// Stream de eventos
final eventosProvider = StreamProvider<List<Evento>>((ref) {
  return EventosService.getEventosStream();
});

// Solicitudes de eventos (mis solicitudes)
final misSolicitudesEventosProvider = FutureProvider<List<EventoSolicitud>>((
  ref,
) {
  return EventosService.getMisSolicitudes();
});

// Solicitudes pendientes (solo admin)
final solicitudesEventosPendientesProvider =
    FutureProvider<List<EventoSolicitud>>((ref) {
      return EventosService.getSolicitudes(estado: 'pendiente');
    });

// ============================================================================
// PELEADORES PROVIDERS
// ============================================================================

// Stream de peleadores
final peleadoresProvider = StreamProvider<List<Peleador>>((ref) {
  return PeleadoresService.getPeleadoresStream();
});

// Solicitudes de peleadores (mis solicitudes)
final misSolicitudesPeleadoresProvider =
    FutureProvider<List<PeleadorSolicitud>>((ref) {
      return PeleadoresService.getMisSolicitudes();
    });

// Solicitudes pendientes (solo admin)
final solicitudesPeleadoresPendientesProvider =
    FutureProvider<List<PeleadorSolicitud>>((ref) {
      return PeleadoresService.getSolicitudes(estado: 'pendiente');
    });

// Estadísticas de peleadores
final estadisticasPeleadoresProvider = FutureProvider<Map<String, int>>((ref) {
  return PeleadoresService.getEstadisticas();
});

// ============================================================================
// NOTIFICACIONES PROVIDERS
// ============================================================================

// Contador de solicitudes pendientes para admin
final solicitudesPendientesCountProvider = FutureProvider<int>((ref) async {
  final eventosAsync = ref.watch(solicitudesEventosPendientesProvider);
  final peleadoresAsync = ref.watch(solicitudesPeleadoresPendientesProvider);

  return await eventosAsync.when(
    data: (eventos) async {
      return await peleadoresAsync.when(
        data: (peleadores) => eventos.length + peleadores.length,
        loading: () => eventos.length,
        error: (_, __) => eventos.length,
      );
    },
    loading: () => 0,
    error: (_, __) => 0,
  );
});
