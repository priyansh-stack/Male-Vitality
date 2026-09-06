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
        apiKey: "AIzaSyBAj-C5oNg9L2tfNoOTdpKMHrATqD0o3tQ",
        authDomain: "male-vitality-427d9.firebaseapp.com",
        projectId: "male-vitality-427d9",
        storageBucket: "male-vitality-427d9.firebasestorage.app",
        messagingSenderId: "932554051961",
        appId: "1:932554051961:web:8727cb85ada8c0ed739fa8",
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
      debugPrint('Default Firebase.initializeApp() error: $e. Falling back to explicit options.');
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: "AIzaSyCtld6v3Ti2G3-FYV_mQKRsU66_Vl9c694",
            appId: "1:932554051961:android:6f69c0b6c7f9d645739fa8",
            messagingSenderId: "932554051961",
            projectId: "male-vitality-427d9",
            storageBucket: "male-vitality-427d9.firebasestorage.app",
          ),
        );
        debugPrint(' Firebase initialized using fallback options');
      } catch (fallbackError) {
        throw Exception(
          'Firebase initialization failed on mobile.\n'
          'Error: $e\nFallback Error: $fallbackError'
        );
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