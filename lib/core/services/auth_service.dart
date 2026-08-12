import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
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
      displayName: map['displayName'] ?? 'User',
      photoUrl: map['photoUrl'],
    );
  }
}

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

  //  Helper method to hash password using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
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
              displayName: user.displayName ?? 'Health User',
              photoUrl: user.photoURL,
            );
            debugPrint(' Auth restored for user: ${_currentUser?.uid}');
          } else {
            _currentUser = null;
            debugPrint(' No user session found');
          }
          notifyListeners();
        });
      } catch (e) {
        debugPrint('Auth state listener error: $e');
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
      debugPrint(' Firebase not initialized - user must login');
    }
  }

  //  FIX: Hash password before sending to Firebase
  Future<AuthUser> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (FirebaseService.isInitialized) {
      try {
        //  Hash the password before sending to Firebase
        final hashedPassword = _hashPassword(password);
        
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: hashedPassword, // Send hashed password
        );
        await credential.user?.updateDisplayName(displayName);
        final user = AuthUser(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          photoUrl: credential.user?.photoURL,
        );
        _currentUser = user;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
        return user;
      } catch (e) {
        debugPrint('Firebase Auth SignUp Error: $e');
        rethrow;
      }
    } else {
      // Development fallback (only for development)
      if (kDebugMode) {
        final user = AuthUser(
          uid: 'uid_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          displayName: displayName,
        );
        _currentUser = user;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
        return user;
      }
      throw Exception('Firebase not initialized');
    }
  }

  //  FIX: Also hash password for sign in
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (FirebaseService.isInitialized) {
      try {
        //  Hash the password before sending to Firebase
        final hashedPassword = _hashPassword(password);
        
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: hashedPassword, // Send hashed password
        );
        final user = AuthUser(
          uid: credential.user!.uid,
          email: email,
          displayName: credential.user!.displayName ?? email.split('@').first,
          photoUrl: credential.user?.photoURL,
        );
        _currentUser = user;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
        return user;
      } catch (e) {
        debugPrint('Firebase Auth SignIn Error: $e');
        rethrow;
      }
    } else {
      // Development fallback (only for development)
      if (kDebugMode) {
        final name = email.split('@').first;
        final displayName = name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'Health Explorer';
        final user = AuthUser(
          uid: 'uid_${email.hashCode.abs()}',
          email: email,
          displayName: displayName,
        );
        _currentUser = user;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
        return user;
      }
      throw Exception('Firebase not initialized');
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
          _isLoading = false;
          _isInitialized = true;
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
      if (kDebugMode) {
        final user = AuthUser(
          uid: 'google_uid_${DateTime.now().millisecondsSinceEpoch}',
          email: 'demo.user@gmail.com',
          displayName: 'Demo User',
        );
        _currentUser = user;
        _isLoading = false;
        _isInitialized = true;
        notifyListeners();
        return user;
      }
      throw Exception('Firebase not initialized');
    }
  }

  Future<void> signOut() async {
    if (FirebaseService.isInitialized) {
      try {
        debugPrint(' Signing out from Firebase...');
        await FirebaseAuth.instance.signOut();
        debugPrint(' Signed out from Firebase');
      } catch (e) {
        debugPrint(' Sign out error: $e');
      }
    }
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
    debugPrint(' Local auth state cleared');
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
          displayName: user.displayName ?? 'Health User',
          photoUrl: user.photoURL,
        );
        _isInitialized = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking current user: $e');
      return false;
    }
  }
}