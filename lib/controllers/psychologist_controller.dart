// import 'dart:convert';
// import 'package:flutter/material.dart';
// import '../models/psychologist_models.dart';
// import '../services/api_service.dart';

// class PsychologistController extends ChangeNotifier {
//   Psychologist? _currentPsychologist;
//   List<Couple> _couples = [];
//   List<TherapySession> _sessions = [];
//   List<CoupleAnalysis> _analyses = [];
//   bool _isLoading = false;
//   String? _errorMessage;
//   String? _successMessage;

//   // Getters
//   Psychologist? get currentPsychologist => _currentPsychologist;
//   List<Couple> get couples => _couples;
//   List<TherapySession> get sessions => _sessions;
//   List<CoupleAnalysis> get analyses => _analyses;
//   bool get isLoading => _isLoading;
//   String? get errorMessage => _errorMessage;
//   String? get successMessage => _successMessage;

//   void _setLoading(bool loading) {
//     _isLoading = loading;
//     notifyListeners();
//   }

//   void _setError(String? error) {
//     _errorMessage = error;
//     _successMessage = null;
//     notifyListeners();
//   }

//   void _setSuccess(String? message) {
//     _successMessage = message;
//     _errorMessage = null;
//     notifyListeners();
//   }

//   // Login del psicólogo
//   Future<bool> loginPsychologist(String email, String password) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final response = await ApiService.post('/auth/psychologist/login', {
//         'email': email,
//         'password': password,
//       });

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _currentPsychologist = Psychologist.fromJson(data['psychologist']);
//         _setLoading(false);
//         return true;
//       } else {
//         _setError('Credenciales inválidas');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError('Error de conexión. Intente nuevamente.');
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Obtener parejas del psicólogo
//   Future<void> getCouples() async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final response = await ApiService.get('/psychologist/couples', requireAuth: true);

//       if (response.statusCode == 200) {
//         final List<dynamic> couplesJson = jsonDecode(response.body);
//         _couples = couplesJson.map((json) => Couple.fromJson(json)).toList();
//       } else {
//         _setError('Error al cargar parejas');
//       }
//     } catch (e) {
//       _setError('Error de conexión');
//     }

//     _setLoading(false);
//   }

//   // Crear nueva pareja
//   Future<bool> createCouple(CreateCoupleRequest request) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final response = await ApiService.post(
//         '/psychologist/couples',
//         request.toJson(),
//         requireAuth: true,
//       );

//       if (response.statusCode == 201) {
//         _setSuccess('Pareja creada exitosamente');
//         await getCouples(); // Recargar lista
//         _setLoading(false);
//         return true;
//       } else {
//         final data = jsonDecode(response.body);
//         _setError(data['message'] ?? 'Error al crear pareja');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError('Error de conexión');
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Actualizar pareja
//   Future<bool> updateCouple(int coupleId, CoupleStatus status, String objetivos) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final response = await ApiService.put(
//         '/psychologist/couples/$coupleId',
//         {
//           'estado': status.toString().split('.').last,
//           'objetivosTerapia': objetivos,
//         },
//         requireAuth: true,
//       );

//       if (response.statusCode == 200) {
//         _setSuccess('Pareja actualizada exitosamente');
//         await getCouples(); // Recargar lista
//         _setLoading(false);
//         return true;
//       } else {
//         _setError('Error al actualizar pareja');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError('Error de conexión');
//       _setLoading(false);
//       return false;
//     }
//   }

//   // Obtener análisis de parejas
//   Future<void> getCouplesAnalysis() async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final response = await ApiService.get('/psychologist/analysis', requireAuth: true);

//       if (response.statusCode == 200) {
//         final List<dynamic> analysisJson = jsonDecode(response.body);
//         _analyses = analysisJson.map((json) => CoupleAnalysis.fromJson(json)).toList();
//       } else {
//         _setError('Error al cargar análisis');
//       }
//     } catch (e) {
//       _setError('Error de conexión');
//     }

//     _setLoading(false);
//   }

//   // Crear sesión
//   Future<bool> createSession(CreateSessionRequest request) async {
//     _setLoading(true);
//     _setError(null);

//     try {
//       final response = await ApiService.post(
//         '/psychologist/sessions',
//         request.toJson(),
//         requireAuth: true,
//       );

//       if (response.statusCode == 201) {
//         _setSuccess('Sesión creada exitosamente');
//         _setLoading(false);
//         return true;
//       } else {
//         _setError('Error al crear sesión');
//         _setLoading(false);
//         return false;
//       }
//     } catch (e) {
//       _setError('Error de conexión');
//       _setLoading(false);
//       return false;
//     }
//   }

//   void clearMessages() {
//     _errorMessage = null;
//     _successMessage = null;
//     notifyListeners();
//   }

//   void logout() {
//     _currentPsychologist = null;
//     _couples.clear();
//     _sessions.clear();
//     _analyses.clear();
//     notifyListeners();
//   }
// }

// class CreateSessionRequest {
//   final int coupleId;
//   final DateTime fecha;
//   final TimeOfDay hora;
//   final double? costo;
//   final String? notas;
//   final String? modalidad; // 'presencial', 'virtual', 'telefonica'
//   final int? duracionMinutos;

//   CreateSessionRequest({
//     required this.coupleId,
//     required this.fecha,
//     required this.hora,
//     this.costo,
//     this.notas,
//     this.modalidad = 'presencial',
//     this.duracionMinutos = 60,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'coupleId': coupleId,
//       'fecha': fecha.toIso8601String(),
//       'hora': '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}',
//       'costo': costo,
//       'notas': notas,
//       'modalidad': modalidad,
//       'duracionMinutos': duracionMinutos,
//     };
//   }
// }

// class GenerateAnalysisRequest {
//   final int coupleId;
//   final String tipoAnalisis;
//   final List<String>? aspectosEspecificos;
//   final DateTime? fechaInicio;
//   final DateTime? fechaFin;

//   GenerateAnalysisRequest({
//     required this.coupleId,
//     required this.tipoAnalisis,
//     this.aspectosEspecificos,
//     this.fechaInicio,
//     this.fechaFin,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'coupleId': coupleId,
//       'tipoAnalisis': tipoAnalisis,
//       'aspectosEspecificos': aspectosEspecificos,
//       'fechaInicio': fechaInicio?.toIso8601String(),
//       'fechaFin': fechaFin?.toIso8601String(),
//     };
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_habits/core/mock_data.dart';
import '../models/psychologist_models.dart';
import '../services/api_service.dart';
import '../models/session_model.dart' as session_model;
import '../models/ia_analysis_model.dart';

class PsychologistController extends ChangeNotifier {
  Psychologist? _currentPsychologist;
  List<Couple> _couples = [];
  List<TherapySession> _sessions = [];
  List<CoupleAnalysis> _analyses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Getters
  Psychologist? get currentPsychologist => _currentPsychologist;
  List<Couple> get couples => _couples;
  List<TherapySession> get sessions => _sessions;
  List<CoupleAnalysis> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    _successMessage = null;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  // Login del psicólogo
  Future<bool> loginPsychologist(String email, String password) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/auth/psychologist/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentPsychologist = Psychologist.fromJson(data['psychologist']);
        _setLoading(false);
        return true;
      } else {
        _setError('Credenciales inválidas');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión. Intente nuevamente.');
      _setLoading(false);
      return false;
    }
  }

  // Obtener parejas del psicólogo
  Future<void> getCouples() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.get(
        '/psychologist/couples',
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final List<dynamic> couplesJson = jsonDecode(response.body);
        _couples = couplesJson.map((json) => Couple.fromJson(json)).toList();
      } else {
        _setError('Error al cargar parejas');
      }
    } catch (e) {
      _setError('Error de conexión');
    }
    _setLoading(false);
  }

  // Crear nueva pareja
  Future<bool> createCouple(CreateCoupleRequest request) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.post(
        '/psychologist/couples',
        request.toJson(),
        requireAuth: true,
      );
      if (response.statusCode == 201) {
        _setSuccess('Pareja creada exitosamente');
        await getCouples(); // Recargar lista
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Error al crear pareja');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión');
      _setLoading(false);
      return false;
    }
  }

  // Actualizar pareja
  Future<bool> updateCouple(
    int coupleId,
    CoupleStatus status,
    String objetivos,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.put('/psychologist/couples/$coupleId', {
        'estado': status.toString().split('.').last,
        'objetivosTerapia': objetivos,
      }, requireAuth: true);
      if (response.statusCode == 200) {
        _setSuccess('Pareja actualizada exitosamente');
        await getCouples(); // Recargar lista
        _setLoading(false);
        return true;
      } else {
        _setError('Error al actualizar pareja');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión');
      _setLoading(false);
      return false;
    }
  }

  // Obtener análisis de parejas
  Future<void> getCouplesAnalysis() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.get(
        '/psychologist/analysis',
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final List<dynamic> analysisJson = jsonDecode(response.body);
        _analyses =
            analysisJson.map((json) => CoupleAnalysis.fromJson(json)).toList();
      } else {
        _setError('Error al cargar análisis');
      }
    } catch (e) {
      _setError('Error de conexión');
    }
    _setLoading(false);
  }

  // Crear sesión - usando el modelo de session_model.dart
  Future<bool> createSession(session_model.CreateSessionRequest request) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.post(
        '/psychologist/sessions',
        request.toJson(),
        requireAuth: true,
      );
      if (response.statusCode == 201) {
        _setSuccess('Sesión creada exitosamente');
        _setLoading(false);
        return true;
      } else {
        _setError('Error al crear sesión');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión');
      _setLoading(false);
      return false;
    }
  }

  // MÉTODO FALTANTE: Generar análisis con IA
  Future<AIAnalysisResult?> generateAIAnalysis(
    AIAnalysisRequest request,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.post(
        '/psychologist/analysis/generate',
        request.toJson(),
        requireAuth: true,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _setSuccess('Análisis generado exitosamente');
        _setLoading(false);
        return AIAnalysisResult.fromJson(data);
      } else {
        _setError('Error al generar análisis');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Error de conexión');
      _setLoading(false);
      return null;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentPsychologist = null;
    _couples.clear();
    _sessions.clear();
    _analyses.clear();
    notifyListeners();
  }
}

// Clase para generar análisis con IA
class GenerateAnalysisRequest {
  final int coupleId;
  final String tipoAnalisis;
  final List<String>? aspectosEspecificos;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  GenerateAnalysisRequest({
    required this.coupleId,
    required this.tipoAnalisis,
    this.aspectosEspecificos,
    this.fechaInicio,
    this.fechaFin,
  });

  Map<String, dynamic> toJson() {
    return {
      'coupleId': coupleId,
      'tipoAnalisis': tipoAnalisis,
      'aspectosEspecificos': aspectosEspecificos,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
    };
  }
}
