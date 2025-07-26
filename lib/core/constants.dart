class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://auth-users-vgbg.onrender.com';
  static const String baseUrlTerapia ='https://cl-terapia.onrender.com';
  static const String baseUrlGestion = 'https://cl-gestion.onrender.com';
  static const String baseUrlModelo = 'https://cl-modelo.onrender.com';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Interaction Types
  static const String conflictType = 'CONFLICTO';
  static const String supportiveConversationType = 'CONVERSACION_DE_APOYO';
  static const String casualConversationType = 'CONVERSACION_CASUAL';
  static const String intimateConversationType = 'CONVERSACION_INTIMA';

  // Communication Styles
  static const String assertiveCommunication = 'ASERTIVO';
  static const String passiveCommunication = 'PASIVO';
  static const String aggressiveCommunication = 'AGRESIVO';
  static const String passiveAggressiveCommunication = 'PASIVO_AGRESIVO';

  // Physical Contact Levels
  static const String noContactLevel = 'SIN_CONTACTO';
  static const String lightContactLevel = 'CONTACTO_LIGERO';
  static const String moderateContactLevel = 'CONTACTO_MODERADO';
  static const String intimateContactLevel = 'CONTACTO_ÍNTIMO';

  // Task Status
  static const String pendingStatus = 'PENDIENTE';
  static const String completedStatus = 'COMPLETADO';
  static const String delayedStatus = 'DEMORADO';
  
    // Tipos de Tareas
  static const String communicationTask = 'EJERCICIO_DE_COMUNICACIÓN';
  static const String mindfulnessTask = 'EJERCICIO_DE_ATENCIÓN_PLENA';
  static const String intimacyTask = 'CONSTRUCCIÓN_DE_INTIMIDAD';
  static const String conflictResolutionTask = 'RESOLUCIÓN_DE_CONFLICTOS';

  // Lista de Emociones
  static const List<String> emotions = [
    'FELIZ', 'TRISTE', 'ENOJADO', 'ANSIOSO', 'EMOCIONADO', 'FRUSTRADO',
    'AMADO', 'SOLO', 'AGRADECIDO', 'ABRUMADO', 'EN PAZ', 'CONFUNDIDO'
  ];
}

class MockConstants {
  // Mock credentials
  static const String mockEmail = 'admin@cloudlove.com';
  static const String mockPassword = 'admin';
  
  // Enable/disable mock mode
  static const bool useMockData = false;
  
  // Mock user data
  static const Map<String, dynamic> mockUser = {
    'id': 1,
    'email': 'admin@cloudlove.com',
    'firstName': 'Admin',
    'lastName': 'User',
    'profilePictureUrl': 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fchisellabs.com%2Fglossary%2Fwhat-is-user%2F&psig=AOvVaw3PBKbjWEP1qTKgYtSD-_Ri&ust=1752353138327000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCMCi96bWtY4DFQAAAAAdAAAAABAE',
  };
  
  // Mock token
  static const String mockToken = 'mock_jwt_token_12345';
}