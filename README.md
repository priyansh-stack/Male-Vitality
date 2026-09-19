# Male Vitality

A Life-Stage Adaptive Health and Longevity Platform for Men.

---

## Executive Summary

Male Vitality is an evidence-informed digital health application engineered specifically to address male physical, hormonal, cardiovascular, mental, and reproductive health across all adult life stages.

Built with Flutter, Dart, and Google Cloud Firestore, the application uses a dynamic Life-Stage Adaptive Rules Engine that evaluates biometrics, subjective assessments, and age demographics to personalize clinical guidance, preventive screening schedules, and daily wellness priorities.

---

## Core Capabilities

### 1. Life-Stage Adaptive Engine
The core rules engine evaluates user parameters across four distinct clinical brackets:
- **Young Adulthood (Ages 18–29)**: Baseline metabolic tracking, physical conditioning, reproductive baseline, stress modulation, and substance awareness.
- **Prime Vitality (Ages 30–44)**: Early cardiovascular disease risk detection, metabolic flexibility, testosterone and endocrine balance, stress management, and fertility tracking.
- **Midlife Transition (Ages 45–59)**: Cardiovascular risk stratification, prostate screening protocols (PSA/DRE), metabolic syndrome mitigation, and sleep architecture maintenance.
- **Mature Longevity (Ages 60+)**: Musculoskeletal health, cognitive reserve, bone density preservation, vascular health, and age-specific preventive oncology screenings.

### 2. Clinical Vitals and Biometric Telemetry
- **Holistic Vitality Score**: Real-time synthesized index derived from sleep efficiency, resting heart rate, physical activity, blood pressure, and mental wellness entries.
- **Abnormal Alert Monitoring**: Immediate flagging of anomalous physiological metrics, including hypertensive thresholds, resting tachycardia/bradycardia, and sustained sleep deficit.
- **Longitudinal Trend Visualizations**: Multi-period historical charts (Daily, Weekly, Monthly, Yearly) to monitor trends over time.
- **Unified Health Metric Logging**: Structured logging for blood pressure (systolic/diastolic), resting heart rate, blood glucose, and body mass index.

### 3. Mental Health and Crisis Intervention
- **Validated Psychological Check-Ins**: Regular scoring of valence, anxiety, stress indicators, and sleep-mood correlations.
- **Algorithmic Risk Pattern Analysis**: Automated detection of concerning downward trajectories aligned with standardized clinical assessment patterns (PHQ/GAD indicators).
- **Emergency Crisis Lifeline Integration**: Direct routing to national crisis resources (including the 988 Suicide and Crisis Lifeline).
- **Guided Exercise and Audio Streaming**: In-app audio player for box breathing, progressive muscle relaxation, and mindfulness exercises.

### 4. Sexual and Reproductive Health
- **Fertility Tracking**: Quantitative logging for semen analysis parameters, including total sperm count, progressive motility, morphology, and semen volume.
- **Lifestyle Correlation Engine**: Analysis of how sleep deprivation, alcohol intake, strenuous exercise, and stress levels correlate with libido and reproductive markers.
- **Clinical Educational Modules**: Evidence-based medical literature addressing testicular health, hormonal balance, varicocele awareness, and erectile physiology.

### 5. Sleep Architecture and Circadian Optimization
- **Sleep Staging Breakdown**: Detailed metrics covering total sleep time, deep sleep duration, REM cycles, and sleep latency.
- **Sleep Efficiency Index**: Calculation of percentage time asleep versus total time in bed.
- **Personalized Sleep Hygiene**: Data-driven recommendations to stabilize circadian rhythms based on daily logging patterns.

### 6. Fitness, Recovery, and Nutrition
- **Strength and Conditioning Tracking**: Workout logging categorized by resistance, cardiovascular, and mobility disciplines.
- **Macronutrient Precision Tracking**: Calorie, protein, carbohydrate, and fat tracking customized to activity levels and metabolic goals.
- **Hydration Logging**: Daily fluid intake monitoring with goal progression.

### 7. Preventive Screenings and Telehealth
- **Preventive Care Protocols**: Evidence-aligned schedules for lipid panels, colorectal screenings, diabetes testing, and prostate evaluations based on USPSTF guidelines.
- **Clinical Summary Export (PDF)**: Automated generation of structured, multi-page clinical health summaries formatted for physician consultations.
- **Telehealth Consultation Hub**: Scheduling, provider communication, and preparation checklist for virtual appointments.

---

## Technical Architecture

The application is structured following Clean Architecture principles, ensuring separation of concerns, testability, and maintainability:

```
lib/
├── core/
│   ├── bloc/              # Global application state (AuthBloc, OnboardingBloc, DashboardBloc)
│   ├── engine/            # Life-stage adaptive clinical rules engine and thresholds
│   ├── models/            # Core domain entities (HealthMetric, BloodPressure, HealthDaily)
│   ├── services/          # Infrastructure services (Firebase, Firestore, Database, Audio, PDF)
│   └── theme/             # Material Design 3 theme system (Light and Dark themes)
├── features/
│   ├── auth/              # Authentication and identity management
│   ├── dashboard/         # Health score, abnormal alerts, metric grids, trend charts
│   ├── fitness_nutrition/ # Workout logging, macronutrient tracking, and repositories
│   ├── health_modules/    # Clinical module navigation and catalog
│   ├── learn/             # Health literacy and evidence-based articles
│   ├── medication/        # Medication and supplement scheduling
│   ├── mental_wellness/   # Mood logging, trend analysis, crisis safety, and guided audio
│   ├── onboarding/        # Multi-stage profile intake and permission requests
│   ├── preventive_care/   # Preventive screening protocols and schedule tracking
│   ├── profile/           # User configuration, security settings, and data exports
│   ├── sexual_health/     # Fertility parameters, semen analysis, and libido logging
│   ├── sleep/             # Sleep staging, efficiency analysis, and optimization
│   ├── substance_use/     # Substance and alcohol assessments with moderation tools
│   ├── telehealth/        # Virtual appointment scheduling and doctor communication
│   └── track/             # Unified multi-metric tracking interface
└── router/                # Declarative routing powered by GoRouter
```

### Technology Stack
- **Framework**: Flutter (SDK ^3.12.2 / Flutter 3.47+)
- **Language**: Dart (SDK ^3.12.2)
- **State Management**: BLoC Pattern (`flutter_bloc`, `bloc`, `hydrated_bloc`)
- **Backend & Cloud Infrastructure**: Firebase Authentication, Google Cloud Firestore, Google Sign-In
- **Routing**: `go_router`
- **Document Generation**: `pdf`, `printing`, `path_provider`
- **Hardware & Peripherals**: `health` (Health Connect / HealthKit bridge), `audioplayers`
- **Local Persistence**: `shared_preferences`, encrypted storage abstractions

---

## Data Model and Security Architecture

### Cloud Firestore Structure
The database enforces strict tenant isolation and logical segregation:

```
users/{uid}/
├── common/
│   └── profile/account                # Shared demographic profile and preferences
├── shared_health/
│   ├── daily/{date}                   # Daily aggregates (steps, calories, sleep, resting HR)
│   ├── heart_rate/{timestamp}         # Time-series pulse telemetry
│   └── sleep/{sessionId}              # Sleep staging records
└── apps/
    └── male_vitality/
        ├── onboarding/state           # Completed onboarding checkpoints
        ├── mood_entries/{id}          # Mental wellness logs
        ├── semen_analyses/{id}        # Reproductive lab records
        └── workouts/{id}              # Exercise sessions
```

### Security and Credential Safeguards
- **Zero Hardcoded Secrets**: Credentials, keystores, and sensitive configuration files are excluded from version control via `.gitignore`.
- **Environment Variable Fallback**: Fallback API configurations dynamically resolve environment variables at compile time (`String.fromEnvironment`) rather than storing raw secrets.
- **Role-Based Security Rules**: Firestore security rules restrict all document reads and writes strictly to the authenticated owner (`request.auth.uid == uid`).
- **Signing Key Separation**: Production keystores are referenced through external `key.properties` or environment variables, with automated fallbacks for continuous integration runners.

---

## Getting Started

### Prerequisites
- Flutter SDK (version 3.47.2 or higher)
- Dart SDK (version 3.13.2 or higher)
- Android Studio / VS Code with Flutter and Dart plugins
- JDK 17 or JDK 21

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/priyansh-stack/Male-Vitality.git
   cd Male-Vitality
   ```

2. **Retrieve dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Place the project `google-services.json` inside the `android/app/` directory.
   - Verify that Firebase Authentication (Email/Password, Google Provider) and Cloud Firestore are active in the target Firebase project.

4. **Execute in Debug Mode**:
   ```bash
   flutter run
   ```

---

## Release Builds and CI/CD

### Building the Release APK
To compile the production release binary:

```bash
flutter build apk --release
```

The output artifact is generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Keystore Configuration
For custom release signing, populate `android/key.properties`:
```properties
storePassword=<KEYSTORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=<KEY_ALIAS>
storeFile=<ABSOLUTE_OR_RELATIVE_PATH_TO_KEYSTORE>
```

When building in automated CI pipelines (e.g., GitHub Actions), the Gradle configuration gracefully defaults to debug signing if the local release keystore is absent, preventing build pipeline failures while maintaining production security.

---

## Verification and Testing

Run the test suite:
```bash
flutter test
```

Perform static analysis:
```bash
flutter analyze
```

---

## Medical Disclaimer

Male Vitality is intended for informational, educational, and self-monitoring purposes only. The software does not provide medical diagnoses, treatment plans, or formal clinical prescriptions. Users should always consult a licensed medical professional or physician for clinical decisions and medical concerns.

---

## License

Copyright (c) Male Vitality. All rights reserved. Proprietary and confidential.
