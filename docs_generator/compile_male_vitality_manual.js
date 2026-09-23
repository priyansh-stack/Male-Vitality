// docs_generator/compile_male_vitality_manual.js
// Master compiler script for the 50+ page Male Vitality Platform Manual

const path = require('path');
const fs = require('fs');

const PDFEngine = require('./pdf_engine');
const buildPart1 = require('./chapters_part1');
const buildPart2 = require('./chapters_part2');
const buildPart3 = require('./chapters_part3');
const buildAppendices = require('./appendices');

const outputDir = path.resolve(__dirname, '../docs');
if (!fs.existsSync(outputDir)) {
  fs.mkdirSync(outputDir, { recursive: true });
}

const outputPath = path.join(outputDir, 'Male_Vitality_Comprehensive_Platform_Guide.pdf');
console.log('Compiling Male Vitality Platform Manual to:', outputPath);

const engine = new PDFEngine(outputPath);

// 1. Cover Page
engine.addCoverPage({
  title: 'MALE VITALITY',
  subtitle: 'Clinical Platform Architecture, Decision Rationale & Biometric Telemetry Manual',
  targetAudience: 'Patients, Clinicians, Investors, Non-Technical Leadership & Reviewers',
  version: 'v1.0.0 Production Release',
  date: 'September 2026',
});

// 2. Executive Manifesto & Platform Vision
engine.addExecutiveManifesto();

// 3. System Architecture & Subsystem Topology Map
engine.addSystemArchitectureOverview();

// 4. Table of Contents (Part I and Part II)
const part1Chapters = [
  { title: 'The Urgent Need: Transforming Men\'s Health', subtitle: 'Overcoming Clinical Inertia through Continuous Passive Telemetry' },
  { title: 'The Male-Exclusive Biometric Cohort', subtitle: 'Why Dedicated XY Physiology Architecture is Clinically Essential' },
  { title: 'System Architecture & Digital Clinic Foundation', subtitle: 'How Flutter, BLoC, and Local Encryption Form an Unbreakable Platform' },
  { title: 'Onboarding & Identity: Zero-Friction Calibration', subtitle: 'How Google Sign-In and People API Eliminate Registration Fatigue' },
  { title: 'The Demographics Engine: Age, DOB & 5 Life Stages', subtitle: 'Clinical Precision in Birthdate Resolution and Cohort Architecture' },
  { title: 'The Clinical Command HUD (Main Dashboard)', subtitle: 'Decoding the Vitality Index: Cardio, Metabolic, Sleep & Mindset' },
  { title: 'Wearable Telemetry & The Fitbit Data Bridge', subtitle: 'How Continuous Biosignals Flow Seamlessly from Wrist to Cloud' },
  { title: 'Sleep Architecture & Hormonal Recovery', subtitle: 'The Supreme Biological Engine of Male Testosterone and Restoration' },
];

const part2Chapters = [
  { title: 'Cardiovascular Health & Resting Heart Rate', subtitle: 'The Body\'s Mechanical Tachometer as an Early-Warning Radar' },
  { title: 'The Confidential Private Vault & PIN Security', subtitle: 'Hardware-Backed Isolation for Ultra-Sensitive Sexual Health Records' },
  { title: 'Sexual & Hormonal Health Module', subtitle: 'Understanding Testosterone Kinetics, Vascular Mechanics & IIEF-5' },
  { title: 'Reproductive Health: WHO 6th Edition Audit', subtitle: 'Demystifying Semen Analysis & Lifestyle Fertility Optimization' },
  { title: 'Clinical Preventive Care & Screening Engine', subtitle: 'Evidence-Based Automated Guidelines from USPSTF Standards' },
  { title: 'Mental Wellness, Stress & Crisis Support', subtitle: 'Breaking the Culture of Silence with Continuous Emotional Anchors' },
  { title: 'Cloud Notifications & FCM Alert Pipeline', subtitle: 'Bi-Directional Telemetry for Critical Biomarker Alerts' },
  { title: 'Complete Architectural & Clinical Decisions', subtitle: 'Exhaustive Rationale Behind Every Technical and Medical Choice' },
  { title: 'Stakeholder FAQ, Glossary & Release Sign-Off', subtitle: 'Plain-English Reference and Official Verification Certificate' },
  { title: 'Appendix A: Patient Intake & Discussion Guide', subtitle: 'Practical Clinical Consultations & Lifestyle Assessment' },
  { title: 'Appendix B: Regulatory & Security Whitepaper', subtitle: 'HIPAA Safeguards, AES-256 Storage & Cryptographic Verification' },
  { title: 'Appendix C: Micronutrient & Pharmacotherapy', subtitle: 'Hormonal Synthesis Protocols & Medication Interactions' },
];

engine.addTableOfContents(part1Chapters, part2Chapters);

// 3. Build Chapters
console.log('Building Part 1 (Chapters 1 - 6)...');
buildPart1(engine);

console.log('Building Part 2 (Chapters 7 - 12)...');
buildPart2(engine);

console.log('Building Part 3 (Chapters 13 - 17, FAQ, Glossary)...');
buildPart3(engine);

console.log('Building Appendices (A: Patient Intake Guide, B: Security Whitepaper)...');
buildAppendices(engine);

// 4. Finalize Headers, Footers & Output
engine.finalizeHeadersAndFooters();

engine.writeStream.on('finish', () => {
  console.log(`\n==============================================`);
  console.log(`MANUAL COMPILED SUCCESSFULLY!`);
  console.log(`Total Pages Generated: ${engine.totalPages}`);
  console.log(`Output Path: ${outputPath}`);
  console.log(`==============================================\n`);
});
