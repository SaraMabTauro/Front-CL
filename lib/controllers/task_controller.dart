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
  List<TareaIndividual> get allTasks => _tareasIndividuales;

  // Getter que filtra las tareas pendientes
  List<TareaIndividual> get pendingTasks {
    return _tareasIndividuales.where((tarea) => tarea.estado == 'pendiente').toList();
  }

  // Getter que filtra las tareas completadas
  List<TareaIndividual> get completedTasks {
    return _tareasIndividuales.where((tarea) => tarea.estado == 'completada').toList();
  }

  // ¡NUEVO! Getter que filtra las tareas RETRASADAS
  List<TareaIndividual> get overdueTasks {
    return _tareasIndividuales.where((tarea) => tarea.estado == 'Declinado').toList();
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
    try{
      final response = await ApiService.post('/asignacion-individual',
      tarea.toJson(),
      requireAuth: true,
      baseUrl: AppConstants.baseUrlGestion
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
    if (task is TareaIndividual) {
      feedbackEndpoint = '/retroalimentaciones/individuales';
    } else if (task is TareaPareja) {
      feedbackEndpoint = '/retroalimentaciones/pareja';
    } else {
      _setError("Tipo de tarea desconocido.");
      _setLoading(false);
      return false;
    }

    try {
      // --- PRIMERA LLAMADA: Enviar la retroalimentación ---
      final feedbackResponse = await ApiService.post(
        feedbackEndpoint,
        feedbackData.toJson(),
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion, // Asegúrate de que esta es la baseUrl correcta
      );

      if (feedbackResponse.statusCode != 201) {
        _setError('Fallo al enviar la retroalimentación: ${feedbackResponse.body}');
        _setLoading(false);
        return false;
      }

      // --- SEGUNDA LLAMADA: Marcar la tarea como completada ---
      final completeResponse = await ApiService.patch(
        // El endpoint para actualizar el estado es diferente
        '/asignacion-individual/${task.id}', 
        {'estado': 'completada'},
        requireAuth: true,
        baseUrl: AppConstants.baseUrlGestion,
      );

      if (completeResponse.statusCode != 200) {
        // La retroalimentación se envió, pero el estado no se actualizó.
        // Es un éxito parcial, pero lo marcaremos como error para que el usuario sepa.
        _setError('Retroalimentación enviada, pero falló al actualizar el estado de la tarea.');
        _setLoading(false);
        return false;
      }

      // Si ambas llamadas fueron exitosas, refrescamos la lista de tareas
      await getIndividualTasksForUser(authController);
      _setSuccess('¡Tarea completada con éxito!');
      _setLoading(false);
      return true;

    } catch (e) {
      _setError('Error de conexión: $e');
      _setLoading(false);
      return false;
    }
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
        _tareasIndividuales = data.map((item) => TareaIndividual.fromJson(item)).toList();
      } else {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Error al obtener las tareas del usuario.';
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

      // --- 4. NUEVO MÉTODO PARA COMPLETAR TAREA ---
    //   Future<bool> completeTask(int taskId, TaskFeedback feedback, AuthController authController) async {
    //     _isLoading = true;
    //     _errorMessage = null;
    //     notifyListeners();

    //     try {
    //       // Prepara el cuerpo de la petición PATCH
    //       final body = {
    //         'estado': 'completada', // Cambia el estado
    //         ...feedback.toJson(),    // Agrega los datos del feedback
    //       };

    //       // Usa el ApiService para hacer la petición PATCH
    //       final response = await ApiService.patch('/asignacion-individual/$taskId', body, baseUrl: AppConstants.baseUrlGestion);

    //       if (response.statusCode == 200) {

    //         await getIndividualTasksForUser(authController);
    //         // La API devuelve la tarea actualizada, la decodificamos
    //         final tareaActualizada = TareaIndividual.fromJson(jsonDecode(response.body));

    //         // Actualizamos la tarea en nuestra lista local para que la UI reaccione
    //         final index = _tareasIndividuales.indexWhere((t) => t.id == taskId);
    //         if (index != -1) {
    //           _tareasIndividuales[index] = tareaActualizada;
    //         }

    //         _setSuccess('Tarea completada con éxito.');
    //         _setLoading(false); // Notifica a los listeners del cambio
    //         return true;
    //       } else {
    //         _setError('Error al completar la tarea: ${response.body}');
    //         _setLoading(false);
    //         return false;
    //       }
    //     } catch (e) {
    //       _setError('Error de conexión al completar la tarea.');
    //       _setLoading(false);
    //       return false;
    //     }
    //   }
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
