import 'package:equatable/equatable.dart';

class PHQ2Score extends Equatable {
  final int littleInterest; // 0-3: Not at all to Nearly every day
  final int feelingDown; // 0-3: Not at all to Nearly every day
  final int totalScore;

  const PHQ2Score({
    required this.littleInterest,
    required this.feelingDown,
  }) : totalScore = littleInterest + feelingDown;

  // Create from individual answers
  factory PHQ2Score.fromAnswers({
    required int littleInterest,
    required int feelingDown,
  }) {
    return PHQ2Score(
      littleInterest: littleInterest.clamp(0, 3),
      feelingDown: feelingDown.clamp(0, 3),
    );
  }

  // Parse from JSON
  factory PHQ2Score.fromJson(Map<String, dynamic> json) {
    return PHQ2Score(
      littleInterest: json['littleInterest'] ?? 0,
      feelingDown: json['feelingDown'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'littleInterest': littleInterest,
      'feelingDown': feelingDown,
      'totalScore': totalScore,
    };
  }

  // Interpretation methods
  bool get isPositive => totalScore >= 3;
  bool get isModerate => totalScore == 2;
  bool get isLow => totalScore <= 1;

  String get interpretation {
    if (totalScore <= 1) return 'Low depression risk';
    if (totalScore == 2) return 'Moderate depression risk - consider follow-up';
    return 'High depression risk - consider professional consultation';
  }

  String get severityLabel {
    if (totalScore <= 1) return 'Minimal';
    if (totalScore == 2) return 'Mild';
    if (totalScore <= 4) return 'Moderate';
    return 'Severe';
  }

  @override
  List<Object?> get props => [littleInterest, feelingDown, totalScore];
}