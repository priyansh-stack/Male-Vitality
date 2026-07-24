import 'package:equatable/equatable.dart';

class HealthSyncState extends Equatable {
  final bool isAppleHealthAuthorized;
  final bool isGoogleFitAuthorized;
  final bool isNotificationsEnabled;
  final DateTime? appleHealthLastSync;
  final DateTime? googleFitLastSync;
  final bool isLoading;

  const HealthSyncState({
    this.isAppleHealthAuthorized = false,
    this.isGoogleFitAuthorized = false,
    this.isNotificationsEnabled = true,
    this.appleHealthLastSync,
    this.googleFitLastSync,
    this.isLoading = false,
  });

  HealthSyncState copyWith({
    bool? isAppleHealthAuthorized,
    bool? isGoogleFitAuthorized,
    bool? isNotificationsEnabled,
    DateTime? appleHealthLastSync,
    DateTime? googleFitLastSync,
    bool? isLoading,
  }) {
    return HealthSyncState(
      isAppleHealthAuthorized: isAppleHealthAuthorized ?? this.isAppleHealthAuthorized,
      isGoogleFitAuthorized: isGoogleFitAuthorized ?? this.isGoogleFitAuthorized,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      appleHealthLastSync: appleHealthLastSync ?? this.appleHealthLastSync,
      googleFitLastSync: googleFitLastSync ?? this.googleFitLastSync,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        isAppleHealthAuthorized,
        isGoogleFitAuthorized,
        isNotificationsEnabled,
        appleHealthLastSync,
        googleFitLastSync,
        isLoading,
      ];
}
