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
      debugPrint(' Firebase initialization error: $e');
      rethrow;
    }
  }

  static Future<void> _initializeWeb() async {
    debugPrint(' Initializing Firebase for Web...');
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
  }

  static Future<void> _initializeMobile() async {
    debugPrint('Initializing Firebase for Mobile...');
    
    try {
      // Automatically reads google-services.json (Android) 
      // or GoogleService-Info.plist (iOS)
      await Firebase.initializeApp();
      debugPrint(' Firebase initialized using native config files');
      
      // Verify config was loaded
      final app = Firebase.app();
      debugPrint('   Project ID: ${app.options.projectId}');
      debugPrint('   App ID: ${app.options.appId}');
      
    } catch (e) {
      throw Exception(
        'Firebase initialization failed on mobile.\n'
        'Please ensure:\n'
        '• Android: android/app/google-services.json exists\n'
        '• iOS: ios/Runner/GoogleService-Info.plist exists\n'
        '• Both files are properly configured\n'
        'Error: $e'
      );
    }
  }

  static String get platform {
    if (kIsWeb) return 'Web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS';
    return 'Unknown';
  }
}