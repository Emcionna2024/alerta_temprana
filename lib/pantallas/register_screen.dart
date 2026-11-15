import 'package:flutter/material.dart';
import '../servicios/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dniController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _institutionIdController = TextEditingController(text: '1'); // Por defecto 1
  final _courseIdController = TextEditingController(text: '1');     // Por defecto 1

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await AuthService.registerStudent(
      dni: _dniController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      institutionId: int.parse(_institutionIdController.text.trim()),
      courseId: int.parse(_courseIdController.text.trim()),
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      setState(() {
        _successMessage = result['message'];
      });
      // Esperar un momento y volver al login
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // [MODIFICACIÓN]: Fondo blanco para modo claro
      appBar: AppBar(
        title: const Text(
          'Registro de Estudiante',
          style: TextStyle(color: Color(0xFF0F120F), fontWeight: FontWeight.bold), // [MODIFICACIÓN]: Texto oscuro legible
        ),
        backgroundColor: Colors.white, // [MODIFICACIÓN]: AppBar blanco
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Ícono de retroceso oscuro
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Creá tu cuenta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F120F), // [MODIFICACIÓN]: Texto principal oscuro (#0F120F)
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFFEF4444)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFFEF4444)), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF50E11).withOpacity(0.1), // [MODIFICACIÓN]: Éxito con primario suave
                        border: Border.all(color: const Color(0xFFF50E11)), // [MODIFICACIÓN]: Borde primario (#F50E11)
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_successMessage!, style: const TextStyle(color: Color(0xFFF50E11)), textAlign: TextAlign.center), // [MODIFICACIÓN]: Texto primario
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _firstNameController,
                    style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF64748B)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _lastNameController,
                    style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFF64748B)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _dniController,
                    style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                    decoration: const InputDecoration(
                      labelText: 'DNI',
                      prefixIcon: Icon(Icons.badge, color: Color(0xFF64748B)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF64748B)),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF64748B)),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _institutionIdController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                          decoration: const InputDecoration(labelText: 'ID Institución'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _courseIdController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Color(0xFF0F120F)), // [MODIFICACIÓN]: Texto oscuro
                          decoration: const InputDecoration(labelText: 'ID Curso'),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF50E11), // [MODIFICACIÓN]: Fondo primario institucional (#F50E11)
                      foregroundColor: Colors.white, // [MODIFICACIÓN]: Texto blanco
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Registrarse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}