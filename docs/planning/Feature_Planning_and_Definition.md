# Feature Planning and Definition: SimplyLock

## 1. Introduction
This document outlines the key features of the SimplyLock application. For each feature, it defines its objective, relevant user stories, acceptance criteria, and potential future enhancements.

## 2. Core Features

### 2.1 Profile Management

-   **Objective:** Allow users to create, manage, and customize blocking configurations for different contexts (e.g., work, study, personal time).
-   **User Stories:**
    -   As a user, I want to create a new blocking profile so I can define a specific set of apps and websites to restrict.
    -   As a user, I want to name my profiles so I can easily identify them.
    -   As a user, I want to select specific apps, categories of apps, and websites to include in a profile's blocklist.
    -   As a user, I want to edit an existing custom profile to update its settings or blocklist.
    -   As a user, I want to delete a custom profile I no longer need.
    -   As a user, I want to see a list of predefined system profiles that I can use immediately.
    -   As a user, I want to enable "Strict Mode" for a profile to make it harder to bypass blocking.
-   **Acceptance Criteria:**
    -   Users can successfully create a profile with a name, icon, color, and description.
    -   Users can use `FamilyActivityPicker` to select items for the `activitySelection` of a profile.
    -   Selected apps/websites are stored with the profile.
    -   Edits to a profile's details and blocklist are saved.
    -   Deleted profiles are removed from the user's list of custom profiles.
    -   System profiles are visible but not editable/deletable.
    -   Custom profiles are persisted using `ProfileStore` and `UserDefaults`.
    -   "Strict Mode" status is saved with the profile.
-   **Potential Future Enhancements:**
    -   Cloud sync for custom profiles across user's devices.
    -   Share profiles with other SimplyLock users.
    -   Duplicate an existing profile to use as a template.

### 2.2 Blocking Engine & Session Management

-   **Objective:** Enforce the blocking rules defined in an active profile for a specified duration.
-   **User Stories:**
    -   As a user, I want to activate a chosen profile for a specific duration (e.g., 1 hour).
    -   As a user, I want the system to block the apps and websites defined in the active profile.
    -   As a user, I want to see how much time is remaining for an active blocking session.
    -   As a user, I want to be able to manually stop an active blocking session if needed (unless Strict Mode is active and prevents this).
-   **Acceptance Criteria:**
    -   When a profile is activated with a duration, `BlockManager` correctly uses `ManagedSettingsStore` to shield the selected apps/websites.
    -   The UI accurately displays the remaining time for the block.
    -   The `stopBlocking()` method in `BlockManager` clears all active restrictions.
    -   The `BlockMonitor` extension correctly starts/stops blocks based on `DeviceActivitySchedule` events, using the `profileID` from event `userInfo`.
    -   The correct `BlockProfile` (name, ID, selection, duration) is used by `BlockManager`.
-   **Potential Future Enhancements:**
    -   "Allowlist" mode: Block everything except selected apps/websites.
    -   Option to add extra time to an ongoing session.
    -   Customizable messages or views for blocked apps (beyond ShieldConfiguration).
    -   Emergency access feature to temporarily bypass a block for a specific app.

### 2.3 Pomodoro Timer

-   **Objective:** Provide users with a Pomodoro timer to structure their work and break intervals, with an option to integrate blocking during focus sessions.
-   **User Stories:**
    -   As a user, I want to start a focus timer for a predefined duration (e.g., 25 minutes).
    -   As a user, I want to start a break timer after a focus session.
    -   As a user, I want to configure the default durations for focus and break sessions.
    -   As a user, I want to link one of my blocking profiles to the focus timer.
    -   As a user, I want the linked blocking profile to automatically activate when the focus timer starts and deactivate when it ends.
    -   As a user, I want to see the current timer status (focus/break, time remaining).
-   **Acceptance Criteria:**
    -   Timer accurately counts down focus and break intervals.
    -   Users can start, pause, and reset the timer.
    -   If a profile is linked and active in settings:
        -   `BlockManager.startBlocking()` is called with the linked profile's details and timer's duration when focus starts.
        -   `BlockManager.stopBlocking()` is called when focus ends or timer is manually stopped.
    -   Timer settings are configurable and persisted.
-   **Potential Future Enhancements:**
    -   Customizable timer sounds/notifications.
    -   Long break option after a set number of Pomodoro sessions.
    -   Tracking of completed Pomodoro sessions.

### 2.4 Usage Insights

-   **Objective:** Help users understand their app usage patterns and the effectiveness of their blocking habits. (Currently uses sample data).
-   **User Stories:**
    -   As a user, I want to see my total screen time for today, this week, or this month.
    -   As a user, I want to see which categories of apps I spend the most time on.
    -   As a user, I want to see a list of my most used apps.
    -   As a user, I want to see how many times the app has blocked attempts to open restricted apps/sites.
    -   As a user, I want to set goals for my app usage (e.g., reduce social media time).
-   **Acceptance Criteria:**
    -   (Initially) Insights screen displays sample data for charts and statistics.
    -   (Future) Insights screen accurately fetches and displays real usage data from `DeviceActivityCenter`.
    -   Users can navigate different time ranges for the data.
    -   Goal setting UI allows creating and viewing basic goals.
-   **Potential Future Enhancements:**
    -   More detailed reports and filtering options.
    -   Comparison of usage over time (e.g., week-over-week).
    -   "Digital Wellbeing Score."
    -   Actionable suggestions based on usage patterns.

### 2.5 Application Settings

-   **Objective:** Allow users to customize application behavior and access information.
-   **User Stories:**
    -   As a user, I want to switch between light and dark themes for the app.
    -   As a user, I want the app to respect my system's light/dark mode setting.
    -   As a user, I want to configure notification preferences (e.g., for timer completion, block attempts - future).
    -   As a user, I want to view the app's version number.
    -   As a user, I want to access the privacy policy and terms of service.
-   **Acceptance Criteria:**
    -   Theme switching works correctly and persists across app launches.
    -   App version information is displayed.
    -   Links to legal documents are present.
    -   (Future) Notification settings are functional.
-   **Potential Future Enhancements:**
    -   More theme customization options.
    -   Language selection within the app.
    -   Data backup and restore options (e.g., export/import profiles).
    -   Haptic feedback settings.

### 2.6 Automation (Future Feature)

-   **Objective:** Allow users to schedule the activation of blocking profiles based on time or location.
-   **User Stories (Examples for Future):**
    -   As a user, I want to schedule my "Work" profile to activate automatically from 9 AM to 5 PM on weekdays.
    -   As a user, I want my "Study" profile to activate when I arrive at the library.
-   **Acceptance Criteria (Examples for Future):**
    -   Time-based schedules correctly activate/deactivate profiles using `DeviceActivitySchedule` and `BlockMonitor`.
    -   Location-based triggers (if implemented) accurately activate/deactivate profiles.
-   **Potential Future Enhancements:**
    -   Calendar integration for scheduling.
    -   Siri Shortcuts support for activating profiles.

---
```
