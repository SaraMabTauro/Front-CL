import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import 'package:go_router/go_router.dart';

const Color kPrimaryColor = Color.fromARGB(255, 98, 147, 197);


class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({Key? key}) : super(key: key);

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  String _frequency = 'Diaria'; // Valor por defecto
  TimeOfDay? _reminderTime;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _reminderTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Hábito'),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre del Hábito'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un nombre.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _targetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Objetivo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa un objetivo.';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor, ingresa un número válido.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unidad (ej: minutos, km)'),
              ),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: const InputDecoration(labelText: 'Frecuencia'),
                items: ['Diaria', 'Semanal', 'Mensual']
                    .map((frequency) => DropdownMenuItem(
                          value: frequency,
                          child: Text(frequency),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value!;
                  });
                },
              ),
              ListTile(
                title: const Text('Recordatorio'),
                subtitle: _reminderTime == null
                    ? const Text('No establecido')
                    : Text(_reminderTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Crear el hábito
                    final newHabit = Habit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _nameController.text,
                      description: _descriptionController.text,
                      frequency: _frequency,
                      target: int.parse(_targetController.text),
                      currentProgress: 0,
                      unit: _unitController.text,
                      reminderTime: _reminderTime,
                    );

                    Provider.of<HabitService>(context, listen: false).addHabit(newHabit);
                    context.pop(); // Regresar a la pantalla anterior
                  }
                },
                child: const Text('Crear Hábito'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}