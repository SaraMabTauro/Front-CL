import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../controllers/psychologist_controller.dart';
import 'psychologist_login_screen.dart';
import 'package:http/http.dart' as http;

class RegisterView extends StatefulWidget {
  static const String routeName = '/register-psychologist';

  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _fotoPerfilUrlController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _cedulaProfesionalController = TextEditingController();
  final TextEditingController _cedulaDocumentoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  String? _selectedProfileImageUrl;
  String? _selectedDocumentImageUrl;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _fotoPerfilUrlController.dispose();
    _especialidadController.dispose();
    _cedulaProfesionalController.dispose();
    _cedulaDocumentoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Aquí simularías subir la imagen a tu servidor y obtener la URL
      // Por ahora, usamos la ruta local como ejemplo
      String imageUrl = await _uploadImageToServer(image.path);
      setState(() {
        _selectedProfileImageUrl = imageUrl;
        _fotoPerfilUrlController.text = imageUrl;
      });
    }
  }

  Future<void> _pickDocumentImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Aquí simularías subir la imagen a tu servidor y obtener la URL
      String imageUrl = await _uploadImageToServer(image.path);
      setState(() {
        _selectedDocumentImageUrl = imageUrl;
        _cedulaDocumentoController.text = imageUrl;
      });
    }
  }

  // Función simulada para subir imagen al servidor
  Future<String> _uploadImageToServer(String imagePath) async {
    // Ejemplo con http/dio
  var request = http.MultipartRequest('POST', Uri.parse('tu-servidor.com/upload'));
  request.files.add(await http.MultipartFile.fromPath('image', imagePath));
  
  var response = await request.send();
  var responseData = await response.stream.bytesToString();
  var jsonResponse = json.decode(responseData);
  
  return jsonResponse['url']; // URL retornada por el servidor
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final psychController = Provider.of<PsychologistController>(context, listen: false);
      final success = await psychController.registerPsychologist(
        correo: _correoController.text.trim(),
        contrasena: _contrasenaController.text,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        fotoPerfilUrl: _fotoPerfilUrlController.text.trim().isNotEmpty ? _fotoPerfilUrlController.text.trim() : null,
        especialidad: _especialidadController.text.trim(),
        cedulaProfesional: _cedulaProfesionalController.text.trim(),
        cedulaDocumento: _cedulaDocumentoController.text.trim().isNotEmpty ? _cedulaDocumentoController.text.trim() : null,
        telefono: _telefonoController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(psychController.successMessage ?? 'Registro exitoso'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed(PsychologistLoginScreen.routeName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(psychController.errorMessage ?? 'Error en el registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF6758A3)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6758A3), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildImagePickerField({
    required String label,
    required String? selectedImageUrl,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6758A3),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                color: Colors.grey[50],
              ),
              child: selectedImageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.image,
                              size: 40,
                              color: Color(0xFF6758A3),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          size: 40,
                          color: const Color(0xFF6758A3),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toca para seleccionar imagen',
                          style: TextStyle(
                            color: Color(0xFF6758A3),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final psychController = Provider.of<PsychologistController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Registro de Psicólogo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6758A3),
        elevation: 0,
        centerTitle: true,
      ),
      body: psychController.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6758A3)),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header con icono
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6758A3).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_add,
                              size: 50,
                              color: Color(0xFF6758A3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Crea tu cuenta profesional',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6758A3),
                            ),
                          ),
                          const Text(
                            'Completa tus datos para comenzar',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Formulario
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(
                            controller: _correoController,
                            label: 'Correo Electrónico',
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su correo';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Ingrese un correo válido';
                              }
                              return null;
                            },
                          ),
                          
                          _buildTextField(
                            controller: _contrasenaController,
                            label: 'Contraseña',
                            icon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: const Color(0xFF6758A3),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          
                          _buildTextField(
                            controller: _nombreController,
                            label: 'Nombre',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su nombre';
                              }
                              return null;
                            },
                          ),
                          
                          _buildTextField(
                            controller: _apellidoController,
                            label: 'Apellido',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su apellido';
                              }
                              return null;
                            },
                          ),
                          
                          _buildTextField(
                            controller: _especialidadController,
                            label: 'Especialidad',
                            icon: Icons.medical_services,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su especialidad';
                              }
                              return null;
                            },
                          ),
                          
                          _buildTextField(
                            controller: _cedulaProfesionalController,
                            label: 'Cédula Profesional',
                            icon: Icons.badge,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su cédula profesional';
                              }
                              return null;
                            },
                          ),
                          
                          _buildTextField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, ingrese su teléfono';
                              }
                              if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Ingrese un número de teléfono válido (10 dígitos)';
                              }
                              return null;
                            },
                          ),
                          
                          // Selector de imagen de perfil
                          _buildImagePickerField(
                            label: 'Foto de Perfil (Opcional)',
                            selectedImageUrl: _selectedProfileImageUrl,
                            onTap: _pickProfileImage,
                            icon: Icons.camera_alt,
                          ),
                          
                          // Selector de documento de cédula
                          _buildImagePickerField(
                            label: 'Documento de Cédula (Opcional)',
                            selectedImageUrl: _selectedDocumentImageUrl,
                            onTap: _pickDocumentImage,
                            icon: Icons.description,
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Botón de registro
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF8C662),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Enlace a login
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                PsychologistLoginScreen.routeName,
                              );
                            },
                            child: RichText(
                              text: const TextSpan(
                                text: '¿Ya tienes una cuenta? ',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Inicia sesión',
                                    style: TextStyle(
                                      color: Color(0xFFF8C662),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}