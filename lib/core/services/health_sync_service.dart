import 'package:flutter/foundation.dart';
import '../models/health_import.dart';
import 'firebase_service.dart';
import 'firestore_service.dart';

class HealthSyncService extends ChangeNotifier {
  final FirestoreService _firestoreService;

  bool _appleHealthAuthorized = false;
  bool _googleFitAuthorized = false;
  bool _notificationsEnabled = true;
  bool _isSyncing = false;

  DateTime? _appleHealthLastSync;
  DateTime? _googleFitLastSync;

  final List<String> _appleHealthTypes = [
    'Steps',
    'Heart Rate',
    'Sleep Analysis',
    'Active Energy',
  ];
  final List<String> _googleFitTypes = [
    'Steps',
    'Heart Rate',
    'Sleep Duration',
    'Blood Oxygen',
    'Active Calories',
  ];

  bool get isAppleHealthAuthorized => _appleHealthAuthorized;
  bool get isGoogleFitAuthorized => _googleFitAuthorized;
  bool get isNotificationsEnabled => _notificationsEnabled;
  bool get isSyncing => _isSyncing;

  DateTime? get appleHealthLastSync => _appleHealthLastSync;
  DateTime? get googleFitLastSync => _googleFitLastSync;

  List<String> get appleHealthTypes => List.unmodifiable(_appleHealthTypes);
  List<String> get googleFitTypes => List.unmodifiable(_googleFitTypes);

  HealthSyncService(this._firestoreService);

  /// Checks and refreshes daily health telemetry from Cloud Firestore
  /// produced by the fit_bit connector application.
  Future<void> syncFitbitAndGoogleHealth(String uid) async {
    if (!FirebaseService.isInitialized || uid.isEmpty) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final daily = await _firestoreService.getTodayHealthDaily(uid);
      if (daily != null) {
        _googleFitLastSync = daily.lastSyncedAt ?? DateTime.now();
        debugPrint(
          '⚡ [HealthSyncService] Real Fitbit/Google Health data retrieved for user: $uid, Steps: ${daily.steps}',
        );
      } else {
        debugPrint(
          'ℹ️ [HealthSyncService] No healthDaily record for today found for user: $uid',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [HealthSyncService] Error verifying health telemetry: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> requestAppleHealthPermission(String uid) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _appleHealthAuthorized = !_appleHealthAuthorized;
    _appleHealthLastSync = _appleHealthAuthorized ? DateTime.now() : null;

    final importSource = HealthImportSource(
      isConnected: _appleHealthAuthorized,
      lastSync: _appleHealthLastSync,
      dataTypes: _appleHealthTypes,
    );

    await _firestoreService.saveHealthImport(
      uid: uid,
      provider: 'apple_health',
      importSource: importSource,
    );

    if (_appleHealthAuthorized && uid.isNotEmpty) {
      await syncFitbitAndGoogleHealth(uid);
    }

    notifyListeners();
    return _appleHealthAuthorized;
  }

  Future<bool> requestGoogleFitPermission(String uid) async {
    await Future.delayed(const Duration(milliseconds: 600));
    _googleFitAuthorized = !_googleFitAuthorized;
    _googleFitLastSync = _googleFitAuthorized ? DateTime.now() : null;

    final importSource = HealthImportSource(
      isConnected: _googleFitAuthorized,
      lastSync: _googleFitLastSync,
      dataTypes: _googleFitTypes,
    );

    await _firestoreService.saveHealthImport(
      uid: uid,
      provider: 'google_fit',
      importSource: importSource,
    );

    if (_googleFitAuthorized && uid.isNotEmpty) {
      await syncFitbitAndGoogleHealth(uid);
    }

    notifyListeners();
    return _googleFitAuthorized;
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
