import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_service.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Member',
      photoUrl: map['photoUrl'],
    );
  }
}

/// Sole Authentication Provider: Real Google Sign-In with Firebase Auth.
/// All legacy email/password, mock fallback users, and mock auth credentials have been removed.
class AuthService extends ChangeNotifier {
  AuthUser? _currentUser;
  bool _isInitialized = false;
  bool _isLoading = true;

  AuthUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  AuthService() {
    _checkInitialAuth();
  }

  void _checkInitialAuth() {
    _isLoading = true;

    if (FirebaseService.isInitialized) {
      try {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          _isLoading = false;
          _isInitialized = true;
          
          if (user != null) {
            _currentUser = AuthUser(
              uid: user.uid,
              email: user.email ?? '',
              displayName: user.displayName ?? (user.email?.split('@').first ?? 'Member'),
              photoUrl: user.photoURL,
            );
            debugPrint('⚡ [AuthService] Real Firebase user authenticated: ${_currentUser?.email} (${_currentUser?.uid})');
          } else {
            _currentUser = null;
            debugPrint('⚡ [AuthService] No active Firebase user session');
          }
          notifyListeners();
        });
      } catch (e) {
        debugPrint('⚡ [AuthService] Auth state listener error: $e');
        _isLoading = false;
        _isInitialized = true;
        _currentUser = null;
        notifyListeners();
      }
    } else {
      _isLoading = false;
      _isInitialized = true;
      _currentUser = null;
      notifyListeners();
      debugPrint('⚡ [AuthService] Firebase not initialized');
    }
  }

  /// Sole sign-in pathway: Google Sign-In with Firebase Auth.
  /// Works across Flutter Web (signInWithPopup) and Android/iOS (GoogleSignIn).
  Future<AuthUser> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    if (!FirebaseService.isInitialized) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Firebase is not initialized. Please verify your Firebase connection.');
    }

    try {
      UserCredential userCredential;
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email'],
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          throw Exception('Google Sign-In was cancelled.');
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        final authUser = AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? (user.email?.split('@').first ?? 'Member'),
          photoUrl: user.photoURL,
        );
        _currentUser = authUser;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
        return authUser;
      } else {
        _isLoading = false;
        notifyListeners();
        throw Exception('Google Sign-In failed: No user profile returned.');
      }
    } catch (e) {
      debugPrint('⚡ [AuthService] Google Sign-In exception: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    if (FirebaseService.isInitialized) {
      try {
        debugPrint('⚡ [AuthService] Signing out from Firebase...');
        if (!kIsWeb) {
          try {
            await GoogleSignIn().signOut();
          } catch (_) {}
        }
        await FirebaseAuth.instance.signOut();
        debugPrint('⚡ [AuthService] Successfully signed out.');
      } catch (e) {
        debugPrint('⚡ [AuthService] Sign out error: $e');
      }
    }
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkCurrentUser() async {
    if (!FirebaseService.isInitialized) {
      return false;
    }
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUser = AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'Member',
          photoUrl: user.photoURL,
        );
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('⚡ [AuthService] Error checking current user: $e');
      return false;
    }
  }
}