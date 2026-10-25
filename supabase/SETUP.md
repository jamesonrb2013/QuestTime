# QuestTime cloud setup

QuestTime is currently hosted on GitHub Pages, which can serve the web app but cannot securely run its own login/database server. The planned free-friendly backend is Supabase Auth + Postgres.

## Cost and safety rules

- Use only the Supabase **Free** plan. Do not upgrade, add a payment method, or enter card details.
- If signup/project creation asks for a payment card or a paid upgrade, stop and do not proceed.
- Never share a password, service-role key, secret key, or recovery code.
- The browser may use only the project's public **publishable key** (or legacy anon key). Never put a service-role/secret key in this repository.
- Cloud save access is restricted by the row-level security policies in `schema.sql`.

## Setup (one-time)

1. Create a Supabase account and start a project on the Free plan only.
2. Name the project `QuestTime`. Pick a strong database password and keep it private; it is not the QuestTime login password.
3. In the project dashboard, open **SQL Editor**, create a query, paste all of `schema.sql`, and run it.
4. Open **Project Settings → API** (or the project's Connect/API details panel). Copy the **Project URL** and the **publishable key**. A legacy `anon` key is also public/client-safe, but never copy a `service_role` or secret key.
5. In **Authentication → URL Configuration**, set the Site URL to `https://jamesonrb2013.github.io/QuestTime/` and add that exact URL to the allowed redirect URLs.
6. Do not share any password or secret. Send only the Project URL and publishable/anon key to configure the public client.

## What this database supports

One private save record per signed-in user, with row-level security enforcing ownership. The app can sync coins, XP, quests, achievements, rewards, and history as a single save document. The app should retain local storage as a temporary offline cache and for migration of existing progress.

## Current status

This repository file prepares the database schema only. Login and cloud sync are not active until the project is created, the schema is run, and the public project URL/key are configured in the app. Existing local progress has not been changed.
