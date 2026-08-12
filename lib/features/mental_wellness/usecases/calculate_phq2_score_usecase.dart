class CalculatePHQ2ScoreUseCase {
  int execute({
    required int littleInterest,
    required int feelingDown,
  }) {
    // PHQ-2 scores: 0=Not at all, 1=Several days, 2=More than half the days, 3=Nearly every day
    return littleInterest + feelingDown;
  }

  bool isPositive(int score) {
    return score >= 3; // 3 or higher indicates possible depression
  }

  String getInterpretation(int score) {
    if (score <= 1) return 'Low depression risk';
    if (score == 2) return 'Moderate depression risk';
    if (score >= 3) return 'High depression risk - consider screening';
    return 'Invalid score';
  }
}