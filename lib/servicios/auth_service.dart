import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // URL base de tu backend (si usás emulador Android, recordá que suele ser 'http://10.0.2.2:3000', 
  // pero para Chrome/Web o Windows local usamos 'http://localhost:3000')
  static const String baseUrl = 'http://localhost:3000/api/auth';

  static Future<Map<String, dynamic>> login({
    String? email,
    String? dni,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          if (email != null && email.isNotEmpty) 'email': email,
          if (dni != null && dni.isNotEmpty) 'dni': dni,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Devuelve el token y los datos del usuario (roles, perfil, etc.)
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al iniciar sesión',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor: $e',
      };
    }
  }
  // NUEVO: Método de Registro de Estudiante
  static Future<Map<String, dynamic>> registerStudent({
    required String dni,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required int institutionId,
    required int courseId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register-student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'dni': dni,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'institutionId': institutionId,
          'courseId': courseId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Registro exitoso',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor: $e',
      };
    }
  }
}
