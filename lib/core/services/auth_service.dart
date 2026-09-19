import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'firebase_service.dart';

class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? dateOfBirth;
  final int? age;
  final String? gender;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.dateOfBirth,
    this.age,
    this.gender,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'age': age,
      'gender': gender,
    };
  }

  factory AuthUser.fromMap(Map<String, dynamic> map) {
    return AuthUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Member',
      photoUrl: map['photoUrl'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.tryParse(map['dateOfBirth']) : null,
      age: map['age'],
      gender: map['gender'],
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

  /// Extracts a clean, professional display name from Google Account profile or email ID.
  static String extractCleanName(String? displayName, String? email) {
    if (displayName != null && displayName.trim().isNotEmpty && displayName.trim() != 'Member') {
      return displayName.trim();
    }
    if (email == null || email.trim().isEmpty) return 'Member';
    final handle = email.split('@').first.trim();
    final cleanHandle = handle.replaceAll(RegExp(r'[0-9]'), '').replaceAll(RegExp(r'[._\-]'), ' ').trim();
    if (cleanHandle.isNotEmpty) {
      return cleanHandle.split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s[0].toUpperCase() + (s.length > 1 ? s.substring(1).toLowerCase() : ''))
          .join(' ');
    }
    return handle;
  }

  /// Default baseline date of birth (e.g., 28-30 year old adult calibration)
  /// Note: Never extract or guess birth years from email username digits.
  static DateTime get defaultBaselineDob => DateTime(1996, 1, 1);

  /// Queries Google People API v1 using Google OAuth token to fetch official Birthday and Gender
  static Future<Map<String, dynamic>?> _fetchGooglePeopleProfile(Map<String, String> authHeaders) async {
    try {
      final uri = Uri.parse('https://people.googleapis.com/v1/people/me?personFields=birthdays,genders,names');
      final res = await http.get(uri, headers: authHeaders);
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        debugPrint('⚠️ [AuthService] Google People API returned status: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ [AuthService] Google People API error: $e');
    }
    return null;
  }

  /// Persists user registration profile directly to Cloud Firestore [users/{uid}]
  Future<void> _syncUserToFirestore(
    User user, 
    String cleanName, {
    DateTime? googleDob,
    String? googleGender,
  }) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final existingDoc = await userRef.get();
      
      DateTime? finalDob = googleDob;
      int? finalAge;
      String finalGender = googleGender ?? 'Male';

      if (existingDoc.exists && existingDoc.data() != null) {
        final data = existingDoc.data()!;
        if (googleDob == null && data['dateOfBirth'] != null) {
          try {
            finalDob = DateTime.parse(data['dateOfBirth'] as String);
            finalAge = (data['age'] as num?)?.toInt() ?? (DateTime.now().year - finalDob.year);
          } catch (_) {}
        }
        if (googleGender == null && data['gender'] != null) {
          finalGender = data['gender'] as String;
        }
      }

      finalDob ??= defaultBaselineDob;
      finalAge ??= DateTime.now().year - finalDob.year;

      await userRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': cleanName,
        'fullName': cleanName,
        'photoUrl': user.photoURL,
        'dateOfBirth': finalDob.toIso8601String(),
        'age': finalAge,
        'gender': finalGender,
        'source': googleDob != null ? 'google_people_api' : 'profile_verified',
        'lastLogin': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('⚡ [AuthService] User registration synced to Cloud Firestore [users/${user.uid}], Age: $finalAge (Born ${finalDob.year}, Gender: $finalGender)');
    } catch (e) {
      debugPrint('⚡ [AuthService] Error syncing user to Cloud Firestore: $e');
    }
  }

  void _checkInitialAuth() {
    _isLoading = true;

    if (FirebaseService.isInitialized) {
      try {
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
          _isLoading = false;
          _isInitialized = true;
          
          if (user != null) {
            final cleanName = extractCleanName(user.displayName, user.email);
            final defaultDob = defaultBaselineDob;
            final defaultAge = DateTime.now().year - defaultDob.year;

            _currentUser = AuthUser(
              uid: user.uid,
              email: user.email ?? '',
              displayName: cleanName,
              photoUrl: user.photoURL,
              dateOfBirth: defaultDob,
              age: defaultAge,
              gender: 'Male',
            );
            _syncUserToFirestore(user, cleanName);
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
      DateTime? googleDob;
      String? googleGender;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('https://www.googleapis.com/auth/user.birthday.read');
        googleProvider.addScope('https://www.googleapis.com/auth/user.gender.read');
        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          clientId: '589835266478-cg9es30vjgir6gbgif14k6dr2u95hbft.apps.googleusercontent.com',
          serverClientId: '589835266478-cg9es30vjgir6gbgif14k6dr2u95hbft.apps.googleusercontent.com',
          scopes: [
            'openid',
            'email',
            'profile',
            'https://www.googleapis.com/auth/userinfo.profile',
            'https://www.googleapis.com/auth/user.birthday.read',
            'https://www.googleapis.com/auth/user.gender.read',
          ],
        );
        try {
          await googleSignIn.signOut();
        } catch (_) {}
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          throw Exception('Google Sign-In was cancelled.');
        }

        // Query official Google Account profile for Birthday & Gender via People API
        try {
          final authHeaders = await googleUser.authHeaders;
          final peopleData = await _fetchGooglePeopleProfile(authHeaders);
          if (peopleData != null) {
            // Extract birthday
            final birthdays = peopleData['birthdays'] as List<dynamic>?;
            if (birthdays != null && birthdays.isNotEmpty) {
              final dateMap = birthdays[0]['date'] as Map<String, dynamic>?;
              if (dateMap != null && dateMap['year'] != null) {
                final year = dateMap['year'] as int;
                final month = (dateMap['month'] as int?) ?? 1;
                final day = (dateMap['day'] as int?) ?? 1;
                googleDob = DateTime(year, month, day);
                debugPrint('⚡ [AuthService] Official Google Account Birthday retrieved: $googleDob');
              }
            }
            // Extract gender
            final genders = peopleData['genders'] as List<dynamic>?;
            if (genders != null && genders.isNotEmpty) {
              final val = genders[0]['value'] as String?;
              if (val != null && val.isNotEmpty) {
                googleGender = val[0].toUpperCase() + val.substring(1).toLowerCase();
                debugPrint('⚡ [AuthService] Official Google Account Gender retrieved: $googleGender');
              }
            }
          }
        } catch (e) {
          debugPrint('⚠️ [AuthService] People API retrieval exception: $e');
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        debugPrint('🔑 [AuthService] idToken present: ${googleAuth.idToken != null}');
        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.idToken != null ? null : googleAuth.accessToken,
        );
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;
      if (user != null) {
        final cleanName = extractCleanName(user.displayName, user.email);
        final resolvedDob = googleDob ?? defaultBaselineDob;
        final resolvedAge = DateTime.now().year - resolvedDob.year;
        final resolvedGender = googleGender ?? 'Male';

        final authUser = AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: cleanName,
          photoUrl: user.photoURL,
          dateOfBirth: resolvedDob,
          age: resolvedAge,
          gender: resolvedGender,
        );
        _currentUser = authUser;
        await _syncUserToFirestore(
          user, 
          cleanName,
          googleDob: googleDob,
          googleGender: googleGender,
        );
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
        final cleanName = extractCleanName(user.displayName, user.email);
        _currentUser = AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: cleanName,
          photoUrl: user.photoURL,
        );
        _syncUserToFirestore(user, cleanName);
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