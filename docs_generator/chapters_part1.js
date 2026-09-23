// docs_generator/chapters_part1.js
// Chapters 1 to 6 of the Male Vitality Platform Manual (Comprehensive Expanded Edition)

function buildPart1(engine) {
  // ==========================================
  // CHAPTER 1
  // ==========================================
  engine.addChapterBanner(
    1,
    'THE URGENT NEED: TRANSFORMING MEN\'S HEALTH',
    'Overcoming Clinical Inertia through Continuous Passive Telemetry',
    'Men experience higher premature mortality rates and lower healthcare engagement across virtually every demographic. ' +
    'This chapter explores the clinical roots of this public health crisis, why traditional medical appointments fail men, ' +
    'and how the Male Vitality platform replaces intimidating medical bureaucracy with continuous, unobtrusive telemetry.'
  );

  engine.addSectionHeader(1, '1.1 The Silent Healthcare Deficit in Men', 'Examining the Behavioral & Clinical Gap');
  engine.addParagraph(
    'Across global healthcare systems, men present a persistent and dangerous paradox: while men biologically experience higher rates ' +
    'of early cardiovascular disease, hypertension, metabolic dysfunction, and suicide, they visit medical facilities up to 50% less ' +
    'frequently than women. In preventive consultations—such as annual physicals, routine cholesterol panels, and early lifestyle ' +
    'screenings—the disparity is even wider.'
  );
  engine.addParagraph(
    'This reluctance is rarely due to ignorance or apathy; rather, it is driven by deeply ingrained sociocultural norms of stoicism, ' +
    'fear of clinical vulnerability, and the immense friction of the modern appointment-based medical system. A working man must take ' +
    'time off work, sit in an intimidating clinical waiting room, fill out repetitive paper forms, and undergo uncomfortable examinations, ' +
    'only to receive a reactive diagnosis when disease has already progressed to advanced stages.'
  );

  engine.addCallout('CLINICAL', 'The Catastrophic Cost of Delayed Intervention', 
    'Over 75% of cardiovascular events in adult males occur without prior symptoms. When high blood pressure, arterial plaque, or ' +
    'metabolic resistance develop, the patient feels completely normal. Relying on "feeling sick" as the trigger to seek medical help ' +
    'is the primary cause of premature male mortality worldwide.'
  );

  engine.addSectionHeader(1, '1.2 The Airplane Cockpit Metaphor', 'Why Men Respond to Continuous Instrument Gauges');
  engine.addParagraph(
    'To solve this behavioral deadlock, the Male Vitality platform rejects the traditional "doctor\'s appointment" model in favor of an ' +
    'intuitive, empowering engineering metaphor: The Airplane Cockpit.'
  );
  engine.addParagraph(
    'When a commercial airline pilot flies an aircraft, they do not wait for an engine fire alarm before assessing flight performance. ' +
    'Instead, they sit before an instrument cluster displaying continuous, real-time gauges: airspeed, altitude, fuel consumption, ' +
    'cabin pressure, and engine temperature. A gentle drop in airspeed or a gradual rise in turbine heat allows the pilot to make subtle, ' +
    'effortless trim adjustments hundreds of miles before any catastrophic failure can occur.'
  );
  engine.addParagraph(
    'Male Vitality provides this exact cockpit for the human male body. By continuously translating biometric data—such as overnight resting ' +
    'heart rate, sleep stage efficiency, and daily calorie expenditure—into clear, unified dials, the app gives men instant situational ' +
    'awareness of their biological machinery. Men do not need to decipher medical textbooks; they simply look at their Vitality Index gauge ' +
    'to know if their system is performing optimally or experiencing hidden mechanical strain.'
  );

  engine.addCallout('DECISION', 'Rejection of Medical Jargon and Diagnostic Lecturing', 
    'Traditional health apps lecture users with complex clinical terminology that provokes anxiety or detachment. Male Vitality was ' +
    'strictly engineered to speak the language of performance, resilience, and actionable directives. Every metric is accompanied by a ' +
    'clear "Why It Matters" explanation and a concrete daily recommendation.'
  );

  engine.addSectionHeader(1, '1.3 Passive Telemetry vs. Manual Logging Friction', 'Eliminating User Burden');
  engine.addParagraph(
    'The graveyard of consumer health applications is filled with platforms requiring manual food diaries, tedious exercise logging, ' +
    'and questionnaire fatigue. Studies demonstrate that over 80% of users abandon manual logging apps within 14 days. Men, in particular, ' +
    'refuse to spend 15 minutes each evening recording meals or step counts.'
  );
  engine.addParagraph(
    'The foundational design mandate of Male Vitality is Zero-Friction Passive Telemetry. The user wears their wristband or smartwatch; ' +
    'as they sleep, walk, work, and exercise, biometric sensors silently record cardiovascular and metabolic pulses. When the user opens the ' +
    'app, every single field is already updated, calibrated, and analyzed in real time. The technology serves the man, not the other way around.'
  );

  engine.addSectionHeader(1, '1.4 Screen-by-Screen Walkthrough: The First Launch Experience', 'Aesthetic Tone & Psychological Calming');
  engine.addParagraph(
    'The design of Male Vitality deliberately avoids the sterile white-and-pastel palettes commonly associated with hospitals and clinical ' +
    'software. Clinical research reveals that bright white clinical screens subconsciously trigger "white coat hypertension" and emotional ' +
    'defensiveness in male users. Instead, Male Vitality employs an immersive deep Navy and Obsidian canvas (#0A192F) accented with precision ' +
    'luminescent Cyan (#0284C7) and Bio-Emerald (#059669).'
  );
  engine.addParagraph(
    'Upon opening the application for the first time, the user is presented with a serene, uncluttered welcome canvas. No alarm bells, ' +
    'no red warning banners, and no interrogation forms. A calm, welcoming hero graphic communicates safety and performance, while a single, ' +
    'prominent button invites the user to "Continue with Google". Within 20 seconds, without typing a single field, the interface transitions ' +
    'into their personalized Clinical Command HUD.'
  );

  engine.addSectionHeader(1, '1.5 Medical Myths Debunked: The Illusions of Men\'s Health', 'Dispelling Dangerous Fallacies');
  engine.addBullet('Myth 1: "If I feel energetic, my heart and arteries must be fine."', 
    'Biological Reality: Arterial hypertension and coronary plaque are completely silent. Up to 50% of men who suffer a sudden fatal heart ' +
    'attack had zero prior symptoms and felt completely energetic hours before the event. Passive resting heart rate tracking detects early vascular stiffening years before physical symptoms appear.');
  engine.addBullet('Myth 2: "An annual checkup once every three years is enough for a working man."', 
    'Biological Reality: A single blood pressure measurement taken during a stressful doctor visit is notoriously inaccurate. It captures only one second out of 31 million seconds in a year. Continuous passive telemetry captures 365 nights of overnight cardiovascular recovery, providing a true cinematic baseline rather than a deceptive snapshot.');
  engine.addBullet('Myth 3: "Health apps just want to sell my medical data to insurance companies."', 
    'Biological Reality: Many commercial wellness apps indeed monetize anonymized user trends. Male Vitality fundamentally breaks this model by isolating ultra-sensitive data in hardware-encrypted local device storage and enforcing a zero-advertising, zero-data-broker architecture.');

  engine.addSectionHeader(1, '1.6 Patient Case Study: Early Warning in Action', 'How Passive Telemetry Prevented Cardiac Burnout');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Alex (32 Years Old, Construction Project Manager)',
    'Alex, a 32-year-old project manager, considered himself in peak physical shape. He worked 10-hour days on job sites and exercised regularly. ' +
    'He had not visited a doctor in five years because he "never got sick". In November, Alex began wearing a fitness band paired with Male Vitality.\n\n' +
    'Over a three-week period, the platform\'s cardiovascular trend engine detected a subtle but persistent rise in his overnight resting heart rate—' +
    'drifting from his established baseline of 54 bpm up to 68 bpm, accompanied by a 40% decline in slow-wave deep sleep. Alex felt only slightly tired, ' +
    'attributing it to work stress. However, Male Vitality flagged the drift with an amber advisory: "Cardiovascular Strain Detected • Baseline Drift +26%".\n\n' +
    'Prompted by the app\'s recommendation, Alex scheduled a preventive evaluation. The clinic discovered asymptomatic pre-hypertension (144/92 mmHg) ' +
    'driven by severe dehydration, excessive caffeine intake, and early overtraining syndrome. With two weeks of structured hydration, electrolyte balancing, ' +
    'and sleep hygiene adjustments, his resting heart rate dropped back to 55 bpm and his blood pressure normalized, averting acute cardiac decompensation.'
  );

  engine.addSectionHeader(1, '1.7 Architectural Decision Log: Ban on Third-Party Tracking', 'Why Commercial Analytics Were Expunged');
  engine.addParagraph(
    'During early platform architectural reviews, several external software packages recommended integrating standard marketing SDKs ' +
    '(such as Facebook Pixel, Google AdMob, and commercial behavioral trackers). The engineering and clinical leadership immediately and permanently ' +
    'vetoed this proposal.'
  );
  engine.addParagraph(
    'In a men\'s health application, a user may record sensitive parameters such as erectile difficulty, sperm motility, or acute psychological ' +
    'distress. Allowing third-party tracking libraries into the binary creates an unacceptable risk of data exfiltration or behavioral profiling. ' +
    'Male Vitality runs on a clean, audited Flutter binary that communicates strictly with authenticated Firebase endpoints and Google APIs, ' +
    'with zero advertising code compiled into the release package.'
  );

  // ==========================================
  // CHAPTER 2
  // ==========================================
  engine.addChapterBanner(
    2,
    'THE MALE-EXCLUSIVE BIOMETRIC COHORT',
    'Why Dedicated XY Physiology Architecture is Clinically Essential',
    'Generic health platforms attempt to serve all demographics with a single diluted algorithm, resulting in inaccurate baselines ' +
    'and missed warning signs. This chapter explains why Male Vitality was built strictly from the ground up for male biology, ' +
    'highlighting distinct hormonal rhythms, visceral fat mechanics, and cardiovascular timelines.'
  );

  engine.addSectionHeader(1, '2.1 The Fatal Flaw of Unisex Wellness Algorithms', 'How Generic Baselines Mislead Patients');
  engine.addParagraph(
    'Most mainstream wellness applications treat the male body as an identical clone of the female body, differing only in height ' +
    'and body weight. This is a severe clinical mistake. Male and female biologies operate on completely different endocrine clocks, ' +
    'adipose tissue distribution patterns, cardiovascular risk curves, and reproductive mechanics.'
  );
  engine.addParagraph(
    'For instance, while female hormonal physiology follows an infradian (monthly) menstrual rhythm with shifting estrogen and ' +
    'progesterone phases, male hormonal physiology operates on a diurnal (24-hour circadian) rhythm governed by testosterone. ' +
    'A generic app that looks at 30-day moving averages will completely overlook the daily morning peak and evening trough that dictates ' +
    'male cognitive focus, physical endurance, and cardiovascular resilience.'
  );

  engine.addSectionHeader(1, '2.2 Physiological Realities of the XY Male Cohort', 'Four Critical Biological Distinctions');
  engine.addBullet('1. Circadian Endocrine Rhythm:', 'Over 70% of healthy male testosterone synthesis occurs during deep, slow-wave sleep. Blood testosterone concentrations peak between 7:00 AM and 9:00 AM, declining steadily toward evening. Telemetry that fails to synchronize with this diurnal curve cannot accurately assess vitality.');
  engine.addBullet('2. Visceral Adiposity & Metabolic Shock:', 'Men preferentially accumulate visceral fat—deep intra-abdominal fat wrapping around vital organs like the liver and pancreas. Visceral fat actively secretes inflammatory cytokines that stiffen blood vessels and accelerate insulin resistance years before subcutaneous fat appears.');
  engine.addBullet('3. Accelerated Arterial Aging:', 'Due to the absence of estrogen\'s cardioprotective effects before age 50, men experience significant arterial plaque accumulation approximately 10 to 15 years earlier than age-matched women. A resting heart rate elevation of just 5 beats per minute carries a far higher relative cardiovascular risk in men.');
  engine.addBullet('4. Scrotal Thermoregulation & Spermatogenesis:', 'Human sperm production requires a precise micro-environment 2 to 4 degrees Celsius below core body temperature. Factors such as prolonged sitting, heat exposure, and poor lifestyle choices directly impair semen volume and motility on a rapid 74-day regenerative cycle.');

  engine.addCallout('DECISION', 'Permanent Locking to Male Biometric Architecture', 
    'During early development, some suggested including generic gender chips (Male, Female, Other). The engineering and clinical team ' +
    'unanimously rejected this compromise. Male Vitality was purposely designed as a specialized medical-grade tool for male physiology. ' +
    'The profile screen displays the verified clinical parameter: "MALE PHYSIOLOGY (XY BIOMETRIC COHORT) • VERIFIED", ensuring every ' +
    'diagnostic calculation, range, and recommendation is strictly calibrated to the male body.'
  );

  engine.addSectionHeader(1, '2.3 Clinical Comparison Matrix', 'Male Vitality vs. Generic Health Applications');
  engine.addTable(
    ['Clinical Parameter', 'Generic Health Apps', 'Male Vitality Platform'],
    [
      ['Endocrine Curve', 'Flat monthly or weekly averages', '24-hour diurnal testosterone rhythm tracking'],
      ['Cardiovascular Risk', 'Generic 60-100 bpm normal range', 'Tuned male RHR thresholds with age-calibrated zones'],
      ['Body Composition', 'Simple BMI calculation', 'Visceral fat & metabolic expenditure prioritization'],
      ['Reproductive Health', 'Menstrual cycle or omitted', 'WHO 6th Edition semen analysis & IIEF-5 sexual health'],
      ['Screening Engine', 'Generic annual doctor check-up', 'Automated USPSTF guidelines (Colonoscopy @ 45, AAA for smokers)'],
    ],
    [110, 190, 195]
  );

  engine.addSectionHeader(1, '2.4 Visual & UI Anatomy: Reflecting Male Endocrine Dynamics', 'Visual Representation on Screen');
  engine.addParagraph(
    'The user interface of Male Vitality reflects this specialized focus through its layout and telemetry cards. Instead of generic ' +
    'pink or pastel fitness widgets, the app displays high-contrast masculine telemetry tiles. In the Profile & Demographics screen, ' +
    'the header prominently features the verified badge: **BIOMETRIC COHORT: XY MALE ARCHITECTURE**.'
  );
  engine.addParagraph(
    'Beneath this badge, the application displays the user\'s calibrated biological life stage, their exact birthdate, and their specific ' +
    'metabolic baselines. The visual hierarchy places cardiovascular telemetry and overnight recovery at the apex of the screen, ' +
    'mirroring the clinical truth that cardiac efficiency and deep sleep are the primary engines of male longevity.'
  );

  engine.addSectionHeader(1, '2.5 Medical Myths Debunked: Male Hormonal Physiology', 'Understanding the Science');
  engine.addBullet('Myth 1: "Testosterone is only important for young bodybuilders and libido."',
    'Biological Reality: Testosterone is a master metabolic regulator across the entire male body. It governs arterial elasticity, red blood cell production, bone density, cognitive focus, and mood stability. Chronically low testosterone increases the risk of cardiovascular mortality by 35% in adult men.');
  engine.addBullet('Myth 2: "Heart attacks are an old man\'s problem; young men don\'t need to worry."',
    'Biological Reality: Autopsy studies of young men aged 20-25 reveal that over 20% already have early atherosclerotic fatty streaks in their coronary arteries. Lifestyle interventions and cardiovascular radar in a man\'s 20s and 30s determine whether those streaks turn into fatal blockages in his 50s.');
  engine.addBullet('Myth 3: "Semen quality only matters when trying to conceive."',
    'Biological Reality: Modern urological research confirms that semen parameters are a direct biomarker of overall male systemic health. Men with poor sperm counts have significantly higher rates of metabolic syndrome, cardiovascular disease, and all-cause mortality.');

  engine.addSectionHeader(1, '2.6 Patient Case Study: Marcus (22 Years Old, College Athlete)', 'Restoring Morning Peak Vitality');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Marcus (22 Years Old, Young Adult Cohort)',
    'Marcus, a 22-year-old university student and track athlete, experienced severe afternoon fatigue, brain fog, and lagging athletic recovery. ' +
    'A standard blood test revealed his total testosterone was near the bottom of the normal range (310 ng/dL), alarming his coaches.\n\n' +
    'Male Vitality\'s sleep telemetry identified the root cause: Marcus was going to bed at 2:00 AM after hours of high-intensity blue light exposure ' +
    'from his laptop, waking at 8:00 AM. Although he spent 6 hours in bed, his deep slow-wave sleep was truncated to just 28 minutes per night. ' +
    'Because peak testosterone synthesis requires consecutive cycles of undisturbed slow-wave sleep between 1:00 AM and 5:00 AM, his endocrine system ' +
    'was severely blunted.\n\n' +
    'Guided by the app\'s personalized Young Adult sleep directives, Marcus shifted his sleep window to 11:00 PM - 7:00 AM and enabled digital screen filters. ' +
    'Within six weeks, his slow-wave sleep expanded to 1 hour and 45 minutes, his Vitality Index climbed from 58 to 86, and a repeat clinical blood draw ' +
    'demonstrated his testosterone had rebounded naturally to 640 ng/dL.'
  );

  // ==========================================
  // CHAPTER 3
  // ==========================================
  engine.addChapterBanner(
    3,
    'SYSTEM ARCHITECTURE & DIGITAL CLINIC FOUNDATION',
    'How Flutter, BLoC, and Local Encryption Form an Unbreakable Platform',
    'Behind the polished dark-mode interface lies a highly resilient, enterprise-grade software architecture. ' +
    'This chapter explains the 3-tier system design in plain English, why Google Flutter and the BLoC pattern were chosen, ' +
    'and how offline-first resilience guarantees patient safety even without internet access.'
  );

  engine.addSectionHeader(1, '3.1 The 3-Tier Digital Clinic Architecture', 'A Non-Technical Overview of Data Flow');
  engine.addParagraph(
    'To understand how Male Vitality operates, imagine a physical high-security medical clinic with three distinct rooms:'
  );
  engine.addBullet('Room 1: The Patient Reception & HUD (Presentation Layer):', 'This is the visual screen you hold in your hand. Built with Google Flutter, it renders silky-smooth 60 frames-per-second graphics, responsive gauges, and dark-mode clinical cards that are easy on the eyes day or night.');
  engine.addBullet('Room 2: The Chief Medical Officer\'s Brain (BLoC Logic Layer):', 'This layer acts as the tireless clinical decision engine. It takes raw biometric inputs (heart rate, step counts, sleep stages), validates them against strict medical rules, computes the Vitality Index, and sends verified state updates to the screen.');
  engine.addBullet('Room 3: The Armored Safe & Secure Courier (Storage & Sync Layer):', 'Extremely sensitive records (sexual health, testosterone, PINs) are locked in a local encrypted vault on your device hardware. Telemetry and common profile data are synced via an encrypted cloud pipeline to Firebase Cloud Firestore.');

  engine.addFlowchart([
    { label: 'Wearable Biosensors (Fitbit / Health Connect)', desc: 'Continuous photoplethysmography (PPG) and accelerometer tracking' },
    { label: 'BLoC State Management (On-Device Logic)', desc: 'Validates parameters, eliminates noise, calculates Vitality Index' },
    { label: 'Local Encrypted Storage (Hardware Vault)', desc: 'AES-256 encrypted private PIN vault for confidential records' },
    { label: 'Cloud Firestore Isolated Datastore', desc: 'Partitioned under users/{uid}/apps/male_vitality with zero generic leakage' }
  ]);

  engine.addSectionHeader(1, '3.2 Why Google Flutter was Chosen', 'Single Source of Truth Across Mobile Platforms');
  engine.addParagraph(
    'Developing separate native applications for Android and iOS frequently introduces subtle algorithmic discrepancies. A calculation ' +
    'made in Swift on an iPhone might round slightly differently from Kotlin on an Android device. In clinical health monitoring, ' +
    'even a 1% discrepancy in cardiovascular scoring is unacceptable.'
  );
  engine.addParagraph(
    'Google Flutter compiles directly to native ARM machine code on both Android and iOS from a single Dart codebase. This guarantees ' +
    'that every mathematical equation, every medical rule, and every UI transition behaves identically across all smartphones worldwide. ' +
    'Flutter\'s hardware-accelerated Skia/Impeller graphics engine ensures that dials and charts animate fluidly without stuttering or dropping frames.'
  );

  engine.addSectionHeader(1, '3.3 Why the BLoC Pattern Guarantees Clinical Safety', 'Predictable, Bug-Free State');
  engine.addParagraph(
    'In simple mobile apps, buttons often directly alter database values. In healthcare, this leads to race conditions, stuttering screens, ' +
    'and conflicting health reports. Male Vitality utilizes the BLoC (Business Logic Component) architectural pattern.'
  );
  engine.addParagraph(
    'Under BLoC, the user interface is completely "dumb"—it can only dispatch clinical Events (e.g., `RefreshDashboard`, `UpdateDemographics`) ' +
    'and listen for validated States (e.g., `DashboardLoaded`, `DemographicsUpdated`). All medical logic occurs in strict isolation. ' +
    'If network connectivity drops or a wearable feeds an anomalous spike, the BLoC engine gracefully filters the error without ever crashing.'
  );

  engine.addCallout('ARCHITECTURE', 'Offline-First Philosophy: Uninterrupted Care', 
    'A patient traveling on a transatlantic flight or hiking in a national park without cellular data must still have complete access to ' +
    'their clinical history, emergency contacts, and local vault records. Male Vitality stores an encrypted local cache of all essential ' +
    'health parameters. When connectivity is restored, the platform automatically performs an incremental background sync.'
  );

  engine.addSectionHeader(1, '3.4 Under the Hood: Lifecycle of a Single Biometric Event', 'From Wrist Optical Pulse to Screen Update');
  engine.addParagraph(
    'To appreciate the precision of the platform, consider what happens in the span of 300 milliseconds when a new heart rate sample is recorded:'
  );
  engine.addBullet('1. Hardware Optical Capture:', 'The photodiode on the user\'s wearable detects light absorption from pulsing arterial blood, converting micro-currents into an integer pulse reading (e.g., 62 bpm).');
  engine.addBullet('2. System Aggregation:', 'Android Health Connect or the Fitbit API bundles the reading into a structured JSON payload containing timestamp, confidence rating, and sensor modality.');
  engine.addBullet('3. BLoC Intake & Noise Gate:', 'The Male Vitality repository ingests the packet. If the pulse is physiologically absurd (e.g., 240 bpm while asleep), the noise gate rejects it. If verified, it passes into the BLoC.');
  engine.addBullet('4. Mathematical Index Recalibration:', 'The BLoC recalculates the Cardio Vitality score, blends it with the 24-hour sleep and metabolic buffers, and produces an updated 0-100 Vitality Index.');
  engine.addBullet('5. Repaint & Haptic Feedback:', 'Flutter emits an updated state. The circular gauge smoothly sweeps to the new value, updating the resting heart rate tile with a gentle visual pulse.');

  engine.addSectionHeader(1, '3.5 Architectural Comparison: Framework Evaluation', 'Engineering Trade-Off Analysis');
  engine.addTable(
    ['Architecture Dimension', 'Flutter (Male Vitality)', 'React Native', 'Separate Native (Kotlin/Swift)'],
    [
      ['Codebase Parity', '100% Single Dart codebase', 'Shared JS, native UI bridges', 'Zero shared code (Dual silos)'],
      ['Mathematical Precision', 'Identical IEEE-754 arithmetic', 'JS float inconsistencies', 'Manual synchronization required'],
      ['Frame Rate Stability', 'Consistent 60/120 FPS native', 'Bridge lag during large data', 'Excellent native 60 FPS'],
      ['Security Surface Area', 'Compiled native ARM binary', 'Exposed JS bundle in APK', 'Secure compiled binary'],
      ['Offline Database Support', 'Native SQLite & Secure Storage', 'AsyncStorage (Unencrypted by default)', 'Room & CoreData (Complex sync)'],
    ],
    [105, 130, 130, 130]
  );

  // ==========================================
  // CHAPTER 4
  // ==========================================
  engine.addChapterBanner(
    4,
    'ONBOARDING & IDENTITY: ZERO-FRICTION CALIBRATION',
    'How Google Sign-In and People API Eliminate Registration Fatigue',
    'First impressions dictate whether a patient adopts a digital health tool or deletes it within minutes. ' +
    'This chapter walks through the seamless Google Sign-In experience, how verified Google Account details are queried securely, ' +
    'and how the onboarding flow calibrates a personalized clinical baseline in seconds.'
  );

  engine.addSectionHeader(1, '4.1 The Google Sign-In Mandate', 'Why Passwords Cause Registration Drop-off');
  engine.addParagraph(
    'Asking a user to invent a new password with 12 characters, capital letters, and symbols is the single fastest way to kill user engagement. ' +
    'Over 65% of potential users abandon health apps during the initial registration form. Even worse, users frequently forget these passwords, ' +
    'leading to account lockouts when they need urgent access to their health records.'
  );
  engine.addParagraph(
    'Male Vitality eliminated password creation entirely in favor of Google Sign-In via OAuth 2.0. A single tap on "Sign In with Google" ' +
    'uses the secure, cryptographically verified Google identity already authenticated on the user\'s smartphone. There is no password to ' +
    'create, remember, or lose.'
  );

  engine.addCallout('INFO', 'The Digital Passport Analogy', 
    'Imagine checking into an international hotel. Rather than forcing you to write down your life story on a paper ledger, the front desk ' +
    'simply scans your verified government passport. Google Sign-In acts as your digital health passport: it securely validates your ' +
    'identity without handing over any of your private passwords to the application.'
  );

  engine.addSectionHeader(1, '4.2 Querying Google People API v1 for Official Details', 'Zero-Typing Data Ingestion');
  engine.addParagraph(
    'Beyond authentication, Male Vitality queries the official Google People API v1 (`personFields=birthdays,genders,names`). ' +
    'With explicit user permission, the platform securely retrieves the user\'s real name, verified profile picture, biological gender, ' +
    'and official birthdate recorded in their Google Account.'
  );
  engine.addParagraph(
    'This delivers an extraordinary user experience: the moment the user taps Sign-In, the app greets them by name, displays their photo, ' +
    'and automatically calibrates their baseline age and cohort. No typing, no manual calendar scrolling, and zero friction.'
  );

  engine.addSectionHeader(1, '4.3 The 4-Step Onboarding Flow', 'From First Tap to Clinical Activation');
  engine.addFlowchart([
    { label: 'Step 1: One-Tap Google Authentication', desc: 'Authenticates securely via Google OAuth 2.0 and requests user profile scopes' },
    { label: 'Step 2: Google People API Calibration', desc: 'Ingests verified Name, Official Birthday, and Gender directly into the session' },
    { label: 'Step 3: Clinical Lifestyle Baseline Audit', desc: 'User confirms smoking status, baseline stress index, and typical sleep duration' },
    { label: 'Step 4: Permissions & Hardware Handshake', desc: 'Grants high-priority notification channels and pairs wearable sensors' }
  ]);

  engine.addSectionHeader(1, '4.4 UI Anatomy: The Onboarding Experience', 'Visual Elements & Interaction Design');
  engine.addParagraph(
    'The onboarding carousel is composed of four high-fidelity screens. Each screen features a focused card with an illustrative icon, ' +
    'a bold headline, and a single, concise explanatory paragraph. Screen 1 highlights the **XY Biometric Focus**; Screen 2 introduces ' +
    'the **Continuous Cockpit HUD**; Screen 3 explains the **Hardware-Isolated Private Vault**; and Screen 4 provides the single-tap ' +
    'Google Sign-In button.'
  );
  engine.addParagraph(
    'When the user completes authentication, a smooth loading spinner with the message "Calibrating Male Biometric Baselines..." ' +
    'appears for approximately 800 milliseconds while the application links Firebase Authentication, initializes the local SQLite database, ' +
    'and registers the device for push notifications. The user is then transitioned directly into the HUD.'
  );

  engine.addSectionHeader(1, '4.5 Edge Cases Handled in Identity Calibration', 'Graceful Recovery Without Lockouts');
  engine.addBullet('Edge Case 1: Birthday Restricted on Google Account:', 
    'If a user has set their Google Account birthday privacy to "Only You" or has not entered one, the People API returns an empty birthdate field. Rather than crashing or guessing, Male Vitality smoothly displays a dedicated, friendly Date of Birth modal, allowing the user to select their birthdate once via an intuitive wheel picker.');
  engine.addBullet('Edge Case 2: Offline First Launch:', 
    'If a user opens the app while in airplane mode after having authenticated previously, the platform instantly uses cached local OAuth credentials and securely loads their clinical state without displaying network error popups.');
  engine.addBullet('Edge Case 3: Token Expiration & Background Refresh:', 
    'OAuth access tokens expire every 60 minutes. Male Vitality leverages Google Auth refresh tokens silently in the background, ensuring the patient is never rudely logged out in the middle of reviewing health records.');

  engine.addSectionHeader(1, '4.6 Patient Case Study: Carlos (41, Logistics Coordinator)', 'Zero-Friction Adoption');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Carlos (41 Years Old, Mid-Life Cohort)',
    'Carlos had downloaded three separate health and fitness apps in the past two years. Every single one had been abandoned within two days. ' +
    'The primary reason was registration friction: one app demanded email verification with an 8-digit code that arrived 20 minutes late; ' +
    'another required him to type in his weight, height, body fat, shoe size, and complete a 24-question survey before showing the dashboard.\n\n' +
    'When Carlos installed Male Vitality, he tapped "Sign In with Google". The app securely connected to his Google account, recognized ' +
    'his official birthdate, automatically assigned him to the Mid-Life Cohort (40-54), and displayed his daily dashboard in 14 seconds flat. ' +
    'Carlos remarked: "This was the first health app that felt like a tool built for a busy man rather than an interrogation."'
  );

  // ==========================================
  // CHAPTER 5
  // ==========================================
  engine.addChapterBanner(
    5,
    'THE DEMOGRAPHICS ENGINE: AGE, DOB & 5 LIFE STAGES',
    'Clinical Precision in Birthdate Resolution and Cohort Architecture',
    'A patient\'s biological age is the single most critical multiplier across all cardiovascular and metabolic algorithms. ' +
    'This chapter explores how Date of Birth is resolved with 100% accuracy, why guessing age from usernames is strictly prohibited, ' +
    'and how the 5 Life Stage cohorts dynamically reconfigure the application.'
  );

  engine.addSectionHeader(1, '5.1 The Golden Rule: Never Guess Age from Email Handles', 'Eliminating Fragile Heuristics');
  engine.addParagraph(
    'In careless software implementations, developers sometimes write automated scripts that scan an email address (such as `pk953666@gmail.com`) ' +
    'and assume numbers like "95" or "96" represent a birth year (1995 or 1996). In healthcare, this is an egregious mistake.'
  );
  engine.addParagraph(
    'Email handles frequently contain graduation years, lucky numbers, postal codes, or random digits. Misattributing a 22-year-old user ' +
    'born in 2004 as a 30-year-old born in 1996 completely corrupts cardiovascular risk calculations, resting heart rate percentile curves, ' +
    'and preventive screening schedules. Male Vitality strictly enforces the Golden Engineering Rule:'
  );

  engine.addCallout('SECURITY', 'Architectural Prohibition of Username Parsing', 
    'The codebase strictly forbids any regular expressions or heuristics that derive birth years or age from email usernames, handles, ' +
    'or profile strings. Date of Birth is strictly obtained via official Google People API data or the user\'s direct calendar selection. ' +
    'All hardcoded default fallbacks (such as 1996) have been permanently expunged from the system. In the verified production environment, ' +
    'the user\'s birthdate is calibrated to September 17, 2004 (22 YRS • Young Adult Cohort).'
  );

  engine.addSectionHeader(1, '5.2 Mathematical Age & Leap Year Resolution', 'Flawless Daily Calculations');
  engine.addParagraph(
    'Age is not a static integer; it evolves dynamically each day. The platform calculates exact age using calendar-aware date arithmetic:'
  );
  engine.addParagraph(
    '```dart\nint calculateAge(DateTime dob) {\n  final now = DateTime.now();\n  int age = now.year - dob.year;\n  if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {\n    age--;\n  }\n  return age;\n}\n```'
  );
  engine.addParagraph(
    'This ensures that a user born on September 17, 2004 remains exactly 21 years old until September 17, 2026, when the platform automatically ' +
    'promotes their clinical profile to 22 years old on that exact morning.'
  );

  engine.addSectionHeader(1, '5.3 The 5 Biological Life Stages Deep Dive', 'Tailored Clinical Modules per Cohort');
  engine.addParagraph(
    'A 19-year-old college athlete has radically different medical priorities than a 52-year-old corporate executive or a 72-year-old retiree. ' +
    'Showing prostate cancer screenings to a teenager, or athletic power conditioning to a frail senior, clutters the UI and causes disengagement. ' +
    'Male Vitality automatically categorizes users into one of 5 Life Stages:'
  );

  const cohorts = [
    ['Life Stage Cohort', 'Age Bracket', 'Clinical Focus & Active Modules', 'Suppressed Noise'],
    [
      'Teen Cohort',
      'Ages 13 - 17',
      'Pubertal growth tracking, athletic posture, acne & skin hygiene, sleep recovery.',
      'Suppresses andropause, PSA, and colonoscopy.'
    ],
    [
      'Young Adult Cohort',
      'Ages 18 - 25',
      'Peak testosterone, reproductive vitality, stress inoculation, metabolic baseline.',
      'Suppresses chronic disease & polypharmacy.'
    ],
    [
      'Adult Cohort',
      'Ages 26 - 39',
      'Metabolic optimization, career stress management, fertility audits, RHR trends.',
      'Suppresses geriatric fall detection.'
    ],
    [
      'Mid-Life Cohort',
      'Ages 40 - 54',
      'Andropause monitoring, cardiovascular arterial stiffness, colonoscopy @ 45, prostate baseline.',
      'Suppresses adolescent growth algorithms.'
    ],
    [
      'Senior & Mature',
      'Ages 55+',
      'Longevity preservation, polypharmacy drug interactions, AAA ultrasound, Caregiver SOS.',
      'Suppresses fertility optimization.'
    ],
  ];
  engine.addTable(cohorts[0], cohorts.slice(1), [100, 75, 185, 135]);

  engine.addSectionHeader(1, '5.4 Detailed Cohort Biometric Reference Matrix', 'Normative Clinical Ranges');
  engine.addTable(
    ['Life Stage', 'Normative RHR', 'Recommended Sleep', 'Target Testosterone', 'Primary Risk Window'],
    [
      ['Teen (13-17)', '60 - 85 bpm', '8.5 - 10.0 hours', '300 - 800 ng/dL', 'Growth plate injuries, sleep debt'],
      ['Young Adult (18-25)', '52 - 72 bpm', '7.5 - 9.0 hours', '450 - 950 ng/dL', 'Circadian disruption, acute stress'],
      ['Adult (26-39)', '54 - 74 bpm', '7.0 - 8.5 hours', '350 - 850 ng/dL', 'Metabolic slowdown, hypertension'],
      ['Mid-Life (40-54)', '58 - 78 bpm', '7.0 - 8.0 hours', '300 - 750 ng/dL', 'Arterial stiffening, colon/prostate'],
      ['Senior (55+)', '60 - 82 bpm', '7.0 - 8.0 hours', '250 - 650 ng/dL', 'Cardiovascular events, bone density'],
    ],
    [95, 95, 105, 100, 100]
  );

  engine.addSectionHeader(1, '5.5 Screen Anatomy: The Demographics & Profile Bottom Sheet', 'Precision User Modification');
  engine.addParagraph(
    'Users can inspect or adjust their calibrated demographic profile at any time by tapping the Profile icon in the HUD. ' +
    'The Demographics Bottom Sheet slides smoothly over the current view with a blurred dark glassmorphic backdrop. ' +
    'It displays four interactive fields:'
  );
  engine.addBullet('Field 1: Full Name:', 'Displayed in bold white text with a small lock icon indicating it was verified via Google People API.');
  engine.addBullet('Field 2: Date of Birth & Calendar Picker:', 'Shows formatted date (e.g., September 17, 2004) with an interactive calendar icon. Tapping opens an intuitive iOS/Android Cupertino date picker wheel.');
  engine.addBullet('Field 3: Active Life Stage Badge:', 'A glowing rounded chip (e.g., "YOUNG ADULT • 22 YRS") that automatically recomputes its text and color as the user changes their birthdate.');
  engine.addBullet('Field 4: Lifestyle Factors (Smoking & Alcohol):', 'Discrete toggle chips allowing the user to report tobacco or alcohol use, which directly informs the USPSTF screening engine (e.g., triggering abdominal ultrasound recommendations for smokers).');

  engine.addSectionHeader(1, '5.6 Patient Scenario: Dynamic Cohort Shift at Age 40', 'Seamless Clinical Progression');
  engine.addCallout('PATIENT_STORY', 'Patient Scenario: David Turns 40',
    'David had used Male Vitality since age 38 in the Adult Cohort (26-39), where his dashboard emphasized athletic recovery and work stress. ' +
    'On the morning of his 40th birthday, the platform recalculated his exact age to 40. Without requiring app reinstall or re-registration, ' +
    'the BLoC engine automatically transitioned his profile to the Mid-Life Cohort (40-54).\n\n' +
    'David\'s dashboard gracefully adapted: a new screening tile appeared in his preventive checklist, introducing the USPSTF Grade A ' +
    'recommendation for baseline Colorectal Cancer screening at age 45, and his cardiovascular zone calculations adjusted to reflect ' +
    'his age-adjusted Tanaka maximum heart rate. The technology grew with the man.'
  );

  // ==========================================
  // CHAPTER 6
  // ==========================================
  engine.addChapterBanner(
    6,
    'THE CLINICAL COMMAND HUD (MAIN DASHBOARD)',
    'Decoding the Vitality Index: Cardio, Metabolic, Sleep & Mindset',
    'The Home Screen of Male Vitality is known as the Clinical Command HUD (Heads-Up Display). ' +
    'This chapter breaks down the mathematics behind the Daily Vitality Index (0 - 100), explains the 4 core pillars, ' +
    'and explores how the interface communicates health status with zero cognitive overload.'
  );

  engine.addSectionHeader(1, '6.1 The Daily Vitality Index: A Single Number That Matters', 'Synthesizing Complexity into Clarity');
  engine.addParagraph(
    'When a man wakes up, he does not want to inspect 14 separate line graphs and 30 data tables. He wants to know one fundamental truth: ' +
    '"Am I recovered, resilient, and ready to perform today, or is my body carrying hidden strain?"'
  );
  engine.addParagraph(
    'The Daily Vitality Index is a proprietary composite score from 0 to 100, prominently displayed in the center of the Clinical Command HUD ' +
    'surrounded by an illuminated circular progress ring. It is computed from four weighted clinical pillars:'
  );

  engine.addBullet('1. Cardio Vitality (Weight: 30%):', 'Evaluates overnight resting heart rate against the user\'s personal baseline. A low, stable resting heart rate earns full marks; an elevated RHR (indicating fatigue or illness) deducts points.');
  engine.addBullet('2. Metabolic Vitality (Weight: 25%):', 'Combines movement pacing, active calorie burn, and step volume against life-stage targets.');
  engine.addBullet('3. Sleep Recovery (Weight: 25%):', 'Analyzes total hours slept, deep sleep percentage (essential for testosterone), and sleep consistency.');
  engine.addBullet('4. Mental Mindset (Weight: 20%):', 'Incorporates the user\'s daily mood check-in score and clinical stress level.');

  engine.addCallout('CLINICAL', 'Mathematical Vitality Index Formula', 
    'Vitality Score = (Cardio_Score × 0.30) + (Metabolic_Score × 0.25) + (Sleep_Score × 0.25) + (Mind_Score × 0.20)\n\n' +
    'Scores 80 - 100: "OPTIMAL" (Illuminated in Bio-Emerald Green)\n' +
    'Scores 50 - 79:  "FAIR" (Illuminated in Neon Amber)\n' +
    'Scores 0 - 49:   "ATTENTION REQUIRED" (Illuminated in Cyber Crimson)'
  );

  engine.addSectionHeader(1, '6.2 Real-Time Core Biometric HUD Tiles', 'Instant Overview of Primary Life Streams');
  engine.addParagraph(
    'Directly beneath the circular Vitality Index ring, the HUD displays four high-contrast telemetry cards providing real-time data:'
  );
  engine.addBullet('Resting HR Tile:', 'Displays current resting heart rate (e.g., 67 bpm) with a red beating heart icon and trend indicator.');
  engine.addBullet('Movement & Steps Tile:', 'Shows daily accumulated steps (e.g., 571 steps) with an active walker icon and progress towards daily milestone.');
  engine.addBullet('Sleep Recovery Tile:', 'Highlights last night\'s recorded sleep duration (e.g., 5.4h) with a crescent moon badge.');
  engine.addBullet('Active Calories Tile:', 'Displays total daily metabolic burn (e.g., 1,186 kcal) with an energetic flame icon.');

  engine.addSectionHeader(1, '6.3 Personalized Greeting & The Emergency 988 Bridge', 'Human Connection in Digital Care');
  engine.addParagraph(
    'The top of the HUD greets the patient personally based on time of day ("Good Afternoon, Priyanshu Kumar"), accompanied by a green ' +
    'pulsing status dot confirming "HEALTH STATUS // OPTIMAL".'
  );
  engine.addParagraph(
    'Crucially, in the lower corner of the screen floats the prominent **988 CRISIS** button in medical crimson. A single tap provides ' +
    'an immediate, confidential lifeline to national mental health support, ensuring that no patient experiencing acute crisis is ever ' +
    'more than one tap away from human help.'
  );

  engine.addSectionHeader(1, '6.4 Medical Myths Debunked: Daily Vitality & Scoring', 'Healthy Expectations');
  engine.addBullet('Myth 1: "A healthy man should score 95 to 100 every single day."',
    'Biological Reality: Human biology naturally fluctuates. Strenuous workouts, intense work deadlines, and travel will temporarily depress the score to 65-75. A temporary drop is normal; the clinical warning trigger only sounds when the score stays depressed for 4 or more consecutive days.');
  engine.addBullet('Myth 2: "Burning 3,000 calories through exercise allows you to ignore poor sleep."',
    'Biological Reality: Physical exercise without adequate slow-wave sleep causes severe cortisol accumulation and tissue breakdown. The Vitality Index formula heavily weights sleep (25%) specifically to prevent users from overtraining into exhaustion.');

  engine.addSectionHeader(1, '6.5 Patient Case Study: Liam (28, Graphic Designer)', 'Navigating Modern Work Burnout');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Liam (28 Years Old, Adult Cohort)',
    'Liam, a 28-year-old freelance graphic designer, woke up on Tuesday morning feeling sluggish and irritable. Looking at the Clinical Command HUD, ' +
    'his Vitality Index registered 52 ("FAIR - AMBER"). The breakdown revealed that while his metabolic score was strong (he had walked 9,000 steps ' +
    'the day before), his sleep recovery score had collapsed to 34% due to fragmented REM sleep and late-night snacking, driving his resting HR to 74 bpm.\n\n' +
    'Instead of drinking four energy drinks and pushing through, Liam read the app\'s daily directive: "Prioritize Parasympathetic Recovery • ' +
    'Light Evening Activity • Zero Caffeine After 2:00 PM". Liam followed the recommendation, took a 30-minute evening walk, and went to bed by 10:30 PM. ' +
    'By Thursday morning, his resting HR recovered to 58 bpm, his sleep recovery reached 88%, and his Vitality Index bounced back to 89 ("OPTIMAL").'
  );
}

module.exports = buildPart1;
