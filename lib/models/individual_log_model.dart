class IndividualEmotionalLog {
  final int cliente_id;
  final String situation;
  final String thought;
  final String emotion;
  final String? physicalSensation;
  final String? behavior;
  final int? stressLevel;
  final double? sleepQualityHours;
  final DateTime fechaRegistro;

  IndividualEmotionalLog({
    required this.cliente_id,
    required this.fechaRegistro,
    required this.situation,
    required this.thought,
    required this.emotion,
    this.physicalSensation,
    this.behavior,
    this.stressLevel,
    this.sleepQualityHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'cliente_id': cliente_id,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'situacion': situation,
      'pensamiento': thought,
      'emocion': emotion,
      'sensacion_fisica': physicalSensation,
      'conducta': behavior,
      'nivel_estres': stressLevel,
      'calidad_sueno_horas': sleepQualityHours,
    };
  }
}
