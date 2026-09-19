// scripts/migrate_firestore_data.js
// Safe, non-destructive migration script for Firebase Project: fitbit-health-dash-81a2f

const { execSync } = require('child_process');

const PROJECT_ID = 'fitbit-health-dash-81a2f';
const BASE_URL = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents`;

function getAccessToken() {
  try {
    const token = execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
    return token;
  } catch (err) {
    console.error('Failed to get access token via gcloud:', err.message);
    process.exit(1);
  }
}

async function apiRequest(endpoint, method = 'GET', body = null, token) {
  const url = endpoint.startsWith('http') ? endpoint : `${BASE_URL}/${endpoint}`;
  const headers = {
    Authorization: `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  const options = { method, headers };
  if (body) {
    options.body = JSON.stringify(body);
  }

  const res = await fetch(url, options);
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`API error [${res.status} ${res.statusText}] at ${url}: ${text}`);
  }
  return await res.json();
}

async function getDocument(docPath, token) {
  try {
    return await apiRequest(docPath, 'GET', null, token);
  } catch (e) {
    if (e.message.includes('404')) return null;
    throw e;
  }
}

async function setDocument(docPath, fields, token) {
  return await apiRequest(docPath, 'PATCH', { fields }, token);
}

async function listDocuments(collectionPath, token) {
  try {
    const res = await apiRequest(collectionPath, 'GET', null, token);
    return res.documents || [];
  } catch (e) {
    if (e.message.includes('404')) return [];
    throw e;
  }
}

async function listSubcollections(docPath, token) {
  try {
    const res = await apiRequest(`${docPath}:listCollectionIds`, 'POST', {}, token);
    return res.collectionIds || [];
  } catch (e) {
    return [];
  }
}

async function migrateUser(uid, token) {
  console.log(`\n========================================`);
  console.log(`Migrating User: ${uid}`);
  console.log(`========================================`);

  const userDoc = await getDocument(`users/${uid}`, token);
  if (!userDoc || !userDoc.fields) {
    console.log(`User doc users/${uid} not found. Skipping.`);
    return;
  }

  const fields = userDoc.fields;
  const subcollections = await listSubcollections(`users/${uid}`, token);
  console.log(`Discovered subcollections: [${subcollections.join(', ')}]`);

  // 1. Common Data: users/{uid}/common/profile & account
  console.log(`\n-> Writing users/${uid}/common/profile & common/account`);
  const commonProfile = {};
  if (fields.email) commonProfile.email = fields.email;
  if (fields.displayName) commonProfile.displayName = fields.displayName;
  if (fields.photoUrl) commonProfile.photoUrl = fields.photoUrl;
  if (fields.dateOfBirth) commonProfile.dateOfBirth = fields.dateOfBirth;
  if (fields.gender) commonProfile.gender = fields.gender;

  await setDocument(`users/${uid}/common/profile`, commonProfile, token);

  const commonAccount = {};
  if (fields.uid) commonAccount.uid = fields.uid;
  if (fields.createdAt) commonAccount.createdAt = fields.createdAt;
  if (fields.updatedAt) commonAccount.updatedAt = fields.updatedAt;
  if (fields.lastLogin) commonAccount.lastLogin = fields.lastLogin;
  if (fields.last_active) commonAccount.lastActive = fields.last_active;

  await setDocument(`users/${uid}/common/account`, commonAccount, token);
  console.log(`  ✓ common/profile and common/account written.`);

  // 2. Shared Health: daily
  if (subcollections.includes('healthDaily')) {
    const docs = await listDocuments(`users/${uid}/healthDaily`, token);
    console.log(`\n-> Migrating ${docs.length} healthDaily records to shared_health/daily/records/`);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/shared_health/daily/records/${docId}`, doc.fields, token);
    }
    await setDocument(`users/${uid}/shared_health/daily`, {
      recordCount: { integerValue: docs.length.toString() },
      updatedAt: { timestampValue: new Date().toISOString() },
    }, token);
    console.log(`  ✓ ${docs.length} daily records copied to shared_health/daily/records.`);
  }

  // 3. Shared Health: heart_rate
  if (subcollections.includes('heartRate')) {
    const docs = await listDocuments(`users/${uid}/heartRate`, token);
    console.log(`\n-> Migrating ${docs.length} heartRate records to shared_health/heart_rate/records/`);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/shared_health/heart_rate/records/${docId}`, doc.fields, token);
    }
    await setDocument(`users/${uid}/shared_health/heart_rate`, {
      recordCount: { integerValue: docs.length.toString() },
      updatedAt: { timestampValue: new Date().toISOString() },
    }, token);
    console.log(`  ✓ ${docs.length} heart rate records copied to shared_health/heart_rate/records.`);
  }

  // 4. Shared Health: sleep
  if (subcollections.includes('sleep')) {
    const docs = await listDocuments(`users/${uid}/sleep`, token);
    console.log(`\n-> Migrating ${docs.length} sleep records to shared_health/sleep/records/`);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/shared_health/sleep/records/${docId}`, doc.fields, token);
    }
    await setDocument(`users/${uid}/shared_health/sleep`, {
      recordCount: { integerValue: docs.length.toString() },
      updatedAt: { timestampValue: new Date().toISOString() },
    }, token);
    console.log(`  ✓ ${docs.length} sleep records copied to shared_health/sleep/records.`);
  }

  // 5. Shared Health: metrics (from health_metrics / healthMetrics ONLY if it exists)
  const metricsCol = subcollections.find(c => c === 'health_metrics' || c === 'healthMetrics');
  if (metricsCol) {
    const docs = await listDocuments(`users/${uid}/${metricsCol}`, token);
    if (docs.length > 0) {
      console.log(`\n-> Migrating ${docs.length} ${metricsCol} records to shared_health/metrics/records/`);
      for (const doc of docs) {
        const docId = doc.name.split('/').pop();
        await setDocument(`users/${uid}/shared_health/metrics/records/${docId}`, doc.fields, token);
      }
      await setDocument(`users/${uid}/shared_health/metrics`, {
        recordCount: { integerValue: docs.length.toString() },
        updatedAt: { timestampValue: new Date().toISOString() },
      }, token);
      console.log(`  ✓ ${docs.length} metrics copied to shared_health/metrics/records.`);
    } else {
      console.log(`  - ${metricsCol} has 0 records; not creating shared_health/metrics.`);
    }
  } else {
    console.log(`  - No health_metrics collection found for user ${uid}; omitting shared_health/metrics.`);
  }

  // 6. Apps: fitbit connection & sync
  if (subcollections.includes('connections')) {
    const connDoc = await getDocument(`users/${uid}/connections/google_health`, token);
    if (connDoc && connDoc.fields) {
      console.log(`\n-> Migrating Fitbit connection to apps/fitbit/connection/google_health`);
      await setDocument(`users/${uid}/apps/fitbit/connection/google_health`, connDoc.fields, token);
      console.log(`  ✓ apps/fitbit/connection/google_health written.`);
    }
  }

  if (subcollections.includes('sync')) {
    const docs = await listDocuments(`users/${uid}/sync`, token);
    console.log(`\n-> Migrating ${docs.length} sync checkpoints to apps/fitbit/sync/`);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/apps/fitbit/sync/${docId}`, doc.fields, token);
    }
    console.log(`  ✓ ${docs.length} sync docs copied to apps/fitbit/sync.`);
  }

  // Also set high-level status on apps/fitbit document
  await setDocument(`users/${uid}/apps/fitbit`, {
    healthConnected: fields.healthConnected || { booleanValue: false },
    updatedAt: { timestampValue: new Date().toISOString() },
  }, token);
  console.log(`  ✓ apps/fitbit summary document written.`);

  // 7. Apps: male_vitality
  // Check if this user had active Male Vitality data
  const hasMaleVitalityData = subcollections.some(c =>
    ['profile', 'lifestyle', 'mood_entries', 'substance', 'testosterone_logs', 'semen_analyses'].includes(c)
  );

  if (!hasMaleVitalityData) {
    console.log(`\n-> User ${uid} has NO Male Vitality data (Fitbit-only user).`);
    console.log(`   [CONFIRMED] NOT creating apps/male_vitality so user will go through fresh onboarding.`);
    return;
  }

  console.log(`\n-> Migrating Male Vitality data for user ${uid}`);

  // Profile
  const profileDoc = await getDocument(`users/${uid}/profile/main`, token);
  let wasOnboarded = false;
  if (profileDoc && profileDoc.fields) {
    await setDocument(`users/${uid}/apps/male_vitality/profile/main`, profileDoc.fields, token);
    if (profileDoc.fields.onboardingCompleted && profileDoc.fields.onboardingCompleted.booleanValue === true) {
      wasOnboarded = true;
    }
    console.log(`  ✓ apps/male_vitality/profile/main written.`);
  }

  // Lifestyle
  const lifestyleDoc = await getDocument(`users/${uid}/lifestyle/factors`, token);
  if (lifestyleDoc && lifestyleDoc.fields) {
    await setDocument(`users/${uid}/apps/male_vitality/lifestyle/factors`, lifestyleDoc.fields, token);
    console.log(`  ✓ apps/male_vitality/lifestyle/factors written.`);
  }

  // Goals
  if (fields.goals) {
    await setDocument(`users/${uid}/apps/male_vitality/goals/main`, fields.goals.mapValue.fields, token);
    console.log(`  ✓ apps/male_vitality/goals/main written.`);
  }

  // Preferences
  if (fields.visibleMetrics) {
    await setDocument(`users/${uid}/apps/male_vitality/preferences/settings`, {
      visibleMetrics: fields.visibleMetrics,
    }, token);
    console.log(`  ✓ apps/male_vitality/preferences/settings written.`);
  }

  // Mood Entries
  if (subcollections.includes('mood_entries')) {
    const docs = await listDocuments(`users/${uid}/mood_entries`, token);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/apps/male_vitality/mood_entries/${docId}`, doc.fields, token);
    }
    console.log(`  ✓ ${docs.length} mood entries copied to apps/male_vitality/mood_entries.`);
  }

  // Substance
  if (subcollections.includes('substance')) {
    const docs = await listDocuments(`users/${uid}/substance`, token);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/apps/male_vitality/substance/${docId}`, doc.fields, token);
    }
    console.log(`  ✓ ${docs.length} substance docs copied to apps/male_vitality/substance.`);
  }

  // Testosterone
  if (subcollections.includes('testosterone_logs')) {
    const docs = await listDocuments(`users/${uid}/testosterone_logs`, token);
    for (const doc of docs) {
      const docId = doc.name.split('/').pop();
      await setDocument(`users/${uid}/apps/male_vitality/testosterone_logs/${docId}`, doc.fields, token);
    }
    console.log(`  ✓ ${docs.length} testosterone logs copied to apps/male_vitality/testosterone_logs.`);
  }

  // Only create onboarding/state if wasOnboarded is strictly true
  if (wasOnboarded) {
    await setDocument(`users/${uid}/apps/male_vitality/onboarding/state`, {
      completed: { booleanValue: true },
      completedAt: { timestampValue: new Date().toISOString() },
    }, token);
    console.log(`  ✓ apps/male_vitality/onboarding/state set to completed: true.`);
  } else {
    console.log(`  - User has not completed Male Vitality onboarding; omitting onboarding/state.`);
  }
}

async function run() {
  console.log('Fetching Google OAuth access token for project fitbit-health-dash-81a2f...');
  const token = getAccessToken();

  const userIds = [
    'rCgW0gCG4PRQ1oPockThDsV662i2',
    'gEnMJsJybzZZIOnFOk5cf4daL9C2',
    'kOtHTCGdEuVDW35bGjTXEbwjzC83',
  ];

  for (const uid of userIds) {
    await migrateUser(uid, token);
  }

  console.log('\n========================================');
  console.log('MIGRATION COMPLETED SUCCESSFULLY!');
  console.log('All legacy collections retained as fallbacks.');
  console.log('========================================');
}

run().catch(err => {
  console.error('Migration failed:', err);
  process.exit(1);
});
