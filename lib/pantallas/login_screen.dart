import 'package:flutter/material.dart';
import '../servicios/auth_service.dart';
import 'contenedor_screen.dart';
import 'register_screen.dart'; // Importaremos la pantalla de registro que crearemos a continuación
import 'estudiante_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrDniController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; // Controla si la contraseña está oculta o visible
  String? _errorMessage;

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final input = _emailOrDniController.text.trim();
    final isEmail = input.contains('@');

    final result = await AuthService.login(
      email: isEmail ? input : null,
      dni: !isEmail ? input : null,
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final userData = result['user'];
      
      // Verificamos si tiene perfil de estudiante o de docente basándonos en los datos del backend
      final bool isStudent = userData['studentProfile'] != null || 
                             (userData['roles'] != null && (userData['roles'] as List).contains('STUDENT'));
      
      final bool isTeacher = userData['teacherProfile'] != null || 
                             (userData['roles'] != null && (userData['roles'] as List).contains('TEACHER'));

      // Definimos la pantalla de destino según su rol
      Widget targetScreen;
      
      if (isStudent && !isTeacher) {
        // Pantalla exclusiva para el estudiante (solo lectura de avisos)
        targetScreen = const EstudianteScreen(); // Reemplazá con el nombre de tu pantalla de alumno
      } else {
        // Pantalla para docente / preceptor / administrador
        targetScreen = const ContenedorScreen(); // Tu pantalla actual de gestión/docente
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      );
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 64,
                    color: Color(0xFF00D2A0),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'EduQuest',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Alerta Temprana - Ingreso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        border: Border.all(color: const Color(0xFFEF4444)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFEF4444)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailOrDniController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico o DNI',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresá tu email o DNI';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // CAMPO CONTRASEÑA CON EL BOTÓN DEL "OJO"
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword, // Se enlaza al estado
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword; // Alterna estado
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresá tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D2A0),
                      foregroundColor: const Color(0xFF0A0F1D),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Botón para ir al Registro
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      '¿No tenés cuenta? Registrate como estudiante',
                      style: TextStyle(color: Color(0xFF38BDF8)),
                    ),
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