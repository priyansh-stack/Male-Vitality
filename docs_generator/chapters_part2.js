// docs_generator/chapters_part2.js
// Chapters 7 to 12 of the Male Vitality Platform Manual (Comprehensive Expanded Edition)

function buildPart2(engine) {
  // ==========================================
  // CHAPTER 7
  // ==========================================
  engine.addChapterBanner(
    7,
    'WEARABLE TELEMETRY & THE FITBIT DATA BRIDGE',
    'How Continuous Biosignals Flow Seamlessly from Wrist to Cloud',
    'Modern wearable biosensors capture millions of data pulses every 24 hours. ' +
    'This chapter demystifies how photoplethysmography and accelerometers measure human vitality, ' +
    'how the cloud data bridge synchronizes records into Firestore, and why fake or mock data was strictly purged.'
  );

  engine.addSectionHeader(1, '7.1 How Wearable Biosensors Listen to the Body', 'Photoplethysmography & Accelerometry Explained');
  engine.addParagraph(
    'When a man straps a smartwatch or fitness tracker to his wrist, small flashing green LED lights shine against his skin. ' +
    'This technology is called Photoplethysmography (PPG).'
  );
  engine.addParagraph(
    'Blood is red because it reflects red light and absorbs green light. Each time the heart contracts, a surge of oxygenated blood ' +
    'expands the capillary vessels in the wrist, absorbing more green light. Between beats, blood volume temporarily decreases, ' +
    'reflecting more light back to the optical photodiode sensor. By measuring these micro-fluctuations hundreds of times per second, ' +
    'the sensor calculates instantaneous heart rate with near-clinical accuracy.'
  );
  engine.addParagraph(
    'Simultaneously, a tiny 3-axis micro-electro-mechanical system (MEMS accelerometer) detects motion across three dimensions. ' +
    'Advanced filtering algorithms distinguish purposeful walking strides from typing on a keyboard, brushing teeth, or driving a vehicle, ' +
    'converting mechanical vibrations into reliable daily step totals and active calorie expenditures.'
  );

  engine.addSectionHeader(1, '7.2 The Telemetry Journey: From Wrist to Cloud Firestore', 'The Five-Station Data Pipeline');
  engine.addFlowchart([
    { label: '1. Wrist Sensor Sampling', desc: 'Optical PPG and accelerometer capture continuous heart rate and step impulses' },
    { label: '2. Bluetooth Low Energy (BLE) Sync', desc: 'Wristband syncs encrypted raw packets to the companion smartphone app' },
    { label: '3. Google Health & Fitbit Cloud Bridge', desc: 'Aggregates raw ticks into standardized daily summaries via Google Health API v4' },
    { label: '4. Cloud Firestore Canonical Datastore', desc: 'Persists records to users/{uid}/shared_health/daily/records/{YYYY-MM-DD}' },
    { label: '5. Male Vitality HUD Live Presentation', desc: 'BLoC engine ingests real-time record and updates the Vitality Index instantly' }
  ]);

  engine.addSectionHeader(1, '7.3 The Zero-Mock Data Mandate', 'Protecting Clinical Trust');
  engine.addParagraph(
    'During early testing of many consumer apps, developers often inject "mock" or simulated numbers (e.g., hardcoding 10,000 steps or ' +
    '72 bpm) to make screenshots look pretty. In a clinical-grade health tool, this practice is dangerous and unethical. ' +
    'A patient viewing a fabricated heart rate score might ignore early signs of dehydration or infection.'
  );
  engine.addParagraph(
    'The engineering team executed a complete, audited purge of all mock and simulated data stores. In Male Vitality, every number ' +
    'displayed on the screen—whether it is 24 steps or 12,000 steps, 67 bpm or 110 bpm—represents authentic, verified telemetry captured ' +
    'from real biosensors. If a sensor is disconnected, the platform transparently reports "Awaiting Sync" rather than inventing numbers.'
  );

  engine.addCallout('ARCHITECTURE', 'The "Force Sync" Reactive Handshake', 
    'On the Clinical Command Profile screen, users can tap the "FORCE SYNC" button at any time. This dispatches a background event ' +
    'that queries Google Health API, pulls the latest intraday wearable packet, updates Firestore, and re-renders the HUD dashboard ' +
    'in under 2.5 seconds without requiring an application restart.'
  );

  engine.addSectionHeader(1, '7.4 Screen Anatomy: Telemetry Status Tile & Sync Indicator', 'Real-Time Hardware Diagnostics');
  engine.addParagraph(
    'In the upper utility bar of the HUD, users can see the real-time status of their telemetry pipeline. A luminescent status dot ' +
    'indicates three states:\n' +
    '• Steady Green: Telemetry synchronized within the last 15 minutes.\n' +
    '• Pulsing Amber: Synchronizing intraday batch from Google Health / Fitbit.\n' +
    '• Dim Gray: Wearable disconnected or smartphone Bluetooth disabled.'
  );
  engine.addParagraph(
    'Tapping this indicator opens the Telemetry Health Sheet, which displays the exact timestamp of the last optical sample, ' +
    'the sensor battery percentage, and the total raw samples ingested during the current 24-hour window.'
  );

  engine.addSectionHeader(1, '7.5 Battery Optimization & Background Polling Rationale', 'Conserving Device Energy');
  engine.addParagraph(
    'Continuous background GPS or aggressive 1-second network polling will rapidly drain a smartphone battery, causing users to ' +
    'uninstall the application. Male Vitality utilizes an intelligent opportunistic synchronization architecture. Telemetry is ' +
    'synced in batches when the wearable negotiates standard BLE intervals, when the user opens the application, or when a high-priority ' +
    'FCM cloud trigger is received. Total daily battery impact on modern smartphones is rigorously constrained to less than 1.5%.'
  );

  engine.addSectionHeader(1, '7.6 Patient Case Study: David (45, Cyclist)', 'Seamless Multi-Device Continuity');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: David (45 Years Old, Mid-Life Cohort)',
    'David, a 45-year-old cyclist, wore a Fitbit tracker during his daily office work, but switched to a dedicated GPS chest-strap ' +
    'monitor during weekend cycling training. Traditional single-device apps frequently overwrite data or fail to record overlapping workouts.\n\n' +
    '(168 bpm), and subsequent post-exercise recovery curve were unified into an accurate 91-point Vitality score, with zero manual entry required.'
  );

  engine.addSectionHeader(1, '7.7 The Metabolic Mathematics of Active Calorie Burn', 'Basal vs. Active Metabolic Expenditure');
  engine.addParagraph(
    'A frequent frustration for men using commercial fitness trackers is severe calorie inaccuracy. Standard commercial algorithms ' +
    'notoriously overestimate daily calorie expenditure by 25% to 40%, causing users to unknowingly consume excess calories and gain visceral fat.'
  );
  engine.addParagraph(
    'Male Vitality implements the validated **Mifflin-St Jeor Equation** strictly tuned for male physiology:\n' +
    '$$\\text{BMR}_{\\text{male}} = (10 \\times \\text{weight}_{\\text{kg}}) + (6.25 \\times \\text{height}_{\\text{cm}}) - (5 \\times \\text{age}_{\\text{years}}) + 5$$\n' +
    'Basal Metabolic Rate (BMR) represents the energy required simply to keep organs functioning while resting motionless in bed. ' +
    'The platform then applies strict Metabolic Equivalents of Task (METs) to active movement recorded by the accelerometer, ' +
    'ensuring that resting burn is never double-counted as active exercise.'
  );
  engine.addParagraph(
    'By separating passive basal expenditure from authentic active caloric burn, the platform delivers an honest, empirical ' +
    'Active Calorie metric on the HUD tile (e.g. 1,186 kcal), providing men with a dependable foundation for body composition management.'
  );

  // ==========================================
  // CHAPTER 8
  // ==========================================
  engine.addChapterBanner(
    8,
    'SLEEP ARCHITECTURE & DEEP HORMONAL RECOVERY',
    'The Supreme Biological Engine of Male Testosterone and Restoration',
    'Sleep is not a passive period of unconsciousness; it is the most metabolically active window for male cellular repair. ' +
    'This chapter explores how the four stages of sleep regulate testosterone production, how the Hypnogram visualizes recovery, ' +
    'and why deep slow-wave sleep is the foundation of male vitality.'
  );

  engine.addSectionHeader(1, '8.1 Why Sleep Governs Male Testosterone Synthesis', 'The Endocrine Factory of the Night');
  engine.addParagraph(
    'Medical research confirms that over 70% of healthy male testosterone synthesis occurs during deep sleep. A landmark clinical study ' +
    'at the University of Chicago demonstrated that restricting healthy young men to 5 hours of sleep per night for just one week resulted ' +
    'in a 15% reduction in daytime testosterone levels—an endocrine decline equivalent to 10 to 15 years of biological aging.'
  );
  engine.addParagraph(
    'When a man is chronically sleep-deprived, his hypothalamus perceives a state of biological emergency, releasing cortisol (the primary ' +
    'stress hormone). Cortisol actively suppresses luteinizing hormone (LH), the pituitary signal that commands the testes to manufacture ' +
    'testosterone. In short: without quality sleep, male vitality collapses regardless of diet or exercise.'
  );

  engine.addSectionHeader(1, '8.2 The Four Sleep Stages Explained for Everyday Men', 'Understanding the Overnight Cycles');
  engine.addBullet('1. Light Sleep (Stages N1 & N2):', 'The transitional gateway where heart rate slows and body temperature drops. Light sleep accounts for approximately 50-60% of the night, clearing adenosine from brain receptors.');
  engine.addBullet('2. Deep / Slow-Wave Sleep (Stage N3):', 'The golden physiological repair phase. Delta brain waves predominate, blood pressure plummets, and the pituitary gland releases growth hormone. Blood supply to muscles increases, tissue damage is repaired, and testosterone production peaks.');
  engine.addBullet('3. REM Sleep (Rapid Eye Movement):', 'The cognitive restoration phase where vivid dreams occur. The brain processes emotional memories, replenishes neurotransmitters, and consolidates new skills. Healthy men naturally experience nocturnal erections during REM, a key indicator of vascular integrity.');
  engine.addBullet('4. Micro-Awakenings:', 'Brief, often unconscious shifts into wakefulness (lasting 30 to 90 seconds) as the body turns or changes position.');

  engine.addSectionHeader(1, '8.3 The Hypnogram: Visualizing Sleep Architecture', 'Decoding the Overnight Rhythm');
  engine.addParagraph(
    'A normal night of human sleep is not a flat line; it consists of four to six 90-minute ultradian cycles. In the first half of the night, ' +
    'the body prioritizes Deep Sleep (physical recovery). In the second half of the night, REM Sleep (mental recovery) dominates.'
  );
  engine.addParagraph(
    'The Male Vitality sleep module renders an interactive Hypnogram chart that plots these cycles across the night. Rather than merely ' +
    'telling the user "You slept 7 hours," the app reveals whether those 7 hours contained the critical 90+ minutes of deep sleep necessary ' +
    'for hormonal regeneration.'
  );

  engine.addTable(
    ['Sleep Quality Tier', 'Recorded Duration', 'Clinical Implications for Men', 'Vitality Impact'],
    [
      ['Poor Sleep', '< 5.5 Hours', 'Acute testosterone suppression, elevated morning cortisol, impaired glucose tolerance', '-15 to -20 Points'],
      ['Fair Sleep', '5.5 - 6.9 Hours', 'Marginal recovery, subtle cognitive lag, reduced physical stamina', '-5 to -10 Points'],
      ['Good Sleep', '7.0 - 8.5 Hours', 'Optimal endocrine synthesis, full neuromuscular restoration, peak focus', 'Full +25 Points'],
      ['Optimal Recovery', '8.5+ Hours', 'Elite athletic regeneration, complete systemic anti-inflammatory recovery', 'Bonus +5 Points'],
    ],
    [95, 95, 215, 90]
  );

  engine.addSectionHeader(1, '8.4 Sleep Debt & The 7-Day Cumulative Deficit Engine', 'Quantifying Biological Fatigue');
  engine.addParagraph(
    'The human brain does not erase sleep deficits after a single good night. If a man sleeps 5 hours for four consecutive nights ' +
    '(accumulating an 8-hour sleep debt) and then sleeps 9 hours on Saturday, he is still operating with an acute 4-hour deficit. ' +
    'The Male Vitality platform calculates a rolling 7-day Sleep Debt index, warning users when cumulative exhaustion threatens ' +
    'cardiovascular stability and cognitive focus.'
  );

  engine.addSectionHeader(1, '8.5 Medical Myths Debunked: Sleep & Recovery Fallacies', 'Scientific Clarity');
  engine.addBullet('Myth 1: "I can train my body to thrive on four or five hours of sleep."',
    'Biological Reality: Decades of sleep science prove that less than 1% of the population carries the rare DEC2 genetic mutation permitting healthy 5-hour sleep. Men who claim they thrive on 5 hours are simply acclimatized to chronic impairment, suffering blunted reaction times and suppressed endocrine synthesis.');
  engine.addBullet('Myth 2: "Drinking alcohol before bed helps you get deeper sleep."',
    'Biological Reality: Alcohol is a potent sedative, but sedation is not sleep. Alcohol completely abolishes REM sleep and severely fragments slow-wave deep sleep, elevating overnight resting heart rate by 8-12 bpm and suppressing testosterone synthesis by up to 25%.');

  engine.addSectionHeader(1, '8.6 Patient Case Study: Ryan (34, ER Nurse)', 'Restructuring Sleep Around Shift Work');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Ryan (34 Years Old, Adult Cohort)',
    'Ryan, a 34-year-old emergency room nurse, rotated between day and night shifts. He suffered from chronic irritability and brain fog. ' +
    'His Male Vitality sleep hypnogram revealed that while he spent 7 hours in bed after night shifts, his deep slow-wave sleep was fragmented ' +
    'into chaotic 5-minute bursts due to daylight penetrating his bedroom and ambient daytime traffic noise.\n\n' +
    'Male Vitality\'s sleep coaching module recommended targeted shift-worker interventions: 100% blackout blinds, high-density silicone earplugs, ' +
    'and an eye mask, coupled with wearing blue-blocking glasses during his morning commute home. Within two weeks, Ryan\'s deep sleep consolidated ' +
    'from 22 minutes to 1 hour and 15 minutes, his resting HR dropped from 71 to 61 bpm, and his Vitality Index climbed from 48 to 82.'
  );

  // ==========================================
  // CHAPTER 9
  // ==========================================
  engine.addChapterBanner(
    9,
    'CARDIOVASCULAR HEALTH & RESTING HEART RATE',
    'The Body\'s Mechanical Tachometer as an Early-Warning Radar',
    'Heart disease remains the leading cause of premature death in men worldwide. ' +
    'This chapter explores how Resting Heart Rate (RHR) and Heart Rate Variability (HRV) serve as continuous, ' +
    'unobtrusive early-warning sensors, detecting infection, dehydration, and arterial fatigue days before symptoms appear.'
  );

  engine.addSectionHeader(1, '9.1 Resting Heart Rate: The Ultimate Tachometer', 'Understanding Cardiac Workload');
  engine.addParagraph(
    'In an automobile, the tachometer displays how many revolutions per minute (RPM) the engine crankshaft is spinning. ' +
    'A healthy, tuned engine idles at a low, calm RPM. If an engine is idling at 3,000 RPM while parked in neutral, you immediately know ' +
    'the engine is under severe mechanical strain.'
  );
  engine.addParagraph(
    'Resting Heart Rate (RHR) is the human body\'s idle speed. Over a 24-hour day, an RHR of 60 bpm means the heart beats 86,400 times. ' +
    'If a man\'s RHR rises to 80 bpm, his heart must beat 115,200 times per day—an extra 28,800 contractions every single day. Over a year, ' +
    'this represents over 10 million unnecessary heartbeats, placing massive hydraulic stress on arterial walls.'
  );

  engine.addCallout('CLINICAL', 'RHR Drift as an Early Infection Warning', 
    'When the body encounters a viral or bacterial pathogen, the immune system initiates an inflammatory cascade hours before the patient ' +
    'develops a fever or sore throat. This immune activation requires metabolic energy, causing resting heart rate to jump 4 to 8 beats ' +
    'per minute overnight. Male Vitality\'s trend engine detects this sudden spike and issues a "Rest & Hydrate Directive" days before illness peaks.'
  );

  engine.addSectionHeader(1, '9.2 Heart Rate Training Zones: The Tanaka Equation', 'Maximizing Aerobic Capacity Safely');
  engine.addParagraph(
    'To maintain a low resting heart rate, men must periodically train their cardiovascular system across defined intensity zones. ' +
    'The platform calculates age-specific zones using the validated Tanaka formula ($HR_{max} = 208 - (0.7 \\times Age)$):'
  );
  engine.addBullet('Zone 1 (Warm-Up / Recovery, 50-60% HRmax):', 'Stimulates active blood flow, promotes lactic acid clearance, and aids recovery without placing stress on joints.');
  engine.addBullet('Zone 2 (Endurance / Fat-Burning, 60-70% HRmax):', 'The cornerstone of longevity. Builds mitochondrial density, trains muscle fibers to burn fat for fuel, and lowers resting blood pressure.');
  engine.addBullet('Zone 3 (Aerobic Conditioning, 70-80% HRmax):', 'Enhances lung capacity, increases cardiac stroke volume, and improves sustained physical stamina.');
  engine.addBullet('Zone 4 & 5 (Anaerobic / Peak, 80-100% HRmax):', 'High-intensity interval training (HIIT) that increases VO2 max and stimulates human growth hormone release in short, controlled doses.');

  engine.addSectionHeader(1, '9.3 Heart Rate Variability (HRV) Explained Simply', 'The Autonomic Balancing Act');
  engine.addParagraph(
    'Most people assume a healthy heart beats like a metronome with exact millisecond intervals. In reality, a healthy heart exhibits ' +
    'subtle, continuous variation between beats (e.g., 850 ms, then 920 ms, then 780 ms). This phenomenon is Heart Rate Variability (HRV).'
  );
  engine.addParagraph(
    'HRV reflects the healthy tug-of-war between two branches of your autonomic nervous system: the Sympathetic system (the gas pedal, ' +
    'driving stress and alertness) and the Parasympathetic system (the brake pedal, driving rest, recovery, and digestion). High HRV means ' +
    'your body is flexible and resilient, ready to adapt to challenges. Low HRV indicates accumulated exhaustion or systemic stress.'
  );

  engine.addSectionHeader(1, '9.4 Screen Anatomy: The Cardiovascular Trend Graph', 'Interactive Visual Telemetry');
  engine.addParagraph(
    'The Cardiovascular Screen features an interactive touch graph displaying the user\'s resting heart rate over 7-day, 30-day, and ' +
    '90-day horizons. Users can drag their finger along the curve to inspect any past day\'s exact resting pulse. A horizontal shaded ' +
    'emerald corridor indicates their personal baseline. When the line drifts above this corridor, amber or crimson warning markers ' +
    'illuminate, accompanied by a plain-English explanation of potential drivers.'
  );

  engine.addSectionHeader(1, '9.5 Patient Case Study: Kevin (51, Marathon Runner)', 'Catching Over-Training & Viral Onset');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Kevin (51 Years Old, Mid-Life Cohort)',
    'Kevin was training for his third marathon. Three weeks before the race, he planned a grueling 20-mile Sunday training run. ' +
    'On Sunday morning, Male Vitality flashed a high-priority amber card: "Cardiovascular Alert • Resting HR +9 bpm (Elevated from 48 to 57 bpm) • ' +
    'HRV Decreased 38%". Kevin felt physically ready to run, but his wife persuaded him to heed the app\'s directive to substitute the 20-mile run ' +
    'with a gentle 2-mile walk and extra hydration.\n\n' +
    'Your app saved you from months of cardiac injury."'
  );

  engine.addSectionHeader(1, '9.6 Heart Rate Recovery (HRR) at 60 Seconds', 'A Premier Indicator of Autonomic Vagal Tone');
  engine.addParagraph(
    'While peak exercise heart rate measures aerobic capacity, the speed at which your heart decelerates in the first 60 seconds ' +
    'after stopping exertion is one of the most powerful predictors of cardiovascular longevity in clinical cardiology. ' +
    'This metric is called Heart Rate Recovery (HRR).'
  );
  engine.addParagraph(
    'During heavy exercise, the sympathetic "fight-or-flight" nervous system drives heart rate upward. The instant exercise ceases, ' +
    'the parasympathetic "vagal brake" must rapidly reactivate to slow cardiac contractions. In a landmark study published in the ' +
    'New England Journal of Medicine (NEJM), researchers followed thousands of adult men over six years:\n' +
    '• **Normal / Athletic Recovery**: Heart rate drops by **20 beats per minute or more** within the first 60 seconds.\n' +
    '• **Impaired Vagal Tone**: Heart rate drops by **12 bpm or fewer** within 60 seconds, which was associated with a fourfold increase ' +
    'in all-cause cardiovascular mortality, even after adjusting for age and cholesterol.'
  );
  engine.addParagraph(
    'Male Vitality automatically captures this post-workout deceleration whenever a paired wearable records an exercise session, ' +
    'displaying your 60-second HRR recovery delta on the workout telemetry card.'
  );

  // ==========================================
  // CHAPTER 10
  // ==========================================
  engine.addChapterBanner(
    10,
    'THE CONFIDENTIAL PRIVATE VAULT & PIN SECURITY',
    'Hardware-Backed Isolation for Ultra-Sensitive Sexual Health Records',
    'Men frequently avoid digital tracking of reproductive and sexual health due to fears of data breaches or embarrassment. ' +
    'This chapter explains the Private Vault architecture, how the local 4-digit PIN creates a bank-grade barrier, ' +
    'and why zero plain-text cloud exposure is guaranteed.'
  );

  engine.addSectionHeader(1, '10.1 The Privacy & Stigma Dilemma in Men\'s Health', 'Why General Cloud Sync is Inappropriate');
  engine.addParagraph(
    'While a man is happy to share his daily step counts or calorie burns with friends or colleagues, the idea of having his ' +
    'erectile function audits, testosterone laboratory reports, or semen analysis parameters stored in an unencrypted general feed ' +
    'causes intense psychological discomfort. If a friend or coworker borrows his smartphone to make a call, the fear that a notification ' +
    'or screen might display private reproductive details creates a powerful barrier to care.'
  );

  engine.addSectionHeader(1, '10.2 The Vault Solution: Local Hardware Encryption', 'The Digital Safe Deposit Box');
  engine.addParagraph(
    'Male Vitality solved this through a strict architectural segregation called the **Confidential Private Vault**. ' +
    'The vault functions like a physical safe deposit box anchored inside the secure hardware enclave of the user\'s personal phone.'
  );
  engine.addParagraph(
    'When the user opens the Sexual Health or Fertility modules, the app presents an interactive security sheet: "Confidential Vault Security". ' +
    'The patient must enter their personal 4-digit PIN. Without this PIN, the screen cannot render sensitive records, and the underlying data ' +
    'remains an unreadable, AES-256 encrypted binary blob on the device storage.'
  );

  engine.addCallout('SECURITY', 'Zero Plaintext Cloud Sharing Architecture', 
    'Unlike generic health platforms that upload every sensitive note to shared cloud analytics, Male Vitality enforces zero plaintext ' +
    'cloud storage for vault records. Highly personal reproductive records are either stored locally within the phone\'s encrypted ' +
    'sandbox or transmitted only as end-to-end encrypted payloads accessible solely by the patient\'s PIN.'
  );

  engine.addSectionHeader(1, '10.3 Vault PIN Workflow: Set, Verify & Reset', 'Step-by-Step Flow');
  engine.addFlowchart([
    { label: 'Step 1: Patient Taps "Private Vault"', desc: 'Triggers security sheet modal; checks if a PIN has been initialized' },
    { label: 'Step 2: Interactive 4-Digit PIN Entry', desc: 'Patient enters PIN via high-contrast cyber-styled security keypad' },
    { label: 'Step 3: Hardware Verification Check', desc: 'Validates input against AES-256 hashed secret in local encrypted storage' },
    { label: 'Step 4: Vault Decryption & Access', desc: 'Unlocks confidential sexual health, testosterone, and fertility modules for the session' }
  ]);

  engine.addSectionHeader(1, '10.4 Auto-Lock & Background Concealment Mechanics', 'Immediate Privacy Protection');
  engine.addParagraph(
    'A frequent vulnerability in mobile health applications is "app-switcher leakage"—when a user switches to another app, the operating ' +
    'system takes a screenshot of the current view and displays it in the multitasking carousel. If the user had a semen analysis open, ' +
    'anyone glancing at their screen could read the confidential report.'
  );
  engine.addParagraph(
    'Male Vitality prevents this via automated lifecycle listeners. The instant the app loses foreground focus (e.g., when the user swipes ' +
    'up to go home or switches apps), the platform immediately blurs the viewport with an opaque frosted privacy shield and re-locks the vault. ' +
    'When the app is reopened, the patient must re-authenticate with their PIN or fingerprint.'
  );

  engine.addSectionHeader(1, '10.5 Medical Myths Debunked: Health Data Security', 'Protecting What Matters');
  engine.addBullet('Myth 1: "My phone already has a lock screen password, so health apps don\'t need extra PINs."',
    'Biological Reality: You frequently unlock your phone to show a family photo, hand your phone to a friend to enter a GPS address, or let a child play a game. A secondary hardware PIN vault guarantees that unlocking your phone does not expose your intimate reproductive records.');
  engine.addBullet('Myth 2: "Storing health records in the cloud is always safer than on your phone."',
    'Biological Reality: Centralized cloud medical databases are high-value targets for ransomware cartels and data breaches. Storing encrypted records locally on your device hardware eliminates the centralized honeypot risk entirely.');

  engine.addSectionHeader(1, '10.6 Hardware Biometric Authentication: Fingerprint & Facial Recognition', 'Instant Convenience with Hardware Enclave Security');
  engine.addParagraph(
    'To make daily vault access effortless while preserving impenetrable security, Male Vitality integrates directly with the ' +
    'Android `BiometricPrompt` API. Rather than typing a 4-digit PIN every single time, patients can unlock their confidential ' +
    'vault using their registered device fingerprint or facial geometry sensor.'
  );
  engine.addParagraph(
    'Crucially, biometric data is never seen, processed, or stored by the Male Vitality application. The Android operating system ' +
    'authenticates the biometric template within its isolated Hardware Security Module (HSM). Upon successful match, the OS releases ' +
    'a cryptographically bound `CryptoObject` that unlocks the local AES-256 cipher. If biometric recognition fails three times, the ' +
    'platform immediately falls back to requiring the master 4-digit PIN.'
  );

  // ==========================================
  // CHAPTER 11
  // ==========================================
  engine.addChapterBanner(
    11,
    'SEXUAL & HORMONAL HEALTH MODULE',
    'Understanding Testosterone Kinetics, Vascular Mechanics & IIEF-5',
    'Sexual health is the ultimate clinical barometer of systemic male cardiovascular and metabolic vitality. ' +
    'This chapter explores the biology of testosterone, how erectile function reflects arterial integrity, ' +
    'and how the validated IIEF-5 scoring system empowers men to take proactive control.'
  );

  engine.addSectionHeader(1, '11.1 Erectile Function as the "Canary in the Coal Mine"', 'The Vascular Connection');
  engine.addParagraph(
    'In traditional coal mining, miners brought a canary into the tunnels. Because canaries have delicate respiratory systems, ' +
    'they showed distress at the slightest trace of toxic gas hours before miners felt any symptoms, providing life-saving early warning.'
  );
  engine.addParagraph(
    'In the male body, erectile function is the cardiovascular canary in the coal mine. The penile arteries are tiny, measuring approximately ' +
    '1 to 2 millimeters in diameter, compared to the coronary arteries supplying the heart (3 to 4 mm) and the carotid arteries to the brain (5 to 7 mm). ' +
    'When systemic plaque accumulation, endothelial dysfunction, or high blood pressure begin to damage blood vessels, the smallest arteries ' +
    'fail first.'
  );
  engine.addParagraph(
    'Cardiologists now recognize that erectile dysfunction (ED) frequently precedes a major coronary event or heart attack by 3 to 5 years. ' +
    'Addressing sexual health is not merely a matter of lifestyle or intimacy—it is an urgent preventive window for life-saving cardiovascular intervention.'
  );

  engine.addSectionHeader(1, '11.2 The IIEF-5 Clinical Scoring System', 'Objective Evidence-Based Assessment');
  engine.addParagraph(
    'Rather than relying on vague subjective questions, Male Vitality integrates the internationally validated **International Index of ' +
    'Erectile Function (IIEF-5)**. This 5-question clinical tool evaluates confidence, erection firmness, maintenance capacity, and satisfaction, ' +
    'generating a score from 5 to 25:'
  );

  engine.addTable(
    ['IIEF-5 Score Range', 'Clinical Classification', 'Recommended Action & Guidance'],
    [
      ['22 - 25 Points', 'Normal / Optimal Function', 'Maintain healthy lifestyle, regular aerobic exercise & sleep hygiene.'],
      ['17 - 21 Points', 'Mild Dysfunction', 'Review cardiovascular risk factors, reduce alcohol & examine sleep quality.'],
      ['12 - 16 Points', 'Mild-to-Moderate Dysfunction', 'Schedule clinical cardiovascular audit (lipid panel, BP check, fasting glucose).'],
      ['8 - 11 Points', 'Moderate Dysfunction', 'Specialist urological consultation recommended; review prescription drug side effects.'],
      ['5 - 7 Points', 'Severe Dysfunction', 'Comprehensive medical evaluation for underlying arterial or endocrine disorders.'],
    ],
    [95, 135, 265]
  );

  engine.addSectionHeader(1, '11.3 Testosterone Dynamics & Circadian Peaks', 'Optimizing the Master Male Hormone');
  engine.addParagraph(
    'Testosterone influences virtually every system in the male body: muscle mass retention, visceral fat regulation, bone mineral density, ' +
    'red blood cell production, mood, and cognitive drive. Natural testosterone synthesis follows a diurnal curve, peaking sharply ' +
    'between 7:00 AM and 9:00 AM before tapering toward evening.'
  );
  engine.addParagraph(
    'Male Vitality provides actionable non-pharmacological directives to optimize natural testosterone levels: maintaining adequate zinc ' +
    'and Vitamin D intake, lifting weights with compound movements, avoiding prolonged scrotal heat, and prioritizing deep sleep.'
  );

  engine.addSectionHeader(1, '11.4 Non-Pharmaceutical Lifestyle Protocols', 'Empowering Natural Recovery');
  engine.addParagraph(
    'When mild or moderate sexual health issues emerge, pharmaceutical solutions (like PDE5 inhibitors) treat symptoms without fixing ' +
    'the underlying vascular plumbing. Male Vitality provides four validated lifestyle protocols proven to restore arterial blood flow:'
  );
  engine.addBullet('1. Dietary Nitric Oxide Precursors:', 'Consuming foods rich in dietary nitrates (beets, arugula, pomegranate, garlic) stimulates endothelial nitric oxide synthase, dilating blood vessels naturally.');
  engine.addBullet('2. Pelvic Floor Conditioning (Kegel / Reverse-Kegel):', 'Strengthening the bulbocavernosus and ischiocavernosus muscles enhances venous occlusion, helping maintain firmness.');
  engine.addBullet('3. Insulin Sensitivity Optimization:', 'High circulating insulin directly damages arterial linings. Shifting to whole foods and daily Zone 2 walking reverses endothelial resistance.');
  engine.addBullet('4. Psychological Stress De-escalation:', 'Sympathetic adrenaline surges trigger severe vasoconstriction. Practicing 4-7-8 breathing lowers cortisol and restores parasympathetic tone.');

  engine.addSectionHeader(1, '11.5 Patient Case Study: James (42, Accountant)', 'Reversing Endothelial Dysfunction');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: James (42 Years Old, Mid-Life Cohort)',
    'James noticed a gradual decline in firmness over six months. Ashamed and embarrassed, he kept it secret from his wife and doctor. ' +
    'After locking his Male Vitality vault with a PIN, he completed the confidential IIEF-5 questionnaire. His score came out to 14 ' +
    '("Mild-to-Moderate Dysfunction"). Rather than shaming him, the app clearly explained the vascular connection: "Penile blood vessels ' +
    'are your early warning radar. Let us optimize your cardiovascular plumbing."\n\n' +
    'James followed the app\'s lifestyle directives: he eliminated evening alcohol, walked 8,000 steps daily, added dietary nitrates, ' +
    'and prioritized 7.5 hours of sleep. Three months later, a repeat IIEF-5 audit showed his score had climbed to 23 ("Normal Function"). ' +
    'More importantly, his resting HR dropped from 76 to 63 bpm and his blood pressure normalized, restoring both his health and his confidence.'
  );

  // ==========================================
  // CHAPTER 12
  // ==========================================
  engine.addChapterBanner(
    12,
    'REPRODUCTIVE HEALTH: WHO 6TH EDITION AUDIT',
    'Demystifying Semen Analysis & Lifestyle Fertility Optimization',
    'Male factor infertility contributes to over 50% of couples struggling to conceive, yet it remains shrouded in taboo. ' +
    'This chapter breaks down the World Health Organization (WHO) 6th Edition reference standards, ' +
    'explaining sperm count, motility, and morphology in clear, reassuring terms.'
  );

  engine.addSectionHeader(1, '12.1 The Global Decline in Male Fertility', 'Why Continuous Monitoring Matters');
  engine.addParagraph(
    'Extensive peer-reviewed epidemiological studies demonstrate that average human sperm counts have declined by over 50% over the last ' +
    'five decades. Factors such as endocrine-disrupting chemicals (microplastics, phthalates), sedentary desk work, poor sleep, and poor diets ' +
    'exert continuous oxidative stress on the male reproductive system.'
  );
  engine.addParagraph(
    'Fortunately, spermatogenesis—the complete cycle of sperm cell creation—takes approximately 74 days. This means that a man who adopts ' +
    'healthier lifestyle habits can witness a complete, measurable rejuvenation of his reproductive parameters in less than three months.'
  );

  engine.addSectionHeader(1, '12.2 The Four Core WHO 6th Edition Parameters', 'What a Semen Analysis Report Means');
  engine.addBullet('1. Semen Volume (Normal: >= 1.4 mL):', 'The total fluid produced during ejaculation, composed of secretions from the prostate, seminal vesicles, and bulbourethral glands that nourish and transport sperm.');
  engine.addBullet('2. Total Sperm Concentration (Normal: >= 16 Million / mL):', 'The density of sperm cells within each milliliter of semen. Adequate concentration ensures a sufficient population capable of navigating the female reproductive tract.');
  engine.addBullet('3. Total Motility (Normal: >= 42% Motile):', 'The percentage of sperm that are actively moving. Progressive motility (sperm swimming in a straight line or large circles) is essential for successful egg fertilization.');
  engine.addBullet('4. Normal Morphology (Normal: >= 4% Normal Form):', 'Evaluates the physical shape of the sperm head, midpiece, and tail. Because nature produces many misshapen cells, having at least 4% with ideal structure meets strict WHO clinical reference standards.');

  engine.addTable(
    ['WHO Clinical Classification', 'Diagnostic Criteria', 'Plain-English Meaning'],
    [
      ['Normozoospermia', 'All parameters meet or exceed WHO reference limits', 'Fully normal, healthy reproductive sample.'],
      ['Oligozoospermia', 'Sperm concentration is below 16 million / mL', 'Lower sperm count; focus on lifestyle & endocrine factors.'],
      ['Asthenozoospermia', 'Total motility is below 42%', 'Sperm movement is sluggish; check scrotal heat & antioxidants.'],
      ['Teratozoospermia', 'Normal morphology is below 4%', 'Higher proportion of irregular sperm shapes; reduce oxidative stress.'],
    ],
    [130, 195, 170]
  );

  engine.addSectionHeader(1, '12.3 The Fertility Lifestyle Optimization Score (0 - 100)', 'Practical Guidance for Men');
  engine.addParagraph(
    'Inside the Reproductive Health module, Male Vitality calculates an interactive **Fertility Lifestyle Optimization Score** ' +
    'based on modifiable environmental factors:'
  );
  engine.addBullet('Scrotal Temperature Management (+25 Pts):', 'Avoiding hot tubs, saunas, laptops resting directly on the lap, and excessively tight compression shorts. Sperm manufacturing requires temperatures 2 to 4°C below core body heat.');
  engine.addBullet('Antioxidant Defense (+25 Pts):', 'Ensuring sufficient intake of Vitamin C, Vitamin E, Selenium, and CoQ10 to protect delicate sperm cell membranes from free-radical oxidation.');
  engine.addBullet('Substance Moderation (+25 Pts):', 'Limiting alcohol and eliminating tobacco/vaping. Nicotine is a potent vasoconstrictor that directly reduces sperm motility and damages DNA integrity.');
  engine.addBullet('Sleep & Physical Conditioning (+25 Pts):', 'Targeting 7.5 hours of restorative sleep to maintain optimal gonadotropin-releasing hormone (GnRH) signaling.');

  engine.addSectionHeader(1, '12.4 Environmental & Lifestyle Threat Audit', 'Silent Killers of Sperm Quality');
  engine.addParagraph(
    'Modern urban environments subject men to subtle endocrine-disrupting chemicals that impair sperm DNA fragmentation. ' +
    'Male Vitality provides a practical avoidance checklist:\n' +
    '• Eliminate drinking hot liquids from single-use plastic cups or microwaving food in plastic containers.\n' +
    '• Avoid carrying hot laptop computers directly on your lap (the heat from the battery and processor quickly elevates scrotal temperature by 3°C).\n' +
    '• Swap tight synthetic cycling or compression briefs for loose, breathable natural fibers (such as bamboo or organic cotton) during sleep.'
  );

  engine.addSectionHeader(1, '12.5 Patient Case Study: Ethan (29, Newlywed)', 'Overcoming Sub-Fertility Through Lifestyle Changes');
  engine.addCallout('PATIENT_STORY', 'Patient Case Study: Ethan (29 Years Old, Adult Cohort)',
    'Ethan and his wife had been trying to conceive for 10 months without success. Ethan\'s clinic semen analysis reported a concentration ' +
    'of 11 million sperm/mL and motility of 28%—placing him in the Oligoasthenozoospermia category. Ethan felt crushed and despondent.\n\n' +
    'Recording his lab parameters in Male Vitality\'s private fertility module, the platform highlighted Ethan\'s work habits: as a software ' +
    'developer, Ethan worked 10 hours a day with a hot MacBook resting directly on his lap, drank five cups of coffee, and soaked in a hot tub ' +
    'every evening to unwind.\n\n' +
    'The app presented the 74-day spermatogenesis recovery roadmap. Ethan switched to a desk mount, stopped hot tub soaking, began taking ' +
    'CoQ10 and Vitamin C, and prioritized 8 hours of sleep. Exactly 80 days later, a repeat semen analysis revealed his sperm concentration ' +
    'had surged to 42 million/mL with 58% motility, achieving full Normozoospermia. Four months later, his wife conceived naturally.'
  );
}

module.exports = buildPart2;
