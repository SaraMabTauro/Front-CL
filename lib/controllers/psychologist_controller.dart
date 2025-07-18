import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_habits/core/constants.dart';
import '../models/psychologist_models.dart';
import '../services/api_service.dart';
import '../models/session_model.dart' as session_model;
import '../models/ia_analysis_model.dart';

class PsychologistController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

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
  Future<bool> loginPsychologist(String correo, String contrasena) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/psicologo/login', {
        'correo': correo,
        'contrasena': contrasena,
      });
      print('Response: ${response.body}');
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final psychologistData = data['psicologo'];

        await _storage.write(key: AppConstants.tokenKey, value: token);

        _currentPsychologist = Psychologist.fromJson(psychologistData);
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

  // Registro del psicólogo
  Future<bool> registerPsychologist({
    required String correo,
    required String contrasena,
    required String nombre,
    required String apellido,
    String? fotoPerfilUrl,
    required String especialidad,
    required String cedulaProfesional,
    String? cedulaDocumento,
    required String telefono,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.post('/psicologo', {
        "correo": correo,
        "contrasena": contrasena,
        "nombre": nombre,
        "apellido": apellido,
        "fotoPerfilUrl": fotoPerfilUrl,
        "especialidad": especialidad,
        "cedulaProfesional": cedulaProfesional,
        "cedulaDocumento": cedulaDocumento,
        "telefono": telefono,
      });

      if (response.statusCode == 201) {
        _setSuccess('Registro exitoso. Por favor, inicie sesión.');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Error en el registro');
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

  Future<bool> updatePsychologist(int id, Map<String, dynamic> data) async {
    try {
      final response = await ApiService.patch('/psicologo/$id', data);
      if (response.statusCode == 200) {
        // Usa el método 'copyWith' que añadiremos al modelo
        _currentPsychologist = _currentPsychologist!.copyWith(
          nombre: data['nombre'],
          apellido: data['apellido'],
          correo: data['correo'],
          telefono: data['telefono'],
          especialidad: data['especialidad'],
          cedulaProfesional: data['cedulaProfesional'],
        );
        _setSuccess('Perfil actualizado');
        _setLoading(false);
        //notifyListeners(); // Notifica a la UI que los datos cambiaron
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message'] ?? 'No se pudo actualizar el psicólogo');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión al actualizar el perfil');
      _setLoading(false);
      return false;
    }
  }

  // Crear nueva pareja
  Future<bool> createCouple({
    required int id,
    required int idParejaA,
    required int idParejaB,
    required String objetivosTerapia,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/parejas', {
        'id': id,
        'idParejaA': idParejaA,
        'idParejaB': idParejaB,
        'objetivosTerapia': objetivosTerapia,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Error al crear pareja');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión. Intente nuevamente.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateCouple({
    required int parejaId,
    required String estatus,
    required String objetivosTerapia,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.patch('/parejas/$parejaId', {
        'estatus': estatus,
        'objetivosTerapia': objetivosTerapia,
      });

      if (response.statusCode == 200) {
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Error al actualizar pareja');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión. Intente nuevamente.');
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

  Future<List<Couple>> getAllCouples() async {
    try {
      final response = await ApiService.get('/parejas');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Couple.fromJson(json)).toList();
      } else {
        _setError('No se pudieron obtener las parejas');
        return [];
      }
    } catch (e) {
      _setError('Error de conexión');
      return [];
    }
  }

  Future<List<Psychologist>> getAllPsychologists() async {
    try {
      final response = await ApiService.get('/psicologo');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Psychologist.fromJson(json)).toList();
      } else {
        _setError('No se pudieron obtener los psicólogos');
        return [];
      }
    } catch (e) {
      _setError('Error de conexión');
      return [];
    }
  }

  Future<Psychologist?> getPsychologistById(int id) async {
    try {
      final response = await ApiService.get('/psicologo/$id');
      if (response.statusCode == 200) {
        return Psychologist.fromJson(jsonDecode(response.body));
      } else {
        _setError('No se encontró el psicólogo');
        return null;
      }
    } catch (e) {
      _setError('Error de conexión');
      return null;
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

// Modelo Psicólogo
// class Psychologist {
//   final int id;
//   final int usuarioId;
//   final String cedulaProfesional;
//   final String? cedulaDocumentoUrl;
//   final LicenseStatus estadoLicencia;
//   final String especialidad;
//   final String nombre;
//   final String apellido;
//   final String correo;
//   final String contrasena;
//   final String? fotoPerfilUrl;
//   final String telefono;
//   final String? fechaCreacion;

//   Psychologist({
//     required this.id,
//     required this.usuarioId,
//     required this.cedulaProfesional,
//     this.cedulaDocumentoUrl,
//     required this.estadoLicencia,
//     required this.especialidad,
//     required this.nombre,
//     required this.apellido,
//     required this.correo,
//     required this.contrasena,
//     this.fotoPerfilUrl,
//     required this.telefono,
//     this.fechaCreacion,
//   });

//   factory Psychologist.fromJson(Map<String, dynamic> json) {
//     return Psychologist(
//       id: json['id'],
//       usuarioId: json['usuarioId'] ?? 0,
//       cedulaProfesional: json['cedulaProfesional'],
//       cedulaDocumentoUrl: json['cedulaDocumentoUrl'] ?? json['cedulaDocumento'],
//       estadoLicencia: LicenseStatus.pendiente,
//       especialidad: json['especialidad'],
//       nombre: json['nombre'],
//       apellido: json['apellido'],
//       correo: json['correo'],
//       contrasena: json['contrasena'],
//       fotoPerfilUrl: json['fotoPerfilUrl'],
//       telefono: json['telefono'] ?? '',
//       fechaCreacion: json['fechaCreacion'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'usuarioId': usuarioId,
//       'cedulaProfesional': cedulaProfesional,
//       'cedulaDocumentoUrl': cedulaDocumentoUrl,
//       'estadoLicencia': estadoLicencia.toString().split('.').last,
//       'especialidad': especialidad,
//       'nombre': nombre,
//       'apellido': apellido,
//       'correo': correo,
//       'contrasena': contrasena,
//       'fotoPerfilUrl': fotoPerfilUrl,
//       'telefono': telefono,
//       'fechaCreacion': fechaCreacion,
//     };
//   }
// }

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
