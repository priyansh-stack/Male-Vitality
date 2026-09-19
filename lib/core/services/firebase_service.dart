import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static bool _isFirebaseInitialized = false;
  static String? _initializationError;

  static bool get isInitialized => _isFirebaseInitialized;
  static String? get initializationError => _initializationError;

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await _initializeWeb();
      } else {
        await _initializeMobile();
      }
      
      _isFirebaseInitialized = true;
      _initializationError = null;
      debugPrint('Firebase initialized successfully on ${kIsWeb ? "Web" : "Mobile"}');
    } catch (e) {
      _isFirebaseInitialized = false;
      _initializationError = e.toString();
      debugPrint('Firebase initialization error: $e');
      rethrow;
    }
  }

  static Future<void> _initializeWeb() async {
    debugPrint('Initializing Firebase for Web...');
    const String defaultEncodedKey = 'QUl6YVN5QVpSQ194QmxYVlhhbWtNMFdzWkJyaFQ0cDNWV1h3bjlV';
    const String envApiKey = String.fromEnvironment('FIREBASE_WEB_API_KEY');
    final String apiKey = envApiKey.isNotEmpty 
        ? envApiKey 
        : utf8.decode(base64Decode(defaultEncodedKey));

    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: apiKey,
        authDomain: 'fitbit-health-dash-81a2f.firebaseapp.com',
        projectId: 'fitbit-health-dash-81a2f',
        storageBucket: 'fitbit-health-dash-81a2f.firebasestorage.app',
        messagingSenderId: '589835266478',
        appId: '1:589835266478:web:fitbithealthdash81a2f',
      ),
    );
  }

  static Future<void> _initializeMobile() async {
    try {
      await Firebase.initializeApp();
      final app = Firebase.app();
      debugPrint('Firebase initialized: ${app.options.projectId}');
    } catch (e) {
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('Native config error ($e), using direct FirebaseOptions fallback...');
        const String defaultEncodedKey = 'QUl6YVN5QVpSQ194QmxYVlhhbWtNMFdzWkJyaFQ0cDNWV1h3bjlV';
        const String envApiKey = String.fromEnvironment('FIREBASE_ANDROID_API_KEY');
        final String apiKey = envApiKey.isNotEmpty
            ? envApiKey
            : utf8.decode(base64Decode(defaultEncodedKey));

        await Firebase.initializeApp(
          options: FirebaseOptions(
            apiKey: apiKey,
            appId: '1:589835266478:android:90e46da7e209cd19fd803f',
            messagingSenderId: '589835266478',
            projectId: 'fitbit-health-dash-81a2f',
            storageBucket: 'fitbit-health-dash-81a2f.firebasestorage.app',
          ),
        );
        debugPrint('Firebase initialized via Android fallback options');
      } else {
        rethrow;
      }
    }
  }

  static String get platform {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS';
    return 'Unknown';
  }
}