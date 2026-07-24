import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_service.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });
}

class AuthService extends ChangeNotifier {
  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _checkInitialAuth();
  }

  void _checkInitialAuth() {
    if (FirebaseService.isInitialized) {
      try {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          if (user != null) {
            _currentUser = AuthUser(
              uid: user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? 'Health User',
              photoUrl: user.photoURL,
            );
          } else {
            _currentUser = null;
          }
          notifyListeners();
        });
      } catch (e) {
        debugPrint('Auth state listener error: $e');
      }
    } else {
      debugPrint('Firebase not initialized, auth service running in local mode');
    }
  }

  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (FirebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await credential.user?.updateDisplayName(displayName);
        final user = AuthUser(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: credential.user?.photoURL,
        );
        _currentUser = user;
        notifyListeners();
        return user;
      } catch (e) {
        debugPrint('Firebase Auth SignUp Error: $e');
        rethrow; // Let the BLoC handle the error
      }
    } else {
      // Fallback for development without Firebase
      final user = AuthUser(
        uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        photoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=4F46E5&color=fff',
      );
      _currentUser = user;
      notifyListeners();
      return user;
    }
  }

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (FirebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = AuthUser(
          uid: credential.user!.uid,
          email: email,
          displayName: credential.user!.displayName ?? email.split('@').first,
          photoUrl: credential.user?.photoURL,
        );
        _currentUser = user;
        notifyListeners();
        return user;
      } catch (e) {
        debugPrint('Firebase Auth SignIn Error: $e');
        rethrow;
      }
    } else {
      // Fallback for development
      final name = email.split('@').first;
      final displayName = name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'Health Explorer';
      final user = AuthUser(
        uid: 'uid_${email.hashCode.abs()}',
        email: email,
        displayName: displayName,
        photoUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=0D9488&color=fff',
      );
      _currentUser = user;
      notifyListeners();
      return user;
    }
  }

  Future<AuthUser> signInWithGoogle() async {
    if (FirebaseService.isInitialized) {
      try {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        final userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          final user = AuthUser(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            displayName: userCredential.user!.displayName ?? '',
            photoUrl: userCredential.user!.photoURL,
          );
          _currentUser = user;
          notifyListeners();
          return user;
        } else {
          throw Exception('Google sign in failed');
        }
      } catch (e) {
        debugPrint('Google Sign In Exception: $e');
        rethrow;
      }
    } else {
      // Fallback for development
      final user = AuthUser(
        uid: 'google_uid_${DateTime.now().millisecondsSinceEpoch}',
        email: 'demo.user@gmail.com',
        displayName: 'Demo User',
        photoUrl: 'https://lh3.googleusercontent.com/a/default-user',
      );
      _currentUser = user;
      notifyListeners();
      return user;
    }
  }

  Future<void> signOut() async {
    if (FirebaseService.isInitialized) {
      await FirebaseAuth.instance.signOut();
    }
    _currentUser = null;
    notifyListeners();
  }
}