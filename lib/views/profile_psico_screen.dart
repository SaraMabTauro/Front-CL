import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/psychologist_controller.dart';
import 'package:intl/intl.dart'; // Necesitarás este paquete para formatear fechas

class PsychologistProfileView extends StatefulWidget {
  const PsychologistProfileView({Key? key}) : super(key: key);

  @override
  _PsychologistProfileViewState createState() =>
      _PsychologistProfileViewState();
}

class _PsychologistProfileViewState extends State<PsychologistProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _cedulaController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // CORRECIÓN: La carga de datos debe ocurrir después de que el widget se construya por primera vez.
    // Usar postFrameCallback es una forma segura de hacerlo.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  // CORRECIÓN: Lógica de carga de datos simplificada y correcta.
  void _loadUserData() {
    // Obtenemos el controlador, no el modelo directamente.
    final psychController = Provider.of<PsychologistController>(
      context,
      listen: false,
    );
    final psychologist = psychController.currentPsychologist;

    if (psychologist != null) {
      _firstNameController.text = psychologist.nombre;
      _lastNameController.text = psychologist.apellido;
      _emailController.text = psychologist.correo;
      _phoneController.text = psychologist.telefono;
      _specialtyController.text = psychologist.especialidad;
      _cedulaController.text = psychologist.cedulaProfesional;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // CORRECIÓN: Lógica de guardado completamente reescrita.
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si el formulario no es válido, no hacemos nada.
    }

    setState(() => _isLoading = true);

    final psychController = Provider.of<PsychologistController>(
      context,
      listen: false,
    );
    final psychologist = psychController.currentPsychologist;

    if (psychologist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: No se pudo identificar al psicólogo.'),
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final updatedData = {
      'nombre': _firstNameController.text.trim(),
      'telefono': _phoneController.text.trim(),
    };

    // Llamamos al método correcto en el controlador
    final success = await psychController.updatePsychologist(psychologist.id, updatedData);

    // Lógica para subir la imagen (si se seleccionó una)
    // if (_selectedImage != null) {
    //   await psychController.updateProfileImage(psychologist.id, _selectedImage!);
    // }

    if (mounted) { // Verificar que el widget todavía está en el árbol
      setState(() {
        _isLoading = false;
        if (success) {
          _isEditing = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Perfil actualizado exitosamente' : psychController.errorMessage ?? 'Error al actualizar el perfil'),
          backgroundColor: success ? const Color(0xFF595082) : Colors.red,
        ),
      );
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _selectedImage = null;
    });
    _loadUserData(); // Recargamos los datos originales
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mi Perfil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF595082),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      // CORRECIÓN: Usamos el PsychologistController como única fuente de verdad.
      body: Consumer<PsychologistController>(
        builder: (context, psychController, child) {
          final psychologist = psychController.currentPsychologist;

          if (psychController.isLoading && psychologist == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (psychologist == null) {
            return const Center(
              child: Text('No se pudieron cargar los datos del psicólogo.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(
                            0xFF595082,
                          ).withOpacity(0.1),
                          // CORRECIÓN: Lógica de imagen simplificada y segura
                          backgroundImage:
                              _selectedImage != null
                                  ? FileImage(_selectedImage!) as ImageProvider
                                  : (psychologist.fotoPerfilUrl != null &&
                                      psychologist.fotoPerfilUrl!.isNotEmpty)
                                  ? NetworkImage(psychologist.fotoPerfilUrl!)
                                  : null,
                          child:
                              (_selectedImage == null &&
                                      (psychologist.fotoPerfilUrl == null ||
                                          psychologist.fotoPerfilUrl!.isEmpty))
                                  ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Color(0xFF595082),
                                  )
                                  : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF595082),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Información Personal'),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'Nombre',
                          icon: Icons.person,
                          enabled: _isEditing,
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'El nombre es requerido'
                                      : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Apellido',
                          icon: Icons.person,
                          enabled: _isEditing,
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'El apellido es requerido'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    label: 'Correo Electrónico',
                    icon: Icons.email,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'El correo es requerido';
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value))
                        return 'Ingrese un correo válido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _phoneController,
                    label: 'Teléfono',
                    icon: Icons.phone,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'El teléfono es requerido'
                                : null,
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle('Información Profesional'),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _specialtyController,
                    label: 'Especialidad',
                    icon: Icons.psychology,
                    enabled: _isEditing,
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'La especialidad es requerida'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _cedulaController,
                    label: 'Cédula Profesional',
                    icon: Icons.badge,
                    enabled: _isEditing,
                    validator:
                        (value) =>
                            (value == null || value.isEmpty)
                                ? 'La cédula es requerida'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  // CORRECIÓN: Usar el objeto 'psychologist' del controlador
                  if (psychologist.fechaCreacion != null) ...[
                    _buildInfoCard(
                      'Fecha de Registro',
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(psychologist.fechaCreacion!),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoCard('ID de Usuario', psychologist.id.toString()),

                  const SizedBox(height: 32),

                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _cancelEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[400],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF595082),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Guardar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ... (tus widgets _buildSectionTitle, _buildTextField, _buildInfoCard no necesitan cambios)
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF595082),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF595082)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF595082), width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[50],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF595082),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }
}
