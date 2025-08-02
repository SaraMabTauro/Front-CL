import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../models/ia_analysis_model.dart';

class AnalysisDetailScreen  extends StatelessWidget {
final CoupleAnalysis analysis;

  const AnalysisDetailScreen({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Análisis para ${analysis.nombrePareja}'),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // La UI principal ahora está contenida en su propio widget
        child: _AnalysisResultsView(analysis: analysis),
      ),
    );
  }
}

class _AnalysisResultsView extends StatelessWidget{
  final CoupleAnalysis analysis;

  const _AnalysisResultsView({required this.analysis});

  @override
  Widget build(BuildContext context) {
    // Definimos el formateador de fecha aquí para reutilizarlo
    // Hacemos el formato manualmente:
    final day = analysis.fechaTendencia.day.toString().padLeft(2, '0');
    final month = analysis.fechaTendencia.month.toString().padLeft(2, '0');
    final year = analysis.fechaTendencia.year.toString();
    
    final formattedDate = '$day/$month/$year';

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
                  child: const Icon(Icons.auto_awesome, color: Color(0xFF595082), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Análisis para ${analysis.nombrePareja}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF20263F)),
                      ),
                      Text(
                        'Fecha de análisis: ${analysis.fechaTendencia}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Conclusión de la IA
            _buildSection(
              title: 'Conclusión de la IA',
              content: Text(analysis.conclusion, style: const TextStyle(fontSize: 14, height: 1.5)),
            ),
            
            const SizedBox(height: 20),
            
            // Insights
            _buildSection(
              title: 'Insights Clave',
              content: Column(
                children: analysis.insightsRecientes.map((insight) => _buildListItem(
                  text: insight,
                  icon: Icons.lightbulb_outline,
                  iconColor: const Color(0xFFF8C662),
                )).toList(),
              ),
            ),
            
            // Aquí puedes añadir secciones para las otras métricas si lo deseas
            // Por ejemplo:
            // const SizedBox(height: 20),
            // _buildSection(title: 'Métricas Detalladas', content: ...),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF20263F)),
          ),
          const Divider(height: 24),
          content,
        ],
      ),
    );
  }

  Widget _buildListItem({required String text, required IconData icon, required Color iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
