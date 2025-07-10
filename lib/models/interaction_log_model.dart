class InteractionLog {
  final String interactionDescription;
  final String interactionType;
  final String? myCommunicationStyle;
  final String? perceivedPartnerCommunicationStyle;
  final String? physicalContactLevel;
  final String myEmotionInInteraction;
  final String? perceivedPartnerEmotion;

  InteractionLog({
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
      'interactionDescription': interactionDescription,
      'interactionType': interactionType,
      'myCommunicationStyle': myCommunicationStyle,
      'perceivedPartnerCommunicationStyle': perceivedPartnerCommunicationStyle,
      'physicalContactLevel': physicalContactLevel,
      'myEmotionInInteraction': myEmotionInInteraction,
      'perceivedPartnerEmotion': perceivedPartnerEmotion,
    };
  }
}
