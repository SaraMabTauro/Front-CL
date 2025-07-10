class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://api.cloudlove.com';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // Interaction Types
  static const String conflictType = 'CONFLICT';
  static const String supportiveConversationType = 'SUPPORTIVE_CONVERSATION';
  static const String casualConversationType = 'CASUAL_CONVERSATION';
  static const String intimateConversationType = 'INTIMATE_CONVERSATION';
  
  // Communication Styles
  static const String assertiveCommunication = 'ASSERTIVE';
  static const String passiveCommunication = 'PASSIVE';
  static const String aggressiveCommunication = 'AGGRESSIVE';
  static const String passiveAggressiveCommunication = 'PASSIVE_AGGRESSIVE';
  
  // Physical Contact Levels
  static const String noContactLevel = 'NO_CONTACT';
  static const String lightContactLevel = 'LIGHT_CONTACT';
  static const String moderateContactLevel = 'MODERATE_CONTACT';
  static const String intimateContactLevel = 'INTIMATE_CONTACT';
  
  // Task Status
  static const String pendingStatus = 'PENDING';
  static const String completedStatus = 'COMPLETED';
  static const String delayedStatus = 'DELAYED';
  
  // Task Types
  static const String communicationTask = 'COMMUNICATION_EXERCISE';
  static const String mindfulnessTask = 'MINDFULNESS_EXERCISE';
  static const String intimacyTask = 'INTIMACY_BUILDING';
  static const String conflictResolutionTask = 'CONFLICT_RESOLUTION';
  
  // Emotions List
  static const List<String> emotions = [
    'HAPPY', 'SAD', 'ANGRY', 'ANXIOUS', 'EXCITED', 'FRUSTRATED',
    'LOVED', 'LONELY', 'GRATEFUL', 'OVERWHELMED', 'PEACEFUL', 'CONFUSED'
  ];
}

class MockConstants {
  // Mock credentials
  static const String mockEmail = 'admin';
  static const String mockPassword = 'admin';
  
  // Enable/disable mock mode
  static const bool useMockData = true;
  
  // Mock user data
  static const Map<String, dynamic> mockUser = {
    'id': 1,
    'email': 'admin@cloudlove.com',
    'firstName': 'Admin',
    'lastName': 'User',
    'profilePictureUrl': 'https://via.placeholder.com/150',
  };
  
  // Mock token
  static const String mockToken = 'mock_jwt_token_12345';
}