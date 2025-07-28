 enum SessionStatus { programada, enProgreso, completada, cancelada }
enum SessionType { individual, pareja, grupal, seguimiento }

class TherapySession {
  final int id;
  final int idPareja;
  final int psychologistId;
  final String titulo;
  final String? descripcion;
  final DateTime fechaHora;
  final int duracionMinutos;
  final SessionType tipo;
  final SessionStatus estado;
  final double costo;
  final String? notas;
  final String? objetivos;
  final DateTime creadoEn;

  TherapySession({
    required this.id,
    required this.idPareja,
    required this.psychologistId,
    required this.titulo,
    this.descripcion,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.tipo,
    required this.estado,
    this.costo = 0.0,
    this.notas,
    this.objetivos,
    required this.creadoEn,
  });

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'],
      idPareja: json['idPareja'],
      psychologistId: json['psychologistId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaHora: DateTime.parse(json['fechaHora']),
      duracionMinutos: json['duracionMinutos'],
      tipo: SessionType.values.firstWhere((e) => e.toString().split('.').last == json['tipo']),
      estado: SessionStatus.values.firstWhere((e) => e.toString().split('.').last == json['estado']),
      costo: json['costo']?.toDouble() ?? 0.0,
      notas: json['notas'],
      objetivos: json['objetivos'],
      creadoEn: DateTime.parse(json['creadoEn']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPareja': idPareja,
      'psychologistId': psychologistId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaHora': fechaHora.toIso8601String(),
      'duracionMinutos': duracionMinutos,
      'tipo': tipo.toString().split('.').last,
      'estado': estado.toString().split('.').last,
      'costo': costo,
      'notas': notas,
      'objetivos': objetivos,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }
}

class CreateSessionRequest {
  final int idPareja;
  final int psychologistId;
  final String titulo;
  final String? descripcion;
  final DateTime fechaHora;
  final int duracionMinutos;
  final SessionType tipo;
  final double costo;
  final String? notas;
  final String? objetivos;
  final SessionStatus estado;

  CreateSessionRequest({
    required this.idPareja,
    required this.psychologistId,
    required this.titulo,
    this.descripcion,
    required this.fechaHora,
    required this.duracionMinutos,
    required this.tipo,
    this.notas,
    this.objetivos,
    this.costo = 0.0,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'idPareja': idPareja,
      'psychologistId': psychologistId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaHora': fechaHora.toIso8601String(), // <-- CLAVE CORREGIDA
      'duracionMinutos': duracionMinutos,
      'tipo': tipo.toString().split('.').last,
      'estado': estado.toString().split('.').last, // <-- CAMPO AÑADIDO
      'costo': costo,
      'notas': notas,
      'objetivos': objetivos,
    };
  }
 }

// class TherapySession {
//   final int? id;
//   final int idPareja;
//   final DateTime fechaSesion;
//   final double costo;
//   final String estatus;
//   final String? notas;

//   TherapySession({
//     this.id,
//     required this.idPareja,
//     required this.fechaSesion,
//     required this.costo,
//     required this.estatus,
//     this.notas,
//   });

//   // Convierte un objeto JSON (de la API) a un objeto TherapySession
//   factory TherapySession.fromJson(Map<String, dynamic> json) {
//     return TherapySession(
//       id: json['id'],
//       idPareja: json['idPareja'],
//       fechaSesion: DateTime.parse(json['fechaSesion']),
//       costo: (json['costo'] as num).toDouble(), // Se asegura de que sea un double
//       estatus: json['estatus'],
//       notas: json['notas'],
//     );
//   }

//   // Convierte un objeto TherapySession a JSON (para enviarlo a la API)
//   Map<String, dynamic> toJson() {
//     return {
//       'idPareja': idPareja,
//       'fechaSesion': fechaSesion.toIso8601String(),
//       'costo': costo,
//       'estatus': estatus,
//       'notas': notas,
//     };
//   }
// }

// class CreateSessionRequest {
//   final int coupleId;
//   final String titulo;
//   final String? descripcion;
//   final DateTime fechaHora;
//   final int duracionMinutos;
//   final SessionType tipo;
//   final String? objetivos;

//   CreateSessionRequest({
//     required this.coupleId,
//     required this.titulo,
//     this.descripcion,
//     required this.fechaHora,
//     required this.duracionMinutos,
//     required this.tipo,
//     this.objetivos,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'coupleId': coupleId,
//       'titulo': titulo,
//       'descripcion': descripcion,
//       'fechaHora': fechaHora.toIso8601String(),
//       'duracionMinutos': duracionMinutos,
//       'tipo': tipo.toString().split('.').last,
//       'objetivos': objetivos,
//     };
//   }
// }