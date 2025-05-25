# Test Plan: SimplyLock

## 1. Introduction

### 1.1 Purpose
This document outlines the testing strategy and plan for the SimplyLock iOS application. It covers various types of testing to ensure the application is functional, reliable, and meets user expectations.

### 1.2 Scope of Testing
The testing will cover all major features of SimplyLock, including:
- Profile Management (creation, editing, deletion, selection)
- Blocking Engine (activation, deactivation, app/website blocking)
- Pomodoro Timer (timer functionality, linking with profiles)
- Usage Insights (data display - initially with sample data)
- Application Settings (theme switching, etc.)
- User Interface and User Experience

## 2. Test Strategy

### 2.1 Unit Tests
-   **Objective:** To test individual components and functions in isolation, particularly business logic within manager classes.
-   **Tools:** XCTest framework.
-   **Focus Areas:**
    -   `ProfileStore`: Logic for adding, updating, deleting, encoding, and decoding custom `Profile` objects.
    -   `BlockManager`: Logic for managing `BlockProfile` state, timer countdown for active blocks (if internally managed), and interaction points with `ManagedSettingsStore` (mocked if possible).
    -   `ThemeManager`: Theme switching logic.
    -   Data model validation and initialization.

### 2.2 Integration Tests
-   **Objective:** To test the interaction between different components of the app.
-   **Tools:** XCTest framework.
-   **Focus Areas:**
    -   Interaction between `ProfilesView`/`ProfileEditorView` and `ProfileStore`.
    -   Interaction between `ProfilesView` (profile activation) and `BlockManager`.
    -   Interaction between `TimerView` and `BlockManager` when a profile is linked.
    -   Interaction between `BlockMonitor` extension and `BlockManager` (requires specialized testing, possibly manual or semi-automated).

### 2.3 UI Tests
-   **Objective:** To verify user interface elements and user flows from the user's perspective.
-   **Tools:** XCTest framework with XCUITest.
-   **Focus Areas:**
    -   Navigating through all screens.
    -   Creating, editing, and deleting a profile.
    -   Activating and deactivating a blocking profile.
    -   Starting, pausing, and resetting the Pomodoro timer.
    -   Linking a profile to the timer and verifying block activation.
    -   Changing app themes.
    -   Verifying UI state changes based on `ObservableObject` updates.

### 2.4 User Acceptance Testing (UAT)
-   **Objective:** To validate that the application meets the requirements and expectations of end-users.
-   **Methodology:** Manual testing based on use cases and user stories. Could involve TestFlight for beta testers.
-   **Focus Areas:** Overall usability, intuitiveness, and feature completeness.

## 3. Test Environment
-   **Hardware:** Various iPhone devices running supported iOS versions (iOS 15+).
-   **Software:**
    -   Latest stable iOS version recommended for primary testing.
    -   Minimum supported iOS version (iOS 15) for compatibility testing.
    -   Xcode for running tests.
-   **Tools:**
    -   Xcode's XCTest/XCUITest runner.
    -   Debugging tools (Xcode debugger, Console).

## 4. Test Cases (High-Level Examples)

### 4.1 Profile Management

| Test Case ID | Description                                                                 | Expected Result                                                                                             | Type          |
|--------------|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|---------------|
| TC-P-001     | Create a new custom profile with specific apps and websites selected.       | Profile is saved correctly with all details and selections; appears in the custom profiles list.            | Integration/UI|
| TC-P-002     | Edit an existing custom profile's name and app selection.                   | Profile details are updated and persisted.                                                                  | Integration/UI|
| TC-P-003     | Delete a custom profile.                                                    | Profile is removed from the list and `UserDefaults`.                                                        | Integration/UI|
| TC-P-004     | Attempt to edit a system profile.                                           | UI does not allow editing of system profiles.                                                               | UI            |
| TC-P-005     | Verify `Profile.appCount` and `Profile.websiteCount` are computed correctly.| Counts match the number of items in `activitySelection`.                                                    | Unit          |
| TC-P-006     | Unit test `ProfileStore` encoding/decoding of `Profile` with `CodableColor`.| Profiles are successfully saved to and loaded from `UserDefaults` without data loss or corruption.        | Unit          |

### 4.2 Blocking Engine & Session Management

| Test Case ID | Description                                                                 | Expected Result                                                                                             | Type          |
|--------------|-----------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|---------------|
| TC-B-001     | Activate a profile for 30 minutes.                                          | Selected apps/websites are blocked; `BlockManager.isBlocking` is true; timer shows correct remaining time. | Integration/UI|
| TC-B-002     | Attempt to open a blocked app.                                              | Shield UI is displayed; app access is prevented.                                                            | Manual/UI     |
| TC-B-003     | Manually stop an active blocking session.                                   | Apps/websites become unblocked; `BlockManager.isBlocking` is false.                                         | Integration/UI|
| TC-B-004     | Let a blocking session expire naturally.                                    | Apps/websites become unblocked automatically when time expires.                                             | Integration   |
| TC-B-005     | Unit test `BlockManager.startBlocking` logic (mock `ManagedSettingsStore`). | Correct settings are applied to the store.                                                                  | Unit          |
| TC-B-006     | Test `BlockMonitor` activation with a valid `profileID` in `userInfo`.    | Correct profile is fetched and blocking starts.                                                             | Manual/Integration (requires setup) |
| TC-B-007     | Test `BlockMonitor` activation with an invalid `profileID`.                 | Blocking does not start; error is logged.                                                                   | Manual/Integration (requires setup) |

### 4.3 Pomodoro Timer

| Test Case ID | Description                                                                       | Expected Result                                                                                                | Type          |
|--------------|-----------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|---------------|
| TC-T-001     | Start a focus timer session.                                                      | Timer counts down correctly.                                                                                   | UI            |
| TC-T-002     | Link a blocking profile and start focus timer.                                    | Linked profile activates for the duration of the focus session; apps are blocked.                              | Integration/UI|
| TC-T-003     | Focus session ends (with linked profile); break starts.                           | Blocking deactivates automatically. Break timer starts.                                                        | Integration/UI|
| TC-T-004     | Pause and resume timer.                                                           | Timer state updates correctly. If blocking was active, it should ideally pause/resume or stop and restart. (Define behavior) | UI            |
| TC-T-005     | Reset timer while a session (and possibly block) is active.                       | Timer resets to default; any active block from the timer is stopped.                                           | Integration/UI|

### 4.4 Usage Insights (Sample Data initially)

| Test Case ID | Description                                                                 | Expected Result                                                              | Type |
|--------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------|------|
| TC-I-001     | Navigate to Insights screen.                                                | Sample charts and statistics are displayed correctly.                        | UI   |
| TC-I-002     | Change time range for insights.                                             | UI updates to reflect (sample) data for the selected range.                  | UI   |

### 4.5 Application Settings

| Test Case ID | Description                                                                 | Expected Result                                                              | Type |
|--------------|-----------------------------------------------------------------------------|------------------------------------------------------------------------------|------|
| TC-S-001     | Switch app theme from light to dark.                                        | All UI elements correctly adapt to the dark theme. Theme selection persists. | UI   |
| TC-S-002     | Verify app theme adapts to system theme changes.                            | App theme changes when system theme changes (if no override is set).         | UI   |

## 5. Unit Test Outline (Examples)

### 5.1 `ProfileStoreTests.swift`
-   `testAddCustomProfile()`
-   `testUpdateCustomProfile()`
-   `testDeleteCustomProfile()`
-   `testLoadProfiles_EmptyUserDefaults()`
-   `testLoadProfiles_WithExistingData()`
-   `testSaveProfiles_EncodingDecodingIntegrity()`
-   `testPreventSystemProfileModification()` (if applicable)
-   `testAddDuplicateCustomProfileByID()` (should prevent or update)

### 5.2 `BlockManagerTests.swift`
-   `testStartBlocking_UpdatesStateCorrectly()`
-   `testStopBlocking_ClearsStateAndSettings()`
-   `testTimerTick_ReducesTimeRemaining()`
-   `testTimerExpiration_StopsBlocking()`
-   `testGetProfileByID_ReturnsCorrectProfile()`
-   `testGetProfileByID_ReturnsNilForInvalidID()`

---
```
This provides a foundational Test Plan.
