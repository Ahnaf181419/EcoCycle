# EcoCycle

**Gamified waste classification & reward engine.** Citizens snap a photo of a waste item, the app classifies it into `recyclable | organic | hazardous | general` with a confidence score, and awards points for correct participation. Low-confidence results enter a dispute workflow; high-confidence results are rewarded immediately. Profiles, a follow graph, an activity feed and a live leaderboard embed the whole thing in a visible community.

---

## Table of contents

1. [Architecture](#architecture)
2. [Tech stack](#tech-stack)
3. [Project layout](#project-layout)
4. [Setup](#setup)
5. [Running the app](#running-the-app)
6. [Edge functions (server API)](#edge-functions-server-api)
7. [Data model](#data-model)
8. [Key design decisions](#key-design-decisions)
9. [Assumptions & limitations](#assumptions--limitations)
10. [Troubleshooting](#troubleshooting)

---

## Architecture

```
┌───────────────────────────────────────────┐
│            Flutter client                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │   UI     │→ │ Logic    │→ │ Data     │ │
│  │ (Views)  │  │ (Riverpod│  │ (Repos + │ │
│  │          │  │ Notifiers)│  │ Services)│ │
│  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────┬─────────────────────────┘
                  │ HTTPS / Realtime WS
                  ▼
┌───────────────────────────────────────────┐
│              Supabase                      │
│  ┌───────────┐  ┌───────────┐  ┌────────┐ │
│  │ Postgres  │  │   Auth    │  │ Storage│ │
│  │  (RLS +   │  │ (JWT)     │  │ (image │ │
│  │  RPC fns) │  │           │  │  blobs)│ │
│  └───────────┘  └───────────┘  └────────┘ │
│              ┌─────────────────┐           │
│              │ Edge Functions  │           │
│              │  (Deno/TS)      │           │
│              │ classify, admin,│           │
│              │ rewards, social,│           │
│              │ disputes        │           │
│              └────────┬────────┘           │
└───────────────────────┼────────────────────┘
                        │ HTTPS
                        ▼
              ┌───────────────────┐
              │ Google Gemini API │
              │ (vision model)    │
              └───────────────────┘
```

**Client — MVVM + Riverpod layered architecture.** Three strict layers per feature: `ui/` (views), `logic/` (StateNotifiers / providers), `data/` (repositories + models + services). UI layer never touches Supabase directly — it goes through a repository or edge-function service.

**Server — three tiers of logic placement:**
- **Postgres** owns invariants that must hold regardless of the caller: schema constraints, RLS policies, atomic counters (`atomic_redeem_points`, `atomic_increment_follow`), triggers (`handle_new_user`), and cascade delete chains.
- **Edge functions (Deno/TS)** own business logic that needs secrets or multi-step orchestration: Gemini classification, audit logging, account deletion, role changes, config updates.
- **Client** owns display logic and composes reads from Postgres views/streams. It never holds privileged credentials.

**Data flow — classification:**
1. User captures/picks an image in `camera_screen.dart`.
2. `ClassificationNotifier.classifyImage()` uploads the bytes to Supabase Storage (`submissions/<uid>/<file>`).
3. Client invokes `classify` edge function with the signed URL + idempotency key.
4. Edge function calls Gemini, cross-validates against any TFLite hint, applies the config-driven confidence threshold, and writes `submissions` + `classifications` (+ `disputes` if low confidence, + `rewards` if high confidence). Every write lands in `audit_log` in the same transaction.
5. Response includes `submissionId`, `state`, `category`, `confidence`, `pointsAwarded`. Client navigates to the result screen, which lives on a `StreamProvider` subscribed to the submission row for real-time state updates.

---

## Tech stack

| Layer | Tech | Why |
|---|---|---|
| UI | Flutter 3.6+ / Dart 3 | Single codebase, Material 3 |
| State | `flutter_riverpod` 2.5 | Compile-time safe, `.select` narrowing, `autoDispose` cleanup |
| Navigation | `go_router` 14 | Declarative, `refreshListenable` for auth gating |
| Backend | Supabase (Postgres + Auth + Storage + Realtime + Edge Functions) | All-in-one, free tier is enough for hackathon, RLS |
| Edge runtime | Deno + TypeScript | Native to Supabase Functions, zero-config deploy |
| ML — primary | Google Gemini `gemini-2.5-flash` | Vision-capable, cheap, fast, no self-hosting |
| ML — secondary | TFLite hook (stubbed) | Optional on-device cross-validation path |
| Models | `freezed` 2.5 + `json_serializable` 6.8 | Immutable state, codegen’d fromJson/toJson |
| Images | `image_picker`, `cached_network_image`, `image` | Capture, display, resize |

---

## Project layout

```
eco_cycle/
├── lib/
│   ├── main.dart              # Supabase init + runApp
│   ├── app.dart               # Router + auth guard + route-level role checks
│   ├── core/
│   │   ├── constants/         # supabase_constants, route_constants, user_role
│   │   ├── theme/             # AppColors, AppSpacing, AppTypography
│   │   ├── extensions/        # DateTime, String, BuildContext helpers
│   │   ├── errors/            # Shared error types
│   │   └── utils/             # Validators, formatters
│   ├── features/
│   │   ├── auth/              # Sign-in, sign-up, session persistence
│   │   ├── classification/    # Camera, upload, classify, result
│   │   ├── disputes/          # Low-confidence resolution queue
│   │   ├── rewards/           # Balance, redeem, history
│   │   ├── social/            # Profiles, follow, feed, leaderboard
│   │   ├── home/              # Landing / quick actions / recent
│   │   ├── settings/          # Privacy, delete account
│   │   └── admin/             # Role mgmt, config, audit viewer
│   └── shared/
│       └── widgets/           # LoadingOverlay, ErrorView, UserAvatar, ...
├── supabase/
│   ├── schema.sql             # All tables, RLS, triggers, functions
│   ├── migrations/            # Additive SQL migrations
│   └── functions/
│       ├── classify/          # Gemini classification
│       ├── admin/             # Role updates, config, account deletion
│       ├── rewards/           # Atomic redemption + audit
│       ├── disputes/          # Resolution workflow
│       └── social/            # Follow/unfollow with atomic counters
├── assets/images/             # Static images
├── docs/                      # Design docs, audit reports, phase plans
└── pubspec.yaml
```

---

## Setup

### Prerequisites

- **Flutter** 3.6 or newer — `flutter --version`
- **Dart** 3 (shipped with Flutter)
- **A Supabase project** — https://supabase.com → New Project (free tier is fine)
- **A Google AI Studio API key** — https://aistudio.google.com/app/apikey (free tier, vision-enabled)
- **Android Studio / Xcode** for emulators (optional)

### 1. Clone & fetch packages

```bash
git clone <repo-url> eco_cycle
cd eco_cycle
flutter pub get
```

### 2. Provision the Supabase backend

**A. Run the schema** — Supabase Dashboard → SQL Editor → paste the contents of `supabase/schema.sql` → Run. Then paste and run every file in `supabase/migrations/` in chronological order.

**B. Create the storage bucket** — Dashboard → Storage → New bucket named `submissions`, public read enabled.

**C. Deploy edge functions** (dashboard-only, no CLI required):
- Dashboard → Edge Functions → Deploy new function
- For each of `classify`, `admin`, `rewards`, `disputes`, `social`:
  - Name: match the folder name exactly
  - Paste the full contents of `supabase/functions/<name>/index.ts`
  - Deploy
- **Disable "Enforce JWT Verification"** on each function (Details tab → toggle off). Each function does its own `auth.getUser()` check, and leaving gateway verification on can cause spurious `Invalid JWT` rejections.

**D. Set secrets** — Dashboard → Project Settings → Edge Functions → Secrets:
- `GEMINI_API_KEY` = your Google AI Studio key
- (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` are injected automatically — don’t add them.)

### 3. Configure the Flutter client

The client has **no hardcoded credentials**. You must pass the Supabase URL and anon key at launch via `--dart-define` (see [Running the app](#running-the-app)).

Get both values from Dashboard → Project Settings → API.

---

## Running the app

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://<your-ref>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
```

**VS Code users:** save the two defines in `.vscode/launch.json` under `toolArgs`:

```json
{
  "configurations": [
    {
      "name": "eco_cycle",
      "request": "launch",
      "type": "dart",
      "toolArgs": [
        "--dart-define=SUPABASE_URL=https://<ref>.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=<anon-key>"
      ]
    }
  ]
}
```

If you forget the defines, the app throws `StateError: Supabase is not configured` at startup — that’s intentional, not a bug. See `lib/core/constants/supabase_constants.dart`.

**Hot-reload vs hot-restart:** changes to widgets hot-reload (`r`). Changes to providers, Supabase init, or constants need a hot-restart (`R`).

---

## Edge functions (server API)

All functions live at `https://<ref>.supabase.co/functions/v1/<name>`. The Flutter client never calls them directly — it goes through `SupabaseFunctionService` which uses `_client.functions.invoke()` so the user JWT is forwarded automatically.

### `classify` — `POST /functions/v1/classify`

Runs Gemini on an uploaded image, writes all downstream rows, returns the final submission state.

```json
// Request
{
  "action": "classify",
  "imageUrl": "https://...signed-url...",
  "storagePath": "submissions/<uid>/<file>.jpg",
  "idempotencyKey": "uuid-v4",
  "tfliteResult": { "category": "recyclable", "confidence": 0.82 }  // optional hint
}

// Response (high-confidence path)
{
  "submissionId": "uuid",
  "state": "REWARDED",
  "category": "recyclable",
  "subcategory": "PET bottle",
  "confidence": 0.94,
  "pointsAwarded": 15
}

// Response (low-confidence path → dispute)
{
  "submissionId": "uuid",
  "state": "DISPUTED",
  "category": "general",
  "confidence": 0.42,
  "pointsAwarded": 0
}
```

### `rewards` — `POST /functions/v1/rewards`

Atomic point redemption. Calls the `atomic_redeem_points(p_user_id, p_points, p_idempotency_key)` RPC which locks the row, checks available balance, inserts a negative `rewards` row with the idempotency key as a unique constraint, and returns the new balance. Writes `audit_log`.

```json
// Request
{ "action": "redeem", "points": 50, "idempotencyKey": "uuid-v4" }

// Response
{ "availableBalance": 130 }

// Error
{ "error": "Insufficient points", "available": 20 }
```

### `disputes` — `POST /functions/v1/disputes`

Moderator/admin-only. Resolves a pending dispute with `APPROVED | REJECTED | OVERRIDDEN`. On OVERRIDDEN, also updates the original submission’s category. Writes audit.

### `admin` — `POST /functions/v1/admin`

- `action: "deleteAccount"` — any user can delete themselves; admins can delete anyone. Writes audit **before** deletion, best-effort storage cleanup, then cascades via `profiles.uid ON DELETE CASCADE`.
- `action: "updateRole"` — admin only. Updates `profiles.role`, writes audit.
- `action: "updateConfig"` — admin only. Merges provided keys into the `config` row.

### `social` — `POST /functions/v1/social`

Follow/unfollow with atomic follower/following counter updates via `atomic_increment_follow` / `atomic_decrement_follow` RPCs.

---

## Data model

Full schema in `supabase/schema.sql`. Key tables:

| Table | Purpose |
|---|---|
| `profiles` | `uid` (FK to `auth.users`, CASCADE), username, role, points, redeemed_points, classification_count, correct_count, is_private, follower/following counts |
| `submissions` | user_id, image_url, storage_path, category, subcategory, confidence, state, points_awarded, `idempotency_key` UNIQUE, classified_at |
| `classifications` | Per-approach audit record (gemini, tflite, ensemble) linked to a submission |
| `disputes` | submission_id, submitter_id, original_category, secondary_category, status, resolution, resolved_by |
| `rewards` | user_id, submission_id, points, type (`CLASSIFICATION` or `REDEMPTION`), `idempotency_key` UNIQUE |
| `follows` | follower_id, followee_id (unique pair) |
| `audit_log` | event_type, actor_id, actor_role, target_type, target_id, details (jsonb). **Every** business operation writes here synchronously. |
| `config` | Singleton row `key='system'` holding `confidenceThreshold`, `pointsPerCategory`, `duplicateTimeWindowHours`, `maxDailySubmissions`, `leaderboardCacheSeconds` |

**Cascade chain:** deleting a row in `auth.users` cascades to `profiles`, which cascades to `submissions`, `classifications`, `disputes`, `rewards`, `follows`. This is what makes `deleteAccount` a single `auth.admin.deleteUser()` call rather than a manual fan-out.

**Submission state machine:** `SUBMITTED → CLASSIFIED → (VERIFIED | REWARDED | DISPUTED) → RESOLVED | REJECTED | FLAGGED_DUPLICATE`. Invalid transitions are blocked at the edge-function layer before insert.

---

## Key design decisions

1. **No hardcoded Supabase credentials in the repo.** Every Supabase constant comes from `--dart-define`; `assertConfigured()` throws at startup if either is missing. Prevents committed-secret incidents and lets CI build signed release artifacts safely.

2. **Classification logic lives in an edge function, not the client.** The Gemini API key must never ship in a mobile binary. Moving the call server-side also means the confidence threshold, category→points map, and cross-validation rules can be changed without a client redeploy.

3. **Idempotency at two layers.** Every write that could be retried (`classify`, `redeem`) carries a client-generated UUID. Postgres enforces the uniqueness with a constraint, and the edge function short-circuits on the duplicate path by returning the original row. A retried network call never awards double points.

4. **Atomic counters live in SQL functions.** Point redemption, follow/unfollow, and correct-count increments are Postgres functions with `SECURITY DEFINER` and `SELECT ... FOR UPDATE` locks — race-free under concurrent load. Doing this in TypeScript would require distributed locks.

5. **State narrowing with Riverpod `.select`.** Auth-aware screens subscribe with `ref.watch(authProvider.select((s) => s.user))` rather than `ref.watch(authProvider)` so transient `isLoading`/`error` churn during sign-in doesn’t rebuild unrelated widgets.

6. **`StateNotifier.mounted` checks after every await.** Async mutation methods in providers guard against notifier disposal mid-operation (screen popped, autoDispose fired). Prevents setState-after-dispose crashes.

7. **Single repository per domain, not per table.** `SubmissionRepository` wraps both reads and writes across `submissions` + `classifications` so the UI never has to compose cross-table queries.

8. **RLS on every table.** Row-level security is the enforcement floor even when edge functions run with the service role key. A bug in an edge function can’t exfiltrate other users’ data because RLS still blocks the client-side read path.

9. **Audit writes are synchronous, same-request.** Every edge-function action that mutates state writes `audit_log` in the same handler, not via an async queue. Meets the spec requirement that deferred audit writes are not acceptable.

10. **Dashboard-first deploy.** README favors the dashboard workflow over the Supabase CLI because the target audience (hackathon judges, first-time runners) may not have the CLI installed. CLI instructions are intentionally omitted in favor of copy-paste simplicity.

---

## Assumptions & limitations

- **Gemini free tier is rate-limited to ~1500 requests/day/model.** For a demo, this is fine. For production, enable billing on the Google Cloud project attached to the API key or swap in a fallback model.
- **TFLite path is stubbed.** The codebase ships `tflite_service.dart` as a pluggable hook but `_dynamicImport()` returns `null` — the cross-validation branch runs only when the edge function receives a non-null `tfliteResult`. Wiring a real on-device model is a drop-in extension.
- **Duplicate image detection is a stub.** `classify/index.ts` has a commented-out placeholder for MD5 hash matching. The schema has an `image_hash` column; the hash computation is left as an extension point.
- **Leaderboard updates are pull-based, not push.** The client re-queries the profiles-sorted-by-points view; real-time subscriptions exist for submission state but not leaderboard ranking. Meets the <60s staleness requirement in the spec.
- **Accuracy rate is derived from `correct_count / classification_count`.** `correct_count` is currently only incremented on dispute resolution overrides; in a production system you’d want a verification step (moderator spot-check or downstream label) to feed it.
- **Single region.** Everything runs in the Supabase project’s home region. No multi-region failover.
- **Test coverage is minimal.** Hackathon scope; the architecture is test-friendly (all Riverpod providers can be overridden) but comprehensive test suites are out of scope for this submission.

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `StateError: Supabase is not configured` at startup | Missing `--dart-define` args | Pass `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `flutter run --dart-define=...` |
| `FunctionException: Invalid JWT` | Gateway rejecting token — usually wrong project ref, wrong anon key, or `verify_jwt` still enabled | Verify `--dart-define` values match the deployed project exactly. Disable "Enforce JWT Verification" on all five functions (Dashboard → each function → Details). |
| `models/gemini-X is not found for API version v1beta` | Model name deprecated or key on wrong API version | Swap the model name in `classify/index.ts` to `gemini-2.5-flash` (or `gemini-2.5-flash-lite` for higher quota) and redeploy. |
| `GenerateRequestsPerDayPerProjectPerModel` quota hit | Free-tier daily cap | Swap to a different Gemini model (separate quota bucket), rotate to a new API key, or enable billing. |
| `PGRST202: Could not find function atomic_redeem_points` | Migration not run, or client calling with old parameter names | Run `supabase/migrations/*` in order. Client must go through the `rewards` edge function, not call the RPC directly. |
| `auth.getUser()` returns null inside an edge function after disabling verify_jwt | Client isn’t passing the session JWT | Use `_client.functions.invoke(...)` from `supabase_flutter` — it forwards the session automatically. Don’t use raw `http.post`. |
| Image picker returns but classify says "image not available" | OS reclaimed the ImagePicker temp file between capture and classify | Retake the photo. This is flagged in the classification provider with an actionable error message. |
| Delete account fails silently | `admin` edge function not deployed with the latest code | Re-copy `supabase/functions/admin/index.ts` to the dashboard and redeploy. |

---

## License

This project was built for the [Hackathon name] and is currently unlicensed. Treat as "all rights reserved" unless a license is added.
