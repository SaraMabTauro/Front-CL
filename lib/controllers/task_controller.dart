import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:smart_habits/models/user_model.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';
import '../core/constants.dart';

class TaskController extends ChangeNotifier {
  // --- ESTADO ---
  List<TareaIndividual> _tareasIndividuales = [];
  List<TareaPareja> _tareasPareja = [];

  User? _currentUser;

  // Es mejor tener estados de carga y error separados para no confundirlos
  bool _isLoadingIndividuales = false;
  bool _isLoadingPareja = false;
  String? _errorIndividuales;
  String? _errorPareja;
  String? _successMessage;
  String? _errorMessage;
  bool _isLoading = false;

  // --- GETTERS ---
  List<TareaIndividual> get tareasIndividuales => _tareasIndividuales;
  List<TareaPareja> get tareasPareja => _tareasPareja;
  bool get isLoadingIndividuales => _isLoadingIndividuales;
  bool get isLoadingPareja => _isLoadingPareja;
  String? get errorIndividuales => _errorIndividuales;
  String? get errorPareja => _errorPareja;
  String? get successMessage => _successMessage;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;

  // --- MÉTODOS DE GESTIÓN DE ESTADO ---
  void _setState({
    bool? loadingIndividual,
    bool? loadingPareja,
    String? errorIndividual,
    String? errorPareja,
    String? success,
  }) {
    _isLoadingIndividuales = loadingIndividual ?? _isLoadingIndividuales;
    _isLoadingPareja = loadingPareja ?? _isLoadingPareja;
    // Resetear errores si hay un nuevo estado de carga o éxito
    _errorIndividuales =
        (loadingIndividual == true || success != null) ? null : errorIndividual;
    _errorPareja =
        (loadingPareja == true || success != null) ? null : errorPareja;
    _successMessage = success;
    notifyListeners();
  }

  // --- 3. GETTERS PARA EL TABBAR (FILTRADO EFICIENTE) ---
  // Getter para todas las tareas (para la pestaña 'Todo')
  List<Tarea> get allTasks {
    return List<Tarea>.from(_tareasIndividuales)..addAll(_tareasPareja);
  }

  // Getter que filtra las tareas pendientes
  List<Tarea> get pendingTasks {
    return allTasks.where((tarea) {
      return tarea.estado.toLowerCase().trim() == 'pendiente';
    }).toList();
  }

  // Getter que filtra las tareas completadas
  List<Tarea> get completedTasks {
    return allTasks.where((tarea) {
      // Aplicamos la misma lógica robusta aquí.
      return tarea.estado.toLowerCase().trim() == 'completada';
    }).toList();
  }

  // ¡NUEVO! Getter específico para el Dashboard (solo tareas individuales pendientes)
  List<TareaIndividual> get pendingIndividualTasks {
    return _tareasIndividuales
        .where((tarea) => tarea.estado == 'pendiente')
        .toList();
  }

  // ¡NUEVO! Getter que filtra las tareas RETRASADAS
  List<Tarea> get overdueTasks {
    return allTasks.where((tarea) {
      return tarea.estado.toLowerCase().trim() == 'demorado';
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

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setSuccess(String? message) {
    _successMessage = message;
    _errorMessage = null;
    notifyListeners();
  }

  // POST: Crear una nueva tarea individual
  Future<bool> createTareaIndividual(TareaIndividual tarea) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.post(
        '/asignacion-individual',
        tarea.toJson(),
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );

      if (response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Error al crear la tarea individual.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión. Por favor, intente de nuevo.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> submitFeedbackAndCompleteTask({
    required Tarea task,
    required AuthController authController,
    required int satisfaction,
    required int difficulty,
    required int utility,
    String? comments,
  }) async {
    _setLoading(true);
    _setError(null);

    if (authController.currentUser == null) {
      _setError("Error: Usuario no encontrado.");
      _setLoading(false);
      return false;
    }

    // 1. Preparamos el cuerpo de la retroalimentación
    final feedbackData = TaskFeedback(
      clienteId: authController.currentUser!.id,
      asignacionId: task.id!,
      calificacionSatisfaccion: satisfaction,
      calificacionDificultad: difficulty,
      calificacionUtilidad: utility,
      comentarios: comments,
    );

    // 2. Determinamos el endpoint correcto basado en el tipo de tarea
    String feedbackEndpoint;
    String completeTaskEndpoint;

    if (task is TareaIndividual) {
      feedbackEndpoint = '/retroalimentaciones/individuales';
      completeTaskEndpoint = '/asignacion-individual/${task.id}';
    } else if (task is TareaPareja) {
      feedbackEndpoint = '/retroalimentaciones/pareja';
      completeTaskEndpoint = '/asignacion-pareja/${task.id}';
    } else {
      _setError("Tipo de tarea desconocido.");
      _setLoading(false);
      return false;
    }

    try {
      final jsonBody = feedbackData.toJson();
      print('--- INICIO DEPURACIÓN FEEDBACK ---');
      print('Endpoint: $feedbackEndpoint');
      print('JSON Enviado: ${jsonEncode(jsonBody)}');
      print('--- FIN DEPURACIÓN FEEDBACK ---');
      
      final feedbackResponse = await ApiService.post(
        feedbackEndpoint,
        jsonBody,
        requireAuth: true,
        baseUrl:
            AppConstants
                .baseUrlGestion, // Asegúrate de que esta es la baseUrl correcta
      );

      if (feedbackResponse.statusCode != 201) {
        _setError(
          'Fallo al enviar la retroalimentación: ${feedbackResponse.body}',
        );
        _setLoading(false);
        return false;
      }

      // --- SEGUNDA LLAMADA: Marcar la tarea como completada ---
      final completeResponse = await ApiService.patch(
        completeTaskEndpoint,
        {'estado': 'completada'},
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );

      if (completeResponse.statusCode != 200) {
        // La retroalimentación se envió, pero el estado no se actualizó.
        // Es un éxito parcial, pero lo marcaremos como error para que el usuario sepa.
        _setError(
          'Retroalimentación enviada, pero falló al actualizar el estado de la tarea.',
        );
        _setLoading(false);
        return false;
      }

      // Si ambas llamadas fueron exitosas, refrescamos la lista de tareas
      if (completeResponse.statusCode == 200 ||
          completeResponse.statusCode == 201) {
        // ¡Refrescamos TODAS las tareas!
        await getAllTasksForUser(authController);
        _setSuccess('¡Tarea completada con éxito!');
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }

    _setLoading(false);
    return false;
  }

  Future<bool> createTareaPareja(TareaPareja tarea) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await ApiService.post(
        '/asignacion-pareja',
        tarea.toJson(),
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );

      if (response.statusCode == 201) {
        _setLoading(false);
        return true; // Devuelve bool, no el objeto
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Fallo al crear la tarea');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
  }

  /// ¡NUEVO! Un método principal para cargar TODAS las tareas del usuario.
  Future<void> getAllTasksForUser(AuthController authController) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Usamos Future.wait para ejecutar ambas llamadas a la API en paralelo.
    // Esto es más rápido que hacer una y luego la otra.
    await Future.wait([
      getIndividualTasksForUser(authController),
      getCoupleTasksForUser(authController),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  /// ¡NUEVO! Obtiene las tareas de pareja.
  Future<void> getCoupleTasksForUser(AuthController authController) async {
    if (!authController.isAuthenticated || authController.currentUser == null) {
      _errorMessage = "Usuario no autenticado.";
      return;
    }
    final userId = authController.currentUser!.id;

    try {
      final response = await ApiService.get(
        '/asignacion-pareja/tareas-por-usuario/$userId', // <-- Usamos el nuevo endpoint
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['tareas'] != null && data['tareas'] is List) {
          final List<dynamic> taskList = data['tareas'];

          _tareasPareja =
              taskList.map((item) => TareaPareja.fromJson(item)).toList();
        } else {
          _tareasPareja = [];
        }
      } else {
        _errorMessage = 'Error al obtener tareas de pareja.';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión en tareas de pareja.';
    }
  }

  // GET: Obtener todas las tareas individuales
  Future<void> getIndividualTasksForUser(AuthController authController) async {
    // Verificamos que el usuario esté logueado
    if (!authController.isAuthenticated || authController.currentUser == null) {
      _errorMessage = "No se puede obtener tareas: Usuario no autenticado.";
      notifyListeners();
      return;
    }

    final userId = authController.currentUser!.id;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.get(
        '/asignacion-individual/por-usuario/$userId', // <-- Usamos el nuevo endpoint
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion, // <-- Usamos la baseUrl correcta
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Usamos el modelo corregido para parsear la respuesta
        _tareasIndividuales =
            data.map((item) => TareaIndividual.fromJson(item)).toList();
      } else {
        final data = jsonDecode(response.body);
        _errorMessage =
            data['message'] ?? 'Error al obtener las tareas del usuario.';
      }
    } catch (e) {
      _errorMessage = 'Error de conexión. Por favor, intente de nuevo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // GET: Obtener una tarea individual por ID
  Future<TareaIndividual> getTareaById(int id) async {
    final response = await ApiService.get('/asignacion-individual/$id');

    if (response.statusCode == 200) {
      return TareaIndividual.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falló al cargar la tarea individual');
    }
  }

  // PATCH: Actualizar una tarea individual
  Future<TareaIndividual> updateTarea(
    int id,
    Map<String, dynamic> updates,
  ) async {
    final response = await ApiService.patch(
      'asignacion-individual/$id',
      updates,
    );

    if (response.statusCode == 200) {
      return TareaIndividual.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falló al actualizar la tarea individual');
    }
  }

  // DELETE: Eliminar una tarea individual
  Future<void> deleteTarea(int id) async {
    final response = await ApiService.delete('/asignacion-individual/$id');

    if (response.statusCode != 204) {
      // 204 No Content
      throw Exception('Falló al eliminar la tarea individual');
    }
  }
}

class TareaParejaController {
  // POST: Crear una nueva tarea de pareja
  Future<TareaPareja> createTarea(TareaPareja tarea) async {
    final response = await ApiService.post('/asignacion-pareja', {
      'psicologoId': tarea.psicologoId,
      'parejaId': tarea.parejaId,
      'titulo': tarea.titulo,
      'descripcion': tarea.descripcion,
      'fechaLimite': tarea.fechaLimite.toIso8601String(),
      'estado': tarea.estado,
    });

    if (response.statusCode == 201) {
      // 201 Created
      return TareaPareja.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falló al crear la tarea de pareja');
    }
  }

  // GET: Obtener todas las tareas de pareja
  Future<List<TareaPareja>> getAllTareas() async {
    final response = await ApiService.get('/asignacion-pareja');

    if (response.statusCode == 200) {
      // 200 OK
      List<dynamic> body = jsonDecode(response.body);
      List<TareaPareja> tareas =
          body.map((dynamic item) => TareaPareja.fromJson(item)).toList();
      return tareas;
    } else {
      throw Exception('Falló al cargar las tareas de pareja');
    }
  }

  // GET: Obtener una tarea de pareja por ID
  Future<TareaPareja> getTareaById(int id) async {
    final response = await ApiService.get('/asignacion-pareja/$id');

    if (response.statusCode == 200) {
      return TareaPareja.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falló al cargar la tarea de pareja');
    }
  }

  // PATCH: Actualizar una tarea de pareja
  Future<TareaPareja> updateTarea(int id, Map<String, dynamic> updates) async {
    final response = await ApiService.patch('/asignacion-pareja/$id', updates);

    if (response.statusCode == 200) {
      return TareaPareja.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falló al actualizar la tarea de pareja');
    }
  }

  // DELETE: Eliminar una tarea de pareja
  Future<void> deleteTarea(int id) async {
    final response = await ApiService.delete('/asignacion-pareja/$id');

    if (response.statusCode != 204) {
      // 204 No Content
      throw Exception('Falló al eliminar la tarea de pareja');
    }
  }
}
