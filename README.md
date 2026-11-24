# Ojie

Ojie is a mobile app that helps Filipino students get through their OJT: time tracking, a daily journal, requirements and a friendly mascot companion. It has two users, the **student** and the **OJT coordinator**. Android first, then iOS.

The full feature plan is in [docs/Ojie – Feature Plan.docx](docs/Ojie%20–%20Feature%20Plan.docx).

## Project structure

| Folder | What is inside |
|---|---|
| [app/](app/) | The Flutter app (student and coordinator) |
| [app/lib/core/](app/lib/core/) | Shared code: config, database (PowerSync), router, theme, languages, notifications, shared widgets |
| [app/lib/features/](app/lib/features/) | One folder per feature, each with `data/`, `domain/` and `presentation/` |
| [app/lib/features/coordinator/](app/lib/features/coordinator/) | Coordinator-only screens |
| [supabase/](supabase/) | Database migrations, seed data, Edge Functions and database tests |
| [powersync/](powersync/) | Sync rules: which data goes down to each user's phone |
| [website/](website/) | Landing page and privacy policy |
| [design/](design/) | Original mascot art and design sources |
| [docs/](docs/) | Feature plan, design specs and build plans |

Inside each feature:

- `data/` reads and saves data (local database, Supabase)
- `domain/` holds models and rules, like how hours are computed
- `presentation/` holds screens, widgets and Riverpod controllers

## Tech stack

Flutter, Riverpod, go_router, freezed · Supabase (Postgres, Auth, Storage, Edge Functions, RLS) · PowerSync (offline-first sync) · Firebase Cloud Messaging and Crashlytics · RevenueCat (later)

## Getting started

Requirements: Flutter (stable), Git, Docker Desktop, Node.js.

```bash
# 1. Secrets
cp .env.example .env        # then fill in the values

# 2. Local database
npx supabase start

# 3. App
cd app
flutter pub get
flutter run --dart-define-from-file=../.env
```
