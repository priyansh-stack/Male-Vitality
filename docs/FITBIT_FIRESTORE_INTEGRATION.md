# Fitbit & Google Health API - Firestore Integration Guide

This document defines the architectural integration contract between the **Fitbit Health Connector application** (`fit_bit`) and **Male-Vitality** (`life_stage_health_app`).

---

## 1. System Architecture & Component Boundaries

```
 ┌─────────────────────────────────────────────────────────┐
 │               Fitbit / Google Health API                │
 └────────────────────────────┬────────────────────────────┘
                              │ OAuth 2.0 & Data Polling
                              ▼
 ┌─────────────────────────────────────────────────────────┐
 │       Fitbit Connector App (`fit_bit` repository)       │
 │                  [DATA PRODUCER]                        │
 │  • Authenticates via Google Health API / Fitbit OAuth   │
 │  • Fetches daily summaries & telemetry                  │
 │  • Normalizes metrics into canonical schema             │
 │  • Writes to Firestore: users/{uid}/healthDaily/{date}  │
 └────────────────────────────┬────────────────────────────┘
                              │
                              ▼ Cloud Firestore
 ┌─────────────────────────────────────────────────────────┐
 │   Firebase Project: fitbit-health-dash-81a2f4           │
 │   Project Number:   589835266478                        │
 │   Database Path:    users/{uid}/healthDaily/{yyyy-MM-dd}│
 └────────────────────────────┬────────────────────────────┘
                              │
                              ▼ Real-time Stream & Point Reads
 ┌─────────────────────────────────────────────────────────┐
 │               Male-Vitality Application                 │
 │                  [DATA CONSUMER]                        │
 │  • Authenticates user via Firebase Auth                 │
 │  • Queries ONLY its own UID:                            │
 │      FirebaseAuth.instance.currentUser!.uid             │
 │  • Displays real biometric telemetry on Command HUD     │
 │  • NEVER touches Fitbit OAuth or duplicates sync logic  │
 │  • Zero fake / placeholder data                         │
 └─────────────────────────────────────────────────────────┘
```

### Strict Architectural Principles
1. **Producer-Consumer Separation**:
   - `fit_bit` is the **Data Producer**: Handles Fitbit OAuth, Google Health API tokens, and daily write operations.
   - `Male-Vitality` is strictly a **Data Consumer**: Reads normalized data from Cloud Firestore. No Fitbit SDK, OAuth flows, or direct Health APIs are invoked.
2. **Strict User Scoping**:
   - All queries and stream subscriptions are scoped to `FirebaseAuth.instance.currentUser!.uid`.
   - Under no circumstances does Male-Vitality query global `users/*` or access any other user's records.
3. **No Fake / Placeholder Metrics**:
   - When no record exists for today, the dashboard displays honest standby indicators (`--`) and `'STANDBY • Waiting for Fitbit or Google Health sync'`.

---

## 2. Canonical Firestore Document Schema

Documents are located at:
```
users/{uid}/healthDaily/{yyyy-MM-dd}
```
*Note: The document ID is formatted in local time as `yyyy-MM-dd` (e.g. `2026-09-17`) to prevent timezone date-boundary shifts.*

### Field Definitions

| Field Name | Type | Unit / Description | Producer (`fit_bit`) | Consumer Fallbacks (`Male-Vitality`) |
|---|---|---|---|---|
| `date` | `String` | `yyyy-MM-dd` local date string | Document ID / `date` | `doc.id` |
| `steps` | `int` | Total steps taken | `int` / `double` | Cast to `int` |
| `calories` | `int` | Total kcal burned | `int` / `double` | Cast to `int` |
| `distanceMeters` | `double` | Distance covered in meters | `double` / `int` | Fallback: `(steps * 0.762)` |
| `activeMinutes` | `int` | Moderate/vigorous active minutes | `int` | `int` |
| `restingHeartRate` | `int` | Resting heart rate in BPM | `int` / `double` | Cast to `int` |
| `sleepMinutes` | `int` | Total duration asleep in minutes | `int` | `sleepFormatted` (`Xh Ym`) |
| `sleepScore` | `int` | Sleep quality score (0–100) | `int` | Nullable |
| `hrvRmssd` | `double` | Heart rate variability (rMSSD in ms) | `hrvRmssd` | Also accepts `avgHrv` |
| `spo2Percentage` | `double` | Blood oxygen saturation (%) | `spo2Percentage` | Also accepts `avgSpo2` |
| `breathingRate` | `double` | Breaths per minute during sleep | `double` | Nullable |
| `source` | `String` | Data source identifier | e.g. `'fitbit_google_health'` | Fallback to `'Fitbit / Google Health'` |
| `updatedAt` | `Timestamp` | Time of last synchronization | `Timestamp` or ISO8601 `String` | Deserialized into `DateTime` |
| `syncStatus` | `String` | Status of payload | e.g. `'synced'` | Nullable |

---

## 3. Firestore Security Rules

To enforce strict user-level isolation and prevent unauthorized access:

```rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    match /users/{uid} {
      allow read, write: if isOwner(uid);

      // Dedicated HealthDaily subcollection
      match /healthDaily/{date} {
        allow read, write: if isOwner(uid);
      }

      match /{allPaths=**} {
        allow read, write: if isOwner(uid);
      }
    }
  }
}
```

---

## 4. Session Lifecycle & Cache Management

To prevent User A's health telemetry from leaking into User B's dashboard upon account switching:
1. **DashboardBloc Reset**: On logout, `ClearDashboardData` is dispatched to the `DashboardBloc`. The active `StreamSubscription` to `watchTodayHealthDaily` is immediately canceled and closed, and the state resets to `DashboardInitial`.
2. **Memory Cache Purge**: `FirestoreService.clearUserCache(userId)` clears all in-memory caches matching `userId-*`.
3. **Screen State Reset**: `UnifiedDashboardScreen.resetState()` clears static cooldown timers and user tracking variables.

---

## 5. Step-by-Step Firebase Console Configuration

Because `Male-Vitality` shares the Firebase project `fitbit-health-dash-81a2f4` with `fit_bit`, its Android package and SHA-1 signing certificates must be registered in the Firebase Console:

### Step 1: Open Firebase Console
1. Navigate to: [Firebase Console](https://console.firebase.google.com/)
2. Select the project: **`fitbit-health-dash-81a2f4`** (Project Number: `589835266478`)

### Step 2: Register Male-Vitality Android App
1. Go to **Project Settings** (gear icon) > **General**.
2. Scroll to **Your apps** and click **Add app** > **Android icon**.
3. Enter the Android package name:
   ```
   com.priyanshu.lifestage.life_stage_health_app
   ```
4. Enter the App nickname:
   ```
   Male-Vitality
   ```
5. Enter the Debug SHA-1 signing certificate fingerprint:
   ```
   b48152247b1c209ea80d010daf8026619e455bcd
   ```
6. Click **Register app**.

### Step 3: Download and Replace `google-services.json`
1. Click **Download google-services.json**.
2. Save the downloaded file to:
   ```
   android/app/google-services.json
   ```
   *(This ensures Android build scripts configure Google Sign-In and Firebase Services with project `fitbit-health-dash-81a2f4`).*

### Step 4: Verify Google Sign-In
1. In Firebase Console, go to **Authentication** > **Sign-in method**.
2. Ensure **Google** provider is enabled.
3. Add the Web Client ID if needed.
