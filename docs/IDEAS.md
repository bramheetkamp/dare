# IDEAS.md — backlog for the self-improving routine

A running menu of high-value, mostly self-contained increments for the hourly routine
(see [`ROUTINE_PROMPT.md`](ROUTINE_PROMPT.md)) to pull from. Each item is sized to be shippable
in a single green run. Pick **one**, keep it small, follow repo conventions
([`../CLAUDE.md`](../CLAUDE.md)), and always leave the build green.

**How to use this file:**
- Treat the *vision-advancing* items in [`../CLAUDE.md`](../CLAUDE.md) (Three Rings, goals,
  "you a year ago") as priority (a). The items here are priority (a)/(b) candidates that don't
  yet live in the build order.
- When you ship one, check it off (`- [x]`) with the commit/PR short SHA, or delete it.
- Prefer items that are **testable as pure logic** so they come with Swift Testing coverage.
- Don't start anything that needs new third-party SDKs, paid services, or `.entitlements`/
  capability changes without leaving a clear note — those may need the human (signing, App Store
  Connect, Firebase console, AdMob account, etc.).

Legend: 🟢 small / self-contained · 🟡 medium · 🔴 needs human setup (signing, console, account).
Ring tags map to the product vision in `../CLAUDE.md`.

---

## ⭐ NEXT PRIORITY — Locket-style quick-post + photo card view (Ring 1)

> The owner has explicitly asked for this next. Do this before anything else.

- [x] 🟡 **Locket-style quick-post sheet (`QuickPostView`)** — replace the current multi-section
  form (`CreatePostView`) with a photo-first, one-screen posting experience:

  **What to build:**
  - New file: `Dare/Core/Explore/Create/Post/Views/QuickPostView.swift` + matching
    `QuickPostViewModel` if needed (or reuse `CreatePostViewModel` directly).
  - **Screen layout (top → bottom):**
    1. Large photo card (~65 % of screen height): rounded rectangle, `scaledToFill`, clips to
       shape. When no photo is selected yet show a dark placeholder with a centred camera icon
       (`photo.on.rectangle`) and "Tap to add photo" label — tapping opens `PhotosPicker`.
       Once selected, the card shows the photo and a small "change" button overlaid top-right.
    2. Note field directly below the card: single-line `TextField`, placeholder `"What's the
       vibe?"`, auto-focuses as soon as a photo is picked. This IS the post title — maps to the
       `title` param of `CreatePostViewModel.createPost`.
    3. Sticky bottom bar: "Post" button (full-width, brand colour, disabled until a photo +
       non-empty note). Shows a `ProgressView` while uploading.
  - **No** location, date, extra caption, or challenge-card sections. Those fields pass as
    empty strings / defaults to the existing service call — nothing breaks on the backend.
  - Wire it in: update `ViewFactory` so `.createPost(challengeId:)` presents `QuickPostView`
    instead of `CreatePostView`. Keep `CreatePostView` in the tree (don't delete it) in case
    it is referenced elsewhere; just stop routing to it from the main flow.
  - The old `CreatePostView` becomes dead-code for now — that's fine; it can be cleaned up in a
    later run.

  **Also build — the matching full-screen post viewer (`LocketPostView`):**
  - New file: `Dare/Core/Detail/Post/Views/LocketPostView.swift`
  - A full-screen card view (used when tapping a `CircleTileView` in `TodayView`):
    1. Photo fills the entire screen edge-to-edge (`scaledToFill`, ignores safe area).
    2. Bottom scrim gradient (black 0 % → 55 % over bottom third).
    3. Over the scrim:
       - Avatar (32 pt circle) + username + time-ago on one line.
       - Note text below (`.title3.weight(.semibold)`, white, 2-line limit).
       - A row of reaction / like button (reuse existing `PostRowButtonsView` styled for dark bg).
    4. "Comments ›" pill at the very bottom — taps to open the existing `PostCommentsView` in a
       sheet.
    5. Swipe-down or back-chevron dismisses.
  - Wire it in: in `TodayView` change the `CircleTileView.onTapGesture` to navigate to a new
    `.locketPost(postId:)` destination in `AppDestination` / `ViewFactory`. The old
    `.postDetail(postId:)` destination stays untouched — just add the new one.
  - `PostsStore` already holds the post data; no new Firestore queries needed for the viewer.

  **Tests:** not much pure logic here — focus on getting the views right. Add at least a
  smoke-test that `QuickPostViewModel` (or `CreatePostViewModel`) accepts a note + image and
  calls through without crashing (mock the upload service if needed, or just test the
  disable-state logic: button is disabled when note is empty).



---

## Widgets (Ring 1 "Today" — retention)

- [ ] 🟡 **WidgetKit home-screen widget** showing the latest close-friends post (image + short
  note) — the Locket-style "window into friends". Small + medium families. Tap deep-links via the
  existing `dare://post?id=` / `dare://home` scheme. Needs a Widget Extension target (note: a new
  *extension target* is one of the few things that DOES require `.pbxproj`/Xcode setup — flag it).
- [ ] 🟡 **"Your streak / next goal update" widget** — flame + current streak + the active goal's
  CTA. Pulls from the same gamification fields on `User`. Reuse `StreakCalculator` pure logic.
- [ ] 🟢 **App Group + shared snapshot store** so the widget can render without a network call:
  write the last feed/streak snapshot to a shared container on app foreground. Pure
  encode/decode logic → unit-testable. Prereq for the widgets above.
- [ ] 🟢 **Deep-link audit for widgets** — make sure every widget tap target resolves in
  `AppDestination.from(url:)`; add tests for any new route.

## Notifications (retention / re-engagement)

- [x] 🟡 **Local notification for the weekly ritual** — a gentle weekly (never daily) nudge to
  post a goal update. Schedule with `UNUserNotificationCenter`; respect a user opt-in flag.
  Vision-aligned: weekly ritual, not a daily mandatory prompt. *(shipped: NotificationService + scheduleWeeklyRitual)*
- [x] 🟢 **Notification permission priming screen** in onboarding — explain the value before the
  iOS prompt (boosts opt-in rate). Gate the system prompt behind a tap. *(shipped: NotificationPermissionView, wired into OnboardingView "Get started")*
- [ ] 🟡 **Push notifications (FCM)** for: new follower, comment on your post, friend completed a
  goal. 🔴 Needs APNs key + Firebase Cloud Messaging console setup + a Cloud Function or backend
  to send. Start with the client token registration + a `NotificationService` stub in `Service/`.
- [x] 🟢 **Notification settings section** in `ProfileSettingsView` — per-type toggles persisted
  to the user doc (`notificationPrefs`). Pure model + a service write. *(shipped: NotificationPrefs + UserService.updateNotificationPrefs + ProfileSettingsView notificationsSection + NotificationPrefsTests)*
- [x] 🟢 **"You a year ago" resurfacing notification** — once the timestamped posts exist, a
  weekly look-back nudge. Pure date-selection logic (find a post ~365 days ago) → unit-testable.
  *(shipped: YearAgoNotificationLogic + YearAgoNotificationLogicTests + NotificationService.scheduleYearAgoReminder + wired into AYearAgoViewModel)*

## Competitions & collective goals (Ring 2 — engagement)

- [ ] 🟡 **Group goal leaderboard (supportive, not cutthroat)** — within a goal, show a calm
  ranking by *consistency* (updates this week), not raw points. Pure ranking logic → tests.
- [x] 🟡 **Weekly challenge "season"** — a time-boxed collective goal with a start/end and a
  shared progress bar. Model: add `startsAt`/`endsAt` to `Challenge`/`Goal`. Pure
  is-active/days-remaining logic → tests. *(shipped: ChallengeSeason.swift + ChallengeSeasonTests.swift + ActiveGoalHeroCard progress bar)*
- [x] 🟢 **Streak freeze / grace day** — one earned "freeze" so a missed week doesn't nuke a long
  streak (proven retention mechanic). Extend `StreakCalculator` + tests.
- [ ] 🟡 **Small accountability groups (3–6 people)** — the "confronting" small-group idea from the
  product direction. A `Group` model + membership subcollection; members see each other's goal
  updates only. Start with the model + service, UI later.

## Ads positioning (monetization — design first, integrate later)

- [ ] 🟢 **Ad slot abstraction** — define an `AdSlot` enum (e.g. `.discoverFeedInterstitial`,
  `.betweenGoalCards`) and a `AdProvider` protocol with a no-op implementation, so placement is
  decided in code now and a real network (AdMob) drops in later. Keep ads **out of the intimate
  Ring 1 feed** — only Discover/Explore. Pure placement-policy logic → tests.
- [ ] 🟢 **Frequency-capping policy** — pure logic deciding when an ad may show (every N cards, max
  M/session, never on first session). Fully unit-testable; no SDK needed.
- [ ] 🔴 **AdMob (Google Mobile Ads SDK) integration** — needs an AdMob account + app IDs +
  `Info.plist` + SPM dependency. Only after the abstraction above. Flag for human setup.

## Marketed / sponsored challenges for companies (B2B monetization)

- [ ] 🟡 **Sponsored challenge model** — extend `Challenge` with optional `sponsor` (name, logo
  URL, brand color) and a `isSponsored` flag. Old docs decode to `nil` (safe). Render a subtle
  "Sponsored by" badge; keep it tasteful and lowkey. Pure model + a badge view.
- [ ] 🟢 **Sponsored-challenge styling guard** — ensure sponsored content only appears in
  Discover/Explore, never the close-friends grid. Pure filter logic → tests.
- [ ] 🟡 **Brand landing / CTA** — a sponsored challenge can carry an external link; open in
  `SFSafariViewController`. Validate/whitelist the URL scheme (https only) — testable.

## A/B testing & experimentation

- [x] 🟢 **Lightweight experiment framework** — an `Experiment` enum + a deterministic bucketing
  function (`hash(uid + experimentKey) % 100 < rolloutPct`). 100% pure, 100% testable, no SDK.
  Lets the routine ship features behind flags safely. *(shipped: Experiment.swift + ExperimentTests.swift)*
- [x] 🟢 **Experiment assignment logging** — record which bucket a user landed in (see logging
  section) so results are measurable. *(shipped: AnalyticsEvent.experimentAssigned)*
- [ ] 🟡 **Firebase Remote Config wiring** — drive experiment rollout %s remotely. 🔴 Needs Remote
  Config enabled in the Firebase console; keep the pure bucketing logic provider-agnostic so it
  works with hardcoded defaults until then.
- [ ] 🟢 **First A/B candidate** — test two home layouts (grid-first vs. goal-hero-first) behind
  the framework. Just the wiring + flag; both layouts already on the roadmap.

## Logging / analytics on views (measurement foundation)

- [x] 🟢 **`AnalyticsEvent` enum + `AnalyticsService` protocol** in `Service/` with a console/no-op
  default impl. Pure event definitions → testable. This is the foundation for everything
  measurement-related (ads, A/B, retention). *(shipped: AnalyticsEvent.swift + AnalyticsService.swift)*
- [x] 🟢 **`.trackScreen(_:)` view modifier** — a reusable SwiftUI modifier that fires a
  screen-view event `onAppear`. Drop it on the main screens (Feed, Explore, Profile, Onboarding,
  Goal detail). Logic (debounce duplicate appears) is testable. *(shipped: View+Analytics.swift + ScreenTracker)*
- [ ] 🟡 **Firebase Analytics integration** behind the `AnalyticsService` protocol. 🔴 Needs the
  Analytics SDK added + console. Swap the no-op impl; no call sites change.
- [x] 🟢 **Funnel events for onboarding** — log start / each step / finish so drop-off is visible.
  Pure event emission; wire into `OnboardingView`. *(shipped: OnboardingView analytics + AnalyticsTests.swift)*

## Apple login & registration (auth growth / App Store requirement)

- [ ] 🔴 **Sign in with Apple** — `ASAuthorizationAppleIDButton` + `signInWithApple` in
  `AuthViewModel`/an auth service, bridged to Firebase Auth's Apple provider. **Required by App
  Store review** if you offer other social logins. Needs the *Sign in with Apple* capability/
  entitlement (human/Xcode + Apple Developer setup) — flag it. Keep the nonce + credential
  handling pure where possible for tests.
- [ ] 🟢 **Account-link/merge handling** — if an Apple sign-in email matches an existing account,
  handle linking gracefully. Pure decision logic (link vs. create vs. error) → testable.
- [ ] 🟢 **Sign-out / delete-account flow** — App Store also requires in-app account deletion if
  you have account creation. Add to `ProfileSettingsView`; service call to delete the user doc +
  auth user. Confirm-dialog + clear copy.
- [x] 🟢 **Auth error messaging** — map Firebase auth error codes to friendly copy. Pure
  mapping function → fully testable. *(shipped: AuthErrorMapper.swift + AuthErrorMapperTests.swift)*

## Fun / polish / "official good additions"

- [x] 🟢 **"You, a year ago" view** — the emotional moat. A screen that surfaces your post(s) from
  ~52 weeks ago. Pure date-window selection over cached posts → unit-testable. High vision value.
  *(shipped: AYearAgoCard + AYearAgoViewModel wired into TodayView, PostFetchService.fetchPosts(uid:from:to:))*
- [ ] 🟢 **Empty-state & loading polish** — friendly empty states for an empty feed / no goals yet
  / no followers, nudging the first action. Pure view work.
- [ ] 🟢 **Haptics on key moments** — streak increment, goal update posted, level up. Small, fun,
  retention-positive. `UIImpactFeedbackGenerator`.
- [ ] 🟢 **Pull-to-refresh + skeleton loaders** on the feed for perceived speed.
- [ ] 🟢 **Share sheet for a post/goal** using `AppRouter.createDeepLink(for:)` — growth loop.
- [x] 🟢 **Mastery trophy case** — turn existing points/levels into a visual achievements grid on
  the profile (the gamification "trophy case" from the vision). Pure level/threshold math exists
  already in `Gamification.swift`; this is mostly view work + tests for any new thresholds.
  *(shipped: AchievementCatalog enum + Achievement struct in Gamification.swift, MasteryTrophyCaseView, Trophies tab in ProfileDetailView, AchievementCatalogTests)*
- [ ] 🟢 **Dark-mode / appearance polish** — there's already a new `AppearanceMode.swift` in the
  tree; finish wiring it through `Style.swift` and settings, add tests for the mode resolution.
- [ ] 🟢 **Retire `Feed 2` / `TestFeed`** — listed tech debt; remove the prototype or fold its best
  bits into the real feed. Clean win.
- [ ] 🟢 **Accessibility pass** — VoiceOver labels + Dynamic Type on the main screens.

## Tech-debt quick wins (from CLAUDE.md "Known tech debt")

- [ ] 🟢 **Bound `UserService.fetchUsers()`** and the non-paginated `CommentService.fetchComments`
  with a sensible page limit. Add tests around the paging/cursor logic.
- [ ] 🟡 **Fix `FriendService.fetchRecommendedFriends` O(n²)** over the follow graph — dedupe and
  cap fan-out. Extract the recommendation logic to a pure function + tests.
- [ ] 🟢 **Store eviction/TTL** — add a simple max-size/age policy to the in-memory stores. Pure
  policy logic → testable.
