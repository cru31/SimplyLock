# Detailed Development Tasks: SimplyLock

## 1. Introduction
This document breaks down the features defined in the "Feature Planning and Definition" document into more granular development tasks. This list can serve as a basis for sprint planning or individual task assignment. Effort and priority are high-level estimates (P0=Critical, P1=High, P2=Medium, P3=Low).

## 2. Phase 1: Core Functionality & Data Model (Largely Completed, listed for documentation)

| Task ID | Description                                                                                                | Feature Area      | Priority | Estimated Effort | Status    |
|---------|------------------------------------------------------------------------------------------------------------|-------------------|----------|------------------|-----------|
| P1-T1   | Refine `Profile` model: Add `FamilyActivitySelection`, UUID, Codable support (`CodableColor`).             | Profile Management| P0       | M                | Done      |
| P1-T2   | Implement `ProfileStore` for `Profile` persistence using `UserDefaults`.                                   | Profile Management| P0       | M                | Done      |
| P1-T3   | Integrate `ProfileStore` into `ProfilesView` & `ProfileEditorView` for CRUD operations.                   | Profile Management| P0       | L                | Done      |
| P1-T4   | Clarify `BlockProfile` naming/ID usage (ensure UI Profile's name/ID are used when creating `BlockProfile`). | Blocking Engine   | P0       | S                | Done      |
| P1-T5   | Integrate `FamilyActivityPicker` into `ProfileEditorView` for app/website selection.                     | Profile Management| P0       | M                | Done      |
| P1-T6   | Implement Profile Activation logic in `ProfilesView` (with duration prompt).                               | Blocking Engine   | P0       | L                | Done      |
| P1-T7   | Update `BlockMonitor` to use `profileID` from schedule event `userInfo`.                                   | Blocking Engine   | P0       | M                | Done      |
| P1-T8   | Inject `ProfileStore` into `SimplyLockApp` environment.                                                    | Core              | P0       | S                | Done      |

## 3. Phase 2: Timer and Remaining UI Implementation

| Task ID | Description                                                                                                | Feature Area | Priority | Estimated Effort | Status    |
|---------|------------------------------------------------------------------------------------------------------------|--------------|----------|------------------|-----------|
| P2-T1   | **Timer View**: Integrate `BlockManager` & `ProfileStore`.                                                 | Timer        | P1       | S                | Done      |
| P2-T2   | **Timer View**: Implement profile selection UI for "Link Blocking Profile".                                  | Timer        | P1       | M                | Done      |
| P2-T3   | **Timer View**: Implement logic to start/stop blocking based on timer state and linked profile.            | Timer        | P1       | L                | Done      |
| P2-T4   | **Timer View**: Display `blockManager.activeProfile.name` if block is from timer.                          | Timer        | P2       | S                | Pending   |
| P2-T5   | **Timer Settings**: Allow selection of a default profile for timer sessions.                               | Timer        | P2       | M                | Pending   |
| P2-T6   | **Home View**: Implement `EmergencyAccessView` functionality (placeholder exists).                         | Home         | P2       | M                | Pending   |
| P2-T7   | **Home View**: Implement `PomodoroSettings` functionality (placeholder exists, may overlap with Timer Settings). | Home / Timer | P2       | M                | Pending   |
| P2-T8   | **Settings View**: Implement `AccountInfoView` (placeholder UI, no backend needed initially).                | Settings     | P3       | S                | Pending   |
| P2-T9   | **Settings View**: Implement `SubscriptionManagementView` (placeholder UI).                                | Settings     | P3       | S                | Pending   |
| P2-T10  | **ShieldConfigurationExtension**: Enhance UI based on active `BlockProfile` details (if possible).         | Blocking Engine| P2       | M                | Pending   |

## 4. Phase 3: Insights Feature Development

| Task ID | Description                                                                                                | Feature Area | Priority | Estimated Effort | Status    |
|---------|------------------------------------------------------------------------------------------------------------|--------------|----------|------------------|-----------|
| P3-T1   | Research & POC: Fetching data from `DeviceActivityCenter` (screen time, app usage).                      | Insights     | P1       | L                | Pending   |
| P3-T2   | Implement data models for storing aggregated usage data.                                                   | Insights     | P1       | M                | Pending   |
| P3-T3   | Develop logic to process and aggregate data from `DeviceActivityCenter`.                                   | Insights     | P1       | L                | Pending   |
| P3-T4   | Replace sample data in `InsightsView` with real, processed usage data.                                     | Insights     | P1       | M                | Pending   |
| P3-T5   | Implement UI for `GoalCreationView` and saving/loading usage goals.                                        | Insights     | P2       | M                | Pending   |
| P3-T6   | Display goal progress in `InsightsView`.                                                                   | Insights     | P2       | S                | Pending   |

## 5. Phase 4: Automation Features

| Task ID | Description                                                                                                | Feature Area | Priority | Estimated Effort | Status    |
|---------|------------------------------------------------------------------------------------------------------------|--------------|----------|------------------|-----------|
| P4-T1   | **Time-Based Automation**: Design UI for creating time-based schedules for profiles.                       | Automation   | P2       | M                | Pending   |
| P4-T2   | **Time-Based Automation**: Implement logic to create/delete `DeviceActivitySchedule`s.                     | Automation   | P1       | L                | Pending   |
| P4-T3   | **Time-Based Automation**: Ensure `profileID` is correctly passed in schedule `userInfo`.                  | Automation   | P1       | S                | Pending   |
| P4-T4   | **Time-Based Automation**: Test `BlockMonitor` with these schedules.                                       | Automation   | P1       | M                | Pending   |
| P4-T5   | **Location-Based Automation (Optional/Advanced)**: Research iOS location APIs for geofencing.            | Automation   | P3       | L                | Pending   |
| P4-T6   | **Location-Based Automation**: Implement UI for setting up location-based triggers.                        | Automation   | P3       | L                | Pending   |
| P4-T7   | **Location-Based Automation**: Implement logic for location monitoring and profile activation.             | Automation   | P3       | XL               | Pending   |

## 6. Phase 5: Settings, Polish, and Further Development

| Task ID | Description                                                                                                | Feature Area | Priority | Estimated Effort | Status    |
|---------|------------------------------------------------------------------------------------------------------------|--------------|----------|------------------|-----------|
| P5-T1   | **Settings**: Implement full functionality for `NotificationSettingsView`.                                 | Settings     | P2       | M                | Pending   |
| P5-T2   | **Settings**: Implement full functionality for `LanguageSettingsView` (if multi-language is pursued).      | Settings     | P3       | L                | Pending   |
| P5-T3   | **Error Handling**: Comprehensive review and enhancement of error handling across the app.                 | Core         | P1       | M                | Pending   |
| P5-T4   | **UI Polish**: Review all screens for UI consistency, accessibility, and overall user experience.          | UI/UX        | P1       | L                | Pending   |
| P5-T5   | **Code Cleanup & Refactoring**: Address any tech debt, improve comments, optimize performance.             | Core         | P2       | L                | Pending   |
| P5-T6   | **Testing**: Write comprehensive Unit Tests for managers and complex logic.                                | Testing      | P1       | L                | Pending   |
| P5-T7   | **Testing**: Write UI Tests for key user flows.                                                            | Testing      | P2       | XL               | Pending   |

**Effort Estimation Key:** S = Small (1-2 days), M = Medium (3-5 days), L = Large (1-2 weeks), XL = Extra Large (>2 weeks)

---
```
This list provides a good breakdown of tasks. Some items marked 'Done' reflect work completed in the previous iteration of development before the documentation phase began.
The status of tasks P2-T1, P2-T2, and P2-T3 should be 'Done' as they were completed in a previous subtask. I've updated the content to reflect this.
