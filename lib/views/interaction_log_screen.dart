import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/journaling_controller.dart';
import '../models/interaction_log_model.dart';
import '../core/constants.dart';

class InteractionLogScreen extends StatefulWidget {
  const InteractionLogScreen({super.key});

  @override
  State<InteractionLogScreen> createState() => _InteractionLogScreenState();
}

class _InteractionLogScreenState extends State<InteractionLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String? _selectedInteractionType;
  String? _selectedMyCommunicationStyle;
  String? _selectedPartnerCommunicationStyle;
  String? _selectedPhysicalContactLevel;
  String? _selectedMyEmotion;
  String? _selectedPartnerEmotion;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitLog() async {
    if (_formKey.currentState!.validate() && 
        _selectedInteractionType != null && 
        _selectedMyEmotion != null) {
      
      final log = InteractionLog(
        interactionDescription: _descriptionController.text.trim(),
        interactionType: _selectedInteractionType!,
        myCommunicationStyle: _selectedMyCommunicationStyle,
        perceivedPartnerCommunicationStyle: _selectedPartnerCommunicationStyle,
        physicalContactLevel: _selectedPhysicalContactLevel,
        myEmotionInInteraction: _selectedMyEmotion!,
        perceivedPartnerEmotion: _selectedPartnerEmotion,
      );

      final journalingController = Provider.of<JournalingController>(context, listen: false);
      final success = await journalingController.submitInteractionLog(log);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro de interacción enviado exitosamente!'),
            backgroundColor: Color(0xFF213722),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, rellene todos los campos obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Registro de Interacción'),
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
              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descripcion de la Interacción *',
                  hintText: 'Describe lo que sucedió durante esta interacción....',
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
                    return 'Por favor describe la interacción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Interaction Type
              _buildDropdownField(
                label: 'Tipo de Interacción *',
                value: _selectedInteractionType,
                items: const [
                  AppConstants.conflictType,
                  AppConstants.supportiveConversationType,
                  AppConstants.casualConversationType,
                  AppConstants.intimateConversationType,
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedInteractionType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // My Communication Style
              _buildDropdownField(
                label: 'Mi estilo de comunicación',
                value: _selectedMyCommunicationStyle,
                items: const [
                  AppConstants.assertiveCommunication,
                  AppConstants.passiveCommunication,
                  AppConstants.aggressiveCommunication,
                  AppConstants.passiveAggressiveCommunication,
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMyCommunicationStyle = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Partner Communication Style
              _buildDropdownField(
                label: 'Estilo de comunicación de la pareja',
                value: _selectedPartnerCommunicationStyle,
                items: const [
                  AppConstants.assertiveCommunication,
                  AppConstants.passiveCommunication,
                  AppConstants.aggressiveCommunication,
                  AppConstants.passiveAggressiveCommunication,
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPartnerCommunicationStyle = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Physical Contact Level
              _buildDropdownField(
                label: 'Nivel de contacto físico',
                value: _selectedPhysicalContactLevel,
                items: const [
                  AppConstants.noContactLevel,
                  AppConstants.lightContactLevel,
                  AppConstants.moderateContactLevel,
                  AppConstants.intimateContactLevel,
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPhysicalContactLevel = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // My Emotion
              _buildEmotionSelector(
                label: 'Mi Emoción *',
                selectedEmotion: _selectedMyEmotion,
                onEmotionSelected: (emotion) {
                  setState(() {
                    _selectedMyEmotion = emotion;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Partner Emotion
              _buildEmotionSelector(
                label: 'Emoción de la pareja (cómo crees que se sintió)',
                selectedEmotion: _selectedPartnerEmotion,
                onEmotionSelected: (emotion) {
                  setState(() {
                    _selectedPartnerEmotion = emotion;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              Consumer<JournalingController>(
                builder: (context, controller, child) {
                  return ElevatedButton(
                    onPressed: controller.isLoading ? null : _submitLog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF213722),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Enviar registro de interacción',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF8C662)),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(_formatEnumValue(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEmotionSelector({
    required String label,
    required String? selectedEmotion,
    required ValueChanged<String> onEmotionSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF20263F),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.emotions.map((emotion) {
              final isSelected = selectedEmotion == emotion;
              return GestureDetector(
                onTap: () => onEmotionSelected(emotion),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF213722) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF213722) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    emotion.toLowerCase().replaceAll('_', ' '),
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF20263F),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatEnumValue(String value) {
    return value.toLowerCase().replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}