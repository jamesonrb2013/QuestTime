# QuestTime ✨

**A free, mobile-friendly quest and screen-time rewards platform.**

QuestTime turns real-life tasks into quests. Complete quests to earn coins and XP, level up, unlock achievements, and redeem rewards.

## Current features

- Email/password accounts with Supabase authentication
- Per-account cloud save (requires running `supabase/schema.sql`)
- Built-in and custom quests, coins, XP, levels, streaks, and achievement badges
- Rewards shop and tracked earned-minute balance
- Customizable app access rules: choose apps that require credits, set a per-app coin cost and pass length, and add your own app entries
- Virtual timed app passes and app-pass history
- JSON backup export and progress reset

## Run it

GitHub Pages: https://jamesonrb2013.github.io/QuestTime/

## Supabase setup

1. Open the Supabase project SQL Editor.
2. Paste and run [supabase/schema.sql](supabase/schema.sql).
3. In Supabase Authentication URL configuration, set the Site URL to `https://jamesonrb2013.github.io/QuestTime/` and add it as an allowed redirect URL.

Only use the publishable browser key in `index.html`. Never put a service-role key or database password in browser code.

## App locking status

The web App Lock page stores each user's app list, whether an app should require coins, the credit price, the pass duration, and virtual passes. **The website cannot actually block or unblock iPhone apps.** Real blocking requires the native iOS Screen Time frameworks, Apple's Family Controls entitlement, explicit user authorization, and monitor/shield extensions.

Native groundwork and setup notes: [ios/QuestTimeScreenTime/README.md](ios/QuestTimeScreenTime/README.md).

## Privacy

QuestTime uses Supabase authentication and a per-user row protected by Row Level Security when the database schema is configured. Progress is also cached in the browser for responsiveness. Export a backup before clearing browser data. App-lock preferences on the website are not enforced by iOS.

## Status

Active build. The website is an evolving platform; native iOS blocking is not complete yet.
