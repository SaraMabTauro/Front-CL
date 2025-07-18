import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../models/psychologist_models.dart';
import '../models/ia_analysis_model.dart';

class PsychologistDashboardScreen extends StatefulWidget {
  const PsychologistDashboardScreen({super.key});

  @override
  State<PsychologistDashboardScreen> createState() =>
      _PsychologistDashboardScreenState();
}

class _PsychologistDashboardScreenState
    extends State<PsychologistDashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final psychController = Provider.of<PsychologistController>(
        context,
        listen: false,
      );
      psychController.getCouples();
      psychController.getCouplesAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Portal Profesional',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<PsychologistController>(
            builder: (context, psychController, child) {
              return PopupMenuButton<String>(
                icon: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    psychController.currentPsychologist?.nombre.substring(
                          0,
                          1,
                        ) ??
                        'P',
                    style: const TextStyle(
                      color: Color(0xFF595082),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onSelected: (value) {
                  if (value == 'logout') {
                    psychController.logout();
                    Navigator.of(
                      context,
                    ).pushReplacementNamed('/psychologist-login');
                  }
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF595082)),
                            const SizedBox(width: 8),
                            Text(
                              psychController.currentPsychologist?.nombre ??
                                  'Psicólogo',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cerrar Sesión'),
                          ],
                        ),
                      ),
                    ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _DashboardOverview(),
          _CouplesManagement(),
          _AnalysisView(),
          _SessionsManagement(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF595082),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Resumen',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Parejas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Análisis',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Sesiones'),
        ],
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview();

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychologistController>(
      builder: (context, psychController, child) {
        final couples = psychController.couples;
        final activeCouples =
            couples.where((c) => c.estado == CoupleStatus.activa).length;
        final pendingCouples =
            couples
                .where((c) => c.estado == CoupleStatus.pendienteAprobacion)
                .length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Saludo personalizado
              Consumer<PsychologistController>(
                builder: (context, controller, child) {
                  return Card(
                    elevation: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF595082), Color(0xFF7B68A2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${controller.currentPsychologist?.nombre ?? 'Doctor'}!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.currentPsychologist?.especialidad ??
                                'Especialista en Terapia de Pareja',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Estadísticas rápidas
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Parejas Activas',
                      value: activeCouples.toString(),
                      icon: Icons.favorite,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Pendientes',
                      value: pendingCouples.toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Parejas',
                      value: couples.length.toString(),
                      icon: Icons.people,
                      color: const Color(0xFF595082),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Sesiones Hoy',
                      value: '3',
                      icon: Icons.event_available,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Acciones rápidas
              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      title: 'Nueva Pareja',
                      subtitle: 'Registrar nueva pareja',
                      icon: Icons.add_circle,
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).pushNamed('/create-couple');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionCard(
                      title: 'Programar Sesión',
                      subtitle: 'Agendar nueva sesión',
                      icon: Icons.schedule,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).pushNamed('/create-session');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Parejas recientes
              const Text(
                'Parejas Recientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
              const SizedBox(height: 16),
              
              if (couples.isEmpty)
                const Center( 
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'No hay parejas registradas',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                Column(
                  children: couples
                      .take(3) 
                      .map((couple) => _CoupleCard(couple: couple))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoupleCard extends StatelessWidget {
  final Couple couple;

  const _CoupleCard({required this.couple});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (couple.estado) {
      case CoupleStatus.activa:
        statusColor = Colors.green;
        statusText = 'Activa';
        break;
      case CoupleStatus.pendienteAprobacion:
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case CoupleStatus.inactiva:
        statusColor = Colors.grey;
        statusText = 'Inactiva';
        break;
      case CoupleStatus.rechazada:
        statusColor = Colors.red;
        statusText = 'Rechazada';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed('/couple-detail', arguments: couple.id);
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF8C662),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          title: Text(
            '${couple.nombreCliente1 ?? 'Cliente 1'} & ${couple.nombreCliente2 ?? 'Cliente 2'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            couple.objetivosTerapia ?? 'Sin objetivos definidos',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CouplesManagement extends StatelessWidget {
  const _CouplesManagement();

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychologistController>(
      builder: (context, psychController, child) {
        return Column(
          children: [
            // Header con botón de agregar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gestión de Parejas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/create-couple');
                    },
                    icon: const Icon(Icons.add),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF595082),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de parejas
            Expanded(
              child:
                  psychController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : psychController.couples.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay parejas registradas',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: psychController.couples.length,
                        itemBuilder: (context, index) {
                          final couple = psychController.couples[index];
                          return _DetailedCoupleCard(couple: couple);
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}

class _DetailedCoupleCard extends StatelessWidget {
  final Couple couple;

  const _DetailedCoupleCard({required this.couple});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (couple.estado) {
      case CoupleStatus.activa:
        statusColor = Colors.green;
        statusText = 'Activa';
        break;
      case CoupleStatus.pendienteAprobacion:
        statusColor = Colors.orange;
        statusText = 'Pendiente Aprobación';
        break;
      case CoupleStatus.inactiva:
        statusColor = Colors.grey;
        statusText = 'Inactiva';
        break;
      case CoupleStatus.rechazada:
        statusColor = Colors.red;
        statusText = 'Rechazada';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${couple.nombreCliente1 ?? 'Cliente 1'} & ${couple.nombreCliente2 ?? 'Cliente 2'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (couple.correoCliente1 != null ||
                couple.correoCliente2 != null) ...[
              Row(
                children: [
                  const Icon(Icons.email, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${couple.correoCliente1 ?? 'N/A'} • ${couple.correoCliente2 ?? 'N/A'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Creado: ${couple.creadoEn.day}/${couple.creadoEn.month}/${couple.creadoEn.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            if (couple.objetivosTerapia != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Objetivos de Terapia:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF20263F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      couple.objetivosTerapia!,
                      style: const TextStyle(color: Color(0xFF20263F)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showEditCoupleDialog(context, couple);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF595082),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamed('/couple-detail', arguments: couple.id);
                  },
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Ver Detalle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595082),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final psychController = Provider.of<PsychologistController>(
                    context,
                    listen: false,
                  );
                  final request = AIAnalysisRequest(
                    coupleId: couple.id,
                    analysisType: 'comprehensive',
                    parameters: {
                      'includeRecommendations': true,
                      'confidenceThreshold': 0.7,
                      'analysisDepth': 'detailed',
                    },
                  );
                  final result = await psychController.generateAIAnalysis(
                    request,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result != null
                              ? 'Análisis generado exitosamente'
                              : psychController.errorMessage ??
                                  'Error al generar análisis',
                        ),
                        backgroundColor:
                            result != null ? Colors.green : Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.auto_graph, size: 16),
                label: const Text('Generar Análisis'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCoupleDialog(BuildContext context, Couple couple) {
    final objetivosController = TextEditingController(
      text: couple.objetivosTerapia,
    );
    CoupleStatus selectedStatus = couple.estado;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Editar Pareja'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<CoupleStatus>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            CoupleStatus.values.map((status) {
                              String statusText;
                              switch (status) {
                                case CoupleStatus.activa:
                                  statusText = 'Activa';
                                  break;
                                case CoupleStatus.pendienteAprobacion:
                                  statusText = 'Pendiente Aprobación';
                                  break;
                                case CoupleStatus.inactiva:
                                  statusText = 'Inactiva';
                                  break;
                                case CoupleStatus.rechazada:
                                  statusText = 'Rechazada';
                                  break;
                              }
                              return DropdownMenuItem(
                                value: status,
                                child: Text(statusText),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: objetivosController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Objetivos de Terapia',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final psychController =
                            Provider.of<PsychologistController>(
                              context,
                              listen: false,
                            );
                        final success = await psychController.updateCouple(
                          parejaId: couple.id,
                          estatus:
                              selectedStatus
                                  .name, // <-- Convierte enum a String
                          objetivosTerapia: objetivosController.text,
                        );

                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pareja actualizada exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
  }
}

class _AnalysisView extends StatelessWidget {
  const _AnalysisView();

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychologistController>(
      builder: (context, psychController, child) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: const Row(
                children: [
                  Icon(Icons.analytics, color: Color(0xFF595082), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Análisis de Parejas',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                ],
              ),
            ),

            // Contenido del análisis
            Expanded(
              child:
                  psychController.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : psychController.analyses.isEmpty
                      ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.analytics_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay análisis disponibles',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: psychController.analyses.length,
                        itemBuilder: (context, index) {
                          final analysis = psychController.analyses[index];
                          return _AnalysisCard(analysis: analysis);
                        },
                      ),
            ),
          ],
        );
      },
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final CoupleAnalysis analysis;

  const _AnalysisCard({required this.analysis});

  @override
  Widget build(BuildContext context) {
    // Determinar el color del riesgo
    Color riskColor;
    String riskText;
    if (analysis.prediccionRiesgoRuptura < 0.3) {
      riskColor = Colors.green;
      riskText = 'Bajo Riesgo';
    } else if (analysis.prediccionRiesgoRuptura < 0.7) {
      riskColor = Colors.orange;
      riskText = 'Riesgo Moderado';
    } else {
      riskColor = Colors.red;
      riskText = 'Alto Riesgo';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y riesgo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    analysis.nombrePareja,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    riskText,
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Métricas principales
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    title: 'Sentimiento',
                    value:
                        '${(analysis.promedioSentimientoIndividual * 100).toInt()}%',
                    color:
                        analysis.promedioSentimientoIndividual > 0.5
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    title: 'Tareas',
                    value:
                        '${(analysis.tasaCompletacionTareas * 100).toInt()}%',
                    color:
                        analysis.tasaCompletacionTareas > 0.7
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    title: 'Estrés',
                    value:
                        '${analysis.promedioEstresIndividual.toStringAsFixed(1)}/10',
                    color:
                        analysis.promedioEstresIndividual < 5
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    title: 'Empatía',
                    value: '${(analysis.empatiaGapScore * 100).toInt()}%',
                    color:
                        analysis.empatiaGapScore > 0.6
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    title: 'Balance',
                    value:
                        '${(analysis.interaccionBalanceRatio * 100).toInt()}%',
                    color:
                        analysis.interaccionBalanceRatio > 0.6
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
                Expanded(
                  child: _MetricItem(
                    title: 'Ciclos -',
                    value: '${analysis.recuentoDeteccionCicloNegativo}',
                    color:
                        analysis.recuentoDeteccionCicloNegativo < 3
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ],
            ),

            // Insights recientes
            if (analysis.insightsRecientes.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Insights Recientes:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
              const SizedBox(height: 12),
              ...analysis.insightsRecientes.map(
                (insight) => Padding(
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
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF20263F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navegar a vista detallada del análisis
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Ver Análisis Detallado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595082),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricItem({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _SessionsManagement extends StatelessWidget {
  const _SessionsManagement();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.event, color: Color(0xFF595082), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Gestión de Sesiones',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/create-session');
                },
                icon: const Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595082),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // Contenido de sesiones
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Gestión de Sesiones',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Próximamente disponible',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
