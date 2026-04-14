# Sipi

Sipi is a mobile study app built around flashcards, testing, progress tracking, and light gamification.

This repository starts from the product wiki and contains the initial MVP foundation.

## MVP scope

Based on the current wiki, the first version should support:

- authentication flow;
- collections CRUD;
- cards CRUD;
- notes on cards;
- local card groups;
- reading mode;
- quiz mode with priority for least-learned cards;
- progress and statistics;
- achievements;
- study plans;
- export of collections without personal stats.

## Suggested stack

Current recommended stack for the first implementation:

- Flutter
- Riverpod
- GoRouter
- Drift or Hive/Isar for local storage
- Supabase or Firebase Auth for authentication

## Project status

This repo is at bootstrap stage.

Already added:

- product-oriented project structure;
- architecture draft;
- domain models;
- feature module placeholders;
- implementation roadmap.

## Structure

- `docs/` - architecture, roadmap, and product notes
- `lib/app/` - app shell, routing, theme
- `lib/core/` - shared utilities, constants, types
- `lib/features/` - feature-first modules
- `test/` - test placeholders

## Next steps

1. Confirm final mobile stack
2. Initialize app dependencies
3. Implement auth flow
4. Implement collections and cards local storage
5. Implement quiz session logic
6. Add progress calculation and profile screens
