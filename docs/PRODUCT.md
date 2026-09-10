# Product scope — Qatar Document Expiry Tracker

Keep future work aligned. **This repository ships v1 only** unless a follow-up explicitly expands scope.

## v1 — Personal offline tracker (this PR)

**Who:** Individuals living in / connected to Qatar who need to renew personal documents on time.

**Jobs to be done**

1. Know which of my documents expire soonest.
2. Get nudged locally before I miss a renewal window.
3. Keep document numbers and photos on-device.

**In scope**

- Flutter app, local-first (Hive), no backend
- Document CRUD: type, optional number, issue/expiry dates, renewal window, notes, optional local photo
- Home list sorted by days remaining with green (>30) / amber (7–30) / red (<7 or expired)
- Local push via `flutter_local_notifications` at configurable intervals (default 30 / 14 / 7 / 1)
- Seeded Qatar templates: QID, Health Card, Residency Permit, Istimara, Driving License, Passport, Vehicle Insurance
- Simple onboarding: pick types → enter expiry dates → home
- Encrypt documents at rest when platform secure storage works; never log document numbers

**Explicitly out of scope for v1**

- Subscriptions / IAP / monetization UI beyond a “Coming soon” stub
- Household / family profiles
- WhatsApp or email reminders
- Accounts, sync, DRF/backend
- Org / B2B dashboards
- Custom design system beyond Material 3

## v1.5 — Lightweight monetization & convenience (future)

Candidates (not built yet):

- Optional premium unlock (IAP) for extra reminder channels or unlimited photo attachments
- Export / backup as encrypted file
- Calendar export (ICS)
- Multilingual UI (EN / AR)
- Stronger biometric app lock

Still **personal**, still primarily on-device.

## v2 — Household & B2B (future)

- Family / household profiles with shared reminders
- WhatsApp / email reminder relays (server-assisted)
- Django REST / sync backend
- Employer / PRO / fleet org views (istimara, insurance, visas at scale)
- Admin audit trails and role-based access

Do not start v2 work in the v1 app module without a dedicated package or service boundary.

## Sensitivity principles (all versions)

- Treat QID and similar identifiers as sensitive PII
- Never commit sample real-looking QID numbers in fixtures or screenshots
- Prefer encryption at rest; if a platform cannot encrypt, surface that clearly in Settings
- Notification copy must not include document numbers
