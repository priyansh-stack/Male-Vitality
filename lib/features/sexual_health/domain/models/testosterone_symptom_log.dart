class TestosteroneSymptomLog {
  final String id;
  final String userId;
  final DateTime timestamp;
  final bool hasLowLibido; // ADAM Question 1
  final bool hasLackEnergy; // ADAM Question 2
  final bool hasStrengthLoss; // ADAM Question 3
  final bool hasLostHeight; // ADAM Question 4
  final bool hasDecreasedEnjoyment; // ADAM Question 5
  final bool isSadOrGrumpy; // ADAM Question 6
  final bool areErectionsLessStrong; // ADAM Question 7
  final bool hasDeterioratedWorkAbility; // ADAM Question 8
  final bool fallsAsleepAfterDinner; // ADAM Question 9
  final bool hasRecentWorkDeterioration; // ADAM Question 10

  const TestosteroneSymptomLog({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.hasLowLibido,
    required this.hasLackEnergy,
    required this.hasStrengthLoss,
    required this.hasLostHeight,
    required this.hasDecreasedEnjoyment,
    required this.isSadOrGrumpy,
    required this.areErectionsLessStrong,
    required this.hasDeterioratedWorkAbility,
    required this.fallsAsleepAfterDinner,
    required this.hasRecentWorkDeterioration,
  });

  /// Clinical ADAM Questionnaire interpretation:
  /// Positive for androgen deficiency if Q1 or Q7 is YES, OR if any 3 other questions are YES.
  bool get isAdamPositive {
    if (hasLowLibido || areErectionsLessStrong) return true;
    int otherCount = 0;
    if (hasLackEnergy) otherCount++;
    if (hasStrengthLoss) otherCount++;
    if (hasLostHeight) otherCount++;
    if (hasDecreasedEnjoyment) otherCount++;
    if (isSadOrGrumpy) otherCount++;
    if (hasDeterioratedWorkAbility) otherCount++;
    if (fallsAsleepAfterDinner) otherCount++;
    if (hasRecentWorkDeterioration) otherCount++;
    return otherCount >= 3;
  }

  int get totalSymptomCount {
    int count = 0;
    if (hasLowLibido) count++;
    if (hasLackEnergy) count++;
    if (hasStrengthLoss) count++;
    if (hasLostHeight) count++;
    if (hasDecreasedEnjoyment) count++;
    if (isSadOrGrumpy) count++;
    if (areErectionsLessStrong) count++;
    if (hasDeterioratedWorkAbility) count++;
    if (fallsAsleepAfterDinner) count++;
    if (hasRecentWorkDeterioration) count++;
    return count;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'userId': userId,
        'timestamp': timestamp.toIso8601String(),
        'hasLowLibido': hasLowLibido,
        'hasLackEnergy': hasLackEnergy,
        'hasStrengthLoss': hasStrengthLoss,
        'hasLostHeight': hasLostHeight,
        'hasDecreasedEnjoyment': hasDecreasedEnjoyment,
        'isSadOrGrumpy': isSadOrGrumpy,
        'areErectionsLessStrong': areErectionsLessStrong,
        'hasDeterioratedWorkAbility': hasDeterioratedWorkAbility,
        'fallsAsleepAfterDinner': fallsAsleepAfterDinner,
        'hasRecentWorkDeterioration': hasRecentWorkDeterioration,
      };

  factory TestosteroneSymptomLog.fromMap(Map<String, dynamic> map, String id) {
    return TestosteroneSymptomLog(
      id: id,
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      hasLowLibido: map['hasLowLibido'] ?? false,
      hasLackEnergy: map['hasLackEnergy'] ?? false,
      hasStrengthLoss: map['hasStrengthLoss'] ?? false,
      hasLostHeight: map['hasLostHeight'] ?? false,
      hasDecreasedEnjoyment: map['hasDecreasedEnjoyment'] ?? false,
      isSadOrGrumpy: map['isSadOrGrumpy'] ?? false,
      areErectionsLessStrong: map['areErectionsLessStrong'] ?? false,
      hasDeterioratedWorkAbility: map['hasDeterioratedWorkAbility'] ?? false,
      fallsAsleepAfterDinner: map['fallsAsleepAfterDinner'] ?? false,
      hasRecentWorkDeterioration: map['hasRecentWorkDeterioration'] ?? false,
    );
  }
}
