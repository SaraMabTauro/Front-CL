class IndividualEmotionalLog {
  final String situation;
  final String thought;
  final String emotion;
  final String? physicalSensation;
  final String? behavior;
  final int? stressLevel;
  final double? sleepQualityHours;

  IndividualEmotionalLog({
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
      'situation': situation,
      'thought': thought,
      'emotion': emotion,
      'physicalSensation': physicalSensation,
      'behavior': behavior,
      'stressLevel': stressLevel,
      'sleepQualityHours': sleepQualityHours,
    };
  }
}
