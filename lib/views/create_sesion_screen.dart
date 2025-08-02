import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../models/session_model.dart';
import '../controllers/auth_controller.dart';

class CreateSessionScreen extends StatefulWidget {
  final int? preselectedCoupleId;

  const CreateSessionScreen({super.key, this.preselectedCoupleId});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _objetivosController = TextEditingController();
  final _costoController = TextEditingController();
  final _notasController = TextEditingController();

  int? _selectedCoupleId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  SessionType _selectedType = SessionType.pareja;
  int _duracionMinutos = 60;

  @override
  void initState() {
    super.initState();
    _selectedCoupleId = widget.preselectedCoupleId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final psychController = Provider.of<PsychologistController>(
        context,
        listen: false,
      );
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      final currentPsychologist = psychController.currentPsychologist;

      if (psychController.couples.isEmpty && currentPsychologist != null) {
        print(
          "CreateSessionScreen: La lista de parejas está vacía. Cargando datos...",
        );
        // Llamamos al método correcto con los parámetros necesarios
        psychController.getCouplesForPsychologist(
          currentPsychologist.id,
          authController,
        );
      }
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _objetivosController.dispose();
    _costoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createSession() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      print("Depuración: El formulario no es válido.");
      return;
    }

    final psychController = Provider.of<PsychologistController>(
      context,
      listen: false,
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final currentPsychologist = psychController.currentPsychologist;

    if (_selectedCoupleId == null) {
      print("Depuración: No se ha seleccionado un ID de pareja.");
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione una pareja.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (currentPsychologist == null) {
      print("Depuración: No se encontró al psicólogo actual.");
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al psicólogo.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print("--- INICIO DEPURACIÓN CREAR SESIÓN ---");
    print("ID de Pareja Seleccionado: $_selectedCoupleId");
    print("ID de Psicólogo: ${currentPsychologist.id}");
    print("Título: ${_tituloController.text}");

    final costoText = _costoController.text.trim();
    if (costoText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El costo es un campo obligatorio.'), backgroundColor: Colors.red),
      );
      return;
    }

    final fechaHora = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    print("Fecha y Hora: ${fechaHora.toIso8601String()}");

    // Usamos CreateSessionRequest del modelo de sesión
    final request = CreateSessionRequest(
      idPareja: _selectedCoupleId!,
      psychologistId: currentPsychologist.id,
      titulo: _tituloController.text,
      descripcion:
          _descripcionController.text.trim().isNotEmpty
              ? _descripcionController.text
              : null,
      fechaHora: fechaHora,
      duracionMinutos: _duracionMinutos,
      tipo: _selectedType,
      estado: SessionStatus.activa,
      costo: double.parse(costoText),
      notas:
          _notasController.text.trim().isEmpty
              ? null
              : _notasController.text.trim(),
      objetivos:
          _objetivosController.text.trim().isNotEmpty
              ? _objetivosController.text
              : null,
    );
    
    final success = await psychController.createSession(request);

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sesión creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            psychController.errorMessage ?? 'Error al crear sesión',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
    print("--- FIN DEPURACIÓN CREAR SESIÓN ---");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Sesión'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Consumer<PsychologistController>(
        builder: (context, psychController, child) {
          if (psychController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selección de pareja
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pareja',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _selectedCoupleId,
                            decoration: const InputDecoration(
                              labelText: 'Seleccionar pareja',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                psychController.couples.map((couple) {
                                  return DropdownMenuItem<int>(
                                    value: couple.id,
                                    child: Text(
                                      '${couple.nombreCliente1 ?? 'Cliente 1'} & ${couple.nombreCliente2 ?? 'Cliente 2'}',
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCoupleId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor seleccione una pareja';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Información de la sesión
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de la Sesión',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _tituloController,
                            decoration: const InputDecoration(
                              labelText: 'Título de la sesión',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor ingrese un título';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción (opcional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _objetivosController,
                            decoration: const InputDecoration(
                              labelText: 'Objetivos (opcional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller:
                                _notasController, // Controlador para notas
                            decoration: const InputDecoration(
                              labelText: 'Notas (opcional)',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fecha y hora
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha y Hora',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const Text('Fecha'),
                                  subtitle: Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  ),
                                  leading: const Icon(Icons.calendar_today),
                                  onTap: _selectDate,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ListTile(
                                  title: const Text('Hora'),
                                  subtitle: Text(_selectedTime.format(context)),
                                  leading: const Icon(Icons.access_time),
                                  onTap: _selectTime,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Configuración adicional
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Configuración',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextFormField(
                            controller:
                                _costoController, // Controlador para costo
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Costo *',
                              border: OutlineInputBorder(),
                              prefixText: '\$ ',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El costo es obligatorio';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Por favor ingrese un número válido';
                              }
                              return null; // El valor es válido
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<SessionType>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de sesión',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                SessionType.values.map((type) {
                                  return DropdownMenuItem<SessionType>(
                                    value: type,
                                    child: Text(_getSessionTypeLabel(type)),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _duracionMinutos,
                            decoration: const InputDecoration(
                              labelText: 'Duración',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 30,
                                child: Text('30 minutos'),
                              ),
                              DropdownMenuItem(
                                value: 45,
                                child: Text('45 minutos'),
                              ),
                              DropdownMenuItem(
                                value: 60,
                                child: Text('1 hora'),
                              ),
                              DropdownMenuItem(
                                value: 90,
                                child: Text('1.5 horas'),
                              ),
                              DropdownMenuItem(
                                value: 120,
                                child: Text('2 horas'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _duracionMinutos = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón crear
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          psychController.isLoading ? null : _createSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          psychController.isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Crear Sesión',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getSessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.individual:
        return 'Individual';
      case SessionType.pareja:
        return 'Pareja';
      case SessionType.grupal:
        return 'Grupal';
    }
  }
}
