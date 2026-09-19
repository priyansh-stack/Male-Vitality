// scripts/clean_and_isolate_firestore.js
// Script to normalize Firestore data, clean up redundant collections, and ensure clean separation:
// - users/{uid}/common (profile, account)
// - users/{uid}/shared_health (daily, heart_rate, sleep, metrics)
// - users/{uid}/apps/fitbit (connection, sync)
// - users/{uid}/apps/male_vitality (profile, lifestyle, onboarding, mood_entries, substance, semen_analyses, etc.)

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

async function deleteDocument(docPath, token) {
  try {
    await apiRequest(docPath, 'DELETE', null, token);
    return true;
  } catch (e) {
    if (e.message.includes('404')) return false;
    throw e;
  }
}

async function listDocuments(collectionPath, token) {
  let allDocs = [];
  let pageToken = '';
  do {
    const url = `${BASE_URL}/${collectionPath}?pageSize=300${pageToken ? `&pageToken=${pageToken}` : ''}`;
    try {
      const res = await apiRequest(url, 'GET', null, token);
      if (res.documents) {
        allDocs = allDocs.concat(res.documents);
      }
      pageToken = res.nextPageToken || '';
    } catch (e) {
      if (e.message.includes('404')) return [];
      throw e;
    }
  } while (pageToken);
  return allDocs;
}

async function listSubcollections(docPath, token) {
  try {
    const res = await apiRequest(`${docPath}:listCollectionIds`, 'POST', {}, token);
    return res.collectionIds || [];
  } catch (e) {
    return [];
  }
}

async function deleteCollectionRecursively(collectionPath, token) {
  const docs = await listDocuments(collectionPath, token);
  for (const doc of docs) {
    const relPath = doc.name.replace(`projects/${PROJECT_ID}/databases/(default)/documents/`, '');
    // Check if doc has subcollections
    const subColls = await listSubcollections(relPath, token);
    for (const sub of subColls) {
      await deleteCollectionRecursively(`${relPath}/${sub}`, token);
    }
    await deleteDocument(relPath, token);
  }
}

async function updateTodayWearableData(uid, token) {
  console.log(`\n-> Updating authoritative wearable data for ${uid} on 2026-09-19...`);
  const todayPath = `users/${uid}/shared_health/daily/records/2026-09-19`;

  // First delete old record so any stale sleep or mock fields are completely expunged
  await deleteDocument(todayPath, token);

  // Write authoritative telemetry
  await setDocument(todayPath, {
    date: { stringValue: '2026-09-19' },
    steps: { integerValue: '24' },
    calories: { integerValue: '736' },
    caloriesBurned: { integerValue: '736' },
    restingHeartRate: { integerValue: '110' },
    updatedAt: { timestampValue: new Date().toISOString() },
  }, token);

  console.log(`  ✓ 2026-09-19 daily record set to steps=24, calories=736, RHR=110, sleep=null`);
}

async function copyCollection(fromPath, toPath, token) {
  const docs = await listDocuments(fromPath, token);
  if (docs.length === 0) return 0;
  for (const doc of docs) {
    const docId = doc.name.split('/').pop();
    await setDocument(`${toPath}/${docId}`, doc.fields, token);
  }
  return docs.length;
}

async function cleanUser(uid, token) {
  console.log(`\n========================================`);
  console.log(`Processing User: ${uid}`);
  console.log(`========================================`);

  const subcollections = await listSubcollections(`users/${uid}`, token);
  console.log(`Current subcollections: [${subcollections.join(', ')}]`);

  // Ensure Male Vitality loose collections are copied to apps/male_vitality if needed
  if (subcollections.includes('semen_analyses')) {
    const count = await copyCollection(`users/${uid}/semen_analyses`, `users/${uid}/apps/male_vitality/semen_analyses`, token);
    console.log(`  Migrated ${count} semen_analyses to apps/male_vitality/semen_analyses`);
  }
  if (subcollections.includes('substance')) {
    const count = await copyCollection(`users/${uid}/substance`, `users/${uid}/apps/male_vitality/substance`, token);
    console.log(`  Migrated ${count} substance to apps/male_vitality/substance`);
  }
  if (subcollections.includes('testosterone_logs')) {
    const count = await copyCollection(`users/${uid}/testosterone_logs`, `users/${uid}/apps/male_vitality/testosterone_logs`, token);
    console.log(`  Migrated ${count} testosterone_logs to apps/male_vitality/testosterone_logs`);
  }
  if (subcollections.includes('mood_entries')) {
    const count = await copyCollection(`users/${uid}/mood_entries`, `users/${uid}/apps/male_vitality/mood_entries`, token);
    console.log(`  Migrated ${count} mood_entries to apps/male_vitality/mood_entries`);
  }

  // Obsolete subcollections to delete
  const obsoleteSubcollections = [
    'healthDaily',
    'heartRate',
    'sleep',
    'sync',
    'connections',
    'health_imports',
    'lifestyle',
    'mood_entries',
    'profile',
    'semen_analyses',
    'substance',
    'testosterone_logs',
  ];

  for (const collName of obsoleteSubcollections) {
    if (subcollections.includes(collName)) {
      console.log(`  -> Deleting obsolete subcollection users/${uid}/${collName}...`);
      await deleteCollectionRecursively(`users/${uid}/${collName}`, token);
      console.log(`     ✓ Deleted.`);
    }
  }

  const remaining = await listSubcollections(`users/${uid}`, token);
  console.log(`Remaining subcollections for ${uid}: [${remaining.join(', ')}]`);
}

async function cleanRootCollections(token) {
  console.log(`\n========================================`);
  console.log(`Checking Root Collections...`);
  console.log(`========================================`);

  const res = await apiRequest(':listCollectionIds', 'POST', {}, token);
  const rootColls = res.collectionIds || [];
  console.log(`Root collection IDs: [${rootColls.join(', ')}]`);

  const obsoleteRoots = [
    'health_imports',
    'healthDaily',
    'heartRate',
    'sleep',
    'sync',
    'connections',
    'lifestyle',
    'mood_entries',
    'profile',
    'semen_analyses',
    'substance',
    'testosterone_logs',
  ];

  for (const r of obsoleteRoots) {
    if (rootColls.includes(r)) {
      console.log(`  -> Deleting obsolete root collection: ${r}...`);
      await deleteCollectionRecursively(r, token);
      console.log(`     ✓ Deleted.`);
    }
  }

  const finalRoots = (await apiRequest(':listCollectionIds', 'POST', {}, token)).collectionIds || [];
  console.log(`Final root collection IDs: [${finalRoots.join(', ')}]`);
}

async function main() {
  console.log('Fetching Google OAuth access token for project fitbit-health-dash-81a2f...');
  const token = getAccessToken();

  const userIds = [
    'rCgW0gCG4PRQ1oPockThDsV662i2',
    'gEnMJsJybzZZIOnFOk5cf4daL9C2',
    'kOtHTCGdEuVDW35bGjTXEbwjzC83',
  ];

  // 1. Update authoritative wearable data for the primary test user
  await updateTodayWearableData('rCgW0gCG4PRQ1oPockThDsV662i2', token);

  // 2. Clean each user
  for (const uid of userIds) {
    await cleanUser(uid, token);
  }

  // 3. Clean root collections
  await cleanRootCollections(token);

  console.log('\n========================================');
  console.log('FIRESTORE CLEANUP & NORMALIZATION COMPLETE!');
  console.log('========================================');
}

main().catch(err => {
  console.error('Execution error:', err);
  process.exit(1);
});
