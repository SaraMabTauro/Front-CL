// Enums
enum UserRole { cliente, psicologo, administrador }
enum LicenseStatus { pendiente, verificada, rechazada }
enum CoupleStatus { pendienteAprobacion, activa, inactiva, rechazada }
enum SessionStatus { agendada, completada, cancelada }
enum TaskStatus { pendiente, completada, retrasada }
enum TaskType { 
  ejercicioComunicacion, 
  actividadAfectiva, 
  resolucionConflictos, 
  reflexionIndividual, 
  exploracionExpectativas 
}

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
      fechaCreacion: json['fechaCreacion'],
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
  final int psicologoId;
  final int cliente1Id;
  final int cliente2Id;
  final CoupleStatus estado;
  final String? objetivosTerapia;
  final DateTime creadoEn;
  final String? nombreCliente1;
  final String? nombreCliente2;
  final String? correoCliente1;
  final String? correoCliente2;

  Couple({
    required this.id,
    required this.psicologoId,
    required this.cliente1Id,
    required this.cliente2Id,
    required this.estado,
    this.objetivosTerapia,
    required this.creadoEn,
    this.nombreCliente1,
    this.nombreCliente2,
    this.correoCliente1,
    this.correoCliente2,
  });

  factory Couple.fromJson(Map<String, dynamic> json) {
    return Couple(
      id: json['id'],
      psicologoId: json['psicologoId'],
      cliente1Id: json['cliente1Id'],
      cliente2Id: json['cliente2Id'],
      estado: CoupleStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['estado']
      ),
      objetivosTerapia: json['objetivosTerapia'],
      creadoEn: DateTime.parse(json['creadoEn']),
      nombreCliente1: json['nombreCliente1'],
      nombreCliente2: json['nombreCliente2'],
      correoCliente1: json['correoCliente1'],
      correoCliente2: json['correoCliente2'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'psicologoId': psicologoId,
      'cliente1Id': cliente1Id,
      'cliente2Id': cliente2Id,
      'estado': estado.toString().split('.').last,
      'objetivosTerapia': objetivosTerapia,
      'creadoEn': creadoEn.toIso8601String(),
    };
  }
}

// Modelo Sesión
class TherapySession {
  final int id;
  final int parejaId;
  final DateTime fechaSesion;
  final double? costo;
  final SessionStatus estado;
  final String? notasSesion;

  TherapySession({
    required this.id,
    required this.parejaId,
    required this.fechaSesion,
    this.costo,
    required this.estado,
    this.notasSesion,
  });

  factory TherapySession.fromJson(Map<String, dynamic> json) {
    return TherapySession(
      id: json['id'],
      parejaId: json['parejaId'],
      fechaSesion: DateTime.parse(json['fechaSesion']),
      costo: json['costo']?.toDouble(),
      estado: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['estado']
      ),
      notasSesion: json['notasSesion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parejaId': parejaId,
      'fechaSesion': fechaSesion.toIso8601String(),
      'costo': costo,
      'estado': estado.toString().split('.').last,
      'notasSesion': notasSesion,
    };
  }
}

// Modelo Análisis de Pareja
class CoupleAnalysis {
  final int parejaId;
  final String nombrePareja;
  final double promedioSentimientoIndividual;
  final double tasaCompletacionTareas;
  final double promedioEstresIndividual;
  final double empatiaGapScore;
  final double interaccionBalanceRatio;
  final int recuentoDeteccionCicloNegativo;
  final double prediccionRiesgoRuptura;
  final DateTime fechaTendencia;
  final List<String> insightsRecientes;

  CoupleAnalysis({
    required this.parejaId,
    required this.nombrePareja,
    required this.promedioSentimientoIndividual,
    required this.tasaCompletacionTareas,
    required this.promedioEstresIndividual,
    required this.empatiaGapScore,
    required this.interaccionBalanceRatio,
    required this.recuentoDeteccionCicloNegativo,
    required this.prediccionRiesgoRuptura,
    required this.fechaTendencia,
    required this.insightsRecientes,
  });

  factory CoupleAnalysis.fromJson(Map<String, dynamic> json) {
    return CoupleAnalysis(
      parejaId: json['parejaId'],
      nombrePareja: json['nombrePareja'],
      promedioSentimientoIndividual: json['promedioSentimientoIndividual']?.toDouble() ?? 0.0,
      tasaCompletacionTareas: json['tasaCompletacionTareas']?.toDouble() ?? 0.0,
      promedioEstresIndividual: json['promedioEstresIndividual']?.toDouble() ?? 0.0,
      empatiaGapScore: json['empatiaGapScore']?.toDouble() ?? 0.0,
      interaccionBalanceRatio: json['interaccionBalanceRatio']?.toDouble() ?? 0.0,
      recuentoDeteccionCicloNegativo: json['recuentoDeteccionCicloNegativo'] ?? 0,
      prediccionRiesgoRuptura: json['prediccionRiesgoRuptura']?.toDouble() ?? 0.0,
      fechaTendencia: DateTime.parse(json['fechaTendencia']),
      insightsRecientes: List<String>.from(json['insightsRecientes'] ?? []),
    );
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

