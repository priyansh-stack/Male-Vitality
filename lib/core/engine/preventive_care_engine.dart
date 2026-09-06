enum ScreeningCategory {
  cardiovascular,
  cancer,
  infectious,
  metabolic,
  sensoryAndBone,
  generalWellness,
}

class ClinicalScreeningGuideline {
  final String id;
  final String title;
  final ScreeningCategory category;
  final String frequency;
  final int minAge;
  final int? maxAge;
  final String evidenceGrade; // e.g. "USPSTF Grade A", "USPSTF Grade B", "AHA Recommended"
  final String plainLanguageWhy;
  final String whatToExpect;
  final String howToInterpret;
  final bool requiresSmoker;
  final bool requiresFamilyHistory;

  const ClinicalScreeningGuideline({
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    required this.minAge,
    this.maxAge,
    required this.evidenceGrade,
    required this.plainLanguageWhy,
    required this.whatToExpect,
    required this.howToInterpret,
    this.requiresSmoker = false,
    this.requiresFamilyHistory = false,
  });
}

class PreventiveCareEngine {
  static const List<ClinicalScreeningGuideline> allGuidelines = [
    // 1. Blood Pressure
    ClinicalScreeningGuideline(
      id: 'bp_screening',
      title: 'Blood Pressure Evaluation',
      category: ScreeningCategory.cardiovascular,
      frequency: 'Every 1 year (or every 6 months if elevated)',
      minAge: 18,
      evidenceGrade: 'USPSTF Grade A',
      plainLanguageWhy:
          'High blood pressure is the "silent killer" in men, leading to heart attack, stroke, and erectile dysfunction with zero early warning signs.',
      whatToExpect:
          'A quick, non-invasive inflatable arm cuff reading at your doctor\'s office or local pharmacy.',
      howToInterpret:
          '< 120/80 mmHg is normal. 120–129/<80 is elevated. ≥ 130/80 indicates Stage 1 hypertension.',
    ),

    // 2. Cholesterol / Lipid Panel
    ClinicalScreeningGuideline(
      id: 'cholesterol_screening',
      title: 'Lipid Panel (Cholesterol & Triglycerides)',
      category: ScreeningCategory.cardiovascular,
      frequency: 'Every 3 to 5 years (annual if on statin or cardiac risk)',
      minAge: 20,
      evidenceGrade: 'USPSTF Grade A / AHA',
      plainLanguageWhy:
          'High LDL cholesterol causes atherosclerotic plaque build-up in coronary arteries, escalating heart disease risk from the late twenties.',
      whatToExpect:
          'A simple morning fasting blood draw analyzing Total Cholesterol, LDL, HDL, and Triglycerides.',
      howToInterpret:
          'Optimal targets: LDL < 100 mg/dL, HDL > 40 mg/dL (higher is protective), Triglycerides < 150 mg/dL.',
    ),

    // 3. Fasting Glucose / HbA1c (Type 2 Diabetes)
    ClinicalScreeningGuideline(
      id: 'diabetes_screening',
      title: 'Fasting Blood Glucose / HbA1c',
      category: ScreeningCategory.metabolic,
      frequency: 'Every 3 years',
      minAge: 35,
      maxAge: 70,
      evidenceGrade: 'USPSTF Grade B',
      plainLanguageWhy:
          'Uncontrolled blood sugar damages microvascular circulation, kidneys, eyesight, and nerves, and directly contributes to severe ED.',
      whatToExpect:
          'Fasting blood draw or finger-prick HbA1c assessing your average blood glucose over the past 90 days.',
      howToInterpret:
          'HbA1c < 5.7% is normal. 5.7%–6.4% indicates prediabetes. ≥ 6.5% indicates diabetes.',
    ),

    // 4. Colorectal Cancer Screening
    ClinicalScreeningGuideline(
      id: 'colorectal_screening',
      title: 'Colorectal Cancer Screening (Colonoscopy / FIT)',
      category: ScreeningCategory.cancer,
      frequency: 'Colonoscopy every 10 years or FIT test annually',
      minAge: 45,
      maxAge: 75,
      evidenceGrade: 'USPSTF Grade A / ACS',
      plainLanguageWhy:
          'Colorectal cancer is the second most lethal cancer in men, yet over 90% of early-stage cases are completely preventable when precancerous polyps are removed.',
      whatToExpect:
          'Options include an annual take-home stool test (FIT/Cologuard) or a comprehensive outpatient colonoscopy with mild twilight sedation.',
      howToInterpret:
          'Negative FIT means no hidden blood. During colonoscopy, any detected polyps are removed and sent for pathology review.',
    ),

    // 5. Prostate-Specific Antigen (PSA) Discussion
    ClinicalScreeningGuideline(
      id: 'psa_screening',
      title: 'Prostate Cancer Screening (PSA Blood Test & Shared Decision)',
      category: ScreeningCategory.cancer,
      frequency: 'Every 1 to 2 years after informed physician discussion',
      minAge: 45,
      maxAge: 69,
      evidenceGrade: 'USPSTF Grade C / AUA Guidelines',
      plainLanguageWhy:
          'Prostate cancer will affect 1 in 8 men. Early detection allows active surveillance and treatment before malignant spread outside the capsule.',
      whatToExpect:
          'A simple blood test measuring prostate-specific antigen, often paired with a brief physical digital rectal exam (DRE).',
      howToInterpret:
          'PSA < 4.0 ng/mL is standard baseline. Values > 4.0 or rapid velocity increases warrant urologist review (remember: finasteride halves PSA values).',
    ),

    // 6. Lung Cancer Low-Dose CT (Smokers)
    ClinicalScreeningGuideline(
      id: 'lung_cancer_screening',
      title: 'Low-Dose CT Lung Screening (LDCT)',
      category: ScreeningCategory.cancer,
      frequency: 'Annual scan',
      minAge: 50,
      maxAge: 80,
      evidenceGrade: 'USPSTF Grade B',
      requiresSmoker: true,
      plainLanguageWhy:
          'Catches asymptomatic lung nodules years before clinical symptoms manifest in long-term smokers.',
      whatToExpect:
          'Fast, painless 15-second chest CT scan using very low radiation without needles or contrast dyes.',
      howToInterpret:
          'Lung-RADS score 1–2 is negative/benign. 3–4 indicates non-calcified nodules requiring 3-month follow-up or biopsy.',
    ),

    // 7. Hepatitis C Screening
    ClinicalScreeningGuideline(
      id: 'hepc_screening',
      title: 'Hepatitis C Antibody Blood Test',
      category: ScreeningCategory.infectious,
      frequency: 'Once in adulthood (or regularly if ongoing risk factors)',
      minAge: 18,
      maxAge: 79,
      evidenceGrade: 'USPSTF Grade B',
      plainLanguageWhy:
          'Chronic Hep C can silently destroy liver tissue over decades, causing cirrhosis or liver cancer, but is now 98% curable with antiviral pills.',
      whatToExpect: 'A routine one-time blood draw.',
      howToInterpret:
          'Non-reactive is negative. Reactive requires an HCV RNA confirmation test.',
    ),

    // 8. HIV & STI Screening
    ClinicalScreeningGuideline(
      id: 'hiv_sti_screening',
      title: 'HIV & Comprehensive STI Panel',
      category: ScreeningCategory.infectious,
      frequency: 'At least once for all teens/adults; annual or quarterly if active/new partners',
      minAge: 15,
      maxAge: 65,
      evidenceGrade: 'USPSTF Grade A / CDC',
      plainLanguageWhy:
          'Young men 18–25 account for almost half of new STIs. Early treatment prevents transmission, urethral scarring, and fertility loss.',
      whatToExpect:
          'Blood draw for HIV/Syphilis and urine sample for Chlamydia and Gonorrhea.',
      howToInterpret:
          'Negative means clean. Positive STI results are curable with targeted antibiotics.',
    ),

    // 9. Abdominal Aortic Aneurysm (AAA)
    ClinicalScreeningGuideline(
      id: 'aaa_screening',
      title: 'Abdominal Aortic Aneurysm Ultrasound (AAA)',
      category: ScreeningCategory.cardiovascular,
      frequency: 'One-time screening ultrasound',
      minAge: 65,
      maxAge: 75,
      evidenceGrade: 'USPSTF Grade B',
      requiresSmoker: true,
      plainLanguageWhy:
          'Smoking weakens the main arterial trunk in senior men, creating ballooning aneurysms that can rupture catastrophically without notice.',
      whatToExpect: 'A gentle 10-minute abdominal ultrasound gel scan.',
      howToInterpret:
          'Aorta diameter < 3.0 cm is normal. ≥ 5.5 cm indicates urgent vascular surgical consultation.',
    ),

    // 10. Bone Density (DEXA) for Senior Men
    ClinicalScreeningGuideline(
      id: 'dexa_screening',
      title: 'Bone Mineral Density Scan (DEXA)',
      category: ScreeningCategory.sensoryAndBone,
      frequency: 'Every 2 years for senior men',
      minAge: 70,
      evidenceGrade: 'USPSTF / Endocrine Society',
      plainLanguageWhy:
          'One in four men over 50 will suffer an osteoporosis-related bone fracture; male hip fractures carry a 30% one-year mortality rate.',
      whatToExpect: 'A quick, open-bed scan that measures bone mineral density in hips and spine.',
      howToInterpret:
          'T-score ≥ -1.0 is normal. -1.0 to -2.5 is osteopenia. ≤ -2.5 is osteoporosis.',
    ),

    // 11. Comprehensive Dental & Oral Cancer Exam
    ClinicalScreeningGuideline(
      id: 'dental_oral_screening',
      title: 'Dental Exam & Oral Cancer Screening',
      category: ScreeningCategory.generalWellness,
      frequency: 'Every 6 months',
      minAge: 13,
      evidenceGrade: 'ADA & CDC Guideline',
      plainLanguageWhy:
          'Chronic periodontal disease releases systemic inflammatory cytokines linked to heart disease and erectile dysfunction.',
      whatToExpect: 'Routine teeth cleaning, gum pocket measurement, and visual oral mucosal inspection.',
      howToInterpret: 'Normal gums are pink and firm without bleeding or deep pockets > 3mm.',
    ),
  ];

  /// Generates the personalized preventive care schedule for a user based on their profile
  static List<ClinicalScreeningGuideline> generateSchedule({
    required int age,
    required bool isSmoker,
    required bool hasFamilyHeartDisease,
    required bool hasFamilyCancer,
  }) {
    return allGuidelines.where((guideline) {
      if (age < guideline.minAge) return false;
      if (guideline.maxAge != null && age > guideline.maxAge!) return false;
      if (guideline.requiresSmoker && !isSmoker) return false;
      return true;
    }).toList();
  }
}
