// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'constants.dart';

// class MockApiService {
//   static Future<http.Response> post(
//     String endpoint,
//     Map<String, dynamic> body, {
//     bool requireAuth = false,
//   }) async {
//     // Simulate network delay
//     await Future.delayed(const Duration(milliseconds: 800));

//     switch (endpoint) {
//       case '/auth/login':
//         return _handleLogin(body);
//       case '/users/register':
//         return _handleRegister(body);
//       case '/journaling/individual-log':
//         return _handleIndividualLog(body);
//       case '/journaling/interaction-log':
//         return _handleInteractionLog(body);
//       case '/auth/psychologist/login':
//         return _handlePsychologistLogin(body);
//       case '/psychologist/couples':
//         return _handleCreateCouple(body);
//       case '/psychologist/sessions':
//         return _handleCreateSession(body);
//       default:
//         if (endpoint.contains('/tasks/') && endpoint.contains('/complete')) {
//           return _handleCompleteTask(endpoint, body);
//         }
//         if (endpoint.contains('/psychologist/couples/') && !endpoint.contains('/complete')) {
//           return _handleUpdateCouple(endpoint, body);
//         }
//         return http.Response('{"message": "Not found"}', 404);
//     }
//   }

//   static Future<http.Response> get(
//     String endpoint, {
//     bool requireAuth = false,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 600));

//     switch (endpoint) {
//       case '/users/me':
//         return _handleGetProfile();
//       case '/tasks':
//         return _handleGetTasks();
//       case '/psychologist/couples':
//         return _handleGetCouples();
//       case '/psychologist/analysis':
//         return _handleGetCouplesAnalysis();
//       default:
//         return http.Response('{"message": "Not found"}', 404);
//     }
//   }

//   static Future<http.Response> put(
//     String endpoint,
//     Map<String, dynamic> body, {
//     bool requireAuth = false,
//   }) async {
//     await Future.delayed(const Duration(milliseconds: 700));

//     switch (endpoint) {
//       case '/users/me':
//         return _handleUpdateProfile(body);
//       default:
//         return http.Response('{"message": "Not found"}', 404);
//     }
//   }

//   // Mock handlers
//   static http.Response _handleLogin(Map<String, dynamic> body) {
//     final email = body['email'];
//     final password = body['password'];

//     if (email == MockConstants.mockEmail &&
//         password == MockConstants.mockPassword) {
//       final response = {
//         'token': MockConstants.mockToken,
//         'user': MockConstants.mockUser,
//       };
//       return http.Response(jsonEncode(response), 200);
//     } else {
//       return http.Response('{"message": "Invalid credentials"}', 401);
//     }
//   }

//   static http.Response _handleRegister(Map<String, dynamic> body) {
//     // Simulate successful registration
//     return http.Response('{"message": "User registered successfully"}', 201);
//   }

//   static http.Response _handleGetProfile() {
//     return http.Response(jsonEncode(MockConstants.mockUser), 200);
//   }

//   static http.Response _handleUpdateProfile(Map<String, dynamic> body) {
//     // Merge updated data with mock user
//     final updatedUser = Map<String, dynamic>.from(MockConstants.mockUser);
//     updatedUser.addAll(body);
//     return http.Response(jsonEncode(updatedUser), 200);
//   }

//   static http.Response _handleIndividualLog(Map<String, dynamic> body) {
//     return http.Response(
//       '{"message": "Individual log submitted successfully"}',
//       201,
//     );
//   }

//   static http.Response _handleInteractionLog(Map<String, dynamic> body) {
//     return http.Response(
//       '{"message": "Interaction log submitted successfully"}',
//       201,
//     );
//   }

//   static http.Response _handleGetTasks() {
//     final tasks = MockData.mockTasks;
//     return http.Response(jsonEncode(tasks), 200);
//   }

//   static http.Response _handleCompleteTask(
//     String endpoint,
//     Map<String, dynamic> body,
//   ) {
//     // Extract task ID from endpoint
//     final taskId = int.tryParse(endpoint.split('/')[2]) ?? 1;

//     // Find and update the task
//     final updatedTask = MockData.mockTasks.firstWhere(
//       (task) => task['id'] == taskId,
//       orElse: () => MockData.mockTasks.first,
//     );

//     // Update status to completed
//     final completedTask = Map<String, dynamic>.from(updatedTask);
//     completedTask['status'] = AppConstants.completedStatus;

//     return http.Response(jsonEncode(completedTask), 200);
//   }

//   // Psychologist handlers
//   static http.Response _handlePsychologistLogin(Map<String, dynamic> body) {
//     final email = body['email'];
//     final password = body['password'];

//     if (email == MockData.mockPsychologistEmail &&
//         password == MockData.mockPsychologistPassword) {
//       final response = {
//         'token': 'mock_psychologist_token_12345',
//         'psychologist': MockData.mockPsychologist,
//       };
//       return http.Response(jsonEncode(response), 200);
//     } else {
//       return http.Response('{"message": "Credenciales inválidas"}', 401);
//     }
//   }

//   static http.Response _handleGetCouples() {
//     return http.Response(jsonEncode(MockData.mockCouples), 200);
//   }

//   static http.Response _handleCreateCouple(Map<String, dynamic> body) {
//     final newCouple = {
//       'id': MockData.mockCouples.length + 1,
//       'psicologoId': 1,
//       'cliente1Id': 100,
//       'cliente2Id': 101,
//       'estado': 'pendienteAprobacion',
//       'objetivosTerapia': body['objetivosTerapia'],
//       'creadoEn': DateTime.now().toIso8601String(),
//       'nombreCliente1': body['nombreCliente1'],
//       'nombreCliente2': body['nombreCliente2'],
//       'correoCliente1': body['correoCliente1'],
//       'correoCliente2': body['correoCliente2'],
//     };

//     MockData.mockCouples.add(newCouple);
//     return http.Response(jsonEncode(newCouple), 201);
//   }

//   static http.Response _handleUpdateCouple(
//     String endpoint,
//     Map<String, dynamic> body,
//   ) {
//     final coupleId = int.tryParse(endpoint.split('/').last) ?? 1;

//     final coupleIndex = MockData.mockCouples.indexWhere(
//       (couple) => couple['id'] == coupleId,
//     );

//     if (coupleIndex != -1) {
//       MockData.mockCouples[coupleIndex]['estado'] = body['estado'];
//       MockData.mockCouples[coupleIndex]['objetivosTerapia'] =
//           body['objetivosTerapia'];
//       return http.Response(jsonEncode(MockData.mockCouples[coupleIndex]), 200);
//     }

//     return http.Response('{"message": "Pareja no encontrada"}', 404);
//   }

//   static http.Response _handleGetCouplesAnalysis() {
//     return http.Response(jsonEncode(MockData.mockCouplesAnalysis), 200);
//   }

//   static http.Response _handleCreateSession(Map<String, dynamic> body) {
//     return http.Response('{"message": "Sesión creada exitosamente"}', 201);
//   }
// }

// class MockData {
//   static final List<Map<String, dynamic>> mockTasks = [
//     {
//       'id': 1,
//       'title': 'Daily Communication Check-in',
//       'description':
//           'Spend 10 minutes sharing how your day went with your partner. Focus on listening without judgment.',
//       'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
//       'status': AppConstants.pendingStatus,
//       'taskType': AppConstants.communicationTask,
//     },
//     {
//       'id': 2,
//       'title': 'Gratitude Exercise',
//       'description':
//           'Write down 3 things you appreciate about your partner and share them.',
//       'dueDate': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
//       'status': AppConstants.pendingStatus,
//       'taskType': AppConstants.mindfulnessTask,
//     },
//     {
//       'id': 3,
//       'title': 'Conflict Resolution Practice',
//       'description':
//           'Practice the "I feel" statements when discussing a minor disagreement.',
//       'dueDate':
//           DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
//       'status': AppConstants.delayedStatus,
//       'taskType': AppConstants.conflictResolutionTask,
//     },
//     {
//       'id': 4,
//       'title': 'Quality Time Activity',
//       'description':
//           'Plan and execute a 30-minute activity together without phones or distractions.',
//       'dueDate':
//           DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
//       'status': AppConstants.completedStatus,
//       'taskType': AppConstants.intimacyTask,
//     },
//     {
//       'id': 5,
//       'title': 'Mindful Breathing Together',
//       'description':
//           'Practice 5 minutes of synchronized breathing with your partner.',
//       'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
//       'status': AppConstants.pendingStatus,
//       'taskType': AppConstants.mindfulnessTask,
//     },
//   ];

//   static final List<Map<String, dynamic>> mockIndividualLogs = [
//     {
//       'id': 1,
//       'situation': 'Had a disagreement about household chores',
//       'thought': 'I feel like I do more work around the house',
//       'emotion': 'FRUSTRATED',
//       'physicalSensation': 'Tension in shoulders and jaw',
//       'behavior': 'Raised my voice and walked away',
//       'stressLevel': 7,
//       'sleepQualityHours': 6.5,
//       'createdAt':
//           DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
//     },
//     {
//       'id': 2,
//       'situation': 'Partner surprised me with my favorite dinner',
//       'thought': 'They really care about making me happy',
//       'emotion': 'LOVED',
//       'physicalSensation': 'Warm feeling in chest',
//       'behavior': 'Gave them a long hug and thanked them',
//       'stressLevel': 2,
//       'sleepQualityHours': 8.5,
//       'createdAt':
//           DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
//     },
//   ];

//   static final List<Map<String, dynamic>> mockInteractionLogs = [
//     {
//       'id': 1,
//       'interactionDescription': 'Discussed weekend plans over breakfast',
//       'interactionType': AppConstants.supportiveConversationType,
//       'myCommunicationStyle': AppConstants.assertiveCommunication,
//       'perceivedPartnerCommunicationStyle': AppConstants.assertiveCommunication,
//       'physicalContactLevel': AppConstants.lightContactLevel,
//       'myEmotionInInteraction': 'HAPPY',
//       'perceivedPartnerEmotion': 'EXCITED',
//       'createdAt':
//           DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
//     },
//     {
//       'id': 2,
//       'interactionDescription': 'Argued about spending money on a vacation',
//       'interactionType': AppConstants.conflictType,
//       'myCommunicationStyle': AppConstants.passiveAggressiveCommunication,
//       'perceivedPartnerCommunicationStyle':
//           AppConstants.aggressiveCommunication,
//       'physicalContactLevel': AppConstants.noContactLevel,
//       'myEmotionInInteraction': 'ANXIOUS',
//       'perceivedPartnerEmotion': 'ANGRY',
//       'createdAt':
//           DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
//     },
//   ];

//   // Agregar al final de la clase MockData:

//   static final Map<String, dynamic> mockPsychologist = {
//     'id': 1,
//     'usuarioId': 100,
//     'cedulaProfesional': 'PSI-12345',
//     'cedulaDocumentoUrl': 'https://example.com/cedula.pdf',
//     'estadoLicencia': 'verificada',
//     'especialidad': 'Terapia de Pareja y Familia',
//     'nombre': 'Dr. María',
//     'apellido': 'González',
//     'correo': 'psicologo@cloudlove.com',
//     'fotoPerfilUrl': 'https://via.placeholder.com/150',
//   };

//   static final List<Map<String, dynamic>> mockCouples = [
//     {
//       'id': 1,
//       'psicologoId': 1,
//       'cliente1Id': 2,
//       'cliente2Id': 3,
//       'estado': 'activa',
//       'objetivosTerapia':
//           'Mejorar la comunicación y resolver conflictos de manera constructiva',
//       'creadoEn':
//           DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
//       'nombreCliente1': 'Juan',
//       'nombreCliente2': 'María',
//       'correoCliente1': 'juan@example.com',
//       'correoCliente2': 'maria@example.com',
//     },
//     {
//       'id': 2,
//       'psicologoId': 1,
//       'cliente1Id': 4,
//       'cliente2Id': 5,
//       'estado': 'pendienteAprobacion',
//       'objetivosTerapia': 'Fortalecer la intimidad emocional y física',
//       'creadoEn':
//           DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
//       'nombreCliente1': 'Carlos',
//       'nombreCliente2': 'Ana',
//       'correoCliente1': 'carlos@example.com',
//       'correoCliente2': 'ana@example.com',
//     },
//     {
//       'id': 3,
//       'psicologoId': 1,
//       'cliente1Id': 6,
//       'cliente2Id': 7,
//       'estado': 'activa',
//       'objetivosTerapia': 'Trabajar en la gestión de emociones y expectativas',
//       'creadoEn':
//           DateTime.now().subtract(const Duration(days: 45)).toIso8601String(),
//       'nombreCliente1': 'Luis',
//       'nombreCliente2': 'Carmen',
//       'correoCliente1': 'luis@example.com',
//       'correoCliente2': 'carmen@example.com',
//     },
//   ];

//   static final List<Map<String, dynamic>> mockCouplesAnalysis = [
//     {
//       'parejaId': 1,
//       'nombrePareja': 'Juan & María',
//       'promedioSentimientoIndividual': 0.65,
//       'tasaCompletacionTareas': 0.80,
//       'promedioEstresIndividual': 6.2,
//       'empatiaGapScore': 0.75,
//       'interaccionBalanceRatio': 0.70,
//       'recuentoDeteccionCicloNegativo': 2,
//       'prediccionRiesgoRuptura': 0.25,
//       'fechaTendencia': DateTime.now().toIso8601String(),
//       'insightsRecientes': [
//         'Mejora significativa en la comunicación durante la última semana',
//         'Se detectó un patrón de evitación en situaciones de conflicto',
//         'Alta correlación entre estrés laboral y tensión en la relación',
//       ],
//     },
//     {
//       'parejaId': 3,
//       'nombrePareja': 'Luis & Carmen',
//       'promedioSentimientoIndividual': 0.45,
//       'tasaCompletacionTareas': 0.60,
//       'promedioEstresIndividual': 7.8,
//       'empatiaGapScore': 0.45,
//       'interaccionBalanceRatio': 0.40,
//       'recuentoDeteccionCicloNegativo': 5,
//       'prediccionRiesgoRuptura': 0.70,
//       'fechaTendencia': DateTime.now().toIso8601String(),
//       'insightsRecientes': [
//         'Ciclo negativo recurrente: crítica → defensividad → retirada',
//         'Baja empatía mutua detectada en las últimas interacciones',
//         'Recomendación: sesión de emergencia para abordar escalada de conflictos',
//       ],
//     },
//   ];

//   // Credenciales mock para psicólogo
//   static const String mockPsychologistEmail = 'psico@cloudlove.com';
//   static const String mockPsychologistPassword = 'psicologo';

// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class MockApiService {
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    switch (endpoint) {
      case '/auth/login':
        return _handleLogin(body);
      case '/users/register':
        return _handleRegister(body);
      case '/journaling/individual-log':
        return _handleIndividualLog(body);
      case '/journaling/interaction-log':
        return _handleInteractionLog(body);
      case '/auth/psychologist/login':
        return _handlePsychologistLogin(body);
      case '/psychologist/couples':
        return _handleCreateCouple(body);
      case '/psychologist/sessions':
        return _handleCreateSession(body);
      case '/psychologist/generate-analysis':
        return _handleGenerateAnalysis(body);
      default:
        if (endpoint.contains('/tasks/') && endpoint.contains('/complete')) {
          return _handleCompleteTask(endpoint, body);
        }
        if (endpoint.contains('/psychologist/couples/') &&
            !endpoint.contains('/complete')) {
          return _handleUpdateCouple(endpoint, body);
        }
        return http.Response('{"message": "Not found"}', 404);
    }
  }

  static Future<http.Response> get(
    String endpoint, {
    bool requireAuth = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    switch (endpoint) {
      case '/users/me':
        return _handleGetProfile();
      case '/tasks':
        return _handleGetTasks();
      case '/psychologist/couples':
        return _handleGetCouples();
      case '/psychologist/analysis':
        return _handleGetCouplesAnalysis();
      default:
        return http.Response('{"message": "Not found"}', 404);
    }
  }

  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requireAuth = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    switch (endpoint) {
      case '/users/me':
        return _handleUpdateProfile(body);
      default:
        return http.Response('{"message": "Not found"}', 404);
    }
  }

  // Mock handlers
  static http.Response _handleLogin(Map<String, dynamic> body) {
    final email = body['email'];
    final password = body['password'];

    if (email == MockConstants.mockEmail &&
        password == MockConstants.mockPassword) {
      final response = {
        'token': MockConstants.mockToken,
        'user': MockConstants.mockUser,
      };
      return http.Response(jsonEncode(response), 200);
    } else {
      return http.Response('{"message": "Invalid credentials"}', 401);
    }
  }

  static http.Response _handleRegister(Map<String, dynamic> body) {
    // Simulate successful registration
    return http.Response('{"message": "User registered successfully"}', 201);
  }

  static http.Response _handleGetProfile() {
    return http.Response(jsonEncode(MockConstants.mockUser), 200);
  }

  static http.Response _handleUpdateProfile(Map<String, dynamic> body) {
    // Merge updated data with mock user
    final updatedUser = Map<String, dynamic>.from(MockConstants.mockUser);
    updatedUser.addAll(body);
    return http.Response(jsonEncode(updatedUser), 200);
  }

  static http.Response _handleIndividualLog(Map<String, dynamic> body) {
    return http.Response(
      '{"message": "Individual log submitted successfully"}',
      201,
    );
  }

  static http.Response _handleInteractionLog(Map<String, dynamic> body) {
    return http.Response(
      '{"message": "Interaction log submitted successfully"}',
      201,
    );
  }

  static http.Response _handleGetTasks() {
    final tasks = MockData.mockTasks;
    return http.Response(jsonEncode(tasks), 200);
  }

  static http.Response _handleCompleteTask(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    // Extract task ID from endpoint
    final taskId = int.tryParse(endpoint.split('/')[2]) ?? 1;

    // Find and update the task
    final updatedTask = MockData.mockTasks.firstWhere(
      (task) => task['id'] == taskId,
      orElse: () => MockData.mockTasks.first,
    );

    // Update status to completed
    final completedTask = Map<String, dynamic>.from(updatedTask);
    completedTask['status'] = AppConstants.completedStatus;

    return http.Response(jsonEncode(completedTask), 200);
  }

  // Psychologist handlers
  static http.Response _handlePsychologistLogin(Map<String, dynamic> body) {
    final email = body['email'];
    final password = body['password'];

    if (email == MockData.mockPsychologistEmail &&
        password == MockData.mockPsychologistPassword) {
      final response = {
        'token': 'mock_psychologist_token_12345',
        'psychologist': MockData.mockPsychologist,
      };
      return http.Response(jsonEncode(response), 200);
    } else {
      return http.Response('{"message": "Credenciales inválidas"}', 401);
    }
  }

  static http.Response _handleGetCouples() {
    return http.Response(jsonEncode(MockData.mockCouples), 200);
  }

  static http.Response _handleCreateCouple(Map<String, dynamic> body) {
    final newCouple = {
      'id': MockData.mockCouples.length + 1,
      'psicologoId': 1,
      'cliente1Id': 100,
      'cliente2Id': 101,
      'estado': 'pendienteAprobacion',
      'objetivosTerapia': body['objetivosTerapia'],
      'creadoEn': DateTime.now().toIso8601String(),
      'nombreCliente1': body['nombreCliente1'],
      'nombreCliente2': body['nombreCliente2'],
      'correoCliente1': body['correoCliente1'],
      'correoCliente2': body['correoCliente2'],
    };

    MockData.mockCouples.add(newCouple);
    return http.Response(jsonEncode(newCouple), 201);
  }

  static http.Response _handleUpdateCouple(
    String endpoint,
    Map<String, dynamic> body,
  ) {
    final coupleId = int.tryParse(endpoint.split('/').last) ?? 1;

    final coupleIndex = MockData.mockCouples.indexWhere(
      (couple) => couple['id'] == coupleId,
    );

    if (coupleIndex != -1) {
      MockData.mockCouples[coupleIndex]['estado'] = body['estado'];
      MockData.mockCouples[coupleIndex]['objetivosTerapia'] =
          body['objetivosTerapia'];
      return http.Response(jsonEncode(MockData.mockCouples[coupleIndex]), 200);
    }

    return http.Response('{"message": "Pareja no encontrada"}', 404);
  }

  static http.Response _handleGetCouplesAnalysis() {
    return http.Response(jsonEncode(MockData.mockCouplesAnalysis), 200);
  }

  static http.Response _handleCreateSession(Map<String, dynamic> body) {
    final newSession = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'coupleId': body['coupleId'],
      'psicologoId': 1,
      'fecha': body['fecha'],
      'hora': body['hora'],
      'modalidad': body['modalidad'] ?? 'presencial',
      'duracionMinutos': body['duracionMinutos'] ?? 60,
      'costo': body['costo'],
      'notas': body['notas'],
      'estado': 'programada',
      'creadoEn': DateTime.now().toIso8601String(),
    };

    return http.Response(jsonEncode(newSession), 201);
  }

  static http.Response _handleGenerateAnalysis(Map<String, dynamic> body) {
    // Simular generación de análisis con IA
    final coupleId = body['coupleId'];
    final tipoAnalisis = body['tipoAnalisis'];

    final newAnalysis = {
      'id': MockData.mockCouplesAnalysis.length + 1,
      'coupleId': coupleId,
      'nombrePareja': 'Análisis Generado',
      'promedioSentimientoIndividual':
          0.65 + (DateTime.now().millisecond % 30) / 100,
      'tasaCompletacionTareas': 0.70 + (DateTime.now().millisecond % 25) / 100,
      'promedioEstresIndividual': 3.0 + (DateTime.now().millisecond % 40) / 10,
      'empatiaGapScore': 0.60 + (DateTime.now().millisecond % 35) / 100,
      'interaccionBalanceRatio': 0.65 + (DateTime.now().millisecond % 30) / 100,
      'recuentoDeteccionCicloNegativo': DateTime.now().millisecond % 6,
      'prediccionRiesgoRuptura': 0.20 + (DateTime.now().millisecond % 50) / 100,
      'insightsRecientes': [
        'Análisis generado automáticamente con IA',
        'Se detectaron patrones de mejora en la comunicación',
        'Recomendación: continuar con las sesiones programadas',
      ],
      'fechaAnalisis': DateTime.now().toIso8601String(),
    };

    MockData.mockCouplesAnalysis.add(newAnalysis);
    return http.Response(jsonEncode(newAnalysis), 200);
  }
}

class MockData {
  // Credenciales del psicólogo
  static const String mockPsychologistEmail = 'psico@cloudlove.com';
  static const String mockPsychologistPassword = 'psicologo';

  // Datos del psicólogo mock
  static const Map<String, dynamic> mockPsychologist = {
    'id': 1,
    'usuarioId': 100,
    'cedulaProfesional': 'PSI-12345',
    'cedulaDocumentoUrl': 'https://example.com/cedula.pdf',
    'estadoLicencia': 'verificada',
    'especialidad': 'Terapia de Pareja y Familia',
    'nombre': 'María',
    'apellido': 'González',
    'correo': 'psico@cloudlove.com', // <-- CAMBIA AQUÍ
    'fotoPerfilUrl': 'https://via.placeholder.com/150',
  };
  // ...existing code...

  // Lista de parejas mock
  static final List<Map<String, dynamic>> mockCouples = [
    {
      'id': 1,
      'psicologoId': 1,
      'cliente1Id': 100,
      'cliente2Id': 101,
      'estado': 'activa',
      'objetivosTerapia':
          'Mejorar la comunicación y resolver conflictos de manera constructiva. Trabajar en la confianza mutua y establecer metas compartidas para el futuro.',
      'creadoEn': '2024-01-20T14:30:00Z',
      'nombreCliente1': 'Ana',
      'nombreCliente2': 'Carlos',
      'correoCliente1': 'ana.martinez@email.com',
      'correoCliente2': 'carlos.rodriguez@email.com',
    },
    {
      'id': 2,
      'psicologoId': 1,
      'cliente1Id': 102,
      'cliente2Id': 103,
      'estado': 'pendienteAprobacion',
      'objetivosTerapia':
          'Superar crisis de pareja después de infidelidad. Reconstruir la confianza y establecer nuevos límites en la relación.',
      'creadoEn': '2024-01-25T09:15:00Z',
      'nombreCliente1': 'Laura',
      'nombreCliente2': 'Miguel',
      'correoCliente1': 'laura.garcia@email.com',
      'correoCliente2': 'miguel.lopez@email.com',
    },
    {
      'id': 3,
      'psicologoId': 1,
      'cliente1Id': 104,
      'cliente2Id': 105,
      'estado': 'activa',
      'objetivosTerapia':
          'Preparación para el matrimonio. Trabajar en expectativas, roles y responsabilidades. Mejorar habilidades de resolución de conflictos.',
      'creadoEn': '2024-02-01T16:45:00Z',
      'nombreCliente1': 'Sofia',
      'nombreCliente2': 'David',
      'correoCliente1': 'sofia.hernandez@email.com',
      'correoCliente2': 'david.morales@email.com',
    },
    {
      'id': 4,
      'psicologoId': 1,
      'cliente1Id': 106,
      'cliente2Id': 107,
      'estado': 'inactiva',
      'objetivosTerapia':
          'Terapia de separación consciente. Aprender a co-parentar de manera efectiva y mantener respeto mutuo.',
      'creadoEn': '2024-01-10T11:20:00Z',
      'nombreCliente1': 'Carmen',
      'nombreCliente2': 'Roberto',
      'correoCliente1': 'carmen.silva@email.com',
      'correoCliente2': 'roberto.torres@email.com',
    },
  ];

  // Análisis de parejas mock
  static final List<Map<String, dynamic>> mockCouplesAnalysis = [
    {
      'id': 1,
      'coupleId': 1,
      'nombrePareja': 'Ana & Carlos',
      'promedioSentimientoIndividual': 0.72,
      'tasaCompletacionTareas': 0.85,
      'promedioEstresIndividual': 4.2,
      'empatiaGapScore': 0.68,
      'interaccionBalanceRatio': 0.75,
      'recuentoDeteccionCicloNegativo': 2,
      'prediccionRiesgoRuptura': 0.25,
      'insightsRecientes': [
        'La pareja muestra una mejora significativa en la comunicación asertiva',
        'Se observa mayor equilibrio en las interacciones positivas vs negativas',
        'Recomendado: continuar con ejercicios de escucha activa',
      ],
      'fechaAnalisis': '2024-02-15T10:00:00Z',
    },
    {
      'id': 2,
      'coupleId': 2,
      'nombrePareja': 'Laura & Miguel',
      'promedioSentimientoIndividual': 0.45,
      'tasaCompletacionTareas': 0.60,
      'promedioEstresIndividual': 7.8,
      'empatiaGapScore': 0.35,
      'interaccionBalanceRatio': 0.40,
      'recuentoDeteccionCicloNegativo': 8,
      'prediccionRiesgoRuptura': 0.78,
      'insightsRecientes': [
        'Alto nivel de estrés individual afecta la dinámica de pareja',
        'Brecha significativa en la percepción emocional mutua',
        'Urgente: implementar técnicas de manejo de crisis',
        'Considerar sesiones individuales complementarias',
      ],
      'fechaAnalisis': '2024-02-15T10:00:00Z',
    },
    {
      'id': 3,
      'coupleId': 3,
      'nombrePareja': 'Sofia & David',
      'promedioSentimientoIndividual': 0.88,
      'tasaCompletacionTareas': 0.92,
      'promedioEstresIndividual': 2.5,
      'empatiaGapScore': 0.85,
      'interaccionBalanceRatio': 0.90,
      'recuentoDeteccionCicloNegativo': 0,
      'prediccionRiesgoRuptura': 0.12,
      'insightsRecientes': [
        'Excelente progreso en todos los indicadores clave',
        'Alta compatibilidad emocional y comunicativa',
        'Listos para transición a sesiones de mantenimiento',
      ],
      'fechaAnalisis': '2024-02-15T10:00:00Z',
    },
    {
      'id': 4,
      'coupleId': 4,
      'nombrePareja': 'Carmen & Roberto',
      'promedioSentimientoIndividual': 0.55,
      'tasaCompletacionTareas': 0.70,
      'promedioEstresIndividual': 6.0,
      'empatiaGapScore': 0.60,
      'interaccionBalanceRatio': 0.65,
      'recuentoDeteccionCicloNegativo': 4,
      'prediccionRiesgoRuptura': 0.45,
      'insightsRecientes': [
        'Progreso estable en el proceso de separación consciente',
        'Mejora en la comunicación sobre temas de co-parentalidad',
        'Mantener enfoque en el bienestar de los hijos',
      ],
      'fechaAnalisis': '2024-02-15T10:00:00Z',
    },
  ];

  // Tareas existentes
  static final List<Map<String, dynamic>> mockTasks = [
    {
      'id': 1,
      'title': 'Daily Communication Check-in',
      'description':
          'Spend 10 minutes sharing how your day went with your partner. Focus on listening without judgment.',
      'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'status': AppConstants.pendingStatus,
      'taskType': AppConstants.communicationTask,
    },
    {
      'id': 2,
      'title': 'Gratitude Exercise',
      'description':
          'Write down 3 things you appreciate about your partner and share them.',
      'dueDate': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'status': AppConstants.pendingStatus,
      'taskType': AppConstants.mindfulnessTask,
    },
    {
      'id': 3,
      'title': 'Conflict Resolution Practice',
      'description':
          'Practice the "I feel" statements when discussing a minor disagreement.',
      'dueDate':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'status': AppConstants.delayedStatus,
      'taskType': AppConstants.conflictResolutionTask,
    },
    {
      'id': 4,
      'title': 'Quality Time Activity',
      'description':
          'Plan and execute a 30-minute activity together without phones or distractions.',
      'dueDate':
          DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'status': AppConstants.completedStatus,
      'taskType': AppConstants.intimacyTask,
    },
    {
      'id': 5,
      'title': 'Mindful Breathing Together',
      'description':
          'Practice 5 minutes of synchronized breathing with your partner.',
      'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'status': AppConstants.pendingStatus,
      'taskType': AppConstants.mindfulnessTask,
    },
  ];

  // Logs individuales existentes
  static final List<Map<String, dynamic>> mockIndividualLogs = [
    {
      'id': 1,
      'situation': 'Had a disagreement about household chores',
      'thought': 'I feel like I do more work around the house',
      'emotion': 'FRUSTRATED',
      'physicalSensation': 'Tension in shoulders and jaw',
      'behavior': 'Raised my voice and walked away',
      'stressLevel': 7,
      'sleepQualityHours': 6.5,
      'createdAt':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
    {
      'id': 2,
      'situation': 'Partner surprised me with my favorite dinner',
      'thought': 'They really care about making me happy',
      'emotion': 'LOVED',
      'physicalSensation': 'Warm feeling in chest',
      'behavior': 'Gave them a long hug and thanked them',
      'stressLevel': 2,
      'sleepQualityHours': 8.5,
      'createdAt':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
  ];

  // Logs de interacción existentes
  static final List<Map<String, dynamic>> mockInteractionLogs = [
    {
      'id': 1,
      'interactionDescription': 'Discussed weekend plans over breakfast',
      'interactionType': AppConstants.supportiveConversationType,
      'myCommunicationStyle': AppConstants.assertiveCommunication,
      'perceivedPartnerCommunicationStyle': AppConstants.assertiveCommunication,
      'physicalContactLevel': AppConstants.lightContactLevel,
      'myEmotionInInteraction': 'HAPPY',
      'perceivedPartnerEmotion': 'EXCITED',
      'createdAt':
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 2,
      'interactionDescription': 'Argued about spending money on a vacation',
      'interactionType': AppConstants.conflictType,
      'myCommunicationStyle': AppConstants.passiveAggressiveCommunication,
      'perceivedPartnerCommunicationStyle':
          AppConstants.aggressiveCommunication,
      'physicalContactLevel': AppConstants.noContactLevel,
      'myEmotionInInteraction': 'ANXIOUS',
      'perceivedPartnerEmotion': 'ANGRY',
      'createdAt':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];
}
