import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/journaling_controller.dart';
import '../core/constants.dart';
import '../controllers/auth_controller.dart';

class IndividualLogScreen extends StatefulWidget {
  const IndividualLogScreen({super.key});

  @override
  State<IndividualLogScreen> createState() => _IndividualLogScreenState();
}

class _IndividualLogScreenState extends State<IndividualLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _situationController = TextEditingController();
  final _thoughtController = TextEditingController();
  final _physicalSensationController = TextEditingController();
  final _behaviorController = TextEditingController();

  String? _selectedEmotion;
  int _stressLevel = 5;
  double _sleepHours = 8.0;

  @override
  void dispose() {
    _situationController.dispose();
    _thoughtController.dispose();
    _physicalSensationController.dispose();
    _behaviorController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    // Usamos la validación segura que ya aprendimos
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Si el formulario no es válido, salimos
    }

    // Comprobación separada para la emoción
    if (_selectedEmotion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, seleccione una emoción.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final journalingController = Provider.of<JournalingController>(
      context,
      listen: false,
    );

    // Llamamos al método del controlador pasando cada valor como un parámetro nombrado.
    // El controlador se encargará de añadir cliente_id, pareja_id y fecha_registro.
    final success = await journalingController.submitIndividualLog(
      authController: Provider.of<AuthController>(context, listen: false),
      situation: _situationController.text.trim(),
      thought: _thoughtController.text.trim(),
      emotion:
          _selectedEmotion!, // Es seguro usar '!' porque ya lo comprobamos arriba
      // Para los campos opcionales, nos aseguramos de pasar 'null' si están vacíos
      physicalSensation:
          _physicalSensationController.text.trim().isEmpty
              ? null
              : _physicalSensationController.text.trim(),

      behavior:
          _behaviorController.text.trim().isEmpty
              ? null
              : _behaviorController.text.trim(),

      stressLevel: _stressLevel,
      sleepQualityHours: _sleepHours,
    );

    // La lógica de retroalimentación no cambia
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro individual enviado correctamente!'),
            backgroundColor: Color(0xFF41644A),
          ),
        );
        Navigator.of(context).pop();
      } else {
        // Ahora puedes mostrar el error específico que viene del controlador
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              journalingController.errorMessage ??
                  'Ocurrió un error inesperado.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registro Individual'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF20263F),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Situation
              TextFormField(
                controller: _situationController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Situación *',
                  hintText: 'Describe que sucede...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF8C662)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor describe la situación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Thought
              TextFormField(
                controller: _thoughtController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Pensamiento *',
                  hintText: '¿Qué pasó por tu mente?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF8C662)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor describe tu pensamiento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Emotion Selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Emoción *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF20263F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          AppConstants.emotions.map((emotion) {
                            final isSelected = _selectedEmotion == emotion;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEmotion = emotion;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFFF8C662)
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFFF8C662)
                                            : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  emotion.toLowerCase().replaceAll('_', ' '),
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : const Color(0xFF20263F),
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Physical Sensation (Optional)
              TextFormField(
                controller: _physicalSensationController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Sensación física (Opcional)',
                  hintText: '¿Cómo se sintió tu cuerpo?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF8C662)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Behavior (Optional)
              TextFormField(
                controller: _behaviorController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Comportamiento (Opcional)',
                  hintText: '¿Qué hiciste?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF8C662)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stress Level Slider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel de Estrés: $_stressLevel/10',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF20263F),
                      ),
                    ),
                    Slider(
                      value: _stressLevel.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: const Color(0xFFF8C662),
                      onChanged: (value) {
                        setState(() {
                          _stressLevel = value.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sleep Hours Slider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Calidad de sueño: ${_sleepHours.toStringAsFixed(1)} horas',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF20263F),
                      ),
                    ),
                    Slider(
                      value: _sleepHours,
                      min: 0,
                      max: 12,
                      divisions: 24,
                      activeColor: const Color(0xFFF8C662),
                      onChanged: (value) {
                        setState(() {
                          _sleepHours = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              Consumer<JournalingController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : _submitLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF41644A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        controller.isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Enviar registro',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  );
                },
              ),

              // Error Message
              Consumer<JournalingController>(
                builder: (context, controller, child) {
                  if (controller.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        controller.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
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
