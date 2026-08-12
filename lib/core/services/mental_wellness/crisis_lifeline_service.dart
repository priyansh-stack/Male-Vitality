import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrisisLifelineService {
  final FirebaseFirestore firestore;

  CrisisLifelineService({required this.firestore});

  // Call 988 Lifeline
  Future<bool> callLifeline() async {
    const url = 'tel:988';
    try {
      if (await canLaunch(url)) {
        await launch(url);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Text 741741
  Future<bool> sendCrisisText({String message = 'HOME'}) async {
    final url = 'sms:741741?body=${Uri.encodeComponent(message)}';
    try {
      if (await canLaunch(url)) {
        await launch(url);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get local crisis resources
  Future<List<Map<String, dynamic>>> getLocalCrisisResources({
    required double latitude,
    required double longitude,
    double radius = 10, // miles
  }) async {
    // This would typically use a geolocation query
    // For now, return mock data
    return [
      {
        'id': 'local_1',
        'name': 'Community Crisis Center',
        'phone': '1-800-273-8255',
        'address': '123 Main St, City',
        'distance': 1.2,
        'is24Hours': true,
      },
      {
        'id': 'local_2',
        'name': 'Emergency Room - City Hospital',
        'phone': '911',
        'address': '456 Health Blvd, City',
        'distance': 2.8,
        'is24Hours': true,
      },
    ];
  }

  // Log crisis contact
  Future<void> logCrisisContact({
    required String userId,
    required String type, // 'call', 'text', 'in_person'
    String? serviceName,
    String? notes,
  }) async {
    await firestore.collection('users').doc(userId).collection('crisis_logs').add({
      'userId': userId,
      'type': type,
      'serviceName': serviceName,
      'notes': notes,
      'timestamp': FieldValue.serverTimestamp(),
      'date': DateTime.now().toIso8601String(),
    });
  }

  // Get crisis contact history
  Future<List<Map<String, dynamic>>> getCrisisHistory(String userId) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('crisis_logs')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
          'date': data['date'] ?? data['timestamp']?.toDate().toIso8601String(),
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Check if user has recent crisis contacts
  Future<bool> hasRecentCrisisContact(String userId, {Duration within = const Duration(days: 30)}) async {
    try {
      final cutoff = DateTime.now().subtract(within);
      final snapshot = await firestore
          .collection('users')
          .doc(userId)
          .collection('crisis_logs')
          .where('date', isGreaterThanOrEqualTo: cutoff.toIso8601String())
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get crisis resource recommendations based on severity
  List<Map<String, String>> getCrisisRecommendations(String severity) {
    final recommendations = <Map<String, String>>[];

    if (severity == 'critical') {
      recommendations.addAll([
        {
          'title': 'Call 988 Now',
          'description': 'Immediate crisis support available 24/7',
          'action': 'call_988',
        },
        {
          'title': 'Go to Emergency Room',
          'description': 'Nearest ER for immediate care',
          'action': 'find_er',
        },
        {
          'title': 'Text HOME to 741741',
          'description': 'Crisis Text Line - 24/7 support',
          'action': 'text_741741',
        },
      ]);
    } else if (severity == 'high') {
      recommendations.addAll([
        {
          'title': 'Call 988 Lifeline',
          'description': 'Free, confidential support',
          'action': 'call_988',
        },
        {
          'title': 'Contact Your Therapist',
          'description': 'Reach out to your mental health professional',
          'action': 'contact_therapist',
        },
      ]);
    } else if (severity == 'moderate') {
      recommendations.addAll([
        {
          'title': 'Crisis Text Line',
          'description': 'Text HOME to 741741',
          'action': 'text_741741',
        },
        {
          'title': 'Warm Line',
          'description': 'Non-crisis support for emotional distress',
          'action': 'warm_line',
        },
      ]);
    } else {
      recommendations.addAll([
        {
          'title': 'SAMHSA Helpline',
          'description': '1-800-662-4357',
          'action': 'call_samhsa',
        },
        {
          'title': 'Find a Therapist',
          'description': 'Search for mental health professionals',
          'action': 'find_therapist',
        },
      ]);
    }

    return recommendations;
  }
}