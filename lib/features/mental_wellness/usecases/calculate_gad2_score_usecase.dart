class CalculateGAD2ScoreUseCase {
  int execute({
    required int feelingNervous,
    required int unableToStopWorrying,
  }) {
    // GAD-2 scores: 0=Not at all, 1=Several days, 2=More than half the days, 3=Nearly every day
    return feelingNervous + unableToStopWorrying;
  }

  bool isPositive(int score) {
    return score >= 3; // 3 or higher indicates possible anxiety disorder
  }

  String getInterpretation(int score) {
    if (score <= 1) return 'Low anxiety risk';
    if (score == 2) return 'Moderate anxiety risk';
    if (score >= 3) return 'High anxiety risk - consider screening';
    return 'Invalid score';
  }
}