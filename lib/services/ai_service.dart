import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/ia_analysis_model.dart'; // Importamos nuestro modelo

class AIService {
  /// Obtiene todos los análisis de parejas de la API de IA.
  static Future<List<CoupleAnalysis>> getAllCouplesAnalysis() async {
    final url = Uri.parse('${AppConstants.baseUrlIA}/couples-analysis'); // Usamos la nueva constante

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'insomnia/11.3.0', // O tu user-agent
        },
      ).timeout(const Duration(seconds: 45)); // Damos un timeout más largo para APIs de IA

      if (response.statusCode == 200) {
        // --- MANEJO DE LA RESPUESTA ANIDADA ---
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Verificamos si la clave principal existe y es una lista
        if (data['analisisParejas'] != null && data['analisisParejas'] is List) {
          final List<dynamic> analysisList = data['analisisParejas'];
          
          // Mapeamos la lista anidada a nuestros objetos CoupleAnalysis
          return analysisList.map((item) => CoupleAnalysis.fromJson(item)).toList();
        } else {
          // Si la clave no existe, devolvemos una lista vacía
          return [];
        }
      } else {
        // Lanzamos una excepción con detalles si la API falla
        throw Exception('Fallo al cargar análisis (Status ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Re-lanzamos la excepción para que el controlador la maneje
      throw Exception('Error de conexión con el servicio de IA: $e');
    }
  }

  /// Obtiene el análisis para una ÚNICA pareja.
  /// (Asumimos que la API podría tener este endpoint en el futuro)
  static Future<CoupleAnalysis?> getAnalysisForCouple(int coupleId) async {
    final url = Uri.parse('${AppConstants.baseUrlIA}/couples-analysis/$coupleId');
    
    // ... (lógica similar a la anterior, pero esperando un solo objeto en lugar de una lista)
    // ...
    return null; // Placeholder
  }
}