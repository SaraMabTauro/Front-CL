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
  final String conclusion; // <-- CAMPO AÑADIDO

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
    required this.conclusion, // <-- AÑADIDO
  });

  factory CoupleAnalysis.fromJson(Map<String, dynamic> json) {
    return CoupleAnalysis(
      parejaId: json['parejaId'],
      nombrePareja: json['nombrePareja'],
      promedioSentimientoIndividual: (json['promedioSentimientoIndividual'] as num).toDouble(),
      tasaCompletacionTareas: (json['tasaCompletacionTareas'] as num).toDouble(),
      promedioEstresIndividual: (json['promedioEstresIndividual'] as num).toDouble(),
      empatiaGapScore: (json['empatiaGapScore'] as num).toDouble(),
      interaccionBalanceRatio: (json['interaccionBalanceRatio'] as num).toDouble(),
      recuentoDeteccionCicloNegativo: json['recuentoDeteccionCicloNegativo'],
      prediccionRiesgoRuptura: (json['prediccionRiesgoRuptura'] as num).toDouble(),
      fechaTendencia: DateTime.parse(json['fechaTendencia']),
      insightsRecientes: List<String>.from(json['insightsRecientes'] ?? []),
      conclusion: json['conclusion'], // <-- AÑADIDO
    );
  }
}

class AIAnalysisRequest {
  final int coupleId;
  final String analysisType;
  final Map<String, dynamic> parameters;

  AIAnalysisRequest({
    required this.coupleId,
    required this.analysisType,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'analysisType': analysisType,
      'parameters': parameters,
    };
  }
}