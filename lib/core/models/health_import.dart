class HealthImportSource {
  final bool isConnected;
  final DateTime? lastSync;
  final List<String> dataTypes;

  HealthImportSource({
    required this.isConnected,
    this.lastSync,
    required this.dataTypes,
  });

  Map<String, dynamic> toMap() {
    return {
      'isConnected': isConnected,
      'lastSync': lastSync?.toIso8601String(),
      'dataTypes': dataTypes,
    };
  }

  factory HealthImportSource.fromMap(Map<String, dynamic> map) {
    return HealthImportSource(
      isConnected: map['isConnected'] ?? false,
      lastSync: map['lastSync'] != null ? DateTime.tryParse(map['lastSync']) : null,
      dataTypes: List<String>.from(map['dataTypes'] ?? []),
    );
  }
}
