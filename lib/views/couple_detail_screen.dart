import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/psychologist_models.dart';
import '../core/constants.dart';
import '../models/session_model.dart';
import '../models/ia_analysis_model.dart';
import '../models/task_model.dart';
import 'package:collection/collection.dart'; // <-- ¡IMPORTACIÓN NECESARIA!

class CoupleDetailScreen extends StatefulWidget {
  final int coupleId;

  const CoupleDetailScreen({super.key, required this.coupleId});

  @override
  State<CoupleDetailScreen> createState() => _CoupleDetailScreenState();
}

class _CoupleDetailScreenState extends State<CoupleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Couple? _couple;
  CoupleAnalysis? _analysis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ¡MÉTODO MEJORADO!
  void _loadInitialData() {
    final psychController = Provider.of<PsychologistController>(
      context,
      listen: false,
    );

    // 1. Obtenemos los datos de la pareja de la lista general
    _couple = psychController.couples.firstWhereOrNull(
      (c) => c.id == widget.coupleId,
    );

    if (_couple != null) {
      _analysis = psychController.analyses.firstWhereOrNull(
        (a) => a.parejaId == widget.coupleId,
      );
      // 2. Le pedimos al controlador que cargue los datos específicos de esta pareja
      psychController.getTasksForCouple(widget.coupleId);
      psychController.getSessionsForCouple(widget.coupleId);
      // psychController.getDiariesForCouple(widget.coupleId); // Si tuvieras este método
    }

    if (mounted) {
      setState(() {});
    }

    // final currentPsychologist = psychController.currentPsychologist;

    // // Forzamos una reconstrucción si es necesario, aunque el Consumer se encargará.
    // setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final coupleData = context
        .watch<PsychologistController>()
        .couples
        .firstWhereOrNull((c) => c.id == widget.coupleId);
    final coupleName = coupleData?.fullCoupleName ?? 'Cargando...';

    if (coupleData == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cargando Pareja...'),
          backgroundColor: const Color(0xFF595082),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    _couple = coupleData;
    _analysis = context
        .watch<PsychologistController>()
        .analyses
        .firstWhereOrNull((a) => a.parejaId == widget.coupleId);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(coupleName),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditCoupleDialog();
                  break;
                case 'assign_task':
                  _showAssignTaskDialog();
                  break;
                case 'schedule_session':
                  _showScheduleSessionDialog();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Color(0xFF595082)),
                        SizedBox(width: 8),
                        Text('Editar Pareja'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'assign_task',
                    child: Row(
                      children: [
                        Icon(Icons.assignment, color: Color(0xFF595082)),
                        SizedBox(width: 8),
                        Text('Asignar Tarea'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'schedule_session',
                    child: Row(
                      children: [
                        Icon(Icons.schedule, color: Color(0xFF595082)),
                        SizedBox(width: 8),
                        Text('Programar Sesión'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Resumen'),
            Tab(icon: Icon(Icons.assignment), text: 'Tareas'),
            Tab(icon: Icon(Icons.book), text: 'Diarios'),
            Tab(icon: Icon(Icons.analytics), text: 'Análisis'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(couple: _couple!, analysis: _analysis),
          _TasksTab(couple: _couple!),
          _DiariesTab(couple: _couple!),
          _AnalysisTab(
            couple: _couple!,
            analysis: _analysis,
            onRefresh: _refreshAIAnalysis,
          ),
        ],
      ),
    );
  }

  void _showEditCoupleDialog() {
    final objetivosController = TextEditingController(
      text: _couple!.objetivosTerapia,
    );
    CoupleStatus selectedStatus = _couple!.estado;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Editar Pareja'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
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
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Objetivos de Terapia',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final psychController =
                            Provider.of<PsychologistController>(
                              dialogContext,
                              listen: false,
                            );
                        final authController = Provider.of<AuthController>(
                          dialogContext,
                          listen: false,
                        );
                        final navigator = Navigator.of(
                          dialogContext,
                        ); // Capturamos el Navigator
                        final messenger = ScaffoldMessenger.of(
                          context,
                        ); // Usamos el context principal para el SnackBar
                        final success = await psychController.updateCouple(
                          parejaId: _couple!.id,
                          estatus: selectedStatus.name,
                          objetivosTerapia: objetivosController.text,
                          authController: authController,
                        );

                        if (!mounted) return;

                        if (success) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Pareja actualizada exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          navigator.pop();

                          _loadInitialData();
                        } else {
                          messenger.showSnackBar(
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

  void _showAssignTaskDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedTaskType = AppConstants.communicationTask;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Asignar Nueva Tarea'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'Título de la Tarea',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedTaskType,
                          decoration: const InputDecoration(
                            labelText: 'Tipo de Tarea',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AppConstants.communicationTask,
                              child: Text('Ejercicio de Comunicación'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.mindfulnessTask,
                              child: Text('Ejercicio de Mindfulness'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.intimacyTask,
                              child: Text('Construcción de Intimidad'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.conflictResolutionTask,
                              child: Text('Resolución de Conflictos'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedTaskType = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Fecha de Vencimiento'),
                          subtitle: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              setState(() {
                                selectedDate = date;
                              });
                            }
                          },
                        ),
                      ],
                    ),
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

                        final newTask = TareaPareja(
                          psicologoId: psychController.currentPsychologist!.id,
                          parejaId: _couple!.id,
                          titulo: titleController.text,
                          descripcion: descriptionController.text,
                          fechaLimite: selectedDate,
                          estado: 'pendiente',
                          // El modelo de TareaPareja no tiene los campos de respuesta, así que los omitimos.
                        );

                        final success = await psychController.createCoupleTask(
                          newTask,
                        );

                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                          psychController.getTasksForCouple(
                            _couple!.id,
                          ); // Refrescar la lista de tareas
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tarea asignada exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                psychController.errorMessage ??
                                    'No se pudo asignar la tarea',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Asignar'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showScheduleSessionDialog() {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    final tituloController = TextEditingController();
    final notesController = TextEditingController();
    final costoController = TextEditingController();
    final objetivosController = TextEditingController();
    String selectedModalidad = 'presencial';
    int selectedDuracion = 60;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Programar Sesión'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: tituloController,
                            decoration: const InputDecoration(
                              labelText: 'Título de la Sesión *',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    (value == null || value.isEmpty)
                                        ? 'El título es requerido'
                                        : null,
                          ),
                          const SizedBox(height: 16),
                          ListTile(
                            title: const Text('Fecha'),
                            subtitle: Text(
                              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (date != null) {
                                setState(() {
                                  selectedDate = date;
                                });
                              }
                            },
                          ),
                          ListTile(
                            title: const Text('Hora'),
                            subtitle: Text(selectedTime.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setState(() {
                                  selectedTime = time;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: selectedModalidad,
                            decoration: const InputDecoration(
                              labelText: 'Modalidad',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'presencial',
                                child: Text('Presencial'),
                              ),
                              DropdownMenuItem(
                                value: 'virtual',
                                child: Text('Virtual'),
                              ),
                              DropdownMenuItem(
                                value: 'telefonica',
                                child: Text('Telefónica'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedModalidad = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: selectedDuracion,
                            decoration: const InputDecoration(
                              labelText: 'Duración (minutos)',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 45,
                                child: Text('45 minutos'),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text('60 minutos'),
                              ),
                              DropdownMenuItem(
                                value: 90,
                                child: Text('90 minutos'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedDuracion = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: costoController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Costo (opcional)',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notas de la Sesión',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        final fechaHora = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );

                        final request = CreateSessionRequest(
                          idPareja: _couple!.id,
                          psychologistId:
                              psychController.currentPsychologist!.id,
                          titulo: tituloController.text,
                          descripcion: notesController.text,
                          fechaHora: fechaHora,
                          duracionMinutos: selectedDuracion,
                          tipo: SessionType.pareja,
                          estado: SessionStatus.activa,
                          costo: double.tryParse(costoController.text) ?? 0.0,
                          notas: notesController.text,
                          objetivos: objetivosController.text,
                        );

                        final success = await psychController.createSession(
                          request,
                        );

                        if (!mounted) return;

                        if (success) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Sesión programada exitosamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          navigator.pop();
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                psychController.errorMessage ??
                                    'Error al crear sesión',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text('Programar'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _refreshAIAnalysis() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Analizando datos con IA...'),
                SizedBox(height: 8),
                Text(
                  'Procesando patrones de comportamiento',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
    );

    // Llamar al método del controlador
    final psychController = Provider.of<PsychologistController>(
      context,
      listen: false,
    );
    psychController
        .getCouplesAnalysis()
        .then((_) {
          Navigator.of(context).pop();

          _loadInitialData();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Análisis actualizado.'),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((error) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                psychController.errorMessage ?? 'Error al actualizar análisis.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
  }
}

// Tab de Resumen
class _OverviewTab extends StatelessWidget {
  final Couple couple;
  final CoupleAnalysis? analysis;

  const _OverviewTab({required this.couple, this.analysis});

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información básica de la pareja
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'Información de la Pareja',
                          style: TextStyle(
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

                  const SizedBox(height: 20),

                  // Información de los clientes
                  Row(
                    children: [
                      Expanded(
                        child: _ClientInfoCard(
                          name: couple.nombreCliente1 ?? 'Cliente 1',
                          email: couple.correoCliente1 ?? 'N/A',
                          color: const Color(0xFFF8C662),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ClientInfoCard(
                          name: couple.nombreCliente2 ?? 'Cliente 2',
                          email: couple.correoCliente2 ?? 'N/A',
                          color: const Color(0xFF41644A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Fecha de creación
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Iniciado: ${couple.creadoEn.day}/${couple.creadoEn.month}/${couple.creadoEn.year}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Objetivos de terapia
          if (couple.objetivosTerapia != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flag, color: Color(0xFF595082)),
                        SizedBox(width: 8),
                        Text(
                          'Objetivos de Terapia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20263F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      couple.objetivosTerapia!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF20263F),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Métricas rápidas si hay análisis
          if (analysis != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.trending_up, color: Color(0xFF595082)),
                        SizedBox(width: 8),
                        Text(
                          'Métricas Actuales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20263F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Bienestar',
                            value:
                                '${(analysis!.promedioSentimientoIndividual * 100).toInt()}%',
                            color:
                                analysis!.promedioSentimientoIndividual > 0.6
                                    ? Colors.green
                                    : Colors.orange,
                            icon: Icons.sentiment_satisfied,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Tareas',
                            value:
                                '${(analysis!.tasaCompletacionTareas * 100).toInt()}%',
                            color:
                                analysis!.tasaCompletacionTareas > 0.7
                                    ? Colors.green
                                    : Colors.orange,
                            icon: Icons.assignment_turned_in,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            title: 'Estrés',
                            value:
                                '${analysis!.promedioEstresIndividual.toStringAsFixed(1)}/10',
                            color:
                                analysis!.promedioEstresIndividual < 5
                                    ? Colors.green
                                    : Colors.red,
                            icon: Icons.psychology,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            title: 'Riesgo',
                            value:
                                analysis!.prediccionRiesgoRuptura < 0.3
                                    ? 'Bajo'
                                    : analysis!.prediccionRiesgoRuptura < 0.7
                                    ? 'Medio'
                                    : 'Alto',
                            color:
                                analysis!.prediccionRiesgoRuptura < 0.3
                                    ? Colors.green
                                    : analysis!.prediccionRiesgoRuptura < 0.7
                                    ? Colors.orange
                                    : Colors.red,
                            icon: Icons.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Tab de Tareas
class _TasksTab extends StatelessWidget {
  final Couple couple;

  const _TasksTab({required this.couple});

  @override
  Widget build(BuildContext context) {
    return Consumer<PsychologistController>(
      builder: (context, psychController, child) {
        if (psychController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTasks = psychController.coupleTasks;
        final pendingTasks =
            allTasks.where((task) => task.estado == 'pendiente').toList();
        final completedTasks =
            allTasks.where((task) => task.estado == 'completada').toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estadísticas de tareas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TaskStatCard(
                          title: 'Pendientes',
                          count: pendingTasks.length,
                          color: Colors.orange,
                          icon: Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TaskStatCard(
                          title: 'Completadas',
                          count: completedTasks.length,
                          color: Colors.green,
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _TaskStatCard(
                          title: 'Total',
                          count: allTasks.length,
                          color: const Color(0xFF595082),
                          icon: Icons.assignment,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tareas pendientes
              const Text(
                'Tareas Pendientes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
              const SizedBox(height: 12),

              if (pendingTasks.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay tareas pendientes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pendingTasks.map(
                  (task) => _TaskCard(task: task, isPending: true),
                ),

              const SizedBox(height: 24),

              // Tareas completadas
              const Text(
                'Tareas Completadas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
              const SizedBox(height: 12),

              ...completedTasks.map(
                (task) => _TaskCard(task: task, isPending: false),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Tab de Diarios
class _DiariesTab extends StatelessWidget {
  final Couple couple;

  const _DiariesTab({required this.couple});

  @override
  Widget build(BuildContext context) {
    // Cuando tengas el método en el controlador, puedes reemplazar esto:
    // final diaries = context.watch<PsychologistController>().diaries;
    // return const Center(
    //   child: Text('La sección de Diarios se conectará a la API próximamente.'),
    // );

    // Simular entradas de diario para cada cliente
    final client1Entries = [
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'situation':
            'Tuvimos una conversación sobre nuestros planes de fin de semana',
        'emotion': 'HAPPY',
        'thought': 'Me siento escuchada y valorada cuando planificamos juntos',
        'stressLevel': 3,
        'sleepHours': 8.0,
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'situation': 'Discutimos sobre las tareas del hogar',
        'emotion': 'FRUSTRATED',
        'thought': 'Siento que no hay equilibrio en las responsabilidades',
        'stressLevel': 7,
        'sleepHours': 6.5,
      },
    ];

    final client2Entries = [
      {
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'situation': 'Planificamos actividades para el fin de semana',
        'emotion': 'EXCITED',
        'thought': 'Me gusta cuando tomamos decisiones juntos',
        'stressLevel': 2,
        'sleepHours': 7.5,
      },
      {
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'situation': 'Mi pareja parecía estresada después del trabajo',
        'emotion': 'CONCERNED',
        'thought': 'Quiero apoyarla pero no sé cómo ayudar',
        'stressLevel': 5,
        'sleepHours': 7.0,
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resumen de actividad
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actividad de Diarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _DiaryStatCard(
                          name: couple.nombreCliente1 ?? 'Cliente 1',
                          entries: client1Entries.length,
                          avgStress:
                              client1Entries
                                  .map((e) => e['stressLevel'] as int)
                                  .reduce((a, b) => a + b) /
                              client1Entries.length,
                          color: const Color(0xFFF8C662),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DiaryStatCard(
                          name: couple.nombreCliente2 ?? 'Cliente 2',
                          entries: client2Entries.length,
                          avgStress:
                              client2Entries
                                  .map((e) => e['stressLevel'] as int)
                                  .reduce((a, b) => a + b) /
                              client2Entries.length,
                          color: const Color(0xFF41644A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Entradas de diario del Cliente 1
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8C662),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Diario de ${couple.nombreCliente1 ?? 'Cliente 1'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...client1Entries.map(
            (entry) => _DiaryEntryCard(
              entry: entry,
              clientColor: const Color(0xFFF8C662),
            ),
          ),

          const SizedBox(height: 24),

          // Entradas de diario del Cliente 2
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF41644A),
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Diario de ${couple.nombreCliente2 ?? 'Cliente 2'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF20263F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          ...client2Entries.map(
            (entry) => _DiaryEntryCard(
              entry: entry,
              clientColor: const Color(0xFF41644A),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab de Análisis
class _AnalysisTab extends StatelessWidget {
  final Couple couple;
  final CoupleAnalysis? analysis;
  final VoidCallback onRefresh;

  const _AnalysisTab({
    required this.couple,
    this.analysis,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (analysis == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay análisis disponible',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Predicción de riesgo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Predicción de Riesgo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20263F),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _RiskIndicator(riskLevel: analysis!.prediccionRiesgoRuptura),

                  const SizedBox(height: 16),

                  Text(
                    _getRiskDescription(analysis!.prediccionRiesgoRuptura),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF20263F),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Métricas detalladas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Métricas Detalladas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF20263F),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _AnalysisMetricRow(
                    title: 'Bienestar Emocional',
                    value: analysis!.promedioSentimientoIndividual,
                    format: 'percentage',
                  ),
                  _AnalysisMetricRow(
                    title: 'Completación de Tareas',
                    value: analysis!.tasaCompletacionTareas,
                    format: 'percentage',
                  ),
                  _AnalysisMetricRow(
                    title: 'Nivel de Estrés Promedio',
                    value: analysis!.promedioEstresIndividual / 10,
                    format: 'scale',
                    isInverted: true,
                  ),
                  _AnalysisMetricRow(
                    title: 'Empatía Mutua',
                    value: analysis!.empatiaGapScore,
                    format: 'percentage',
                  ),
                  _AnalysisMetricRow(
                    title: 'Balance de Interacciones',
                    value: analysis!.interaccionBalanceRatio,
                    format: 'percentage',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Insights y recomendaciones
          if (analysis!.insightsRecientes.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb, color: Color(0xFFF8C662)),
                        SizedBox(width: 8),
                        Text(
                          'Insights y Recomendaciones',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20263F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ...analysis!.insightsRecientes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final insight = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              index < analysis!.insightsRecientes.length - 1
                                  ? 12
                                  : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(top: 8, right: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8C662),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                insight,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF20263F),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Botón para generar nuevo análisis
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generar Nuevo Análisis con IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF595082),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRiskDescription(double riskLevel) {
    if (riskLevel < 0.3) {
      return 'La pareja muestra indicadores positivos de estabilidad. Continúen con el trabajo actual y mantengan las rutinas establecidas.';
    } else if (riskLevel < 0.7) {
      return 'Se observan algunas áreas de preocupación que requieren atención. Recomendamos intensificar las sesiones y enfocarse en los ejercicios de comunicación.';
    } else {
      return 'La pareja presenta indicadores de alto riesgo. Se requiere intervención inmediata y posiblemente sesiones individuales complementarias.';
    }
  }

  void _showGenerateAnalysisDialog(
    BuildContext context,
    VoidCallback onRefresh,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF595082)),
                SizedBox(width: 8),
                Text('Generar Análisis con IA'),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'El sistema analizará automáticamente:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),
                Text('• Patrones de comunicación recientes'),
                Text('• Tendencias emocionales individuales'),
                Text('• Progreso en tareas asignadas'),
                Text('• Factores de riesgo emergentes'),
                Text('• Recomendaciones personalizadas'),
                SizedBox(height: 16),
                Text(
                  'Este proceso puede tomar unos minutos.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
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
                onPressed: () {
                  Navigator.of(context).pop();
                  onRefresh();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF595082),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Generar Análisis'),
              ),
            ],
          ),
    );
  }
}

// Widgets auxiliares
class _ClientInfoCard extends StatelessWidget {
  final String name;
  final String email;
  final Color color;

  const _ClientInfoCard({
    required this.name,
    required this.email,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: Text(
                  name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF20263F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
    );
  }
}

class _TaskStatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _TaskStatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final bool isPending;
  final Tarea task;

  const _TaskCard({required this.task, required this.isPending});

  @override
  Widget build(BuildContext context) {
    Color typeColor;
    IconData typeIcon;

    switch (task.type) {
      case TaskType.individual:
        typeColor = Colors.blue;
        typeIcon = Icons.chat;
        break;
      case TaskType.couple:
        typeColor = Colors.purple;
        typeIcon = Icons.people;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF20263F),
                        ),
                      ),
                      Text(
                        'Asignado a: Ambos',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Pendiente',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Completada',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              task.descripcion,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF20263F),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Vence: ${(task.fechaLimite).day}/${(task.fechaLimite).month}/${(task.fechaLimite).year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryStatCard extends StatelessWidget {
  final String name;
  final int entries;
  final double avgStress;
  final Color color;

  const _DiaryStatCard({
    required this.name,
    required this.entries,
    required this.avgStress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF20263F),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entries.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const Text(
                    'Entradas',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${avgStress.toStringAsFixed(1)}/10',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: avgStress < 5 ? Colors.green : Colors.red,
                    ),
                  ),
                  const Text(
                    'Estrés Prom.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DiaryEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final Color clientColor;

  const _DiaryEntryCard({required this.entry, required this.clientColor});

  @override
  Widget build(BuildContext context) {
    final date = entry['date'] as DateTime;
    final emotion = entry['emotion'] as String;
    final stressLevel = entry['stressLevel'] as int;

    Color emotionColor;
    IconData emotionIcon;

    switch (emotion) {
      case 'FELIZ':
        emotionColor = Colors.green;
        emotionIcon = Icons.sentiment_very_satisfied;
        break;
      case 'EMOCIONADO':
        emotionColor = Colors.orange;
        emotionIcon = Icons.sentiment_very_satisfied;
        break;
      case 'FRUSTADO':
        emotionColor = Colors.red;
        emotionIcon = Icons.sentiment_dissatisfied;
        break;
      case 'CONCERNADO':
        emotionColor = Colors.orange;
        emotionIcon = Icons.sentiment_neutral;
        break;
      default:
        emotionColor = Colors.grey;
        emotionIcon = Icons.sentiment_neutral;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: emotionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(emotionIcon, color: emotionColor, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      emotion.toLowerCase().replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: emotionColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              'Situación:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Text(
              entry['situation'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF20263F),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Pensamiento:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            Text(
              entry['thought'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF20263F),
                height: 1.3,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.psychology,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Estrés: $stressLevel/10',
                        style: TextStyle(
                          fontSize: 12,
                          color: stressLevel < 5 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.bedtime, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Sueño: ${entry['sleepHours']}h',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskIndicator extends StatelessWidget {
  final double riskLevel;

  const _RiskIndicator({required this.riskLevel});

  @override
  Widget build(BuildContext context) {
    Color riskColor;
    String riskText;

    if (riskLevel < 0.3) {
      riskColor = Colors.green;
      riskText = 'Bajo Riesgo';
    } else if (riskLevel < 0.7) {
      riskColor = Colors.orange;
      riskText = 'Riesgo Moderado';
    } else {
      riskColor = Colors.red;
      riskText = 'Alto Riesgo';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              riskText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: riskColor,
              ),
            ),
            Text(
              '${(riskLevel * 100).toInt()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: riskColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: riskLevel,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(riskColor),
          minHeight: 8,
        ),
      ],
    );
  }
}

class _AnalysisMetricRow extends StatelessWidget {
  final String title;
  final double value;
  final String format;
  final bool isInverted;

  const _AnalysisMetricRow({
    required this.title,
    required this.value,
    required this.format,
    this.isInverted = false,
  });

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      final effectiveValue = isInverted ? 1 - value : value;
      if (effectiveValue > 0.7) return Colors.green;
      if (effectiveValue > 0.4) return Colors.orange;
      return Colors.red;
    }

    String getDisplayValue() {
      switch (format) {
        case 'percentage':
          return '${(value * 100).toInt()}%';
        case 'scale':
          return '${(value * 10).toStringAsFixed(1)}/10';
        default:
          return value.toStringAsFixed(2);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Color(0xFF20263F)),
              ),
              Text(
                getDisplayValue(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: getColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: isInverted ? 1 - value : value,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(getColor()),
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
