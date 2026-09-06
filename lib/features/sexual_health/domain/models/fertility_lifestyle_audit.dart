class FertilityLifestyleAudit {
  final String userId;
  final DateTime updatedAt;
  final bool avoidsHeatExposure; // No hot tubs, saunas, laptop directly on lap
  final bool looseUnderwear; // Boxers instead of tight briefs
  final bool takesAntioxidants; // CoQ10, Zinc, Selenium, L-Carnitine
  final bool nonSmokerAndVaper;
  final bool moderateOrZeroAlcohol;
  final int monthsTryingToConceive;
  final int partnerAge;
  final bool hasVaricoceleHistory;

  const FertilityLifestyleAudit({
    required this.userId,
    required this.updatedAt,
    this.avoidsHeatExposure = true,
    this.looseUnderwear = true,
    this.takesAntioxidants = false,
    this.nonSmokerAndVaper = true,
    this.moderateOrZeroAlcohol = true,
    this.monthsTryingToConceive = 0,
    this.partnerAge = 30,
    this.hasVaricoceleHistory = false,
  });

  // Calculate lifestyle fertility optimization score (0-100)
  int get optimizationScore {
    int score = 0;
    if (avoidsHeatExposure) score += 20;
    if (looseUnderwear) score += 15;
    if (takesAntioxidants) score += 25;
    if (nonSmokerAndVaper) score += 25;
    if (moderateOrZeroAlcohol) score += 15;
    return score;
  }

  // Clinical criteria for when to seek an ASRM / AUA Reproductive Urologist
  bool get shouldConsultSpecialist {
    if (hasVaricoceleHistory) return true;
    if (partnerAge < 35 && monthsTryingToConceive >= 12) return true;
    if (partnerAge >= 35 && monthsTryingToConceive >= 6) return true;
    return false;
  }

  String get specialistGuidelineReason {
    if (hasVaricoceleHistory) {
      return 'History of varicocele or testicular trauma warrants early clinical evaluation by a reproductive urologist.';
    }
    if (partnerAge >= 35 && monthsTryingToConceive >= 6) {
      return 'Partner age is ≥35 with 6+ months of unprotected intercourse without conception (ASRM Guideline threshold).';
    }
    if (monthsTryingToConceive >= 12) {
      return '12+ months of regular unprotected intercourse without conception meets the clinical definition of subfertility.';
    }
    return 'Currently within the standard expectant conception window. Continue tracking and lifestyle optimization.';
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'updatedAt': updatedAt.toIso8601String(),
      'avoidsHeatExposure': avoidsHeatExposure,
      'looseUnderwear': looseUnderwear,
      'takesAntioxidants': takesAntioxidants,
      'nonSmokerAndVaper': nonSmokerAndVaper,
      'moderateOrZeroAlcohol': moderateOrZeroAlcohol,
      'monthsTryingToConceive': monthsTryingToConceive,
      'partnerAge': partnerAge,
      'hasVaricoceleHistory': hasVaricoceleHistory,
    };
  }

  factory FertilityLifestyleAudit.fromMap(Map<String, dynamic> map, String userId) {
    return FertilityLifestyleAudit(
      userId: userId,
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      avoidsHeatExposure: map['avoidsHeatExposure'] ?? true,
      looseUnderwear: map['looseUnderwear'] ?? true,
      takesAntioxidants: map['takesAntioxidants'] ?? false,
      nonSmokerAndVaper: map['nonSmokerAndVaper'] ?? true,
      moderateOrZeroAlcohol: map['moderateOrZeroAlcohol'] ?? true,
      monthsTryingToConceive: (map['monthsTryingToConceive'] as num?)?.toInt() ?? 0,
      partnerAge: (map['partnerAge'] as num?)?.toInt() ?? 30,
      hasVaricoceleHistory: map['hasVaricoceleHistory'] ?? false,
    );
  }
}
