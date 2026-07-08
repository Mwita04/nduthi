import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(_handleTokenRefresh);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
        'FCM Message received: ${message.notification?.title} - ${message.notification?.body}');
  }

  static void _handleTokenRefresh(String token) {
    debugPrint('FCM token refreshed: $token');
  }

  static Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }
}
