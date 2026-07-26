import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/core/models/bloodpressure.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';

class HealthMetric extends Equatable {
  final String id;
  final String userId;
  final MetricType type;
  final dynamic value;
  final String unit;
  final DateTime timeStamp;
  final MetricSource source;
  final Map<String,dynamic> metaData;
  final bool isAbnormal;
  final String? note;

  const HealthMetric({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timeStamp,
    required this.source,
    this.metaData = const {},
    this.isAbnormal = false,
    this.note,
  });

  // Factory for blood pressure
  factory HealthMetric.bloodPressure({
    required String userId,
    required int systolic,
    required int diastolic,
    int? pulse,
    required DateTime timestamp,
    MetricSource source = MetricSource.manual,
    String? note,
  }) {
    final bp = Bloodpressure(
      systolic: systolic,
      diastolic: diastolic,
      pulse: pulse,
      mesuredAt: timestamp,
    );
    return HealthMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: MetricType.bloodPressure,
      value: bp,
      unit: 'mmHg',
      timeStamp: timestamp,
      source: source,
      note: note,
      isAbnormal: bp.Category != BloodPresureCategory.normal,
      metaData: {
        'systolic': systolic,
        'diastolic': diastolic,
        'pulse': pulse,
      },
    );
  }

  // Factory for weight
  factory HealthMetric.weight({
    required String userId,
    required double weight,
    required DateTime timestamp,
    MetricSource source = MetricSource.manual,
    String? note,
  }) {
    return HealthMetric(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      type: MetricType.weight,
      value: weight,
      unit: 'kg',
      timeStamp: timestamp,
      source: source,
      note: note,
      metaData: {'weight': weight},
    );
  }


  // Map method for firebase

  Map<String,dynamic> toMap(){
    return {
      'id':id,
      'userId':userId,
      'type':type,
      'value':value,
      'unit':unit,
      'timestamp':timeStamp.toIso8601String(),
      'source':source.toString(),
      'metadata':metaData,
      'isAbnormal':isAbnormal,
      'note':note,
    };

  }

  // factory method for retriving data from firebase
  factory HealthMetric.fromMap(Map<String,dynamic> map){
    final type = MetricType.values.firstWhere(
      (e) => e.toString() == map['type'],
    );
    dynamic value = map['value'];

    if(type == MetricType.bloodPressure){
      value = Bloodpressure.fromMap(map['value']);
    }

    return HealthMetric(id: map['id'],
       userId: map['userId'], type: type, value:value, unit: map['unit'],
       timeStamp: DateTime.parse(map['timestamp']),
       source: MetricSource.values.firstWhere(
        (e) => e.toString() == map['source'],
       ),
       metaData: map['metaData'] ?? {},
       isAbnormal: map['isAbnormal']?? false,
       note: map['note'],
      );
  }

  

  @override
  List<Object?> get props => [id,userId,type,value,timeStamp,source];

}