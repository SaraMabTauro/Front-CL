import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_habits/models/task_model.dart';
import '../controllers/psychologist_controller.dart';
import '../controllers/task_controller.dart';
import '../core/constants.dart';

// Enum para controlar qué formulario se muestra
enum TaskAssignmentType { individual, couple }

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Tipo de asignación seleccionado
  TaskAssignmentType _assignmentType = TaskAssignmentType.individual;

  // Controladores para los campos del formulario
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Variables para los dropdowns y el selector de fecha
  int? _selectedClientId;
  int? _selectedCoupleId;
  String? _selectedTaskType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla, nos aseguramos de tener la lista de parejas y clientes.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PsychologistController>(context, listen: false).getCouples();
      Provider.of<PsychologistController>(context, listen: false).getIndividualClients();
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createTask() async {
    // Usamos la validación segura
    if (!(_formKey.currentState?.validate() ?? false) || _selectedDate == null) {
      // Si la fecha es nula, mostramos un mensaje
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione una fecha límite.'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final psychController = Provider.of<PsychologistController>(context, listen: false);

    bool success = false;
    String? errorMessage;

    try {
      if (_assignmentType == TaskAssignmentType.individual) {
        final tareaIndividualController = Provider.of<TaskController>(context, listen: false);
        final tarea = TareaIndividual(
          psicologoId: Provider.of<PsychologistController>(context, listen: false).currentPsychologist!.id,
          clienteId: _selectedClientId!,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          fechaLimite: _selectedDate!,
          estado: 'pendiente',
          creadoEn: DateTime.now(),
        );
        // Llama al método para crear la tarea individual
        success = await tareaIndividualController.createTareaIndividual(tarea);
        print("Creando tarea individual: ${tarea.toJson()}");
        errorMessage = tareaIndividualController.errorMessage;
        success = true; // Placeholder
      } else {
        final tareaParejaController = Provider.of<TaskController> (context, listen: false);
        final tarea = TareaPareja(
          psicologoId: Provider.of<PsychologistController>(context, listen: false).currentPsychologist!.id,
          parejaId: _selectedCoupleId!,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          fechaLimite: _selectedDate!,
          estado: AppConstants.pendingStatus,
        );
        // Llama al método para crear la tarea de pareja
        success = await tareaParejaController.createTareaPareja(tarea);
        errorMessage = tareaParejaController.errorMessage;
        print("Creando tarea de pareja: ${tarea.toJson()}"); // Placeholder
        success = true; // Placeholder
      }

      if (success) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Tarea creada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      } else {
        // El controlador debería haber seteado un mensaje de error.
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al crear la tarea.'), // O usa el mensaje del controller
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Ocurrió un error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
    } finally {
      // taskController.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el PsychController para obtener las listas de clientes y parejas
    final psychController = context.watch<PsychologistController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Nueva Tarea'),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- PASO 1: Selector de tipo de asignación ---
              const Text(
                '1. Asignar a:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SegmentedButton<TaskAssignmentType>(
                segments: const [
                  ButtonSegment<TaskAssignmentType>(
                    value: TaskAssignmentType.individual,
                    label: Text('Individuo'),
                    icon: Icon(Icons.person),
                  ),
                  ButtonSegment<TaskAssignmentType>(
                    value: TaskAssignmentType.couple,
                    label: Text('Pareja'),
                    icon: Icon(Icons.people),
                  ),
                ],
                selected: {_assignmentType},
                onSelectionChanged: (Set<TaskAssignmentType> newSelection) {
                  setState(() {
                    _assignmentType = newSelection.first;
                    // Reseteamos las selecciones al cambiar de tipo
                    _selectedClientId = null;
                    _selectedCoupleId = null;
                  });
                },
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: const Color(0xFF595082).withOpacity(0.2),
                  selectedForegroundColor: const Color(0xFF595082),
                ),
              ),

              const SizedBox(height: 24),

              // --- PASO 2: Selección específica (depende del paso 1) ---
              if (_assignmentType == TaskAssignmentType.individual)
                DropdownButtonFormField<int>(
                  value: _selectedClientId,
                  hint: const Text('Seleccione un cliente'),
                  decoration: const InputDecoration(labelText: 'Cliente *', border: OutlineInputBorder()),
                  items: psychController.individualClients.map((client) {
                    return DropdownMenuItem<int>(
                      value: client.id,
                      child: Text('${client.nombre} ${client.apellido}'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedClientId = value),
                  validator: (value) => value == null ? 'Debe seleccionar un cliente' : null,
                )
              else
                DropdownButtonFormField<int>(
                  value: _selectedCoupleId,
                  hint: const Text('Seleccione una pareja'),
                  decoration: const InputDecoration(
                    labelText: 'Pareja *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people_outline),
                  ),
                  items: psychController.couples.map((couple) {
                    return DropdownMenuItem<int>(
                      value: couple.id,
                      // Asumiendo que el modelo 'Couple' ya tiene los nombres
                      child: Text(
                        '${couple.nombreCliente1 ?? 'N/A'} & ${couple.nombreCliente2 ?? 'N/A'}'
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCoupleId = value;
                    });
                  },
                  validator: (value) => value == null ? 'Debe seleccionar una pareja' : null,
                ),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // --- PASO 3: Detalles de la tarea (comunes a ambos) ---
              const Text(
                '2. Detalles de la Tarea:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título de la Tarea *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'El título es requerido' : null,
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedTaskType,
                hint: const Text('Seleccione un tipo de ejercicio'),
                decoration: const InputDecoration(
                  labelText: 'Tipo de Ejercicio *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  AppConstants.communicationTask,
                  AppConstants.mindfulnessTask,
                  AppConstants.intimacyTask,
                  AppConstants.conflictResolutionTask,
                ].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    // Formateamos el texto para que sea legible
                    child: Text(type.replaceAll('_', ' ').toLowerCase().capitalize()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTaskType = value;
                  });
                },
                validator: (value) => value == null ? 'Debe seleccionar un tipo' : null,
              ),

              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descripcionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripción / Instrucciones *',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'La descripción es requerida' : null,
              ),
              
              const SizedBox(height: 16),

              // Selector de Fecha Límite
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4)
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                    _selectedDate == null 
                        ? 'Seleccionar fecha límite *'
                        : 'Fecha Límite: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  ),
                  onTap: () => _selectDate(context),
                  trailing: _selectedDate != null 
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _selectedDate = null),
                      ) 
                    : null,
                ),
              ),
              // Validador manual para la fecha
              if (_formKey.currentState?.validate() == true && _selectedDate == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 12.0),
                  child: Text('La fecha límite es requerida', style: TextStyle(color: Colors.red, fontSize: 12)),
                ),


              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _createTask,
                icon: const Icon(Icons.assignment_add),
                label: const Text('Crear Tarea'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF595082),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pequeña extensión para capitalizar el texto del dropdown
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}