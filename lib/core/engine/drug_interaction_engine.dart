enum InteractionSeverity {
  critical, // Absolutely contraindicated / life-threatening
  major,    // Significant clinical risk requiring physician consult
  moderate, // Monitor closely
  caution,  // Clinical note (e.g., lab value distortion)
}

class DrugInteractionRule {
  final List<String> drugClassA; // e.g. ["sildenafil", "viagra", "tadalafil", "cialis"]
  final List<String> drugClassB; // e.g. ["nitroglycerin", "nitro", "isosorbide"]
  final InteractionSeverity severity;
  final String title;
  final String description;
  final String clinicalRecommendation;

  const DrugInteractionRule({
    required this.drugClassA,
    required this.drugClassB,
    required this.severity,
    required this.title,
    required this.description,
    required this.clinicalRecommendation,
  });

  bool matches(String name1, String name2) {
    final n1 = name1.toLowerCase().trim();
    final n2 = name2.toLowerCase().trim();

    final aMatches1 = drugClassA.any((drug) => n1.contains(drug));
    final bMatches2 = drugClassB.any((drug) => n2.contains(drug));

    final aMatches2 = drugClassA.any((drug) => n2.contains(drug));
    final bMatches1 = drugClassB.any((drug) => n1.contains(drug));

    return (aMatches1 && bMatches2) || (aMatches2 && bMatches1);
  }
}

class DrugInteractionAlert {
  final String drugA;
  final String drugB;
  final InteractionSeverity severity;
  final String title;
  final String description;
  final String recommendation;

  const DrugInteractionAlert({
    required this.drugA,
    required this.drugB,
    required this.severity,
    required this.title,
    required this.description,
    required this.recommendation,
  });
}

class DrugInteractionEngine {
  static const List<DrugInteractionRule> rules = [
    // 1. ED meds + Nitrates (Critical)
    DrugInteractionRule(
      drugClassA: ['sildenafil', 'viagra', 'tadalafil', 'cialis', 'vardenafil', 'levitra'],
      drugClassB: ['nitroglycerin', 'nitro', 'isosorbide', 'imdur', 'monoket', 'nitrostat', 'amyl nitrite'],
      severity: InteractionSeverity.critical,
      title: 'Dangerous Hypotension Risk (Contraindicated)',
      description: 'Co-administration of PDE5 inhibitors with nitrates causes profound, life-threatening drops in systemic blood pressure.',
      clinicalRecommendation: 'Do NOT take these together under any circumstances. Immediately consult your cardiologist or prescribing physician.',
    ),
    // 2. ED meds + Alpha blockers (Major)
    DrugInteractionRule(
      drugClassA: ['sildenafil', 'viagra', 'tadalafil', 'cialis', 'vardenafil'],
      drugClassB: ['tamsulosin', 'flomax', 'doxazosin', 'cardura', 'terazosin', 'alfuzosin'],
      severity: InteractionSeverity.major,
      title: 'Orthostatic Hypotension Warning',
      description: 'Both medications dilate blood vessels and relax smooth muscle, potentially causing dizziness, lightheadedness, and fainting upon standing.',
      clinicalRecommendation: 'Separate doses by at least 4 to 6 hours. Discuss dosage adjustments with your urologist or primary physician.',
    ),
    // 3. Anticoagulants + NSAIDs (Major)
    DrugInteractionRule(
      drugClassA: ['warfarin', 'coumadin', 'apixaban', 'eliquis', 'rivaroxaban', 'xarelto', 'dabigatran', 'pradaxa'],
      drugClassB: ['ibuprofen', 'advil', 'motrin', 'naproxen', 'aleve', 'aspirin', 'meloxicam', 'diclofenac'],
      severity: InteractionSeverity.major,
      title: 'Elevated Internal Bleeding Risk',
      description: 'NSAIDs irritate the stomach lining and impair platelet aggregation, compounding anticoagulant hemorrhage risks.',
      clinicalRecommendation: 'Consider safer pain alternatives like Acetaminophen (Tylenol) after clearing with your doctor.',
    ),
    // 4. ACE Inhibitors / ARBs + Potassium (Major)
    DrugInteractionRule(
      drugClassA: ['lisinopril', 'enalapril', 'ramipril', 'losartan', 'valsartan', 'spironolactone'],
      drugClassB: ['potassium', 'k-lor', 'klor-con', 'salt substitute'],
      severity: InteractionSeverity.major,
      title: 'Hyperkalemia (Elevated Potassium) Risk',
      description: 'Blood pressure medications that affect the renin-angiotensin system reduce potassium excretion, which can trigger cardiac arrhythmias.',
      clinicalRecommendation: 'Avoid over-the-counter potassium supplements and high-potassium salt substitutes without regular serum lab monitoring.',
    ),
    // 5. Statins + Macrolides / Strong CYP3A4 inhibitors (Moderate)
    DrugInteractionRule(
      drugClassA: ['atorvastatin', 'lipitor', 'simvastatin', 'zocor', 'lovastatin'],
      drugClassB: ['clarithromycin', 'erythromycin', 'ketoconazole', 'itraconazole', 'fluconazole'],
      severity: InteractionSeverity.moderate,
      title: 'Statin Toxicity / Muscle Damage Risk',
      description: 'Certain antibiotics and antifungals block statin metabolism, increasing circulating blood levels and risk of rhabdomyolysis.',
      clinicalRecommendation: 'Temporary suspension of statin therapy during antibiotic course may be advised by your doctor.',
    ),
    // 6. 5-ARIs (Prostate/Hair) PSA Distortion Note (Caution)
    DrugInteractionRule(
      drugClassA: ['finasteride', 'proscar', 'propecia', 'dutasteride', 'avodart'],
      drugClassB: ['psa', 'prostate'],
      severity: InteractionSeverity.caution,
      title: 'Serum PSA Value Suppression',
      description: '5-alpha reductase inhibitors artificially lower Prostate-Specific Antigen (PSA) test levels by approximately 50%.',
      clinicalRecommendation: 'Always notify your physician you take this medication so they can apply the 2x adjustment factor when evaluating cancer risk.',
    ),
  ];

  /// Evaluates a list of user medications for known interactions and polypharmacy
  static List<DrugInteractionAlert> checkInteractions(List<String> medicationNames) {
    final alerts = <DrugInteractionAlert>[];

    for (int i = 0; i < medicationNames.length; i++) {
      for (int j = i + 1; j < medicationNames.length; j++) {
        final medA = medicationNames[i];
        final medB = medicationNames[j];

        for (final rule in rules) {
          if (rule.matches(medA, medB)) {
            alerts.add(
              DrugInteractionAlert(
                drugA: medA,
                drugB: medB,
                severity: rule.severity,
                title: rule.title,
                description: rule.description,
                recommendation: rule.clinicalRecommendation,
              ),
            );
          }
        }
      }
    }

    return alerts;
  }

  /// Checks if the patient meets criteria for Polypharmacy (≥ 5 concurrent medications)
  static bool isPolypharmacy(int medicationCount) {
    return medicationCount >= 5;
  }
}
