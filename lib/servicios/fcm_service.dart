import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log('Mensaje en background: ${message.messageId}');
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> inicializar({
    required int userIdLogueado,
    required String tokenJwt, // <--- 1. Recibimos el JWT aquí también
    required Function(RemoteMessage) onMensajeRecibido,
  }) async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    const AndroidInitializationSettings initAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: initAndroid);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        log('Usuario tocó la notificación local: ${details.payload}');
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'canal_ausencias',
      'Alertas de Ausencias Docentes',
      description: 'Notificaciones prioritarias de clases suspendidas',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 3. Manejar Estado 1: App abierta (Foreground) -> Forzar banner visual
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Mensaje en foreground recibido: ${message.notification?.title}');
      
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }

      onMensajeRecibido(message);
    });

    // 4. Obtener el Token FCM y enviarlo al backend de Neon/Prisma
    String? token;
    if (kIsWeb) {
      token = await _messaging.getToken(
        vapidKey: 'BBaTJkZGCkE4S4gfgHf8EtRC3bZB78wOWEpHupTN1TFm8kWECokGvzG-QlalWDiTQeEN4izQgbybbqE20AUm_gg',
      );
    } else {
      token = await _messaging.getToken();
    }
    
    if (token != null) {
      log('Token FCM obtenido: $token');
      await _enviarTokenAlBackend(userIdLogueado, token, tokenJwt); // <--- 2. Pasamos el tokenJwt aquí
    }

    // Escuchar si el token se refresca automáticamente
    _messaging.onTokenRefresh.listen((newToken) {
      _enviarTokenAlBackend(userIdLogueado, newToken, tokenJwt); // <--- 3. Y también aquí
    });
  }

  // 5. Método privado para sincronizar el token adaptándose al dispositivo (Web o Android)
  static Future<void> _enviarTokenAlBackend(int userId, String token, String tokenJwt) async {
    try {
      final url = Uri.parse('http://localhost:3000/api/devices');
      
      final String plataformaDetectada = kIsWeb ? 'flutter_web' : 'flutter_android';

      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenJwt',
        },
        body: jsonEncode({
          'userId': userId,
          'token': token,
          'platform': plataformaDetectada,
        }),
      );
      log('Token FCM ($plataformaDetectada) registrado exitosamente en la base de datos.');
    } catch (e) {
      log('Error al enviar el Token FCM al backend: $e');
    }
  }
}