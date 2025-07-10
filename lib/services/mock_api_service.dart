import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class MockApiService {
  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool requireAuth = false}) async {
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
      default:
        if (endpoint.contains('/tasks/') && endpoint.contains('/complete')) {
          return _handleCompleteTask(endpoint, body);
        }
        return http.Response('{"message": "Not found"}', 404);
    }
  }
  
  static Future<http.Response> get(String endpoint, {bool requireAuth = false}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    switch (endpoint) {
      case '/users/me':
        return _handleGetProfile();
      case '/tasks':
        return _handleGetTasks();
      default:
        return http.Response('{"message": "Not found"}', 404);
    }
  }
  
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool requireAuth = false}) async {
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
    
    if (email == MockConstants.mockEmail && password == MockConstants.mockPassword) {
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
    return http.Response('{"message": "Individual log submitted successfully"}', 201);
  }
  
  static http.Response _handleInteractionLog(Map<String, dynamic> body) {
    return http.Response('{"message": "Interaction log submitted successfully"}', 201);
  }
  
  static http.Response _handleGetTasks() {
    final tasks = MockData.mockTasks;
    return http.Response(jsonEncode(tasks), 200);
  }
  
  static http.Response _handleCompleteTask(String endpoint, Map<String, dynamic> body) {
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
}

class MockData {
  static final List<Map<String, dynamic>> mockTasks = [
    {
      'id': 1,
      'title': 'Daily Communication Check-in',
      'description': 'Spend 10 minutes sharing how your day went with your partner. Focus on listening without judgment.',
      'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
      'status': AppConstants.pendingStatus,
      'taskType': AppConstants.communicationTask,
    },
    {
      'id': 2,
      'title': 'Gratitude Exercise',
      'description': 'Write down 3 things you appreciate about your partner and share them.',
      'dueDate': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      'status': AppConstants.pendingStatus,
      'taskType': AppConstants.mindfulnessTask,
    },
    {
      'id': 3,
      'title': 'Conflict Resolution Practice',
      'description': 'Practice the "I feel" statements when discussing a minor disagreement.',
      'dueDate': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'status': AppConstants.delayedStatus,
      'taskType': AppConstants.conflictResolutionTask,
    },
    {
      'id': 4,
      'title': 'Quality Time Activity',
      'description': 'Plan and execute a 30-minute activity together without phones or distractions.',
      'dueDate': DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
      'status': AppConstants.completedStatus,
      'taskType': AppConstants.intimacyTask,
    },
    {
      'id': 5,
      'title': 'Mindful Breathing Together',
      'description': 'Practice 5 minutes of synchronized breathing with your partner.',
      'dueDate': DateTime.now().add(const Duration(days: 3)).toIso8601String(),
      'status': AppConstants.pendingStatus,
      'taskType': AppConstants.mindfulnessTask,
    },
  ];
  
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
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
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
      'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
  ];
  
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
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    },
    {
      'id': 2,
      'interactionDescription': 'Argued about spending money on a vacation',
      'interactionType': AppConstants.conflictType,
      'myCommunicationStyle': AppConstants.passiveAggressiveCommunication,
      'perceivedPartnerCommunicationStyle': AppConstants.aggressiveCommunication,
      'physicalContactLevel': AppConstants.noContactLevel,
      'myEmotionInInteraction': 'ANXIOUS',
      'perceivedPartnerEmotion': 'ANGRY',
      'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];
}