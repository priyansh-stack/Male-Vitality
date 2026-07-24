import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/health_import.dart';
import 'firebase_service.dart';

class FirestoreService {
  // In-memory cache for local fallback
  static final Map<String, UserProfile> _profileStore = {};
  static final Map<String, Map<String, HealthImportSource>> _healthImportStore = {};

  Future<void> saveUserProfile(UserProfile profile) async {
    _profileStore[profile.uid] = profile;

    if (FirebaseService.isInitialized) {
      try {
        final userRef = FirebaseFirestore.instance.collection('users').doc(profile.uid);
        
        await userRef.set({
          'onboarding_completed': profile.onboardingCompleted,
          'last_active': FieldValue.serverTimestamp(),
          'email': profile.email,
          'displayName': profile.displayName,
        }, SetOptions(merge: true));

        await userRef.collection('profile').doc('main').set(profile.toMap());
        await userRef.collection('lifestyle').doc('factors').set(profile.lifestyle.toMap());

        if (profile.emergencyContact != null) {
          await userRef.collection('emergency').doc('contact').set(profile.emergencyContact!.toMap());
        }

        debugPrint('UserProfile synced to Firestore [users/${profile.uid}]');
      } catch (e) {
        debugPrint('Firestore write error (using local store): $e');
      }
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    if (FirebaseService.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('profile')
            .doc('main')
            .get();
        if (doc.exists && doc.data() != null) {
          return UserProfile.fromMap(doc.data()!);
        }
      } catch (e) {
        debugPrint('Firestore read error: $e');
      }
    }
    return _profileStore[uid];
  }

  Future<void> saveHealthImport({
    required String uid,
    required String provider, // 'apple_health' or 'google_fit'
    required HealthImportSource importSource,
  }) async {
    _healthImportStore.putIfAbsent(uid, () => {});
    _healthImportStore[uid]![provider] = importSource;

    if (FirebaseService.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('health_imports')
            .doc(uid)
            .set({
          provider: importSource.toMap(),
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('Health import saved to Firestore [health_imports/$uid/$provider]');
      } catch (e) {
        debugPrint('Firestore health import error: $e');
      }
    }
  }

  Map<String, HealthImportSource>? getHealthImports(String uid) {
    return _healthImportStore[uid];
  }
}
