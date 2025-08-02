import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/psychologist_controller.dart';
import '../controllers/auth_controller.dart';
import 'dart:math';

class CreateCoupleScreen extends StatefulWidget {
  const CreateCoupleScreen({super.key});

  @override
  State<CreateCoupleScreen> createState() => _CreateCoupleScreenState();
}

class _CreateCoupleScreenState extends State<CreateCoupleScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCliente1Controller = TextEditingController();
  final _apellidoCliente1Controller = TextEditingController();
  final _correoCliente1Controller = TextEditingController();

  final _nombreCliente2Controller = TextEditingController();
  final _apellidoCliente2Controller = TextEditingController();
  final _correoCliente2Controller = TextEditingController();

  final _objetivosController = TextEditingController();

  @override
  void dispose() {
    _nombreCliente1Controller.dispose();
    _apellidoCliente1Controller.dispose();
    _correoCliente1Controller.dispose();
    _nombreCliente2Controller.dispose();
    _apellidoCliente2Controller.dispose();
    _correoCliente2Controller.dispose();
    _objetivosController.dispose();
    super.dispose();
  }

  Future<void> _createCouple() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final psychController = Provider.of<PsychologistController>(
      context,
      listen: false,
    );
    final authController = Provider.of<AuthController>(context, listen: false);
    final navigator = Navigator.of(
      context,
    ); // Captura el Navigator antes del await
    final messenger = ScaffoldMessenger.of(context); // Y el ScaffoldMessenger

    // 2. Comienza el bloque try/catch para manejar todo el flujo
    try {
      // 3. Activa el estado de carga UNA VEZ al principio
      psychController.clearMessages(); // Limpia errores antiguos
      psychController.sendLoading(true); // Método para setear loading

      final psicologoId = psychController.currentPsychologist?.id;
      if (psicologoId == null) {
        // Lanza un error controlado que será capturado por el catch
        throw Exception(
          'No se pudo identificar al psicólogo. Por favor, inicie sesión de nuevo.',
        );
      }

      // --- Genera contraseñas temporales seguras ---
      String generatePassword() {
        const length = 10;
        const chars =
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()';
        return String.fromCharCodes(
          Iterable.generate(
            length,
            (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
          ),
        );
      }

      final passwordCliente1 = generatePassword();
      final passwordCliente2 = generatePassword();

      // --- Registrar Cliente 1 ---
      print("Registrando Cliente 1...");
      final user1 = await authController.registerClient(
        correo: _correoCliente1Controller.text.trim(),
        username:
            _correoCliente1Controller.text
                .trim()
                .split('@')
                .first, // Genera un username
        contrasena: passwordCliente1, // Usa la contraseña generada
        nombre: _nombreCliente1Controller.text.trim(),
        apellido: _apellidoCliente1Controller.text.trim(),
        rol: 'cliente', // Envía el string que espera tu backend
        idPsicologo: psicologoId,
      );
      if (user1 == null) {
        throw Exception(
          'Error al registrar al Cliente 1. ${authController.errorMessage}',
        );
      }

      // --- Registrar Cliente 2 ---
      print("Registrando Cliente 2...");
      final user2 = await authController.registerClient(
        correo: _correoCliente2Controller.text.trim(),
        username: _correoCliente2Controller.text.trim().split('@').first,
        contrasena: passwordCliente2, // Usa la contraseña generada
        nombre: _nombreCliente2Controller.text.trim(),
        apellido: _apellidoCliente2Controller.text.trim(),
        rol: 'cliente',
        idPsicologo: psicologoId,
      );
      if (user2 == null) {
        // Opcional: Podrías añadir lógica para eliminar a user1 si este paso falla.
        throw Exception(
          'Error al registrar al Cliente 2. ${authController.errorMessage}',
        );
      }

      // --- Crear la Pareja ---
      print("Creando la pareja con IDs: ${user1.id}, ${user2.id}");
      final success = await psychController.createCouple(
        idParejaA: user1.id,
        idParejaB: user2.id,
        psychologistId: psicologoId,
        objetivosTerapia: _objetivosController.text.trim(),
        authController: authController,
      );
      if (!success) {
        throw Exception(
          'Error al crear la pareja. ${psychController.errorMessage}',
        );
      }

      // 4. Detén la carga en caso de éxito
      psychController.sendLoading(false);

      // --- Éxito Total ---
      // Muestra un diálogo con las contraseñas generadas
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('¡Pareja Creada con Éxito!'),
                content: SelectableText(
                  'La pareja ha sido registrada.\n\n'
                  'Credenciales Cliente 1:\n'
                  'Usuario: ${_correoCliente1Controller.text.trim()}\n'
                  'Contraseña: $passwordCliente1\n\n'
                  'Credenciales Cliente 2:\n'
                  'Usuario: ${_correoCliente2Controller.text.trim()}\n'
                  'Contraseña: $passwordCliente2\n\n'
                  'Por favor, guarde estas contraseñas para compartirlas con sus pacientes.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                      navigator.pop(); // Vuelve a la pantalla anterior
                    },
                    child: const Text('Entendido'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      // 5. Captura CUALQUIER error del flujo
      print("ERROR en _createCouple: $e");
      psychController.sendLoading(false); // DETIENE la carga
      psychController.setitError(
        e.toString().replaceAll("Exception: ", ""),
      ); // Muestra el error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nueva Pareja'),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Introducción
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Registro de Nueva Pareja',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Complete la información de ambos miembros de la pareja para crear su perfil terapéutico.',
                      style: TextStyle(color: Colors.blue.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Cliente 1
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8C662),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cliente 1',
                          style: TextStyle(
                            fontSize: 20,
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
                          child: TextFormField(
                            controller: _nombreCliente1Controller,
                            decoration: InputDecoration(
                              labelText: 'Nombre *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF595082),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _apellidoCliente1Controller,
                            decoration: InputDecoration(
                              labelText: 'Apellido *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF595082),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _correoCliente1Controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico *',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF595082),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el correo';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cliente 2
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF41644A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cliente 2',
                          style: TextStyle(
                            fontSize: 20,
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
                          child: TextFormField(
                            controller: _nombreCliente2Controller,
                            decoration: InputDecoration(
                              labelText: 'Nombre *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF595082),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _apellidoCliente2Controller,
                            decoration: InputDecoration(
                              labelText: 'Apellido *',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF595082),
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _correoCliente2Controller,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico *',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF595082),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingrese el correo';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        if (value.trim() ==
                            _correoCliente1Controller.text.trim()) {
                          return 'Los correos deben ser diferentes';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Objetivos de Terapia
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF595082),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Objetivos de Terapia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF20263F),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _objetivosController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Objetivos y Metas Terapéuticas *',
                        hintText:
                            'Describa los objetivos principales que se trabajarán con esta pareja...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF595082),
                          ),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor defina los objetivos de terapia';
                        }
                        if (value.trim().length < 20) {
                          return 'Los objetivos deben ser más descriptivos (mín. 20 caracteres)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF595082)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Color(0xFF595082),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Consumer<PsychologistController>(
                      builder: (context, psychController, child) {
                        return ElevatedButton(
                          onPressed:
                              psychController.isLoading ? null : _createCouple,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF595082),
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
                                    'Crear Pareja',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Mensaje de error
              Consumer<PsychologistController>(
                builder: (context, psychController, child) {
                  if (psychController.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          psychController.errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
