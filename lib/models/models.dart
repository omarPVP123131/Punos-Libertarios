// lib/models/models.dart

// ============================================================================
// EVENTO MODEL
// ============================================================================

class Evento {
  final String id;
  final String titulo;
  final DateTime fecha;
  final String hora;
  final String ubicacion;
  final EventType tipo;
  final String participantes;
  final String imagenUrl;
  final double precio;
  final EventStatus estado;
  final int asistentes;
  final String descripcion;
  final String? createdBy;

  Evento({
    required this.id,
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.ubicacion,
    required this.tipo,
    required this.participantes,
    required this.imagenUrl,
    required this.precio,
    required this.estado,
    this.asistentes = 0,
    this.descripcion = '',
    this.createdBy,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] as String,
      titulo: json['titulo'] ?? '',
      fecha: DateTime.parse(json['fecha']),
      hora: json['hora'] ?? '',
      ubicacion: json['ubicacion'] ?? '',
      tipo: EventType.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => EventType.profesional,
      ),
      participantes: json['participantes'] ?? '',
      imagenUrl: json['imagen_url'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      estado: EventStatus.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EventStatus.proximo,
      ),
      asistentes: json['asistentes'] ?? 0,
      descripcion: json['descripcion'] ?? '',
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'fecha': fecha.toIso8601String(),
      'hora': hora,
      'ubicacion': ubicacion,
      'tipo': tipo.name,
      'participantes': participantes,
      'imagen_url': imagenUrl,
      'precio': precio,
      'estado': estado.name,
      'asistentes': asistentes,
      'descripcion': descripcion,
    };
  }
}

enum EventType { profesional, tradicional, amateur, internacional }

enum EventStatus { proximo, enVivo, finalizado }

extension EventTypeExtension on EventType {
  String get label {
    switch (this) {
      case EventType.profesional:
        return 'Profesional';
      case EventType.tradicional:
        return 'Tradicional';
      case EventType.amateur:
        return 'Amateur';
      case EventType.internacional:
        return 'Internacional';
    }
  }

  String get color {
    switch (this) {
      case EventType.profesional:
        return '#E63946';
      case EventType.tradicional:
        return '#FF6B35';
      case EventType.amateur:
        return '#457B9D';
      case EventType.internacional:
        return '#9B59B6';
    }
  }

  String get icon {
    switch (this) {
      case EventType.profesional:
        return '🏆';
      case EventType.tradicional:
        return '🛕';
      case EventType.amateur:
        return '🥋';
      case EventType.internacional:
        return '🌍';
    }
  }
}

extension EventStatusExtension on EventStatus {
  String get label {
    switch (this) {
      case EventStatus.proximo:
        return 'Próximo';
      case EventStatus.enVivo:
        return 'En Vivo';
      case EventStatus.finalizado:
        return 'Finalizado';
    }
  }
}

// ============================================================================
// PELEADOR MODEL
// ============================================================================

class Peleador {
  final String id;
  final String nombre;
  final String? apodo;
  final String rango;
  final int edad;
  final double peso;
  final double? altura;
  final int experienciaAnos;
  final int victorias;
  final int derrotas;
  final int empates;
  final int kos;
  final String? imagenUrl;
  final String imagenEmoji;
  final String colorHex;
  final String? descripcion;
  final List<String> logros;
  final String? estilo;
  final String? entrenador;
  final String nacionalidad;
  final String? gimnasio;
  final bool activo;
  final String? createdBy;

  Peleador({
    required this.id,
    required this.nombre,
    this.apodo,
    required this.rango,
    required this.edad,
    required this.peso,
    this.altura,
    required this.experienciaAnos,
    this.victorias = 0,
    this.derrotas = 0,
    this.empates = 0,
    this.kos = 0,
    this.imagenUrl,
    this.imagenEmoji = '🥊',
    this.colorHex = '#D32F2F',
    this.descripcion,
    this.logros = const [],
    this.estilo,
    this.entrenador,
    this.nacionalidad = 'México',
    this.gimnasio,
    this.activo = true,
    this.createdBy,
  });

  factory Peleador.fromJson(Map<String, dynamic> json) {
    return Peleador(
      id: json['id'] as String,
      nombre: json['nombre'] ?? '',
      apodo: json['apodo'],
      rango: json['rango'] ?? '',
      edad: json['edad'] ?? 0,
      peso: (json['peso'] ?? 0).toDouble(),
      altura: json['altura'] != null
          ? (json['altura'] as num).toDouble()
          : null,
      experienciaAnos: json['experiencia_anos'] ?? 0,
      victorias: json['victorias'] ?? 0,
      derrotas: json['derrotas'] ?? 0,
      empates: json['empates'] ?? 0,
      kos: json['kos'] ?? 0,
      imagenUrl: json['imagen_url'],
      imagenEmoji: json['imagen_emoji'] ?? '🥊',
      colorHex: json['color_hex'] ?? '#D32F2F',
      descripcion: json['descripcion'],
      logros: json['logros'] != null ? List<String>.from(json['logros']) : [],
      estilo: json['estilo'],
      entrenador: json['entrenador'],
      nacionalidad: json['nacionalidad'] ?? 'México',
      gimnasio: json['gimnasio'],
      activo: json['activo'] ?? true,
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apodo': apodo,
      'rango': rango,
      'edad': edad,
      'peso': peso,
      'altura': altura,
      'experiencia_anos': experienciaAnos,
      'victorias': victorias,
      'derrotas': derrotas,
      'empates': empates,
      'kos': kos,
      'imagen_url': imagenUrl,
      'imagen_emoji': imagenEmoji,
      'color_hex': colorHex,
      'descripcion': descripcion,
      'logros': logros,
      'estilo': estilo,
      'entrenador': entrenador,
      'nacionalidad': nacionalidad,
      'gimnasio': gimnasio,
      'activo': activo,
    };
  }

  String get nombreCompleto {
    if (apodo != null && apodo!.isNotEmpty) {
      return '$nombre "$apodo"';
    }
    return nombre;
  }

  String get record => '$victorias-$derrotas-$empates';
}

// ============================================================================
// SOLICITUD MODELS
// ============================================================================

class EventoSolicitud {
  final String id;
  final Evento evento;
  final String estadoSolicitud; // pendiente, aprobada, rechazada
  final String? razonRechazo;
  final String solicitanteId;
  final String? revisadoPor;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  EventoSolicitud({
    required this.id,
    required this.evento,
    required this.estadoSolicitud,
    this.razonRechazo,
    required this.solicitanteId,
    this.revisadoPor,
    required this.createdAt,
    this.reviewedAt,
  });

  factory EventoSolicitud.fromJson(Map<String, dynamic> json) {
    return EventoSolicitud(
      id: json['id'] as String,
      evento: Evento.fromJson(json),
      estadoSolicitud: json['estado_solicitud'] ?? 'pendiente',
      razonRechazo: json['razon_rechazo'],
      solicitanteId: json['solicitante_id'],
      revisadoPor: json['revisado_por'],
      createdAt: DateTime.parse(json['created_at']),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
    );
  }
}

class PeleadorSolicitud {
  final String id;
  final Peleador peleador;
  final String estadoSolicitud; // pendiente, aprobada, rechazada
  final String? razonRechazo;
  final String solicitanteId;
  final String? revisadoPor;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  PeleadorSolicitud({
    required this.id,
    required this.peleador,
    required this.estadoSolicitud,
    this.razonRechazo,
    required this.solicitanteId,
    this.revisadoPor,
    required this.createdAt,
    this.reviewedAt,
  });

  factory PeleadorSolicitud.fromJson(Map<String, dynamic> json) {
    return PeleadorSolicitud(
      id: json['id'] as String,
      peleador: Peleador.fromJson(json),
      estadoSolicitud: json['estado_solicitud'] ?? 'pendiente',
      razonRechazo: json['razon_rechazo'],
      solicitanteId: json['solicitante_id'],
      revisadoPor: json['revisado_por'],
      createdAt: DateTime.parse(json['created_at']),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
    );
  }
}
