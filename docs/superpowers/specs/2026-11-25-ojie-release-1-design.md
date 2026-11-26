# Ojie Release 1 ("Unang Araw") Design

- **Date:** November 25, 2026
- **Owner:** Kurt Michael S. Salut
- **Status:** Draft for Kurt's review
- **Source:** `docs/Ojie – Feature Plan.docx`, decisions made in the brainstorming session, `docs/quality/ojie-quality-bar.md`

---

## 1. Goal and scope

Release 1 is what a student needs from the **first day of OJT**, plus the basic coordinator tools. It is tested with BiPSU students through Firebase App Distribution (Play Console comes later).

### In Release 1

**Shared**
- Google sign in, role selection (student or coordinator)
- Coordinator verification (manual approval by the Ojie team)
- English and Filipino, light and dark mode
- Offline-first with automatic sync
- Local reminders (time in, check-in, deadlines)
- Download my data, delete my account (Google Play requirement)

**Student**
- OJT profile setup (skippable steps), Meet Ojie
- One-tap time in and time out, breaks and lunch (including a fixed lunch), forgot-to-time-out fix with "edited" mark
- Absent, holiday and work suspension days; overtime and undertime
- Projected end date
- Evening check-in (3 questions), mood sticker, photos with captions
- Requirements checklist (from the coordinator, or Ojie's default list)
- Join a batch with a join code and a consent screen
- Rank titles, island journey map, streaks
- Daily tips, Day 1 prep guide, emergency contacts

**Coordinator**
- "Waiting for approval" state
- Create batches, join codes (show, change, close), remove students
- Intern list with search and filters, student detail (hours, logs, requirement status)
- Requirements and deadlines setup for a batch
- Action-first home ("Aksyon")

### Not in Release 1
Supervisor signature, DTR export, document vault, submit to coordinator and review queue, announcements, batch actions, batch export, badges, milestone celebrations, weekly recap, widget, photo/location stamp, tags and search, app lock, incident log, stuck helper (Release 2); AI report builder, Pro payments, Word export, OJT Wrapped, completion card (Release 3); everything marked v2/v3 in the feature plan.

### Success criteria
- A student can time in and out with no signal and never lose an entry.
- The time-in action is reachable in one tap after opening the app.
- A coordinator sees only what the consent screen promised, proven by database tests.
- Every screen meets the Ojie Quality Bar (11 pillars) with evidence.

---

## 2. Users and roles

| Role | How they get it | What they can do |
|---|---|---|
| Student | Picks "Student" after first sign in | Everything in the student app, only on their own data |
| Coordinator (pending) | Picks "Coordinator" | Sees the waiting screen only. No student data. |
| Coordinator (approved) | Ojie team sets `approved` in the Supabase dashboard | Coordinator app, only for students in their own batches who consented |
| Ojie team (admin) | Supabase dashboard access | Approves coordinators, edits tips and default requirements |

Rules:
- The role and the coordinator status can **never be changed from the app**. They are protected on the server (column privileges plus a trigger). A student cannot become a coordinator by editing data.
- A user picks a role once. Changing role later is done by the Ojie team.
- Verification in Release 1 is manual. The admin sees the coordinator's Google email and, if it matches a known school domain (for example `@bipsu.edu.ph`), a "school email" flag to help decide.

---

## 3. Design system

Approved during brainstorming. Built as Flutter theme tokens; feature code uses tokens only.

### 3.1 Principles
1. Calm base, warm heart: clean structure; warmth comes from Ojie's words, his supportive moments, and soft details, not loud colors.
2. Ojie is a friend, not a sticker: he appears when the student needs him (morning greeting, evening check-in, hard days, milestones), never nags or guilt-trips.
3. Records are trustworthy: hours, logs and requirements are clear and serious. Clarity before fun.
4. Celebrate effort, not hours: no comparison, no pressure.
5. He speaks like a senior friend: casual Taglish, kind, sometimes funny, never mocking.

### 3.2 Color: "Kape't Krema"
All text colors pass WCAG AA (checked).

| Token | Light | Dark |
|---|---|---|
| background | `#FBF6EE` | `#171415` |
| surface | `#FFFFFF` | `#211D1E` |
| surface2 | `#F4ECE1` | `#2B2627` |
| border | `#EADFD0` | `#3A3335` |
| inputBorder | `#9C8B79` | `#807476` |
| text | `#241F1C` | `#F4EEE6` |
| text2 | `#6B5E54` | `#BFB3A8` |
| text3 | `#736457` | `#9A8E84` |
| successSoft / onSuccessSoft | `#E3F1E8` / `#1F5C39` | `#1E3326` / `#9EDDB6` |
| warningSoft / onWarningSoft | `#FBEFD9` / `#7A4800` | `#3A2E17` / `#F2C27A` |
| dangerSoft / onDangerSoft | `#FBE3E1` / `#8C1D18` | `#3A1E1C` / `#FFB4AB` |
| disabled / onDisabled | `#EFE6DA` / `#A3958A` | `#2B2627` / `#6E6264` |
| primary | `#C84E14` (white text) | `#FF7A33` (text `#1A1213`) |
| primaryPressed | `#A9420F` | `#FF9459` |
| primaryText (links) | `#B5470F` | `#FF8A4C` |
| primarySoft / onPrimarySoft | `#FCE6D8` / `#8A3410` | `#3A2418` / `#FFB98F` |
| success | `#2F7D4F` | `#6BC48F` |
| warning | `#9A5B00` | `#F2B24C` |
| danger | `#B3261E` | `#FF8A80` |

Orange is used only for the main action on a screen and the selected tab, never for decoration.

### 3.3 Typography
- **Fraunces** (SOFT 100, weight 600): titles and Ojie's voice.
- **Plus Jakarta Sans**: body, buttons, labels and **all numbers** (tabular figures, so running time does not jitter).
- Fonts are bundled in the app (works offline). All sizes scale with the phone's font setting.

| Style | Font | Size / line height |
|---|---|---|
| display | Fraunces 600 | 32 / 38 |
| title | Fraunces 600 | 24 / 30 |
| heading | Fraunces 600 | 19 / 25 |
| numberXL | Jakarta 800, tabular | 40 / 44 |
| body | Jakarta 400 | 15 / 23 |
| bodyStrong | Jakarta 600 | 15 / 23 |
| caption | Jakarta 500 | 13 / 18 |
| label | Jakarta 700, caps, +0.07em | 11 / 14 |

### 3.4 Spacing, shape, elevation, motion
- Spacing scale (4-point): 4, 8, 12, 16, 24, 32, 48. Screen side padding 20, gap between cards 12.
- Radius: 8 (small chips), 14 (buttons, inputs), 22 (cards), 28 (sheets), full (pills).
- Elevation: separation by borders and tone. Shadows only on floating layers (sheets, dialogs).
- Motion: 100 ms press feedback (scale 0.97), 200 ms small changes, 300 ms screen and sheet transitions (ease-out), spring for Ojie and celebrations. Respects "reduce animations". Animations never block input.
- Touch targets at least 48 × 48 dp.

### 3.5 Icons and mascot
- **Lucide** icons only (one stroke weight). Selected tab: orange icon on a soft orange pill.
- **No emoji** in buttons, labels, tags or navigation.
- Ojie poses (made in ChatGPT from `design/mascot/Ojie.png`, prompts in `docs/design/ojie-pose-prompts.md`): waving, thumbs up, sleepy with coffee, writing, comforting, celebrating, sleeping, oops, plus 5 mood stickers. Stored in `design/mascot/poses/`, exported to the app as WebP at 2 sizes.
- Until a pose exists, the waving pose is used. No screen is blocked by missing art.

---

## 4. Navigation

### 4.1 Student: 4 tabs
| Tab | Contents |
|---|---|
| **Ngayon** (home) | Time card (time in/out, running time, breaks), Ojie's message (morning tip / evening check-in prompt), small progress and streak, nearest deadline |
| **Journal** | Evening check-in, list of entries by date, attendance calendar (absent, holiday, fix a forgotten time out) |
| **Reqs** | Requirements checklist with deadlines and status |
| **Journey** | Island map, rank, streak, projected end date |

Top right of Ngayon: **Tulong** (Day 1 guide, emergency contacts; one tap, works offline) and **Profile** (OJT profile, join a batch, settings, download data, delete account).

### 4.2 Coordinator: 4 tabs
| Tab | Contents |
|---|---|
| **Aksyon** (home) | Only items that need action: inactive students, missing requirements near deadline, new members. Batch switcher at the top. |
| **Interns** | Search, filters (Behind, Missing reqs, Inactive), student detail |
| **Reqs** | Batch requirements and deadlines, done/missing count per requirement |
| **Batches** | Create batch, join code (show, change, close), switch batch |

A pending coordinator sees only the "Sandali lang po!" waiting screen.

### 4.3 First-run flow
Sign in with Google → pick role → (student) OJT profile wizard, every step skippable → Meet Ojie (skippable, under 30 seconds) → Ngayon. (Coordinator) → waiting screen → after approval, Batches (create the first batch).

---

## 5. Architecture

```
Flutter app (Riverpod, go_router)
  presentation  → screens and widgets, read state from providers
  domain        → plain Dart models (freezed) and rules (hours, streaks, end date)
  data          → repositories: read/write the local PowerSync SQLite database
        │                         ▲
        │ local writes             │ live queries (watch)
        ▼                         │
  PowerSync SQLite on the phone (source of truth for the UI)
        │ upload queue (SupabaseConnector)      ▲ download (Sync Streams, per user)
        ▼                                       │
  Supabase Postgres (RLS on every table) ──► PowerSync Service
  Supabase Auth (Google) · Storage (photos) · Edge Functions (delete-account)
```

- The UI never waits for the network. Every write goes to SQLite first.
- Domain rules (hours, streaks, rank, end date) are pure Dart functions with unit tests.
- Screens get data from Riverpod providers backed by repositories. The temporary global `db` from setup moves into a provider.
- Routing: go_router with a redirect guard based on auth state, role and coordinator status. Student and coordinator route trees are separate.
- Riverpod is used without code generation (plain providers) to keep the build simple; `freezed` and `json_serializable` still use `build_runner`.
- Packages added in Release 1: `flutter_riverpod`, `go_router`, `freezed`, `json_serializable`, `intl`, `flutter_localizations`, `lucide_icons_flutter`, `flutter_local_notifications`, `timezone`, `image_picker`, `flutter_image_compress`, `connectivity_plus`, `share_plus`. (Exact package names and versions are checked against pub.dev before adding.)

---

## 6. Data model

All ids are UUIDs made on the phone. All tables have `created_at` and `updated_at`. Every table has RLS on, explicit grants, and is part of the `powersync` publication.

### 6.1 Tables

**profiles** (one per user, created by a trigger on sign up)
`id` (= auth user id), `full_name`, `avatar_url`, `role` (`student` | `coordinator` | null until picked), `coordinator_status` (`pending` | `approved` | `rejected` | null), `locale` (`en` | `fil`), `onboarded_at`
- Users may update only `full_name`, `locale`, `onboarded_at`, and set `role` once (from null). `coordinator_status` is set to `pending` by the server when role becomes `coordinator`; only the admin can change it.

**schools** (seeded; read-only for users)
`id`, `name`, `short_name`, `email_domain`

**ojt_profiles** (student, one row)
`user_id`, `school_id`, `program`, `required_hours`, `start_date`, `work_days` (e.g. Mon–Fri), `shift_start`, `shift_end`, `fixed_lunch_start`, `fixed_lunch_end` (nullable), `deduct_breaks` (default true), `count_overtime` (default false), `host_company`, `supervisor_name`, `timezone` (default `Asia/Manila`)

**time_entries**
`id`, `user_id`, `work_date`, `time_in`, `time_out` (null while open), `source` (`tap` | `manual`), `is_edited`, `edit_reason`, `edited_at`, `recorded_offline` (bool), `server_received_at` (set by the server)
- Only one open entry per user (partial unique index on `user_id` where `time_out is null`).
- `time_in < time_out`; neither can be later than `server_received_at` plus 2 minutes (no future times).

**breaks**
`id`, `time_entry_id`, `user_id`, `started_at`, `ended_at`

**day_marks**
`id`, `user_id`, `date`, `kind` (`absent` | `holiday` | `suspension`), `note`. One per user per date.

**journal_entries**
`id`, `user_id`, `entry_date`, `did`, `learned`, `problems`, `mood` (`happy` | `productive` | `okay` | `tired` | `stressed`, nullable), `submitted_at` (always null in Release 1)

**journal_photos**
`id`, `journal_entry_id`, `user_id`, `storage_path`, `caption`, `taken_at`. Files live in a private Storage bucket `journal-photos/<user_id>/...`.

**batches**
`id`, `coordinator_id`, `school_id`, `name`, `term`, `join_code` (8 characters, no look-alike letters), `join_open`, `closed_at`

**batch_members**
`batch_id`, `student_id`, `joined_at`, `consent_version`, `consented_at`, `left_at`
- Created only through the `join_batch(code, consent_version)` database function, which checks the code, that the batch is open, and records consent. Students cannot insert rows directly. Leaving sets `left_at`.

**batch_requirements**
`id`, `batch_id`, `title`, `description`, `due_date`, `sort_order`

**default_requirements** (seeded; Ojie's default list based on CHED CMO 104 s. 2017)
`id`, `title`, `description`, `sort_order`

**student_requirements** (the student's own checklist)
`id`, `user_id`, `batch_requirement_id` (nullable), `default_requirement_id` (nullable), `title`, `due_date`, `status` (`todo` | `done`), `done_at`
- When a student joins a batch, rows are created from the batch's requirements; when a coordinator adds a requirement, rows are added for every member (server trigger). Students without a batch get the default list on first open.

**emergency_contacts**
`id`, `user_id`, `name`, `phone`, `relation`

**daily_tips** (seeded, read-only)
`id`, `stage` (`first_week` | `middle` | `last_week`), `text_en`, `text_fil`, `active`

**device_tokens** (push)
`id`, `user_id`, `token`, `platform`, `last_seen_at`

### 6.2 What syncs to whom (PowerSync Sync Streams)
| Stream | Who | Data |
|---|---|---|
| own data (auto) | every user | their own rows in all personal tables |
| reference (auto) | every user | schools, daily_tips, default_requirements |
| coordinator batches (auto) | approved coordinators | their batches, batch_requirements |
| coordinator students (auto) | approved coordinators | for active, consented members of their batches: profile name/avatar, ojt_profiles (hours fields only), time_entries, breaks, day_marks, student_requirements |

**Never synced to a coordinator:** journal_entries, journal_photos, moods, emergency_contacts, streaks, rank. These rules are mirrored exactly in RLS and tested.

### 6.3 Computed on the phone (not stored)
Daily hours, total hours, streak, rank, island position, projected end date. They are derived from the tables above with pure functions, so they always match the records.

---

## 7. Time rules

- **Day hours** = (time_out − time_in) − breaks inside that span (if `deduct_breaks`) − the fixed lunch if set and no break was logged during it (never deducted twice). The app shows how the number was computed.
- **Open entry**: running time shown live. Time in is blocked while an entry is open.
- **Overtime**: time beyond `shift_end` counts only if `count_overtime` is on; otherwise shown as "not counted".
- **Absent / holiday / suspension**: do not add hours; holidays and suspensions are not absences; all change the projected end date.
- **Forgot to time out**: if an entry is open past `shift_end` + 3 hours, Ojie asks to fix it. Fixing requires a reason; the entry gets `is_edited = true` (the server sets it on any time change and it can never be cleared). Edits to entries older than 7 days are marked "late edit".
- **Projected end date** = walk forward over scheduled work days from today, skipping marked holidays, adding the average scheduled day length until required hours are reached. Shown as "Mga March 14" (an estimate, never a promise).
- **Clock honesty**: the server records `server_received_at` on every entry. Entries made offline are marked `recorded_offline`. Times later than the receive time are rejected. Coordinators see the offline and edited marks. Ojie is transparent instead of trying to block every trick.

### Progress and fun (no rewards for hours)
- **Rank** is a progress label, not a reward: it follows the percent of required hours (0, 10, 25, 40, 60, 80, 100% → Bagong Salta, Taga-Xerox, Kape Runner, Excel Warrior, Paborito ni Boss, Halos Empleyado, OJT Legend). Never compared with others.
- **Island map**: 10 stops spaced evenly over the required hours, each with a fun fact.
- **Streak** (the real reward): consecutive scheduled work days with an evening check-in. Weekends, days off, holidays and suspensions never break it. 2 streak savers per month. Ending a streak shows a kind message, never guilt.

---

## 8. Offline, sync and files
- All writes go to SQLite and the PowerSync upload queue; uploads retry automatically.
- Duplicate uploads are ignored (the id already exists); permanently rejected changes are reported to Crashlytics and shown to the user.
- A small sync pill shows "Naka-sync" or "N hindi pa naka-sync".
- Photos: compressed on the phone (max 1600 px, WebP/JPEG ~80%), queued with the PowerSync attachments queue, uploaded on Wi-Fi only unless the user allows mobile data.
- Conflicts: last write wins per row (one person edits their own data).
- Sign out wipes the local database (`disconnectAndClear`).

---

## 9. Notifications
- **Local** (scheduled on the phone, work offline): time-in reminder 10 minutes after shift start if not timed in; check-in reminder 30 minutes after time out; deadline reminders 3 days and 1 day before. Skipped on days off and holidays and once done.
- Quiet hours 9 PM – 7 AM by default; at most 3 reminders a day. Each type can be turned off.
- **Push (FCM)**: only "your coordinator account is approved" in Release 1.

---

## 10. Account, data and privacy
- **Consent screen** before joining a batch lists exactly what the coordinator can and cannot see (section 6.2), in plain Filipino/English, with a version number stored with the consent.
- **Leave batch** any time: the coordinator immediately loses access (RLS uses `left_at is null`).
- **Download my data**: exports the user's records as JSON and CSV through the share sheet (works offline from the local database).
- **Delete account**: an Edge Function (`delete-account`) deletes the auth user, all rows (cascade) and Storage files after a confirmation; the app then clears the local database.
- No journal text, names or moods in analytics or crash logs.

---

## 11. Security (threats and defenses)

| Threat | Defense | Proof |
|---|---|---|
| Student reads another student's data | RLS: `user_id = auth.uid()`; sync streams per user | pgTAP test |
| Student becomes coordinator | role/status columns not writable; trigger sets `pending` | pgTAP test |
| Pending coordinator sees students | RLS requires `coordinator_status = 'approved'` | pgTAP test |
| Coordinator sees journal or moods | no policy or stream exposes them | pgTAP test |
| Coordinator keeps access after student leaves | RLS checks `left_at is null` | pgTAP test |
| Joining a batch without a valid code | only `join_batch()` can insert; checks open code | pgTAP test |
| Guessing join codes | 8 chars from 31 symbols (~850 billion combos); `join_batch` rate-limited per user | pgTAP test |
| Editing hours silently | server sets `is_edited`, cannot be cleared; edits keep a reason | pgTAP test |
| Future or fake times | server rejects times after receipt; offline mark shown | pgTAP test |
| Reading someone's photos | private bucket, path-based Storage policies | pgTAP test |
| Leaked secrets | only public values in the app; server secrets in Supabase secrets | review |
| Shared phone | sign out wipes local data; app lock comes in Release 2 | manual test |

Before the BiPSU pilot: Supabase Pro (no pausing, backups), a separate production Supabase project and PowerSync production instance, a release signing key stored safely, API key restrictions in Google Cloud, Supabase auth rate limits reviewed.

---

## 12. States and copy
Every screen designs loading, empty (sleeping Ojie), error (oops Ojie, what to do next), offline (works normally, sync pill shows pending) and success states. Copy lives in ARB files (English and Filipino); Ojie's lines are written in his voice and reviewed by Kurt.

---

## 13. Testing
- **Unit:** hours with breaks and fixed lunch, overtime, projected end date, streak with holidays and savers, rank, island position, join code format.
- **Widget:** each screen in light/dark, large font, empty/error/offline states.
- **Integration (on device):** sign in, onboarding, time in/out offline then sync, check-in with photo, join batch with consent, coordinator sees the student but not the journal.
- **Database (pgTAP):** every row in the security table above.
- **Definition of Done:** the checklist in `docs/quality/ojie-quality-bar.md`.

---

## 14. Build order (for the implementation plan)
1. App foundation: theme tokens and components, fonts, Lucide, l10n, Riverpod and router skeleton, sync pill.
2. Database: all migrations, RLS, functions, seeds, pgTAP tests, sync streams. Drop `connection_checks`.
3. Auth and onboarding: sign in, role, OJT profile wizard, Meet Ojie, coordinator waiting screen.
4. Time tracking: time card, breaks, day marks, fixes, hours rules, projected end date.
5. Journal: evening check-in, mood, photos (attachments queue).
6. Requirements: default list, batch requirements, checklist.
7. Batches: coordinator create/join code, student join with consent, leave.
8. Journey: rank, island map, streak.
9. Companion: daily tips, Day 1 guide, emergency contacts, local reminders.
10. Coordinator: Aksyon home, Interns list and detail, Reqs.
11. Account: settings, download data, delete account.
12. Pilot readiness: production projects, release signing, App Distribution.

## 15. Open items (do not block the start)
- Ojie pose art (Kurt, in progress).
- BiPSU's next OJT batch date (sets the deadline).
- The real Ojie default requirements list wording (draft from CMO 104, Kurt reviews).
- Daily tips and Day 1 guide content (Claude drafts in Ojie's voice, Kurt reviews).
