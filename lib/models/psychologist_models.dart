// Enums
enum UserRole { cliente, psicologo, administrador }
enum LicenseStatus { pendiente, verificada, rechazada }
enum CoupleStatus { pendienteAprobacion, activa, inactiva, rechazada }
// enum SessionStatus { agendada, completada, cancelada }
enum TaskStatus { pendiente, completada, retrasada }
// enum TaskType { 
//   ejercicioComunicacion, 
//   actividadAfectiva, 
//   resolucionConflictos, 
//   reflexionIndividual, 
//   exploracionExpectativas 
// }

// Modelo Psicólogo
class Psychologist {
  final int id;
  final int usuarioId;
  final String cedulaProfesional;
  final String? cedulaDocumentoUrl;
  final LicenseStatus estadoLicencia;
  final String especialidad;
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;
  final String? fotoPerfilUrl;
  final String telefono;
  final DateTime? fechaCreacion;

  Psychologist({
    required this.id,
    required this.usuarioId,
    required this.cedulaProfesional,
    this.cedulaDocumentoUrl,
    required this.estadoLicencia,
    required this.especialidad,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
    this.fotoPerfilUrl,
    required this.telefono,
    this.fechaCreacion,
  });

  // CORRECIÓN: Añade un método copyWith. Es fundamental para manejar el estado inmutable.
  Psychologist copyWith({
    int? id,
    int? usuarioId,
    String? cedulaProfesional,
    String? cedulaDocumentoUrl,
    LicenseStatus? estadoLicencia,
    String? especialidad,
    String? nombre,
    String? apellido,
    String? correo,
    String? contrasena,
    String? fotoPerfilUrl,
    String? telefono,
    DateTime? fechaCreacion,
  }){
    return Psychologist(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      cedulaProfesional: cedulaProfesional ?? this.cedulaProfesional,
      cedulaDocumentoUrl: cedulaDocumentoUrl ?? this.cedulaDocumentoUrl,
      estadoLicencia: estadoLicencia ?? this.estadoLicencia,
      especialidad: especialidad ?? this.especialidad,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      contrasena: contrasena ?? this.contrasena,
      fotoPerfilUrl: fotoPerfilUrl ?? this.fotoPerfilUrl,
      telefono: telefono ?? this.telefono,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  } 

  factory Psychologist.fromJson(Map<String, dynamic> json) {
    return Psychologist(
      id: json['id'],
      usuarioId: json['usuarioId'] ?? 0,
      cedulaProfesional: json['cedulaProfesional'],
      cedulaDocumentoUrl: json['cedulaDocumentoUrl'] ?? json['cedulaDocumento'],
      estadoLicencia: LicenseStatus.pendiente,
      especialidad: json['especialidad'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
      contrasena: json['contrasena'],
      fotoPerfilUrl: json['fotoPerfilUrl'],
      telefono: json['telefono'] ?? '',
      fechaCreacion: json['fechaCreacion'] != null 
                    ? DateTime.parse(json['fechaCreacion']) 
                    : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'cedulaProfesional': cedulaProfesional,
      'cedulaDocumentoUrl': cedulaDocumentoUrl,
      'estadoLicencia': estadoLicencia.toString().split('.').last,
      'especialidad': especialidad,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'contrasena': contrasena,
      'fotoPerfilUrl': fotoPerfilUrl,
      'telefono': telefono,
      'fechaCreacion': fechaCreacion,
    };
  }
}

// Modelo Pareja
class Couple {
  final int id;
  final CoupleStatus estado;
  final String? objetivosTerapia;
  final DateTime creadoEn;
  String? nombreCliente1;
  String? nombreCliente2;
  String? correoCliente1;
  String? correoCliente2;
  final List<CoupleMemberId> miembrosIds;

  String get fullCoupleName {
    final name1 = nombreCliente1 ?? 'Cliente 1';
    final name2 = nombreCliente2 ?? 'Cliente 2';
    return '$name1 & $name2';
  }

  Couple({
    required this.id,
    required this.estado,
    this.objetivosTerapia,
    required this.creadoEn,
    required this.miembrosIds,
  });

  factory Couple.fromJson(Map<String, dynamic> json) {

    var miembrosList = json['miembros'] as List? ?? []; // Manejo seguro de nulos
    List<CoupleMemberId> miembrosIds = miembrosList.map((i) => CoupleMemberId.fromJson(i)).toList();

    return Couple(
      id: json['id'],
      estado: CoupleStatus.values.firstWhere(
        (e) => e.name == json['estatus'],
        orElse: () => CoupleStatus.inactiva,
      ),
      objetivosTerapia: json['objetivosTerapia'],
      creadoEn: DateTime.parse(json['fechaCreacion']),
      miembrosIds: miembrosIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'estatus': estado.toString().split('.').last,
      'objetivosTerapia': objetivosTerapia,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }
}

class CoupleMemberId {
  final int id;
  CoupleMemberId({required this.id});

  factory CoupleMemberId.fromJson(Map<String, dynamic> json) {
    return CoupleMemberId(id: json['id']);
  }
}

// Modelo para crear nueva pareja
class CreateCoupleRequest {
  final String nombreCliente1;
  final String apellidoCliente1;
  final String correoCliente1;
  final String nombreCliente2;
  final String apellidoCliente2;
  final String correoCliente2;
  final String objetivosTerapia;

  CreateCoupleRequest({
    required this.nombreCliente1,
    required this.apellidoCliente1,
    required this.correoCliente1,
    required this.nombreCliente2,
    required this.apellidoCliente2,
    required this.correoCliente2,
    required this.objetivosTerapia,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreCliente1': nombreCliente1,
      'apellidoCliente1': apellidoCliente1,
      'correoCliente1': correoCliente1,
      'nombreCliente2': nombreCliente2,
      'apellidoCliente2': apellidoCliente2,
      'correoCliente2': correoCliente2,
      'objetivosTerapia': objetivosTerapia,
    };
  }
}


