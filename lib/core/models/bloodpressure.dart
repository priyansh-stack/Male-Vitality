
import 'package:life_stage_health_app/core/models/health_enums.dart';

class Bloodpressure{

  final int systolic; // Squeeze (heart squeezing/pumping)
  final int diastolic; // Rest (heart relaxing/filling)
  final int? pulse;
  final DateTime? mesuredAt;

  const Bloodpressure({
    required this.systolic,
    required this.diastolic,
     this.pulse,
     this.mesuredAt,
  });


  bool get isvalid => systolic>0 && systolic < 300 && diastolic >0 && diastolic <200;

  BloodPresureCategory get Category {
    if(systolic<120 && diastolic <80) return BloodPresureCategory.normal;
    if (systolic <130 && diastolic <80) return BloodPresureCategory.elevated;
    if(systolic <140 && diastolic <90) return BloodPresureCategory.hypertensionStage1;
    if(systolic >=140 && diastolic >= 90) return BloodPresureCategory.hypertensionStage2;
    return BloodPresureCategory.hypertensiveCrisis;
  }

  //converting to store in firebase

  Map<String,dynamic> toMap() { // using tomap instead of tojson - for better implementation and understanding 
    return {
      'systolic': systolic,
      'diastolic':diastolic,
      'pulse':pulse,
      'mesuredAt':mesuredAt?.toIso8601String(),
    };
  }

  //taking from firebase

  factory Bloodpressure.fromMap(Map<String,dynamic> map){
    return Bloodpressure(
      systolic: map['systolic'],
      diastolic: map['diastolic'],
      pulse: map['pulse'],
      mesuredAt: DateTime.tryParse(map['mesuredAt']??'') ?? DateTime.now(),

    );
  }

}