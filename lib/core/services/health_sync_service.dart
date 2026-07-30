import 'package:flutter/foundation.dart';
import '../models/health_import.dart';
import 'firestore_service.dart';

class HealthSyncService extends ChangeNotifier {
  final FirestoreService _firestoreService;

  bool _appleHealthAuthorized = false;
  bool _googleFitAuthorized = false;
  bool _notificationsEnabled = true;

  DateTime? _appleHealthLastSync;
  DateTime? _googleFitLastSync;

  final List<String> _appleHealthTypes = ['Steps', 'Heart Rate', 'Sleep Analysis', 'Active Energy'];
  final List<String> _googleFitTypes = ['Steps', 'Heart Rate', 'Sleep Duration', 'Blood Oxygen'];

  bool get isAppleHealthAuthorized => _appleHealthAuthorized;
  bool get isGoogleFitAuthorized => _googleFitAuthorized;
  bool get isNotificationsEnabled => _notificationsEnabled;

  DateTime? get appleHealthLastSync => _appleHealthLastSync;
  DateTime? get googleFitLastSync => _googleFitLastSync;

  List<String> get appleHealthTypes => List.unmodifiable(_appleHealthTypes);
  List<String> get googleFitTypes => List.unmodifiable(_googleFitTypes);

  HealthSyncService(this._firestoreService);

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

    notifyListeners();
    return _googleFitAuthorized;
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
  }
}
