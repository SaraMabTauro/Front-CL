
enum TaskType {
  individual,
  couple,
} // Un enum para tener tipos seguros y evitar errores de texto

abstract class Tarea {
  final int? id;
  final int psicologoId;
  final String titulo;
  final String descripcion;
  final DateTime fechaLimite;
  final String estado;
  final TaskType type;

  // Constructor para la clase base
  Tarea({
    this.id,
    required this.psicologoId,
    required this.titulo,
    required this.descripcion,
    required this.fechaLimite,
    required this.estado,
    required this.type,
  });
}

class TareaIndividual extends Tarea {
  final int clienteId; 
  final DateTime? completadoEn;
  final DateTime? creadoEn;
  final DateTime? actualizadoEn;

  TareaIndividual({
    super.id,
    required super.psicologoId,
    required this.clienteId, // Se inicializa aquí
    required super.titulo,
    required super.descripcion,
    required super.fechaLimite,
    required super.estado,
    this.completadoEn,
    this.creadoEn,
    this.actualizadoEn,
  }) : super(
         // Se pasan los valores comunes al constructor de Tarea
         type: TaskType.individual,
       );

  // El factory 'fromJson' necesita construir la clase hija
  factory TareaIndividual.fromJson(Map<String, dynamic> json) {
    return TareaIndividual(
      id: json['id'],
      psicologoId: json['psicologoId'],
      clienteId: json['clienteId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaLimite: DateTime.parse(json['fechaLimite']),
      estado: json['estado'],
      completadoEn: json['completadoEn'] == null ? null : DateTime.parse(json['completadoEn']),
      creadoEn: DateTime.parse(json['creadoEn']) ,
      actualizadoEn: DateTime.parse(json['actualizadoEn'] ?? DateTime.now()), // Si no hay actualizadoEn, usamos ahora
    );
  }

  // <-- MÉTODO AÑADIDO (¡ESENCIAL!)
  Map<String, dynamic> toJson() {
    return {
      'psicologoId': psicologoId,
      'clienteId': clienteId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaLimite': fechaLimite.toIso8601String(),
      'estado': estado,
    };
  }
}

class TareaPareja extends Tarea {
  final int parejaId; // Campo específico

  TareaPareja({
    super.id,
    required super.psicologoId,
    required this.parejaId, // Se inicializa aquí
    required super.titulo,
    required super.descripcion,
    required super.fechaLimite,
    required super.estado,
  }) : super(
         type: TaskType.couple,
       );

  // Factory 'fromJson' para la clase hija
  factory TareaPareja.fromJson(Map<String, dynamic> json) {
    return TareaPareja(
      id: json['id'],
      psicologoId: json['psicologoId'],
      parejaId: json['parejaId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaLimite: DateTime.parse(json['fechaLimite']),
      estado: json['estado'],
    );
  }

  // <-- MÉTODO AÑADIDO (¡ESENCIAL!)
  Map<String, dynamic> toJson() {
    return {
      'psicologoId': psicologoId,
      'parejaId': parejaId,
      'titulo': titulo,
      'descripcion': descripcion,
      'fechaLimite': fechaLimite.toIso8601String(),
      'estado': estado,
    };
  }
}

// En models/task_model.dart

// Puedes reemplazar tu antiguo 'TaskFeedback' por este modelo más completo.
class TaskFeedback {
  final int clienteId;
  final int asignacionId; // Este es el ID de la tarea
  final int calificacionSatisfaccion;
  final int calificacionDificultad;
  final int calificacionUtilidad;
  final String? comentarios;

  TaskFeedback({
    required this.clienteId,
    required this.asignacionId,
    required this.calificacionSatisfaccion,
    required this.calificacionDificultad,
    required this.calificacionUtilidad,
    this.comentarios,
  });

  Map<String, dynamic> toJson() {
    // Las claves deben ser idénticas a las que espera tu API
    return {
      'clienteId': clienteId,
      'asignacionId': asignacionId,
      'calificacionSatisfaccion': calificacionSatisfaccion,
      'calificacionDificultad': calificacionDificultad,
      'calificacionUtilidad': calificacionUtilidad,
      'comentarios': comentarios,
    };
  }
}