
import 'package:equatable/equatable.dart';
import 'health_enums.dart';

class Bloodpressure extends Equatable {
  final int systolic;
  final int diastolic;
  final int? pulse;
  final DateTime? mesuredAt;

  const Bloodpressure({
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.mesuredAt,
  });

  bool get isValid => systolic > 0 && systolic < 300 && diastolic > 0 && diastolic < 200;

  BloodPresureCategory get Category {
    if (systolic < 120 && diastolic < 80) return BloodPresureCategory.normal;
    if (systolic < 130 && diastolic < 80) return BloodPresureCategory.elevated;
    if (systolic < 140 && diastolic < 90) return BloodPresureCategory.hypertensionStage1;
    if (systolic >= 140 && diastolic >= 90) return BloodPresureCategory.hypertensionStage2;
    return BloodPresureCategory.hypertensiveCrisis;
  }

  Map<String, dynamic> toMap() {
    return {
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'mesuredAt': mesuredAt?.toIso8601String(),
    };
  }

  factory Bloodpressure.fromMap(Map<String, dynamic> map) {
    return Bloodpressure(
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      pulse: map['pulse'],
      mesuredAt: DateTime.tryParse(map['mesuredAt'] ?? '') ?? DateTime.now(),
    );
  }

  String get formatted => '$systolic/$diastolic${pulse != null ? ' (${pulse}bpm)' : ''}';

  @override
  List<Object?> get props => [systolic, diastolic, pulse, mesuredAt];
}