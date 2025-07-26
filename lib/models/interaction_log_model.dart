class InteractionLog {
  final int reporterClientId;
  final int coupleId;
  final DateTime interactionDate;
  final String interactionDescription;
  final String interactionType;
  final String? myCommunicationStyle;
  final String? perceivedPartnerCommunicationStyle;
  final String? physicalContactLevel;
  final String myEmotionInInteraction;
  final String? perceivedPartnerEmotion;

  InteractionLog({
    required this.reporterClientId,
    required this.coupleId,
    required this.interactionDate,
    required this.interactionDescription,
    required this.interactionType,
    this.myCommunicationStyle,
    this.perceivedPartnerCommunicationStyle,
    this.physicalContactLevel,
    required this.myEmotionInInteraction,
    this.perceivedPartnerEmotion,
  });

  Map<String, dynamic> toJson() {
    return {
      'reporter_client_id': reporterClientId,
      'couple_id': coupleId,
      'interaction_date': interactionDate.toIso8601String(),
      'interaction_description': interactionDescription,
      'interaction_type': interactionType,
      'my_communication_style': myCommunicationStyle,
      'perceived_partner_communication_style': perceivedPartnerCommunicationStyle,
      'physical_contact_level': physicalContactLevel,
      'my_emotion_in_interaction': myEmotionInInteraction,
      'perceived_partner_emotion': perceivedPartnerEmotion,
    };
  }
}
