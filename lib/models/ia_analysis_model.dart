class AIAnalysisRequest {
  final int coupleId;
  final String analysisType;
  final Map<String, dynamic>? parameters;

  AIAnalysisRequest({
    required this.coupleId,
    required this.analysisType,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'analysisType': analysisType,
      'parameters': parameters,
    };
  }
}

class AIAnalysisResult {
  final int id;
  final int coupleId;
  final String analysisType;
  final String summary;
  final List<String> insights;
  final List<String> recommendations;
  final Map<String, dynamic> metrics;
  final double confidenceScore;
  final DateTime generatedAt;

  AIAnalysisResult({
    required this.id,
    required this.coupleId,
    required this.analysisType,
    required this.summary,
    required this.insights,
    required this.recommendations,
    required this.metrics,
    required this.confidenceScore,
    required this.generatedAt,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AIAnalysisResult(
      id: json['id'],
      coupleId: json['coupleId'],
      analysisType: json['analysisType'],
      summary: json['summary'],
      insights: List<String>.from(json['insights']),
      recommendations: List<String>.from(json['recommendations']),
      metrics: Map<String, dynamic>.from(json['metrics']),
      confidenceScore: json['confidenceScore'].toDouble(),
      generatedAt: DateTime.parse(json['generatedAt']),
    );
  }
}
