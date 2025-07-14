import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../models/ia_analysis_model.dart';

class GenerateAnalysisScreen extends StatefulWidget {
  const GenerateAnalysisScreen({super.key});

  @override
  State<GenerateAnalysisScreen> createState() => _GenerateAnalysisScreenState();
}

class _GenerateAnalysisScreenState extends State<GenerateAnalysisScreen> {
  int? _selectedCoupleId;
  String _selectedAnalysisType = 'comprehensive';
  bool _isGenerating = false;
  AIAnalysisResult? _lastResult;

  final Map<String, String> _analysisTypes = {
    'comprehensive': 'Análisis Integral',
    'communication': 'Análisis de Comunicación',
    'emotional': 'Análisis Emocional',
    'behavioral': 'Análisis Conductual',
    'risk_assessment': 'Evaluación de Riesgo',
    'progress': 'Análisis de Progreso',
  };

  final Map<String, String> _analysisDescriptions = {
    'comprehensive': 'Análisis completo de todos los aspectos de la relación',
    'communication': 'Evaluación de patrones de comunicación y estilos',
    'emotional': 'Análisis del estado emocional y bienestar individual',
    'behavioral': 'Evaluación de comportamientos y patrones de interacción',
    'risk_assessment': 'Predicción de riesgo de ruptura y factores de alerta',
    'progress': 'Evaluación del progreso terapéutico y mejoras',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final psychController = Provider.of<PsychologistController>(context, listen: false);
      psychController.getCouples();
    });
  }

  Future<void> _generateAnalysis() async {
    if (_selectedCoupleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione una pareja'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _lastResult = null;
    });

    final request = AIAnalysisRequest(
      coupleId: _selectedCoupleId!,
      analysisType: _selectedAnalysisType,
      parameters: {
        'includeRecommendations': true,
        'confidenceThreshold': 0.7,
        'analysisDepth': 'detailed',
      },
    );

    final psychController = Provider.of<PsychologistController>(context, listen: false);
    final result = await psychController.generateAIAnalysis(request);

    setState(() {
      _isGenerating = false;
      _lastResult = result;
    });

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análisis generado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Análisis con IA'),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header con información de IA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF595082), Color(0xFF7B68A2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Análisis Inteligente',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Utiliza inteligencia artificial avanzada para generar insights profundos sobre las dinámicas de pareja',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🤖 Powered by AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Selección de pareja
            Consumer<PsychologistController>(
              builder: (context, psychController, child) {
                return Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.people, color: Color(0xFF595082)),
                            SizedBox(width: 8),
                            Text(
                              'Seleccionar Pareja',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF20263F),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedCoupleId,
                          decoration: InputDecoration(
                            hintText: 'Seleccione una pareja para analizar',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF595082)),
                            ),
                            prefixIcon: const Icon(Icons.search),
                          ),
                          items: psychController.couples.map((couple) {
                            return DropdownMenuItem<int>(
                              value: couple.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${couple.nombreCliente1 ?? 'Cliente 1'} & ${couple.nombreCliente2 ?? 'Cliente 2'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    couple.estado.toString().split('.').last,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCoupleId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // Tipo de análisis
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.analytics, color: Color(0xFF595082)),
                        SizedBox(width: 8),
                        Text(
                          'Tipo de Análisis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20263F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._analysisTypes.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: RadioListTile<String>(
                          value: entry.key,
                          groupValue: _selectedAnalysisType,
                          onChanged: (value) {
                            setState(() {
                              _selectedAnalysisType = value!;
                            });
                          },
                          title: Text(
                            entry.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _analysisDescriptions[entry.key] ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          activeColor: const Color(0xFF595082),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón de generar análisis
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateAnalysis,
                icon: _isGenerating 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? 'Generando Análisis...' : 'Generar Análisis con IA',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595082),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            
            // Mostrar progreso
            if (_isGenerating) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const LinearProgressIndicator(
                        color: Color(0xFF595082),
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Analizando datos de la pareja...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Esto puede tomar unos momentos',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            // Mostrar resultados
            if (_lastResult != null) ...[
              const SizedBox(height: 24),
              _buildAnalysisResults(_lastResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(AIAnalysisResult result) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del resultado
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF595082).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF595082),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _analysisTypes[result.analysisType] ?? 'Análisis',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20263F),
                        ),
                      ),
                      Text(
                        'Confianza: ${(result.confidenceScore * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Completado',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Resumen
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen Ejecutivo',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.summary,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Insights
            const Text(
              'Insights Clave',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20263F),
              ),
            ),
            const SizedBox(height: 12),
            ...result.insights.map((insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Color(0xFFF8C662),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Recomendaciones
            const Text(
              'Recomendaciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF20263F),
              ),
            ),
            const SizedBox(height: 12),
            ...result.recommendations.map((recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: 20),
            
            // Métricas
            if (result.metrics.isNotEmpty) ...[
              const Text(
                'Métricas Detalladas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: result.metrics.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF595082),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Exportar análisis
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de exportación próximamente'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Exportar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF595082),
                      side: const BorderSide(color: Color(0xFF595082)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Guardar análisis
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Análisis guardado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF595082),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
