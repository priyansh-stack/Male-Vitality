import 'package:equatable/equatable.dart';
import 'package:life_stage_health_app/core/models/health_enums.dart';

class HealthScore extends Equatable {
  final int score;
  final DateTime calculatedAt;
  final Map<HealthCategory,int> categoryScores;
  final List<String> recommendations;
  final String? userId;
  final Map<HealthCategory,String> categoryDescriptions;

  const HealthScore({
    required this.score,
    required this.calculatedAt,
    required this.categoryScores,
    required this.recommendations,
    this.userId,
    this.categoryDescriptions = const {},
  });
    // category scores with validation
  int getCategoryScore(HealthCategory category){
    return categoryScores[category] ?? 0;
  }

  bool get isHealthy => score >70;

  ScoreStatus get status {
    if(score >= 80) return ScoreStatus.excellent;
    if(score >=70) return ScoreStatus.good;
    if(score >= 50) return ScoreStatus.fair;
    if(score >= 30) return ScoreStatus.poor;

    return ScoreStatus.critical;
  }

  Map<String,dynamic> toMap(){
    return {
      'score':score,
      'calculatedAt': calculatedAt.toIso8601String(),
      'categoryScores': categoryScores.map(
        (key,value) => MapEntry(key.toString(), value)
      ),
      'recommendations': recommendations,
      'userId':userId,
    };
  }

// factory method for retriving data
  factory HealthScore.fromJson(Map<String, dynamic> json) {
    final categoryScores = (json['categoryScores'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        HealthCategory.values.firstWhere((e) => e.toString() == key),
        value as int,
      ),
    );
    return HealthScore(
      score: json['score'],
      calculatedAt: DateTime.parse(json['calculatedAt']),
      categoryScores: categoryScores,
      recommendations: List<String>.from(json['recommendations']),
      userId: json['userId'],
    );
  }

  
  
  @override
  List<Object?> get props => [score, calculatedAt, categoryScores, recommendations];

}