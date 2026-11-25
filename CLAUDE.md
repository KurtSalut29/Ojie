# Ojie: rules for Claude Code

## Working with Kurt
- Kurt is a solo developer. Explain things in simple Taglish, no deep words.
- Plan first, get approval, then build. Ask before big or hard-to-undo changes.

## Stack
- App: Flutter + Riverpod + go_router + freezed/json_serializable. Android first, then iOS.
- Backend: Supabase (Postgres, Auth, Storage, Edge Functions). Run the CLI with `npx supabase`.
- Offline: PowerSync. The phone's SQLite database is the source the UI reads from.
- AI calls only from Supabase Edge Functions, never from the app.

## Structure
- `app/lib/core/` for shared code; `app/lib/features/<feature>/{data,domain,presentation}` for features.
- Coordinator screens live only in `app/lib/features/coordinator/`. Never mix student and coordinator tools on one screen.
- Tests mirror `lib/` under `app/test/`. Database privacy tests (pgTAP) go in `supabase/tests/`.
- Every database change is a new file in `supabase/migrations/`. Never edit an old migration.
- Only add folders for features being built now (no empty future folders).

## Product rules (from the feature plan, never break these)
- Privacy: coordinators only see hours, time logs, stamps (if on), requirement status, documents, signatures and what the student submits. Moods, unsubmitted journal entries, rank, badges, streaks, outfits, allowance and squad activity stay private.
- Enforce privacy in BOTH Supabase RLS and PowerSync sync rules, and test it.
- No rewards for hours: badges, points and leaderboards reward showing up and checking in, never hours logged.
- Honest records: edited entries are always marked edited; signed weeks are locked.
- AI never makes things up: it only uses what the student logged.
- Every action works offline first and syncs later without double entries (use client-generated UUIDs).
- Root `.env` holds only PUBLIC app values: it is compiled into the app via `--dart-define-from-file`. Server secrets go in `supabase/functions/.env` (or Supabase secrets). Neither file goes into Git.

## Commands
- `cd app && flutter analyze && flutter test`
- `npx supabase start` / `npx supabase db reset` / `npx supabase test db`
