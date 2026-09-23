// docs_generator/pdf_engine.js
// Core layout, styling, and rendering engine for Male Vitality Platform Manual

const PDFDocument = require('pdfkit');
const fs = require('fs');
const path = require('path');

class PDFEngine {
  constructor(outputPath) {
    this.outputPath = outputPath;
    this.doc = new PDFDocument({
      size: 'A4',
      margins: { top: 50, bottom: 50, left: 50, right: 50 },
      bufferPages: true,
      autoFirstPage: false,
    });

    this.writeStream = fs.createWriteStream(outputPath);
    this.doc.pipe(this.writeStream);

    // Color Palette
    this.colors = {
      primaryNavy: '#0A192F',
      secondaryNavy: '#1E293B',
      accentCyan: '#0284C7',
      accentEmerald: '#059669',
      accentAmber: '#D97706',
      accentPurple: '#7C3AED',
      accentRose: '#E11D48',
      textDark: '#0F172A',
      textMuted: '#475569',
      borderSubtle: '#CBD5E1',
      bgLight: '#F8FAFC',
      bgCard: '#F1F5F9',
      white: '#FFFFFF',
    };

    this.pageWidth = 595.28;
    this.pageHeight = 841.89;
    this.contentWidth = this.pageWidth - 100; // 495.28
    this.contentBottom = this.pageHeight - 60;
  }

  ensureSpace(neededHeight) {
    if (this.doc.y + neededHeight > this.contentBottom) {
      this.doc.addPage();
      this.doc.y = 65;
    }
  }

  addCoverPage({ title, subtitle, targetAudience, version, date }) {
    this.doc.addPage();
    const doc = this.doc;

    // Background Gradient / Solid Deep Navy
    doc.rect(0, 0, this.pageWidth, this.pageHeight).fill(this.colors.primaryNavy);

    // Decorative Accent Header Bar
    doc.rect(50, 60, 8, 80).fill(this.colors.accentCyan);

    // Title
    doc.fillColor(this.colors.white)
      .font('Helvetica-Bold')
      .fontSize(32)
      .text('MALE VITALITY', 70, 65, { characterSpacing: 1.5 });

    doc.fillColor(this.colors.accentCyan)
      .font('Helvetica-Bold')
      .fontSize(16)
      .text('CLINICAL PLATFORM ARCHITECTURE & DECISION MANUAL', 70, 105, { characterSpacing: 1 });

    doc.fillColor('#94A3B8')
      .font('Helvetica')
      .fontSize(11)
      .text('Comprehensive Systems Engineering, Biometric Rationale & Plain-English Health Guide', 70, 128);

    // Decorative Divider Line
    doc.moveTo(50, 160).lineTo(this.pageWidth - 50, 160).lineWidth(1.5).strokeColor(this.colors.accentCyan).stroke();

    // Central Card
    doc.roundedRect(50, 190, this.contentWidth, 360, 12).fill('#112240');
    doc.roundedRect(50, 190, this.contentWidth, 360, 12).lineWidth(1).strokeColor('#233554').stroke();

    let cy = 215;
    doc.fillColor(this.colors.accentEmerald).font('Helvetica-Bold').fontSize(13).text('EXECUTIVE PURPOSE & DESIGN MANDATE', 75, cy);
    cy += 25;

    const summaryText = 
      'This clinical manual provides a comprehensive, non-technical exploration of the Male Vitality platform. ' +
      'It breaks down every architectural decision, data pathway, clinical rule, and user experience flow into clear, ' +
      'accessible language. Whether you are a patient, healthcare provider, clinical investigator, or non-technical stakeholder, ' +
      'this guide explains WHY each feature was built, HOW biometric signals travel securely from body to screen, and ' +
      'WHAT clinical safeguards protect male physical and reproductive longevity.';

    doc.fillColor('#E2E8F0').font('Helvetica').fontSize(10.5).text(summaryText, 75, cy, { width: this.contentWidth - 50, lineGap: 5 });
    cy += 110;

    // Key Pillars Table inside Card
    const pillars = [
      { label: 'XY Biometric Focus', desc: 'Exclusive male hormonal rhythms, cardiovascular timelines & health architecture.' },
      { label: 'Continuous Telemetry', desc: 'Real-time Fitbit & Health Connect integration with zero manual logging friction.' },
      { label: 'Confidential Local Vault', desc: 'Hardware-backed PIN barrier safeguarding reproductive & hormonal records.' },
      { label: 'Clinical Intelligence', desc: 'USPSTF preventive guidelines & WHO 6th Edition fertility classification.' },
    ];

    pillars.forEach((p, idx) => {
      const colX = idx % 2 === 0 ? 75 : 75 + (this.contentWidth - 50) / 2;
      const rowY = cy + Math.floor(idx / 2) * 85;
      
      doc.roundedRect(colX, rowY, (this.contentWidth - 70) / 2, 72, 6).fill('#1E2D4A');
      doc.fillColor(this.colors.accentCyan).font('Helvetica-Bold').fontSize(10).text(p.label, colX + 10, rowY + 10);
      doc.fillColor('#CBD5E1').font('Helvetica').fontSize(8.5).text(p.desc, colX + 10, rowY + 26, { width: (this.contentWidth - 110) / 2, lineGap: 2 });
    });

    // Metadata Footer Area on Cover
    const metaY = 590;
    doc.roundedRect(50, metaY, this.contentWidth, 180, 10).fill('#0D1B2A');
    doc.roundedRect(50, metaY, this.contentWidth, 180, 10).lineWidth(1).strokeColor('#1F2E47').stroke();

    const metaItems = [
      ['DOCUMENT CLASSIFICATION', 'Comprehensive Engineering & Clinical Reference Manual'],
      ['TARGET AUDIENCE', 'Patients, Clinicians, Investors, Non-Technical Leadership & Reviewers'],
      ['PRIMARY PLATFORMS', 'Google Flutter (Android Release Build), Firebase Firestore, Google Health API'],
      ['BIOMETRIC COHORTS', 'Teen (13-17), Young Adult (18-25), Adult (26-39), Mid-Life (40-54), Senior (55+)'],
      ['SYSTEM RELEASE', 'v1.0.0 Production Release (62.9 MB Optimized Native ARM64/x86_64)'],
      ['AUTHOR & ENGINEERING TEAM', 'Male Vitality Systems Architecture & Clinical Health Group'],
      ['PUBLICATION DATE', 'September 2026 • Verified & Certified Release'],
    ];

    let my = metaY + 16;
    metaItems.forEach(([k, v]) => {
      doc.fillColor(this.colors.accentCyan).font('Helvetica-Bold').fontSize(8).text(k + ':', 70, my, { width: 160 });
      doc.fillColor('#F8FAFC').font('Helvetica').fontSize(8.5).text(v, 235, my, { width: this.contentWidth - 200 });
      my += 22;
    });
  }

  addExecutiveManifesto() {
    this.doc.addPage();
    this.doc.y = 65;

    this.addSectionHeader(1, 'PLATFORM VISION & CLINICAL MANIFESTO', 'The Philosophy of Proactive Male Telemetry');

    this.addParagraph(
      'The modern healthcare apparatus was designed for acute sickness rather than chronic vitality. For the male population, ' +
      'this structural flaw has produced staggering public health casualties: premature heart attacks, untreated mental distress, ' +
      'metabolic syndrome, and undetected hormonal decline. The Male Vitality platform represents an engineering-first solution ' +
      'to this crisis, bridging the dangerous chasm between everyday life and clinical medicine.'
    );

    this.addSectionHeader(2, 'The Five Foundational Platform Laws', 'Guiding Every Architectural & Clinical Decision');

    const laws = [
      { num: 'I', title: 'Passive Telemetry Over Manual Burden', desc: 'No user should ever be forced into daily questionnaire fatigue. Hardware sensors (wrist PPG, accelerometry) passively collect data while the man works, sleeps, and lives.' },
      { num: 'II', title: 'Absolute Privacy & Hardware Isolation', desc: 'Ultra-sensitive male health data (sexual health, sperm analysis, mental stress) is isolated on the smartphone\'s secure physical hardware with AES-256 encryption and never leaked to ad networks or unauthorized cloud silos.' },
      { num: 'III', title: 'Male-Exclusive Endocrine & Cardiovascular Tuning', desc: 'Generic unisex wellness formulas misdiagnose male risk. Algorithms must be tuned to the male 24-hour diurnal testosterone clock, visceral adiposity patterns, and Tanaka cardiovascular curves.' },
      { num: 'IV', title: 'Rigorous Evidence-Based Standards', desc: 'Every alert and screening recommendation derives from validated global clinical authorities: USPSTF preventive guidelines, WHO 6th Edition semen parameters, and IIEF-5 urological assessments.' },
      { num: 'V', title: 'Instrument Clarity Over Medical Mysticism', desc: 'The interface functions as an airplane cockpit instrument cluster. Biometric complexity is condensed into an intuitive 0-100 Vitality Index that inspires immediate, confident action.' },
    ];

    laws.forEach(l => {
      this.ensureSpace(45);
      const y = this.doc.y;
      this.doc.roundedRect(50, y, 26, 24, 4).fill(this.colors.secondaryNavy);
      this.doc.fillColor(this.colors.accentCyan).font('Helvetica-Bold').fontSize(10).text(l.num, 50, y + 6, { width: 26, align: 'center' });
      this.doc.fillColor(this.colors.textDark).font('Helvetica-Bold').fontSize(9.5).text(l.title, 84, y);
      this.doc.fillColor(this.colors.textMuted).font('Helvetica').fontSize(8.5).text(l.desc, 84, y + 14, { width: this.contentWidth - 36, lineGap: 2 });
      this.doc.y = y + 42;
    });

    this.doc.moveDown(0.5);
    this.addCallout('CLINICAL', 'Clinical Positioning & Physician Collaboration',
      'Male Vitality is engineered to augment, rather than replace, licensed clinical physicians. By providing months of high-fidelity, ' +
      'longitudinal cardiovascular and sleep telemetry, the platform transforms a 15-minute annual physical from subjective guesswork into ' +
      'an empirical diagnostic masterclass.'
    );
  }

  addSystemArchitectureOverview() {
    this.doc.addPage();
    this.doc.y = 65;

    this.addSectionHeader(1, 'SYSTEM TOPOLOGY & SUBSYSTEM ARCHITECTURE', 'End-to-End Component Blueprints Across Four Enclaves');

    this.addParagraph(
      'To provide full visibility for technical evaluators, systems engineers, and hospital CIOs, this section diagrams ' +
      'the four distinct architectural enclaves that power Male Vitality. Each layer operates under strict least-privilege ' +
      'boundaries, ensuring that sensor collection, cryptographic secrets, state machines, and cloud services remain decoupled.'
    );

    this.addTable(
      ['Architecture Enclave', 'Subsystem Components', 'Technologies & Protocols', 'Security & Trust Boundary'],
      [
        ['1. Peripheral Hardware', 'Wrist PPG Optical Diodes, 3-Axis MEMS Accelerometer, Sensor DSP', 'BLE 5.2, Nordic Semiconductor SDK, Proprietary Sensor Firmware', 'Physical wrist contact; local hardware buffer; zero OS access'],
        ['2. Mobile OS & Hardware Sandbox', 'Android Health Connect, EncryptedSharedPreferences, Keystore Enclave, NotificationManager', 'Kotlin / Android 14+ Security SDK, AES-256-GCM Hardware HSM, Channel Priority 4', 'Operating system sandbox; hardware cryptographic chip; isolated user space'],
        ['3. Local Presentation & Logic', 'Google Flutter 3.x UI, BLoC State Machines, SQLite Cache, CustomPainter Gauges', 'Dart Native ARM64, flutter_bloc, sqflite, pure Dart mathematical engines', 'Client-side runtime memory; unidirectional data flow; zero external scripts'],
        ['4. Cloud Services & Identity', 'Firebase Auth, Isolated Cloud Firestore, Firebase Cloud Messaging v1, Google People API', 'HTTPS / TLS 1.3, OAuth 2.0 Bearer Tokens, JWT Service Accounts, Firestore Rules', 'Encrypted cloud datastore; partitioned under users/{uid}/apps/male_vitality'],
      ],
      [105, 130, 130, 130]
    );

    this.addFlowchart([
      { label: 'Layer 1: Wearable Biosensor Acquisition', desc: 'Continuous 25Hz optical sampling captures heart rate pulses and kinetic step vibrations' },
      { label: 'Layer 2: Local OS Aggregation & Normalization', desc: 'Health Connect filters motion artifacts and bundles raw records into hourly metrics' },
      { label: 'Layer 3: On-Device BLoC State Machine & Vault', desc: 'Validates physiological thresholds, updates Vitality Index, and stores sensitive records in AES-256 vault' },
      { label: 'Layer 4: Authenticated Cloud Telemetry Sync', desc: 'Incremental sync of general telemetry to partitioned Firestore datastore via OAuth 2.0' }
    ]);

    this.doc.moveDown(0.5);
    this.addCallout('DECISION', 'Architectural Principle of Least Cloud Exposure',
      'The overarching engineering thesis of Male Vitality is to minimize cloud surface area. Cloud storage is utilized exclusively ' +
      'for cross-device telemetry backup and high-priority FCM notification triggers. No diagnostic computation, no cryptographic keys, ' +
      'and no unencrypted sexual health records ever touch third-party cloud servers.'
    );
  }

  addTableOfContents(part1Chapters, part2Chapters) {
    // PAGE 1 OF TOC (Chapters 1 - 8)
    this.doc.addPage();
    this.doc.y = 65;

    this.addSectionHeader(1, 'TABLE OF CONTENTS: PART I', 'Platform Architecture, Core Telemetry & Dashboard Systems');
    this.addParagraph(
      'Part I introduces the core medical philosophy, the software engineering stack, zero-friction identity onboarding, ' +
      'the clinical HUD dashboard, and continuous passive telemetry pipelines through wrist wearables and sleep sensors.'
    );
    this.doc.moveDown(0.5);

    part1Chapters.forEach((ch, idx) => {
      this.ensureSpace(32);
      const y = this.doc.y;

      this.doc.roundedRect(50, y, 65, 20, 4).fill(this.colors.secondaryNavy);
      this.doc.fillColor(this.colors.accentCyan).font('Helvetica-Bold').fontSize(8.5).text(`CH ${idx + 1}`, 50, y + 5, { width: 65, align: 'center' });

      this.doc.fillColor(this.colors.textDark).font('Helvetica-Bold').fontSize(10).text(ch.title, 125, y + 1, { width: 310 });
      this.doc.fillColor(this.colors.textMuted).font('Helvetica').fontSize(8).text(ch.subtitle, 125, y + 13, { width: 310 });

      this.doc.fillColor(this.colors.accentEmerald).font('Helvetica-Bold').fontSize(9).text(ch.pageHint || `Module 0${idx + 1}`, 445, y + 5, { width: 100, align: 'right' });

      this.doc.y = y + 26;
    });

    this.doc.moveDown(0.8);
    this.addCallout('INFO', 'Navigating Part I',
      'Readers new to digital health are encouraged to begin with Chapters 1 and 2 to grasp the male health deficit, then proceed ' +
      'to Chapter 6 for an in-depth tour of the daily Clinical Command HUD.'
    );

    // PAGE 2 OF TOC (Chapters 9 - 17)
    this.doc.addPage();
    this.doc.y = 65;

    this.addSectionHeader(1, 'TABLE OF CONTENTS: PART II', 'Specialized Clinical Modules, Vault Security & Governance');
    this.addParagraph(
      'Part II explores specialized clinical domains including cardiovascular trend radar, the hardware-isolated PIN vault, ' +
      'sexual health (IIEF-5), WHO 6th Edition semen analysis, automated USPSTF screenings, 988 mental crisis support, and decisions.'
    );
    this.doc.moveDown(0.5);

    part2Chapters.forEach((ch, idx) => {
      this.ensureSpace(32);
      const y = this.doc.y;
      const chNum = idx + 9;

      this.doc.roundedRect(50, y, 65, 20, 4).fill(this.colors.secondaryNavy);
      this.doc.fillColor(this.colors.accentCyan).font('Helvetica-Bold').fontSize(8.5).text(`CH ${chNum}`, 50, y + 5, { width: 65, align: 'center' });

      this.doc.fillColor(this.colors.textDark).font('Helvetica-Bold').fontSize(10).text(ch.title, 125, y + 1, { width: 310 });
      this.doc.fillColor(this.colors.textMuted).font('Helvetica').fontSize(8).text(ch.subtitle, 125, y + 13, { width: 310 });

      this.doc.fillColor(this.colors.accentEmerald).font('Helvetica-Bold').fontSize(9).text(ch.pageHint || `Module ${chNum}`, 445, y + 5, { width: 100, align: 'right' });

      this.doc.y = y + 26;
    });

    this.doc.moveDown(0.8);
    this.addCallout('SECURITY', 'Confidentiality of Specialized Health Modules',
      'Chapters 10, 11, and 12 contain documentation regarding hardware-isolated sexual and reproductive health data. ' +
      'All architectures comply with HIPAA security safeguards and local-first cryptographic principles.'
    );
  }

  addChapterBanner(chapterNum, title, subtitle, summary) {
    this.doc.addPage();
    this.doc.y = 65;

    const y = this.doc.y;
    // Dark Header Banner Card
    this.doc.roundedRect(50, y, this.contentWidth, 100, 8).fill(this.colors.primaryNavy);

    // Chapter badge
    this.doc.roundedRect(65, y + 14, 80, 18, 4).fill(this.colors.accentCyan);
    this.doc.fillColor(this.colors.primaryNavy).font('Helvetica-Bold').fontSize(9).text(`CHAPTER ${chapterNum}`, 65, y + 18, { width: 80, align: 'center' });

    // Chapter Title
    this.doc.fillColor(this.colors.white).font('Helvetica-Bold').fontSize(18).text(title, 65, y + 40, { width: this.contentWidth - 30 });
    this.doc.fillColor('#94A3B8').font('Helvetica-Oblique').fontSize(10.5).text(subtitle, 65, y + 66, { width: this.contentWidth - 30 });

    this.doc.y = y + 115;

    // Executive Summary Callout
    this.addCallout('EXECUTIVE_BRIEF', 'Chapter Executive Briefing', summary);
    this.doc.moveDown(0.8);
  }

  addSectionHeader(level, title, subtitle = '') {
    const spaceNeeded = level === 1 ? 55 : (level === 2 ? 42 : 30);
    this.ensureSpace(spaceNeeded);

    if (level === 1) {
      this.doc.moveDown(0.6);
      const y = this.doc.y;
      this.doc.rect(50, y, 4, 20).fill(this.colors.accentCyan);
      this.doc.fillColor(this.colors.primaryNavy).font('Helvetica-Bold').fontSize(15).text(title, 60, y + 2);
      if (subtitle) {
        this.doc.fillColor(this.colors.textMuted).font('Helvetica-Oblique').fontSize(9.5).text(subtitle, 60, y + 20);
        this.doc.y = y + 36;
      } else {
        this.doc.y = y + 26;
      }
    } else if (level === 2) {
      this.doc.moveDown(0.5);
      const y = this.doc.y;
      this.doc.fillColor(this.colors.secondaryNavy).font('Helvetica-Bold').fontSize(12).text(title, 50, y);
      if (subtitle) {
        this.doc.fillColor(this.colors.textMuted).font('Helvetica').fontSize(8.5).text(subtitle, 50, y + 16);
        this.doc.y = y + 28;
      } else {
        this.doc.y = y + 18;
      }
    } else {
      this.doc.moveDown(0.4);
      this.doc.fillColor(this.colors.accentCyan).font('Helvetica-Bold').fontSize(10.5).text(title, 50, this.doc.y);
      this.doc.moveDown(0.2);
    }
  }

  addParagraph(text) {
    this.ensureSpace(35);
    this.doc.fillColor(this.colors.textDark)
      .font('Helvetica')
      .fontSize(9.5)
      .text(text, 50, this.doc.y, {
        width: this.contentWidth,
        align: 'justify',
        lineGap: 3.5,
      });
    this.doc.moveDown(0.6);
  }

  addBullet(boldPrefix, text) {
    this.ensureSpace(24);
    const y = this.doc.y;
    // Custom bullet dot
    this.doc.circle(56, y + 6, 2.5).fill(this.colors.accentCyan);

    const doc = this.doc;
    doc.fillColor(this.colors.textDark).font('Helvetica-Bold').fontSize(9.5).text(boldPrefix + ' ', 66, y, { continued: true });
    doc.font('Helvetica').text(text, { width: this.contentWidth - 16, lineGap: 3 });
    this.doc.moveDown(0.4);
  }

  addCallout(type, title, text) {
    const config = {
      EXECUTIVE_BRIEF: { bg: '#F8FAFC', border: '#0284C7', titleColor: '#0284C7', icon: 'BRIEFING' },
      CLINICAL: { bg: '#ECFDF5', border: '#059669', titleColor: '#059669', icon: 'CLINICAL RATIONALE' },
      DECISION: { bg: '#EFF6FF', border: '#3B82F6', titleColor: '#1D4ED8', icon: 'ARCHITECTURAL DECISION' },
      SECURITY: { bg: '#FEF2F2', border: '#DC2626', titleColor: '#B91C1C', icon: 'SECURITY SAFEGUARD' },
      PATIENT_STORY: { bg: '#FAF5FF', border: '#9333EA', titleColor: '#7E22CE', icon: 'PATIENT JOURNEY SCENARIO' },
      INFO: { bg: '#F1F5F9', border: '#475569', titleColor: '#334155', icon: 'NOTE & CONTEXT' },
    }[type] || { bg: '#F1F5F9', border: '#475569', titleColor: '#334155', icon: 'NOTE' };

    // Estimate height
    const estimatedHeight = Math.ceil(text.length / 85) * 13 + 36;
    this.ensureSpace(estimatedHeight + 10);

    const y = this.doc.y;
    this.doc.roundedRect(50, y, this.contentWidth, estimatedHeight, 6).fill(config.bg);
    this.doc.rect(50, y, 4, estimatedHeight).fill(config.border);

    this.doc.fillColor(config.titleColor).font('Helvetica-Bold').fontSize(8.5).text(`[${config.icon}]  ${title.toUpperCase()}`, 64, y + 8);
    this.doc.fillColor(this.colors.textDark).font('Helvetica').fontSize(9).text(text, 64, y + 24, { width: this.contentWidth - 26, lineGap: 3 });

    this.doc.y = y + estimatedHeight + 10;
  }

  addTable(headers, rows, colWidths = null) {
    const numCols = headers.length;
    const defaultColWidth = this.contentWidth / numCols;
    const widths = colWidths || Array(numCols).fill(defaultColWidth);

    const rowHeight = 22;
    const tableHeight = (rows.length + 1) * rowHeight;
    this.ensureSpace(tableHeight + 15);

    let currentY = this.doc.y;

    // Header Row
    this.doc.rect(50, currentY, this.contentWidth, rowHeight).fill(this.colors.secondaryNavy);
    let currentX = 50;
    headers.forEach((h, i) => {
      this.doc.fillColor(this.colors.white).font('Helvetica-Bold').fontSize(8.5).text(h, currentX + 6, currentY + 6, { width: widths[i] - 12 });
      currentX += widths[i];
    });

    currentY += rowHeight;

    // Data Rows
    rows.forEach((row, rIdx) => {
      const bgColor = rIdx % 2 === 0 ? this.colors.white : this.colors.bgLight;
      this.doc.rect(50, currentY, this.contentWidth, rowHeight).fill(bgColor);
      this.doc.rect(50, currentY, this.contentWidth, rowHeight).lineWidth(0.5).strokeColor(this.colors.borderSubtle).stroke();

      let cellX = 50;
      row.forEach((cell, cIdx) => {
        const isBoldFirst = cIdx === 0;
        this.doc.fillColor(this.colors.textDark)
          .font(isBoldFirst ? 'Helvetica-Bold' : 'Helvetica')
          .fontSize(8)
          .text(String(cell), cellX + 6, currentY + 6, { width: widths[cIdx] - 12 });
        cellX += widths[cIdx];
      });

      currentY += rowHeight;
    });

    this.doc.y = currentY + 10;
  }

  addFlowchart(steps) {
    const boxHeight = 36;
    const spacing = 18;
    const totalHeight = steps.length * (boxHeight + spacing);
    this.ensureSpace(totalHeight + 10);

    let y = this.doc.y;

    steps.forEach((st, idx) => {
      // Step box
      this.doc.roundedRect(65, y, this.contentWidth - 30, boxHeight, 6).fill('#1E293B');
      this.doc.roundedRect(65, y, this.contentWidth - 30, boxHeight, 6).lineWidth(1).strokeColor(this.colors.accentCyan).stroke();

      // Step Number circle
      this.doc.circle(85, y + 18, 11).fill(this.colors.accentCyan);
      this.doc.fillColor(this.colors.primaryNavy).font('Helvetica-Bold').fontSize(9).text(String(idx + 1), 77, y + 13, { width: 16, align: 'center' });

      // Step Label and Description
      this.doc.fillColor(this.colors.white).font('Helvetica-Bold').fontSize(9.5).text(st.label, 106, y + 6);
      this.doc.fillColor('#94A3B8').font('Helvetica').fontSize(8).text(st.desc, 106, y + 20, { width: this.contentWidth - 75 });

      // Arrow down if not last
      if (idx < steps.length - 1) {
        const arrowY = y + boxHeight;
        this.doc.moveTo(85, arrowY).lineTo(85, arrowY + spacing).lineWidth(1.5).strokeColor(this.colors.accentCyan).stroke();
        this.doc.polygon([81, arrowY + spacing - 4], [89, arrowY + spacing - 4], [85, arrowY + spacing]).fill(this.colors.accentCyan);
      }

      y += boxHeight + spacing;
    });

    this.doc.y = y + 5;
  }

  finalizeHeadersAndFooters() {
    const pages = this.doc.bufferedPageRange();
    const total = pages.count;
    this.totalPages = total;

    for (let i = 0; i < total; i++) {
      this.doc.switchToPage(i);

      // Skip header/footer on cover page (page 0)
      if (i === 0) continue;

      const origBottom = this.doc.page.margins.bottom;
      this.doc.page.margins.bottom = 0;

      // Running Header
      this.doc.moveTo(50, 42).lineTo(this.pageWidth - 50, 42).lineWidth(0.5).strokeColor(this.colors.borderSubtle).stroke();
      this.doc.fillColor(this.colors.textMuted).font('Helvetica-Bold').fontSize(7.5).text('MALE VITALITY CLINICAL PLATFORM', 50, 31, { lineBreak: false });
      this.doc.font('Helvetica-Oblique').text('COMPREHENSIVE SYSTEMS & DECISION GUIDE', 250, 31, { width: 295, align: 'right', lineBreak: false });

      // Running Footer
      this.doc.moveTo(50, this.pageHeight - 40).lineTo(this.pageWidth - 50, this.pageHeight - 40).lineWidth(0.5).strokeColor(this.colors.borderSubtle).stroke();
      this.doc.fillColor(this.colors.textMuted).font('Helvetica').fontSize(7.5).text('Confidential • Internal Healthcare & Engineering Documentation', 50, this.pageHeight - 32, { lineBreak: false });
      this.doc.font('Helvetica-Bold').text(`Page ${i + 1} of ${total}`, 400, this.pageHeight - 32, { width: 145, align: 'right', lineBreak: false });

      this.doc.page.margins.bottom = origBottom;
    }

    this.doc.end();
  }
}

module.exports = PDFEngine;
