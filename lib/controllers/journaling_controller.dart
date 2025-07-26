import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/individual_log_model.dart';
import '../models/interaction_log_model.dart';
import '../services/api_service.dart';
import '../core/constants.dart';
import 'auth_controller.dart';

class JournalingController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  JournalingController();

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

  Future<bool> submitIndividualLog({
    // La firma del método sigue siendo la misma
    required AuthController authController,
    required String situation,
    required String thought,
    required String emotion,
    String? physicalSensation,
    String? behavior,
    int? stressLevel,
    double? sleepQualityHours,
  }) async {
    _setLoading(true);
    _setError(null);

    // 1. Usamos la instancia 'authController' que recibimos como parámetro.
    if (!authController.isAuthenticated || authController.currentUser == null) {
      _setError("Usuario no autenticado como cliente.");
      _setLoading(false);
      return false;
    }

    // 2. ¡AQUÍ ESTÁ LA CORRECCIÓN CLAVE!
    // NO creamos una nueva instancia. Usamos la que ya tenemos.
    final currentUser = authController.currentUser!;
    final int clienteId = currentUser.id;
    // 3. Creamos el objeto completo (tu lógica aquí ya estaba bien)
    final logData = IndividualEmotionalLog(
      cliente_id: clienteId,
      fechaRegistro: DateTime.now(),
      situation: situation,
      thought: thought,
      emotion: emotion,
      physicalSensation: physicalSensation,
      behavior: behavior,
      stressLevel: stressLevel,
      sleepQualityHours: sleepQualityHours,
    );

    try {

      print('Enviando JSON a la API: ${jsonEncode(logData.toJson())}');

      // 4. La petición a la API no cambia
      final response = await ApiService.post(
        '/registros',
        logData.toJson(),
        requireAuth: true,
        baseUrl: AppConstants.baseUrlModelo,
      );

      if (response.statusCode == 201) {
        _setSuccess('Registro individual enviado con éxito!');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(data['message'] ?? 'Fallo al enviar el registro');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de red. Por favor, intente de nuevo.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> submitInteractionLog({
    // Parámetros que necesita este método:
    required AuthController authController,
    required String interactionDescription,
    required String interactionType,
    String? myCommunicationStyle,
    String? perceivedPartnerCommunicationStyle,
    String? physicalContactLevel,
    required String myEmotionInInteraction,
    String? perceivedPartnerEmotion,
  }) async {
    _setLoading(true);
    _setError(null);

    // 1. Validamos la sesión del usuario usando el AuthController pasado como parámetro
    if (!authController.isAuthenticated || authController.currentUser == null) {
      _setError("Usuario no autenticado como cliente.");
      _setLoading(false);
      return false;
    }

    final currentUser = authController.currentUser!;
    final int reporterId = currentUser.id;
    final int? coupleId = currentUser.parejaId;

    // 2. Comprobamos que el usuario pertenezca a una pareja, ya que es requerido
    if (coupleId == null) {
      _setError(
        "Este registro solo puede ser realizado por un usuario que pertenezca a una pareja.",
      );
      _setLoading(false);
      return false;
    }

    // 3. Creamos el objeto InteractionLog con todos los datos necesarios
    final logData = InteractionLog(
      reporterClientId: reporterId,
      coupleId: coupleId,
      interactionDate: DateTime.now(),
      interactionDescription: interactionDescription,
      interactionType: interactionType,
      myCommunicationStyle: myCommunicationStyle,
      perceivedPartnerCommunicationStyle: perceivedPartnerCommunicationStyle,
      physicalContactLevel: physicalContactLevel,
      myEmotionInInteraction: myEmotionInInteraction,
      perceivedPartnerEmotion: perceivedPartnerEmotion,
    );

    try {
      final response = await ApiService.post(
        '/interacciones', 
        logData.toJson(), 
        requireAuth: true,
        baseUrl: AppConstants.baseUrlModelo, 
      );

      if (response.statusCode == 201) {
        _setSuccess('Registro de interacción enviado con éxito!');
        _setLoading(false);
        return true;
      } else {
        final data = jsonDecode(response.body);
        _setError(
          data['message'] ?? 'Fallo al enviar el registro de interacción',
        );
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error de red. Por favor, intente de nuevo.');
      _setLoading(false);
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
