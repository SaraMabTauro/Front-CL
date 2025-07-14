enum SessionStatus { programada, enProgreso, completada, cancelada }
enum SessionType { individual, pareja, grupal, seguimiento }

class TherapySession {
  final int id;
  final int coupleId;
  final int psychologistId;
  final String titulo;
  final String? descripcion;
  final DateTime fechaHora;
  final int duracionMinutos;
  final SessionType tipo;
  final SessionStatus estado;
  final String? notas;
  final String? objetivos;
  final DateTime creadoEn;

  TherapySession({
    required this.id,
    required this.coupleId,
    required this.psychologistId,
    required this.titulo,
    this.descripcion,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.tipo,
    required this.estado,
    this.notas,
    this.objetivos,
    required this.creadoEn,
  });

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'],
      coupleId: json['coupleId'],
      psychologistId: json['psychologistId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaHora: DateTime.parse(json['fechaHora']),
      duracionMinutos: json['duracionMinutos'],
      tipo: SessionType.values.firstWhere((e) => e.toString().split('.').last == json['tipo']),
      estado: SessionStatus.values.firstWhere((e) => e.toString().split('.').last == json['estado']),
      notas: json['notas'],
      objetivos: json['objetivos'],
      creadoEn: DateTime.parse(json['creadoEn']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coupleId': coupleId,
      'psychologistId': psychologistId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaHora': fechaHora.toIso8601String(),
      'duracionMinutos': duracionMinutos,
      'tipo': tipo.toString().split('.').last,
      'estado': estado.toString().split('.').last,
      'notas': notas,
      'objetivos': objetivos,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }
}

class CreateSessionRequest {
  final int coupleId;
  final String titulo;
  final String? descripcion;
  final DateTime fechaHora;
  final int duracionMinutos;
  final SessionType tipo;
  final String? objetivos;

  CreateSessionRequest({
    required this.coupleId,
    required this.titulo,
    this.descripcion,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.tipo,
    this.objetivos,
  });

  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaHora': fechaHora.toIso8601String(),
      'duracionMinutos': duracionMinutos,
      'tipo': tipo.toString().split('.').last,
      'objetivos': objetivos,
    };
  }
}

  