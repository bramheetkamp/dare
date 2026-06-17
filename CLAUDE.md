# CLAUDE.md — Dare

Guidance for Claude Code (claude.ai/code) when working in this repository.

## What this is

**Dare** is an iOS social app for posting and completing *dares/challenges*. Users follow each
other, create challenges, post photo/video responses, like, comment, and (new) build daily
streaks and earn points for staying active.

- **Platform:** iOS (SwiftUI, Swift 5.9+)
- **Min toolchain:** Xcode 16 (the project uses `objectVersion = 70` filesystem‑synchronized
  groups — **new `.swift` files under `Dare/`, `DareTests/`, `DareUITests/` are added to the
  build automatically; you do NOT need to edit `project.pbxproj`**)
- **Backend:** Firebase — Auth, Firestore, Storage (`GoogleService-Info.plist`)
- **Image loading:** Kingfisher (SPM)
- **Tests:** Swift Testing (`import Testing`, `@Test`) for unit tests in `DareTests/`,
  XCTest for `DareUITests/`.

## Product Vision & Direction

> Full strategy + market analysis: [`docs/MARKET_ANALYSIS.md`](docs/MARKET_ANALYSIS.md).

Dare is evolving from "post a dare" into **a lowkey window into what drives the people around
you — and a mirror on your own growth over time.** The questions the app answers:

- For your friends: *What are they into? What are they challenging themselves with? What drives them?*
- For new/random people: *get to know them through what drives them* — a shared or local goal.
- For yourself: *Am I actually growing?* — see your progress vs. a year ago.

It is **not** a workout-posting app. The core interaction is dead simple: **a quick picture + a
short note** ("5am bake test 🥐", "first clean pull-up"), then a "✅ good/done" tap.

**Design principles:**
- **Lowkey by default** (like Locket): small circle, no public like-counts, no pressure to perform.
  Lurking is fine.
- **Goals & journeys over one-off dares:** you *join* or start a goal ("learn to bake",
  "woodcutting master", "AI master", "builder") and post quick updates toward it over time.
  Goals can be **collective** — friends or a **local small group** supporting each other, not
  competing.
- **Weekly ritual, never a daily mandatory prompt** (BeReal died of daily-prompt fatigue).
- **Strangers stay in their own room** (a Discover/groups surface), never in the intimate feed.
- **"You, a year ago" is the emotional core / moat:** resurface what drove you a year ago and how
  far you've come. Powered for free by the timestamped quick-pic-+-note primitive.

**Three rings** (see analysis doc): Ring 1 "Today" = calm close-friends grid + widget (daily,
retention); Ring 2 "Goals & Journeys" = the catchy ongoing ritual (engagement); Ring 3 "Discover"
= opt-in strangers/local groups chasing the same goals (growth). Existing gamification
(streaks/points/levels) becomes a **mastery trophy case**; the streak counts weekly goal-updates,
not daily opens.

**Build order (current target):** retire the `Feed 2`/`TestFeed` fork → reshape home into a
grid + active-goal hero card → evolve `Challenge` into a joinable `Goal` with progress updates →
2-tap quick-post → retie `StreakCalculator` to weekly goal updates → "a year ago" resurfacing →
WidgetKit widget → Discover/groups.

## Commands

```bash
# Build (replace destination as needed)
xcodebuild -project Dare.xcodeproj -scheme Dare \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Unit + UI tests
xcodebuild -project Dare.xcodeproj -scheme Dare \
  -destination 'platform=iOS Simulator,name=iPhone 16' test

# Open in Xcode
open Dare.xcodeproj

# Fire a deep link at a running simulator
xcrun simctl openurl booted "dare://challenge?id=<challengeId>"
xcrun simctl openurl booted "dare://post?id=<postId>"
xcrun simctl openurl booted "dare://profile?id=<userId>"
xcrun simctl openurl booted "dare://home"
```

## Architecture

**MVVM + observable stores + a central router.**

```
Firestore  ──Service──▶  Store (@Published cache)  ──▶  ViewModel  ──▶  View
```

- **Entry:** `DareApp.swift` configures Firebase and injects six `@StateObject`s as
  environment objects: `AuthViewModel`, `AppRouter`, `PostsStore`, `UsersStore`,
  `ChallengesStore`, `PlayerManager`. Deep links arrive via `.onOpenURL`.
- **Auth gate:** `ContentView` switches on `AuthViewModel.authState`
  (`.loading` / `.authenticated` / `.unauthenticated`). First‑run users see `OnboardingView`
  before the login screen (gated by `@AppStorage("hasSeenOnboarding")`).
- **Navigation:** `AppRouter` owns a `NavigationPath`, sheets, full‑screen covers, and the
  selected tab index. Destinations are the `AppDestination` enum; `ViewFactory` maps a
  destination to its view. Deep links are parsed by `AppDestination.from(url:)`.
- **Tabs:** `MainTabView` — Feed, Explore, Profile (+ an experimental `TestFeed`).
- **Stores** (`PostsStore`, `UsersStore`, `ChallengesStore`) are in‑memory upsert caches keyed
  by document id. Views read from the store; services write to Firestore and feed the store.

### Key folders
- `Dare/Core/Feed/` — the production feed (`FeedViewModel`, `FeedListView`, `PostRow*`).
- `Dare/Core/Feed 2/` — an experimental TikTok‑style prototype (`TestFeed`), hardcoded data.
- `Dare/Core/Gamification/` — streak/points UI (`StreakBadgeView`).
- `Dare/Core/Onboarding/` — first‑run explanation flow.
- `Dare/Service/` — all Firestore/Storage access. **Anything touching Firebase lives here.**
- `Dare/Model/` — `User`, `PublicPost`, `Challenge`, `Comment`, `ChallengeCategory`,
  `Gamification` (pure `StreakCalculator` + `GamificationLevel`).
- `Dare/Utils/` — `AppRouter`, `ViewFactory`, `AppDestination`, extensions, styling.

## Conventions

- **Firebase only in `Service/`** (and `GamificationService`). ViewModels call services and
  publish results; views never touch Firestore directly.
- **Keep pure logic out of Firebase types** so it stays unit‑testable. Example: streak and
  level math live in `Gamification.swift` (no Firebase import) and are covered by tests; the
  Firestore plumbing lives in `GamificationService.swift`.
- **Tests must not call `Firestore.firestore()` / `Auth.auth()`** unless Firebase is
  configured — those crash without `FirebaseApp.configure()`. Unit tests target pure logic
  (deep‑link parsing, streak/level math, date formatting).
- **Models** are `Decodable` with `@DocumentID var id: String?`. New optional fields are safe
  to add (old documents decode to `nil`).
- **New files** drop into the right folder under `Dare/` — they are picked up by the build
  automatically (synchronized groups). No `.pbxproj` surgery.

## Gamification (retention)

- `User` carries optional `points`, `currentStreak`, `longestStreak`, `lastActiveAt`.
- `StreakCalculator` decides streak transitions (same day → unchanged, next day → +1,
  gap → reset to 1). `GamificationLevel` maps points → level + progress.
- `GamificationService.recordDailyActivity(uid:)` is called once per app open
  (`AuthViewModel.recordDailyActivity()`); it bumps the streak/points only on a new calendar
  day and refreshes the cached user.
- `StreakBadgeView` surfaces the flame + points in the main toolbar.

## Deep linking

Custom scheme **`dare://`** (declared in `Info.plist`). Routes are matched on the URL host
(`dare://<route>?id=<id>`), falling back to the path. Supported routes: `challenge`, `post`,
`comments`, `category`, `profile`, `profileSettings`, `createPost`, `createChallenge`, `home`,
`explore`, `searchPeople`, `registration`. `AppRouter.createDeepLink(for:)` builds share URLs.
For Universal Links later: add an Associated Domains entitlement + `apple-app-site-association`
and extend `AppDestination.from` (it already accepts `https` paths).

## Known tech debt (good first targets)

- `FriendService.fetchRecommendedFriends` is O(n²) over the follow graph.
- `UserService.fetchUsers()` and the non‑paginated `CommentService.fetchComments` are unbounded.
- Stores have no eviction/TTL.
- `Feed 2` / `TestFeed` is a prototype — finish or remove it.

## Backlog / ideas

> Standing menu of self-contained increments to pull from: [`docs/IDEAS.md`](docs/IDEAS.md)
> (widgets, notifications, competitions, ads positioning, sponsored challenges, A/B testing,
> view logging/analytics, Sign in with Apple, and polish). The hourly routine
> ([`docs/ROUTINE_PROMPT.md`](docs/ROUTINE_PROMPT.md)) reads it each run. Check items off when shipped.
