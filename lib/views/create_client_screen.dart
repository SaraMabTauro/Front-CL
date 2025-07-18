import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

class CreateClientScreen extends StatefulWidget {
  const CreateClientScreen({super.key});
  static const String routeName = '/create-client';

  @override
  State<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends State<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _idPsicologoController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _correoController.dispose();
    _usernameController.dispose();
    _contrasenaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _idPsicologoController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final response = await Provider.of<AuthController>(context, listen: false)
          .registerClient(
        correo: _correoController.text.trim(),
        username: _usernameController.text.trim(),
        contrasena: _contrasenaController.text,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        rol: 'paciente',
        idPsicologo: int.tryParse(_idPsicologoController.text) ?? 1,
      );

      setState(() => _isLoading = false);

      if (response != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cliente creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Provider.of<AuthController>(context, listen: false).errorMessage ??
                  'Error al crear cliente',
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
      appBar: AppBar(
        title: const Text('Registrar Cliente'),
        backgroundColor: const Color(0xFF595082),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _correoController,
                  decoration: const InputDecoration(labelText: 'Correo'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese el correo' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Usuario'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese el usuario' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contrasenaController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese la contraseña' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese el nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apellidoController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese el apellido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _idPsicologoController,
                  decoration: const InputDecoration(labelText: 'ID Psicólogo'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Ingrese el ID del psicólogo' : null,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateClient,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF595082),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrar Cliente'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}