# QuestTime ✨

**A free, mobile-friendly quest and screen-time rewards tracker.**

QuestTime turns real-life tasks into quests. Complete quests to earn coins and XP, level up, unlock achievements, and redeem coins for tracked screen-time rewards.

## Features in the MVP

- Mobile-first dashboard
- Built-in and custom quests
- Coins, XP, levels, and progress bar
- Daily quest streaks
- Achievement badges
- Rewards shop with 15, 30, 60, and 90-minute rewards
- Earned-minute balance and redemption history
- Activity history and JSON backup export
- Local browser storage; no account, backend, paid API, or subscription required

## Run it

Open `index.html` in a browser, or publish this repository with GitHub Pages.

### Enable GitHub Pages

1. Open this repository's **Settings**.
2. Select **Pages** under **Code and automation**.
3. Under **Build and deployment**, choose **Deploy from a branch**.
4. Choose branch **main** and folder **/(root)**, then click **Save**.
5. Wait for the deployment to finish. The site should be available at `https://jamesonrb2013.github.io/QuestTime/`.

## Important limitations

This is a web app, not a native iOS Screen Time controller. Redeeming a reward tracks minutes inside QuestTime; it does **not** currently block or unblock other iPhone apps or enforce a timer. Native blocking would require a separate iOS app and Apple's Screen Time APIs and entitlements.

Progress is stored in the current browser on the current device. It is not synced across devices. Export a backup before clearing browser data.

## Privacy

QuestTime's MVP has no server-side account or analytics. Quest data and progress are stored locally in the browser with `localStorage`. Anyone with access to the same browser profile may be able to view or change that data.

## Project status

MVP v0.1.0 — actively being built.
