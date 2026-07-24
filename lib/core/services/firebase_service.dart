import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static const String projectId = 'priyanshu-f7933';
  static bool _isFirebaseInitialized = false;

  static bool get isInitialized => _isFirebaseInitialized;

  static Future<void> initialize() async {
    try {
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyC-LXGocdO_PHkQYEWanwtRfBVyp02Z-a4',
            appId: '1:691595668326:web:a07772f7314876ced636a7',
            messagingSenderId: '691595668326',
            projectId: 'priyanshu-f7933',
            storageBucket: 'priyanshu-f7933.firebasestorage.app',
            authDomain: 'priyanshu-f7933.firebaseapp.com',
          ),
        );
        _isFirebaseInitialized = true;
        debugPrint('Firebase initialized successfully for project: $projectId');
      }
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      _isFirebaseInitialized = false;
    }
  }
}