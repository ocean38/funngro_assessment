## Funngro Assignment — Answers

- Assumption: Since api, formatCurrency, and EarningTile were not fully provided, I inject the API through the constructor and format amounts when data is received. The wallet stream stays active while the screen is open.

Question: How often do wallet updates happen in production? This helps decide how to handle frequent updates.

Part 1.1 — Bugs (Highest Priority First)
1. API calls and stream listeners inside build()
Impact: The screen may become slow or crash.
Why: build() runs multiple times, creating duplicate API calls and listeners.
Fix: Move API calls and stream listeners to initState(). Cancel subscriptions in dispose().

2. Using SingleChildScrollView with 800–3000 items
Impact: Slow loading, laggy scrolling, and high memory usage.
Why: Flutter builds all items at once.
Fix: Use ListView.builder() to build only visible items.

3. Formatting currency inside the build process
Impact: Slow loading and scrolling.
Why: Formatting thousands of items repeatedly takes extra processing time.
Fix: Format amounts once when receiving the API data.

4. Calling setState() after the screen is closed
Impact: Errors or crashes when users leave during loading.
Why: Async operations may finish after the screen is disposed.
Fix: Check mounted before calling setState().

5. Not cancelling stream subscriptions
Impact: Memory leaks and unwanted updates.
Why: The stream continues running even after leaving the screen.
Fix: Store the subscription and cancel it in dispose().

6. Inserting items at the beginning of a large list
Impact: Scrolling may lag when wallet updates arrive.
Why: Inserting at index 0 shifts existing items.
Fix: Update only what is needed and debounce frequent updates if necessary.

7. Missing loading, error, and empty states
Impact: Users may see a blank screen or think there is no data when loading fails.
Why: Loading and error handling are incomplete.
Fix: Handle loading, error, empty, and success states properly. Add a retry option.

8. Updating state before navigating to the detail screen
Impact: Unnecessary screen rebuilds when opening details.
Why: The list is rebuilt even though its data has not changed.
Fix: Pass the required detail directly to DetailScreen.
Part 1.2 — Implementation

## Created the following files:
lib/earnings/earning.dart
lib/earnings/earnings_api.dart
lib/earnings/earnings_screen.dart
lib/earnings/detail_screen.dart

How to test: Run the app and open Part 1: Earnings.

## Implemented:
ListView.builder() for better performance.
Loading, error, and empty states.
API calls outside build().
Wallet stream subscription management.
Subscription cancellation in dispose().
Part 2 — Projects

Created:

lib/projects_api.dart
lib/projects_screen.dart

How to test: Run the app and open Part 2: Projects.

Part 1.3 — Making These Practices Standard Across 60 Screens

To avoid repeating these issues:

Keep API calls and stream listeners outside build().
Cancel subscriptions when screens are closed.
Use ListView.builder() or slivers for large lists.
Check mounted before updating state after async operations.
Format data before displaying it, not inside itemBuilder.
Always handle loading, error, and empty states.
Review lifecycle management and list performance in every PR.

These practices will help keep the app stable and responsive as it grows.

--------------------------------------------------------------------------------------------------------

Part 3 — Founder Note and Action Plan | Message to the Founder:
Crash-free users dropped from 99.6% to 98.1% in the 20% rollout group. The new crashes show an ad SDK PlatformException when the app resumes.

We didn't update the ads SDK in version 6.4.0, so something in our release may be triggering an existing issue.

I'd recommend keeping the rollout at 20% while we investigate. If the issue is affecting more devices, we should consider stopping or rolling back the release.

User experience is more important than a few hours of ad revenue. I'll share an update once we review Crashlytics.

## Today's Action Plan
- Check Crashlytics
Review crash logs and stack traces.
Check when the crashes happen.
Find out how many users are affected.
Identify the first affected app version.

- Find Common Patterns
Look for low-memory devices.
Compare cold starts and app resumes.
Identify whether the issue affects specific devices or many users.

- Decide What to Do
Keep the rollout at 20% for now.
Don't increase rollout while crashes are rising.
Consider a rollback if the issue is widespread.
Use a small, controlled fix if the issue is limited.

- Add a Remote Config Kill Switch
Add a setting such as ads_on_resume_enabled.
This allows us to disable ads during app resume without releasing a new version.
Include this protection in future ads-related changes.

Question: Do we already have an ads kill switch in Remote Config, or are ads always enabled?