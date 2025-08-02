import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_habits/controllers/auth_controller.dart';
import 'package:smart_habits/core/constants.dart';
import '../models/psychologist_models.dart';
import '../services/api_service.dart';
import '../models/session_model.dart';
import '../models/task_model.dart';
import '../models/ia_analysis_model.dart';
import '../models/user_model.dart';
import '../services/ai_service.dart';

class PsychologistController extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();

  Psychologist? _currentPsychologist;
  TherapySession? _currentTherapySession;
  List<Couple> _couples = [];
  List<TherapySession> _sessions = [];
  List<Tarea> _coupleTasks = [];
  List<CoupleAnalysis> _analyses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  List<Client> _individualClients = [];
  List<TareaIndividual> _individualTasksAssigned = [];
  List<TareaPareja> _coupleTasksAssigned = [];

  // Getters
  Psychologist? get currentPsychologist => _currentPsychologist;
  List<Couple> get couples => _couples;
  List<TherapySession> get sessions => _sessions;
  List<Tarea> get coupleTasks => _coupleTasks;
  List<CoupleAnalysis> get analyses => _analyses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<Client> get individualClients => _individualClients;
  bool get isAuthenticated => _currentPsychologist != null;
  List<Tarea> get allAssignedTasks {
    return List<Tarea>.from(_individualTasksAssigned)
      ..addAll(_coupleTasksAssigned);
  }

  List<TherapySession> get sessionsToday {
    final now = DateTime.now();
    return _sessions.where((session) {
      return session.fechaHora.year == now.year &&
          session.fechaHora.month == now.month &&
          session.fechaHora.day == now.day;
    }).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void sendLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setitError(String? message) {
    _errorMessage = message;
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
      // _setError('Error de conexión. Intente nuevamente.');
      // _setLoading(false);
      // return false;
      print('¡ERROR ATRAPADO EN EL LOGIN!');
      print('Tipo de error: ${e.runtimeType}');
      print('Error: $e');

      _setError(
        'Error procesando los datos del usuario.',
      ); // Un mensaje más preciso
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

  /// ¡NUEVO! Método principal para cargar todos los datos del psicólogo.
  Future<void> fetchDashboardData(AuthController authController) async {
    if (_currentPsychologist == null) {
      _setError("Psicólogo no autenticado.");
      return;
    } // No hacer nada si no hay psicólogo

    _setLoading(true);
    _setError(null);
    notifyListeners();

    await Future.wait([
      getCouplesForPsychologist(_currentPsychologist!.id, authController),
      getPatientsForPsychologist(_currentPsychologist!.id),
      getSessionsForPsychologist(_currentPsychologist!.id),
      getAllTasksForPsychologist(_currentPsychologist!.id),
      getCouplesAnalysis(),
    ]);
    _setLoading(false);
    notifyListeners();
  }

  Future<void> getAllTasksForPsychologist(int psychologistId) async {
    // Ejecutamos ambas en paralelo para eficiencia
    await Future.wait([
      getIndividualTasksForPsychologist(psychologistId),
      getCoupleTasksForPsychologist(psychologistId),
    ]);
  }

  /// Obtiene las tareas individuales asignadas por un psicólogo.
  Future<void> getIndividualTasksForPsychologist(int psychologistId) async {
    try {
      final response = await ApiService.get(
        '/asignacion-individual/por-psicologo/$psychologistId',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _individualTasksAssigned =
            data.map((item) => TareaIndividual.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error al obtener tareas individuales del psicólogo: $e');
    }
  }

  // Obtiene las tareas de pareja asignadas por un psicólogo.
  Future<void> getCoupleTasksForPsychologist(int psychologistId) async {
    try {
      // NOTA: Necesitarás un endpoint como este en tu backend.
      // Si no lo tienes, puedes omitir esta llamada por ahora.
      final response = await ApiService.get(
        '/asignacion-pareja/por-psicologo/$psychologistId',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _coupleTasksAssigned = data.map((item) => TareaPareja.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error al obtener tareas de pareja del psicólogo: $e');
    }
  }


  Future<void> getCouplesForPsychologist(
    int psychologistId,
    AuthController authController,
  ) async {
    try {
      // 1. OBTENER DATOS BASE
      final response = await ApiService.get(
        '/parejas/psicologo/$psychologistId',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia, // URL del servicio de TERAPIA
      );

      if (response.statusCode != 200) {
        _setError('Error al obtener la lista de parejas: ${response.body}');
        return;
      }

      final List<dynamic> data = jsonDecode(response.body);
      // El 'fromJson' corregido ahora funciona con esta respuesta
      List<Couple> tempCouples =
          data.map((item) => Couple.fromJson(item)).toList();

      // 2. ENRIQUECER DATOS
      for (var couple in tempCouples) {
        if (couple.miembrosIds.isNotEmpty) {
          // --- BLOQUE DE DEPURACIÓN Y LÓGICA CLARA ---
          final userId1 = couple.miembrosIds[0].id;
          print("Enriqueciendo... Obteniendo datos para usuario ID: $userId1");
          final user1 = await authController.getUserById(userId1);
          if (user1 != null) {
            couple.nombreCliente1 = '${user1.nombre} ${user1.apellido}';
            couple.correoCliente1 = user1.correo;
          } else {
            couple.nombreCliente1 = 'Usuario ID $userId1 no encontrado';
          }
        }
        if (couple.miembrosIds.length > 1) {
          final userId2 = couple.miembrosIds[1].id;
          print("Enriqueciendo... Obteniendo datos para usuario ID: $userId2");
          final user2 = await authController.getUserById(userId2);
          if (user2 != null) {
            couple.nombreCliente2 = '${user2.nombre} ${user2.apellido}';
            couple.correoCliente2 = user2.correo;
          } else {
            couple.nombreCliente2 = 'Usuario ID $userId2 no encontrado';
          }
        }
      }

      // 3. ACTUALIZAR ESTADO
      _couples = tempCouples;
      print(
        "Parejas cargadas y enriquecidas exitosamente: ${_couples.length} encontradas.",
      );
    } catch (e) {
      _setError('Error de conexión general al obtener parejas: $e');
      print('Error de conexión general al obtener parejas: $e');
    }
  }

  // En PsychologistController

  /// Obtiene las sesiones de un psicólogo.
  Future<void> getSessionsForPsychologist(int psychologistId) async {
    try {
      final endpoint = '/sesiones/psicologo/$psychologistId';
      print("Depuración: Llamando al endpoint de sesiones: $endpoint");

      final response = await ApiService.get(
        endpoint,
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia, // Esta baseUrl es correcta
      );

      print("Depuración: Respuesta del servidor de sesiones - Status: ${response.statusCode}");
      
      if (response.statusCode == 200) {
        print("Depuración: Cuerpo de la respuesta de sesiones: ${response.body}");
        final List<dynamic> data = jsonDecode(response.body);
        
        // Hacemos el parseo dentro de un try-catch para aislar errores de modelo
        try {
          _sessions = data.map((item) => TherapySession.fromJson(item)).toList();
          print("Depuración: Parseo de ${data.length} sesiones exitoso.");
        } catch (e) {
          print("¡ERROR DE PARSEO EN EL MODELO! Revisa TherapySession.fromJson. Error: $e");
          _setError("Error al procesar los datos de las sesiones.");
        }
      } else {
        _setError('Error al obtener sesiones (Status ${response.statusCode})');
      }
    } catch (e) {
      print("Depuración: CATCH general al obtener sesiones: $e");
      _setError('Error de conexión al obtener sesiones');
    }
  }

  Future<bool> createIndividualTask(TareaIndividual tarea) async {
    _setLoading(true);
    _setError(null);
    try {
      print('Enviando JSON para crear tarea: ${jsonEncode(tarea.toJson())}');
      final response = await ApiService.post(
        '/asignacion-individual',
        tarea
            .toJson(), // Asumiendo que TareaIndividual tiene un toJson() correcto
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 201) {
        _setSuccess('Tarea individual creada con éxito.');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Fallo al crear la tarea individual');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> createCoupleTask(TareaPareja tarea) async {
    _setLoading(true);
    _setError(null);
    try {
      print('Enviando JSON para crear tarea: ${jsonEncode(tarea.toJson())}');
      final response = await ApiService.post(
        '/asignacion-pareja',
        tarea.toJson(),
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 201) {
        _setSuccess('Tarea de pareja creada con éxito.');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Fallo al crear la tarea de pareja');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> getPatientsForPsychologist(int psychologistId) async {
    try {
      final response = await ApiService.get(
        '/psicologo/$psychologistId/pacientes',
        requireAuth: true,
        baseUrl: AppConstants.baseUrl, // URL de Auth/Users
      );
      if (response.statusCode == 200) {
        final List<dynamic> clientsJson = jsonDecode(response.body);
        _individualClients =
            clientsJson.map((json) => Client.fromJson(json)).toList();
      } else {
        _setError('Error al cargar clientes individuales: ${response.body}');
      }
    } catch (e) {
      _setError('Error de conexión al obtener clientes: $e');
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
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.patch('/psicologo/$id', data);
      if (response.statusCode == 200) {
        // La API puede devolver el objeto actualizado. Si es así, lo usamos.
        final updatedPsychologistData = jsonDecode(response.body);
        _currentPsychologist = Psychologist.fromJson(updatedPsychologistData);

        _setSuccess('Perfil actualizado exitosamente');
        notifyListeners(); // Notifica a la UI que los datos cambiaron
        _setLoading(false);
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

  Future<bool> updateSession(
    int sessionId,
    Map<String, dynamic> updates,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.patch(
        '/sesiones/$sessionId',
        updates,
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia,
      );

      if (response.statusCode == 200) {
        // La API puede devolver el objeto actualizado. Si es así, lo usamos.
        final updatedSession = jsonDecode(response.body);
        _currentTherapySession = TherapySession.fromJson(updatedSession);

        // Actualizamos la sesión en nuestra lista local
        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index != -1) {
          _sessions[index] = updatedSession;
        }

        _setSuccess('Sesión actualizado exitosamente');
        notifyListeners(); // Notifica a la UI que los datos cambiaron
        _setLoading(false);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _setError(
          errorData['message'] ??
              'No se pudo actualizar la Sesión ${response.body}',
        );
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión al actualizar la sesión');
      _setLoading(false);
      return false;
    }
  }

  // Crear nueva pareja
  Future<bool> createCouple({
    // required int id,
    required int idParejaA,
    required int idParejaB,
    required int psychologistId,
    required String objetivosTerapia,
    required AuthController authController,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/parejas', {
        // 'id': id,
        'idParejaA': idParejaA,
        'idParejaB': idParejaB,
        'psychologistId': psychologistId,
        'objetivosTerapia': objetivosTerapia,
        'estatus': 'activa',
      }, baseUrl: AppConstants.baseUrlTerapia);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _setLoading(false);
        await getCouplesForPsychologist(psychologistId, authController);
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
    required AuthController authController,
  }) async {
    _setLoading(true);
    _setError(null);
    notifyListeners();

    try {
      final response = await ApiService.patch(
        '/parejas/$parejaId',
        {'estatus': estatus, 'objetivosTerapia': objetivosTerapia},
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia,
      );

      if (response.statusCode == 200) {
        await getCouplesForPsychologist(
          currentPsychologist!.id,
          authController,
        );
        _setSuccess('Pareja actualizada existosamente');
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
    try {
      _analyses = await AIService.getAllCouplesAnalysis();
      // final response = await ApiService.get(
      //   '/psychologist/analysis',
      //   requireAuth: true,
      // );
      // if (response.statusCode == 200) {
      //   final List<dynamic> analysisJson = jsonDecode(response.body);
      //   _analyses =
      //       analysisJson.map((json) => CoupleAnalysis.fromJson(json)).toList();
      // } else {
      //   _setError('Error al cargar análisis');
      // }
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  // Crear sesión - usando el modelo de session_model.dart
  Future<bool> createSession(CreateSessionRequest request) async {
    _setLoading(true);
    _setError(null);
    notifyListeners();
    try {
      final jsonBody = request.toJson();
      print("Enviando JSON para crear sesión: ${jsonEncode(jsonBody)}");
      final response = await ApiService.post(
        '/sesiones',
        request.toJson(),
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia,
      );
      if (response.statusCode == 201) {
        _setSuccess('Sesión creada exitosamente');
        // Refrescamos la lista de sesiones del psicólogo, no solo de la pareja.
        if (_currentPsychologist != null) {
          await getSessionsForPsychologist(_currentPsychologist!.id);
        }
        _setLoading(false);
        return true;
      } else {
        // Damos un mensaje de error más detallado
        _setError(
          'Error al crear sesión (Status ${response.statusCode}): ${response.body}',
        );
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión al crear sesión: $e');
      _setLoading(false);
      return false;
    }
  }

  // ¡NUEVO! Método para obtener las sesiones de una pareja específica.
  Future<void> getSessionsForCouple(int coupleId) async {
    _setLoading(true);
    _setError(null);
    notifyListeners();
    try {
      // Asumimos un endpoint como /parejas/:id/sesiones
      final response = await ApiService.get(
        '/parejas/$coupleId/sesiones',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _sessions = data.map((item) => TherapySession.fromJson(item)).toList();
      } else {
        _setError('Error al obtener las sesiones.');
      }
    } catch (e) {
      _setError('Error de conexión al obtener sesiones.');
    }
    _setLoading(false);
    notifyListeners();
  }

  // ¡NUEVO! Método para obtener las tareas de una pareja específica.
  Future<void> getTasksForCouple(int coupleId) async {
    _setLoading(true);
    _setError(null);
    notifyListeners();
    try {
      // Asumimos un endpoint como /parejas/:id/tareas
      final response = await ApiService.get(
        '/parejas/$coupleId/tareas',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _coupleTasks = data.map((item) => TareaPareja.fromJson(item)).toList();
      } else {
        _setError('Error al obtener las tareas.');
      }
    } catch (e) {
      _setError('Error de conexión al obtener tareas.');
    }
    _setLoading(false);
    notifyListeners();
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

  Future<bool> updateIndividualTask(
    int taskId,
    Map<String, dynamic> updates,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.patch(
        '/asignacion-individual/$taskId',
        updates,
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );

      if (response.statusCode == 200) {
        _setSuccess('Tarea individual actualizada exitosamente');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Fallo al actualizar la tarea individual');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteIndividualTask(int taskId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.delete(
        '/asignacion-individual/$taskId',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _setSuccess('Tarea individual eliminada exitosamente');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Fallo al eliminar la tarea individual');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCoupleTask(
    int taskId,
    Map<String, dynamic> updates,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.patch(
        '/asignacion-pareja/$taskId',
        updates,
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200) {
        _setSuccess('Tarea de pareja actualizada');
        return true;
      } else {
        _setError('Error al actualizar tarea de pareja: ${response.body}');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCoupleTask(int taskId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.delete(
        '/asignacion-pareja/$taskId',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _setSuccess('Tarea de pareja eliminada correctamente');
        return true;
      } else {
        _setError('No se pudo eliminar la tarea de pareja');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteSession(int sessionId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.delete(
        '/sesiones/$sessionId',
        requireAuth: true,
        baseUrl: AppConstants.baseUrlTerapia,
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        _setSuccess('Sesión eliminada correctamente');
        return true;
      } else {
        _setError('No se pudo eliminar la sesión');
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _currentPsychologist = null;
    _couples.clear();
    _sessions.clear();
    _analyses.clear();
    _individualClients.clear();

    await _storage.delete(key: AppConstants.tokenKey);
    notifyListeners();
  }
  
  Future<bool> generateAIAnalysis(AIAnalysisRequest request) async {
    _setLoading(true);
    _setError(null);
    notifyListeners();

    try {
      // Llamamos al nuevo método POST en nuestro servicio de IA
      final newAnalysis = await AIService.generateNewAnalysis(request);

      if (newAnalysis != null) {
        // --- LÓGICA DE ACTUALIZACIÓN DE ESTADO ---
        // Después de generar un nuevo análisis, refrescamos la lista completa
        // para asegurarnos de que tenemos todos los datos actualizados.
        await getCouplesAnalysis();
        
        _setSuccess('Análisis generado exitosamente');
        _setLoading(false);
        // notifyListeners() ya es llamado por getCouplesAnalysis
        return true;
      } else {
        _setError('No se recibió un análisis válido del servidor.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
}
