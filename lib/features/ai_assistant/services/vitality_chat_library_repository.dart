// lib/features/ai_assistant/services/vitality_chat_library_repository.dart
//
// Per-user isolated Chat Library repository backed by Cloud Firestore with SharedPreferences offline cache.
// Allows users to view past AI consultations, resume conversations, and delete sessions.

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'vitality_gemini_service.dart';

class VitalityChatSession {
  final String id;
  final String title;
  final String lastMessagePreview;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  const VitalityChatSession({
    required this.id,
    required this.title,
    required this.lastMessagePreview,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'lastMessagePreview': lastMessagePreview,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };

  factory VitalityChatSession.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List? ?? [];
    return VitalityChatSession(
      id: json['id'] as String? ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Health Consultation',
      lastMessagePreview: json['lastMessagePreview'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      messages: rawMessages
          .map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList(),
    );
  }

  VitalityChatSession copyWith({
    String? id,
    String? title,
    String? lastMessagePreview,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
  }) {
    return VitalityChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}

class VitalityChatLibraryRepository {
  final FirebaseFirestore? _customFirestore;
  final FirebaseAuth? _customAuth;

  VitalityChatLibraryRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _customFirestore = firestore,
        _customAuth = auth;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  String? get _currentUid => _auth?.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _sessionsCollection {
    final uid = _currentUid;
    final fs = _firestore;
    if (uid == null || uid.isEmpty || fs == null) return null;
    return fs.collection('users').doc(uid).collection('ai_chat_sessions');
  }

  /// Fetches all chat sessions for the current authenticated user.
  Future<List<VitalityChatSession>> fetchSessions() async {
    final collection = _sessionsCollection;
    if (collection != null) {
      try {
        final snap = await collection.orderBy('updatedAt', descending: true).get();
        final sessions = snap.docs.map((d) => VitalityChatSession.fromJson(d.data())).toList();
        await _cacheSessionsLocally(sessions);
        return sessions;
      } catch (e) {
        debugPrint('[VitalityChatLibrary] Firestore read failed, reading local cache: $e');
      }
    }
    return _readLocalCachedSessions();
  }

  /// Saves or updates a chat session in the user's private library.
  Future<void> saveSession(VitalityChatSession session) async {
    final collection = _sessionsCollection;
    if (collection != null) {
      try {
        await collection.doc(session.id).set(session.toJson(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[VitalityChatLibrary] Firestore save failed: $e');
      }
    }
    await _saveLocalSession(session);
  }

  /// Deletes a specific chat session from the user's private library.
  Future<void> deleteSession(String sessionId) async {
    final collection = _sessionsCollection;
    if (collection != null) {
      try {
        await collection.doc(sessionId).delete();
      } catch (e) {
        debugPrint('[VitalityChatLibrary] Firestore delete failed: $e');
      }
    }
    await _deleteLocalSession(sessionId);
  }

  /// Clears all sessions for current user.
  Future<void> clearAllSessions() async {
    final collection = _sessionsCollection;
    if (collection != null) {
      try {
        final snap = await collection.get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint('[VitalityChatLibrary] Firestore clear failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_ai_sessions_${_currentUid ?? 'default'}');
  }

  // --- Local Cache Helpers ---

  String get _localCacheKey => 'cached_ai_sessions_${_currentUid ?? 'default'}';

  Future<void> _cacheSessionsLocally(List<VitalityChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_localCacheKey, encoded);
    } catch (_) {}
  }

  Future<List<VitalityChatSession>> _readLocalCachedSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localCacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        return decoded
            .map((s) => VitalityChatSession.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _saveLocalSession(VitalityChatSession session) async {
    final sessions = await _readLocalCachedSessions();
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      sessions[idx] = session;
    } else {
      sessions.insert(0, session);
    }
    await _cacheSessionsLocally(sessions);
  }

  Future<void> _deleteLocalSession(String sessionId) async {
    final sessions = await _readLocalCachedSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await _cacheSessionsLocally(sessions);
  }
}
