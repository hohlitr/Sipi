# Sipi Architecture Draft

## Product direction

Sipi is a study assistant focused on:

- flashcard learning;
- repeated testing;
- tracking weak material;
- progress visibility;
- lightweight gamification.

## First architecture choice

Recommended first implementation:

- mobile-first Flutter app;
- feature-first module structure;
- local-first data model;
- optional backend for auth and sync.

## Core domains

### Auth
- sign up
- sign in
- optional password reset

### Collections
- create, edit, delete collections
- title and description

### Cards
- question
- answer
- optional note
- learning stats

### Groups
- local grouping inside collections

### Quiz
- generate sessions from weakest cards
- optional hide notes mode
- save attempts and correct answers

### Progress
- per-card mastery
- per-collection progress
- global statistics

### Achievements
- configurable milestones

### Study plans
- target progress for a date range

### Export
- collection export without personal stats

## Suggested phases

1. Local MVP
2. Auth + sync
3. Parent/teacher features
4. Collaboration and sharing
