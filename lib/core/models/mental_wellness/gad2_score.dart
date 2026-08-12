import 'package:equatable/equatable.dart';

class GAD2Score extends Equatable {
  final int feelingNervous; // 0-3: Not at all to Nearly every day
  final int unableToControlWorry; // 0-3: Not at all to Nearly every day
  final int totalScore;

  const GAD2Score({
    required this.feelingNervous,
    required this.unableToControlWorry,
  }) : totalScore = feelingNervous + unableToControlWorry;

  // Create from individual answers
  factory GAD2Score.fromAnswers({
    required int feelingNervous,
    required int unableToControlWorry,
  }) {
    return GAD2Score(
      feelingNervous: feelingNervous.clamp(0, 3),
      unableToControlWorry: unableToControlWorry.clamp(0, 3),
    );
  }

  // Parse from JSON
  factory GAD2Score.fromJson(Map<String, dynamic> json) {
    return GAD2Score(
      feelingNervous: json['feelingNervous'] ?? 0,
      unableToControlWorry: json['unableToControlWorry'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feelingNervous': feelingNervous,
      'unableToControlWorry': unableToControlWorry,
      'totalScore': totalScore,
    };
  }

  // Interpretation methods
  bool get isPositive => totalScore >= 3;
  bool get isModerate => totalScore == 2;
  bool get isLow => totalScore <= 1;

  String get interpretation {
    if (totalScore <= 1) return 'Low anxiety risk';
    if (totalScore == 2) return 'Moderate anxiety risk - consider follow-up';
    return 'High anxiety risk - consider professional consultation';
  }

  String get severityLabel {
    if (totalScore <= 1) return 'Minimal';
    if (totalScore == 2) return 'Mild';
    if (totalScore <= 4) return 'Moderate';
    return 'Severe';
  }

  @override
  List<Object?> get props => [feelingNervous, unableToControlWorry, totalScore];
}