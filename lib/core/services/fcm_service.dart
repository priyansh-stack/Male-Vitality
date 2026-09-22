import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('FCM: Handling background message ${message.messageId} - ${message.notification?.title}');
  } catch (e) {
    debugPrint('FCM: Background handler error: $e');
  }
}

class FcmService {
  FcmService._internal();
  static final FcmService instance = FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _currentUserId;

  static const AndroidNotificationChannel _clinicalChannel = AndroidNotificationChannel(
    'clinical_alerts_channel',
    'Clinical Biomarker & Directive Alerts',
    description: 'High-priority notifications for critical male vitality biomarkers and directives.',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // 1. Request OS permissions (Android 13+ & iOS)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM: Authorization status: ${settings.authorizationStatus}');

      // 2. Setup Android local notification channel
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('FCM: User tapped foreground notification payload: ${response.payload}');
        },
      );

      final androidPlatform = _localNotifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlatform != null) {
        await androidPlatform.createNotificationChannel(_clinicalChannel);
      }

      // 3. Foreground message listener (renders heads-up notification)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM: Foreground message received: ${message.notification?.title}');
        _showForegroundNotification(message);
      });

      // 4. Notification tap when app was in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM: App opened from notification: ${message.data}');
      });

      // 5. Token refresh listener
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('FCM: Token refreshed: $newToken');
        if (_currentUserId != null) {
          _persistTokenToFirestore(_currentUserId!, newToken);
        }
      });

      _initialized = true;
    } catch (e) {
      debugPrint('FCM: Initialization error: $e');
    }
  }

  Future<void> syncUserSession(String userId) async {
    _currentUserId = userId;
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint('FCM: Retrieved device token for user $userId: $token');
        await _persistTokenToFirestore(userId, token);
      }
    } catch (e) {
      debugPrint('FCM: Error syncing user token: $e');
    }
  }

  Future<void> _persistTokenToFirestore(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'lastFcmRegistration': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FCM: Failed to save token to Firestore: $e');
    }
  }

  Future<void> updateTopicSubscription(String topicKey, bool enabled) async {
    try {
      if (enabled) {
        await _fcm.subscribeToTopic(topicKey);
        debugPrint('FCM: Subscribed to topic $topicKey');
      } else {
        await _fcm.unsubscribeFromTopic(topicKey);
        debugPrint('FCM: Unsubscribed from topic $topicKey');
      }
    } catch (e) {
      debugPrint('FCM: Error updating topic subscription $topicKey: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'Male Vitality Alert',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _clinicalChannel.id,
          _clinicalChannel.name,
          channelDescription: _clinicalChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data.toString(),
    );
  }
}
