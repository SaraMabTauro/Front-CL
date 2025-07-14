// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../controllers/psychologist_controller.dart';
// import '../models/session_model.dart';

// class CreateSessionScreen extends StatefulWidget {
//   const CreateSessionScreen({super.key});

//   @override
//   State<CreateSessionScreen> createState() => _CreateSessionScreenState();
// }

// class _CreateSessionScreenState extends State<CreateSessionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _tituloController = TextEditingController();
//   final _descripcionController = TextEditingController();
//   final _objetivosController = TextEditingController();
  
//   int? _selectedCoupleId;
//   DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
//   TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
//   int _duracionMinutos = 60;
//   SessionType _selectedType = SessionType.pareja;

//   @override
//   void dispose() {
//     _tituloController.dispose();
//     _descripcionController.dispose();
//     _objetivosController.dispose();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final psychController = Provider.of<PsychologistController>(context, listen: false);
//       psychController.getCouples();
//     });
//   }

//   Future<void> _selectDate() async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF595082),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _selectTime() async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF595082),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   Future<void> _createSession() async {
//     if (_formKey.currentState!.validate() && _selectedCoupleId != null) {
//       final fechaHora = DateTime(
//         _selectedDate.year,
//         _selectedDate.month,
//         _selectedDate.day,
//         _selectedTime.hour,
//         _selectedTime.minute,
//       );


//       final request = CreateSessionRequest (
//         coupleId: _selectedCoupleId!,
//         fecha: fechaHora,
//         hora: _selectedTime,
//         costo: null, // Puedes agregar lógica para el costo si es necesario
//         notas: _descripcionController.text.trim().isNotEmpty ? _descripcionController.text : null,
//       );

//       final psychController = Provider.of<PsychologistController>(context, listen: false);
//       final success = await psychController.createSession(request);

//       if (success && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Sesión programada exitosamente'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.of(context).pop();
//       }
//     } else if (_selectedCoupleId == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Por favor seleccione una pareja'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   String _getSessionTypeText(SessionType type) {
//     switch (type) {
//       case SessionType.individual:
//         return 'Individual';
//       case SessionType.pareja:
//         return 'Pareja';
//       case SessionType.grupal:
//         return 'Grupal';
//       case SessionType.seguimiento:
//         return 'Seguimiento';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text('Nueva Sesión'),
//         backgroundColor: const Color(0xFF595082),
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header informativo
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: Colors.blue.shade200),
//                 ),
//                 child: Column(
//                   children: [
//                     const Icon(
//                       Icons.event_available,
//                       color: Colors.blue,
//                       size: 32,
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Programar Nueva Sesión',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Configure los detalles de la sesión terapéutica.',
//                       style: TextStyle(
//                         color: Colors.blue.shade700,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // Selección de pareja
//               Consumer<PsychologistController>(
//                 builder: (context, psychController, child) {
//                   return Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Seleccionar Pareja *',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF20263F),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                         DropdownButtonFormField<int>(
//                           value: _selectedCoupleId,
//                           decoration: InputDecoration(
//                             hintText: 'Seleccione una pareja',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                               borderSide: const BorderSide(color: Color(0xFF595082)),
//                             ),
//                           ),
//                           items: psychController.couples.map((couple) {
//                             return DropdownMenuItem<int>(
//                               value: couple.id,
//                               child: Text(
//                                 '${couple.nombreCliente1 ?? 'Cliente 1'} & ${couple.nombreCliente2 ?? 'Cliente 2'}',
//                                 style: const TextStyle(fontSize: 14),
//                               ),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedCoupleId = value;
//                             });
//                           },
//                           validator: (value) {
//                             if (value == null) {
//                               return 'Por favor seleccione una pareja';
//                             }
//                             return null;
//                           },
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
              
//               const SizedBox(height: 20),
              
//               // Título de la sesión
//               TextFormField(
//                 controller: _tituloController,
//                 decoration: InputDecoration(
//                   labelText: 'Título de la Sesión *',
//                   hintText: 'Ej: Sesión de comunicación asertiva',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Color(0xFF595082)),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Por favor ingrese el título';
//                   }
//                   return null;
//                 },
//               ),
              
//               const SizedBox(height: 16),
              
//               // Descripción
//               TextFormField(
//                 controller: _descripcionController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Descripción (Opcional)',
//                   hintText: 'Descripción detallada de la sesión...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Color(0xFF595082)),
//                   ),
//                   alignLabelWithHint: true,
//                 ),
//               ),
              
//               const SizedBox(height: 20),
              
//               // Fecha y hora
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Fecha *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF20263F),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           InkWell(
//                             onTap: _selectDate,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade400),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                   const Icon(Icons.calendar_today, color: Color(0xFF595082)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Hora *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF20263F),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           InkWell(
//                             onTap: _selectTime,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Colors.grey.shade400),
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     _selectedTime.format(context),
//                                     style: const TextStyle(fontSize: 16),
//                                   ),
//                                   const Icon(Icons.access_time, color: Color(0xFF595082)),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 20),
              
//               // Duración y tipo
//               Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Duración (minutos) *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF20263F),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           DropdownButtonFormField<int>(
//                             value: _duracionMinutos,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             ),
//                             items: [30, 45, 60, 90, 120].map((duration) {
//                               return DropdownMenuItem<int>(
//                                 value: duration,
//                                 child: Text('$duration min'),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _duracionMinutos = value!;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Tipo de Sesión *',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: Color(0xFF20263F),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           DropdownButtonFormField<SessionType>(
//                             value: _selectedType,
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                             ),
//                             items: SessionType.values.map((type) {
//                               return DropdownMenuItem<SessionType>(
//                                 value: type,
//                                 child: Text(_getSessionTypeText(type)),
//                               );
//                             }).toList(),
//                             onChanged: (value) {
//                               setState(() {
//                                 _selectedType = value!;
//                               });
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
              
//               const SizedBox(height: 20),
              
//               // Objetivos
//               TextFormField(
//                 controller: _objetivosController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Objetivos de la Sesión (Opcional)',
//                   hintText: 'Objetivos específicos a trabajar en esta sesión...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                     borderSide: const BorderSide(color: Color(0xFF595082)),
//                   ),
//                   alignLabelWithHint: true,
//                 ),
//               ),
              
//               const SizedBox(height: 32),
              
//               // Botones de acción
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         side: const BorderSide(color: Color(0xFF595082)),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Cancelar',
//                         style: TextStyle(
//                           color: Color(0xFF595082),
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     flex: 2,
//                     child: Consumer<PsychologistController>(
//                       builder: (context, psychController, child) {
//                         return ElevatedButton(
//                           onPressed: psychController.isLoading ? null : _createSession,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF595082),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: psychController.isLoading
//                               ? const CircularProgressIndicator(color: Colors.white)
//                               : const Text(
//                                   'Programar Sesión',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
              
//               // Mensaje de error
//               Consumer<PsychologistController>(
//                 builder: (context, psychController, child) {
//                   if (psychController.errorMessage != null) {
//                     return Padding(
//                       padding: const EdgeInsets.only(top: 16),
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.red.shade200),
//                         ),
//                         child: Text(
//                           psychController.errorMessage!,
//                           style: TextStyle(color: Colors.red.shade700),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     );
//                   }
//                   return const SizedBox.shrink();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../models/session_model.dart'; 

class CreateSessionScreen extends StatefulWidget {
  final int? preselectedCoupleId;

  const CreateSessionScreen({
    Key? key,
    this.preselectedCoupleId,
  }) : super(key: key);

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _objetivosController = TextEditingController();

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
      final psychController = Provider.of<PsychologistController>(context, listen: false);
      if (psychController.couples.isEmpty) {
        psychController.getCouples();
      }
    });
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _objetivosController.dispose();
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
    if (_formKey.currentState!.validate() && _selectedCoupleId != null) {
      final fechaHora = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Usamos CreateSessionRequest del modelo de sesión
      final request = CreateSessionRequest(
        coupleId: _selectedCoupleId!,
        titulo: _tituloController.text,
        descripcion: _descripcionController.text.trim().isNotEmpty 
            ? _descripcionController.text 
            : null,
        fechaHora: fechaHora,
        duracionMinutos: _duracionMinutos,
        tipo: _selectedType,
        objetivos: _objetivosController.text.trim().isNotEmpty 
            ? _objetivosController.text 
            : null,
      );

      final psychController = Provider.of<PsychologistController>(context, listen: false);
      final success = await psychController.createSession(request);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(psychController.errorMessage ?? 'Error al crear sesión'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
                            items: psychController.couples.map((couple) {
                              return DropdownMenuItem<int>(
                                value: couple.id,
                                child: Text('Pareja ${couple.id}'),
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
                          const SizedBox(height: 16),
                          DropdownButtonFormField<SessionType>(
                            value: _selectedType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de sesión',
                              border: OutlineInputBorder(),
                            ),
                            items: SessionType.values.map((type) {
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
                              DropdownMenuItem(value: 30, child: Text('30 minutos')),
                              DropdownMenuItem(value: 45, child: Text('45 minutos')),
                              DropdownMenuItem(value: 60, child: Text('1 hora')),
                              DropdownMenuItem(value: 90, child: Text('1.5 horas')),
                              DropdownMenuItem(value: 120, child: Text('2 horas')),
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
                      onPressed: psychController.isLoading ? null : _createSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: psychController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
      case SessionType.seguimiento:
        return 'Seguimiento';
    }
  }
}
