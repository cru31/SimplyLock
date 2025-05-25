# Software Requirements Specification: SimplyLock

## 1. Introduction

### 1.1 Purpose
This document specifies the software requirements for SimplyLock, an iOS application designed to help users manage their app and device usage time, promoting digital wellbeing and focus.

### 1.2 Scope
SimplyLock provides users with tools to:
- Create and manage custom blocking profiles for applications and websites.
- Set timers for focused work sessions, optionally linked with blocking profiles.
- Gain insights into their application usage patterns.
- Configure application settings for a personalized experience.
The application leverages Apple's Screen Time API (FamilyControls and ManagedSettings) for blocking functionalities.

### 1.3 Overview
This document details the functional and non-functional requirements of SimplyLock. It covers user interactions, system capabilities, and constraints.

## 2. Overall Description

### 2.1 Product Perspective
SimplyLock is a standalone iOS application. It interacts with the iOS system via the Screen Time API to monitor and control application/website access. It also uses standard iOS frameworks for UI and data persistence.

### 2.2 Product Features
The major features of SimplyLock include:
- **Profile Management:** Users can create, edit, and delete blocking profiles, specifying which apps and websites to restrict.
- **Session Blocking:** Users can activate a selected profile for a specified duration.
- **Pomodoro Timer:** A built-in timer to help users manage focus and break intervals, with an option to link a blocking profile during focus sessions.
- **Usage Insights:** Visualizations and statistics about app usage patterns. (Currently uses sample data, real data integration planned).
- **Customizable Settings:** Options for theme customization, notification preferences, etc.
- **Theme Engine:** Supports light and dark modes, and potentially custom themes.

### 2.3 User Classes and Characteristics
The primary user class is any iOS user who wishes to:
- Reduce distractions from their mobile device.
- Improve focus and productivity.
- Understand their digital habits better.
- Limit access to certain apps/websites for themselves or family members (if Screen Time is managed for others, though current scope is self-management).
Users are expected to be familiar with standard iOS app interactions.

### 2.4 Operating Environment
- **Platform:** iOS
- **Minimum OS Version:** iOS 15.0+ (due to Screen Time API dependencies and SwiftUI features).
- **Hardware:** Compatible iPhone devices.

### 2.5 Design and Implementation Constraints
- Must use Apple's Screen Time API (`FamilyControls`, `ManagedSettings`, `DeviceActivity`) for core blocking functionality.
- Adherence to App Store review guidelines.
- User data privacy is paramount; local storage (UserDefaults, potentially SwiftData) for profiles and settings. No remote server for user data unless explicitly stated for features like premium account sync.
- Development in Swift and SwiftUI.

## 3. Specific Requirements

### 3.1 Functional Requirements

#### 3.1.1 Profile Management (FR-P)
- **FR-P1:** The system shall allow users to create new custom blocking profiles.
- **FR-P2:** For each profile, users shall be able to specify a name, icon, color, and description.
- **FR-P3:** Users shall be able to select specific applications, categories of applications, and web domains to be blocked for each profile using the `FamilyActivityPicker`.
- **FR-P4:** Users shall be able to edit existing custom profiles (name, icon, color, description, app/website selection, strict mode).
- **FR-P5:** Users shall be able to delete custom profiles.
- **FR-P6:** The system shall provide a set of predefined, non-editable system profiles (e.g., "Focus Mode", "SNS Block").
- **FR-P7:** Users shall be able to set a "Strict Mode" for a profile, which (if implemented) would prevent deactivation of the block until the timer expires.
- **FR-P8:** Custom profiles (including their app/website selections) shall be persistently stored on the device.

#### 3.1.2 Session Blocking (FR-B)
- **FR-B1:** Users shall be able to select any profile (system or custom) and activate it for a user-defined duration.
- **FR-B2:** When a profile is active, the selected applications and websites shall be blocked by the system using the Screen Time API.
- **FR-B3:** Users shall be able to manually stop an active blocking session.
- **FR-B4:** The system shall display the remaining time for an active blocking session.
- **FR-B5:** The `BlockManager` shall use the `ManagedSettingsStore` to apply blocking rules.
- **FR-B6:** The `BlockMonitor` extension shall correctly start and stop blocking sessions based on `DeviceActivitySchedule` events (relevant for future automation).
    - **FR-B6.1:** `BlockMonitor` shall use a `profileID` passed in the schedule's event `userInfo` to determine which profile to activate.

#### 3.1.3 Timer (FR-T)
- **FR-T1:** The system shall provide a Pomodoro-style timer with configurable focus and break durations.
- **FR-T2:** Users shall be able to start, pause, resume, and reset the timer.
- **FR-T3:** Users shall have the option to link an existing blocking profile (system or custom) to the timer's focus sessions.
- **FR-T4:** If a profile is linked and the "Link Blocking Profile" option is active:
    - **FR-T4.1:** The linked profile shall be automatically activated when a focus session starts. The duration of the block will be the duration of the focus session.
    - **FR-T4.2:** The blocking shall be automatically deactivated when the focus session ends or is manually stopped.
- **FR-T5:** The timer shall visually indicate the remaining time for the current session (focus or break).
- **FR-T6:** The timer settings (durations, auto-start options) shall be configurable.

#### 3.1.4 Usage Insights (FR-I) - (Note: Currently uses sample data)
- **FR-I1:** The system shall display overall screen time for selected periods (e.g., today, this week).
- **FR-I2:** The system shall display a breakdown of screen time by application category.
- **FR-I3:** The system shall list the most frequently used applications.
- **FR-I4:** The system shall provide information about blocking effectiveness (e.g., number of block attempts).
- **FR-I5:** Users shall be able to set usage goals (e.g., limit screen time for a specific app).
- **FR-I6 (Future):** Replace sample data with actual data fetched from the Screen Time API (`DeviceActivityCenter`).

#### 3.1.5 Settings (FR-S)
- **FR-S1:** Users shall be able to switch between light and dark application themes.
- **FR-S2:** The application theme shall adapt to the system's theme by default.
- **FR-S3 (Future):** Users shall be able to configure notification preferences.
- **FR-S4 (Future):** Users shall be able to change the application language.
- **FR-S5:** The system shall display app version and links to privacy policy/terms of service.

### 3.2 Non-Functional Requirements

#### 3.2.1 Usability (NFR-U)
- **NFR-U1:** The application shall have an intuitive and easy-to-navigate user interface.
- **NFR-U2:** Key functions (activating a profile, starting the timer) shall be accessible with minimal taps.
- **NFR-U3:** Feedback shall be provided for user actions (e.g., confirmation of profile activation).

#### 3.2.2 Performance (NFR-P)
- **NFR-P1:** UI transitions and animations shall be smooth.
- **NFR-P2:** Activating or deactivating a block should occur with minimal delay (<2 seconds).
- **NFR-P3:** Loading of profiles and settings should be fast.

#### 3.2.3 Reliability (NFR-R)
- **NFR-R1:** The blocking mechanism shall reliably block selected apps/websites when active.
- **NFR-R2:** The application should handle errors gracefully (e.g., permission denial for Screen Time API).

#### 3.2.4 Security (NFR-SEC)
- **NFR-SEC1:** All user-specific data (profiles, selections) shall be stored locally on the device.
- **NFR-SEC2:** No sensitive user data should be transmitted externally without explicit user consent for specific features (e.g., iCloud sync, if implemented).

#### 3.2.5 Maintainability (NFR-M)
- **NFR-M1:** Code shall be well-structured, commented, and follow Swift best practices.
- **NFR-M2:** Components (e.g., `BlockManager`, `ProfileStore`) shall be modular and have clear responsibilities.

### 3.3 Interface Requirements
- **IR-1:** The application will use the `FamilyControls` framework for app/website selection (`FamilyActivityPicker`).
- **IR-2:** The application will use the `ManagedSettings` framework to apply blocking rules.
- **IR-3:** The application will use the `DeviceActivity` framework for monitoring and scheduling blocking intervals (via `BlockMonitor` extension).

## 4. Use Cases (High-Level)

- **UC-1: Create and Activate a Custom Blocking Profile**
    1. User navigates to Profiles screen.
    2. User taps "Add New Profile".
    3. User names the profile, selects apps/websites, and saves.
    4. User selects the new profile from the list.
    5. User is prompted for a duration.
    6. User confirms duration.
    7. System activates blocking for the selected apps/websites for the specified duration.

- **UC-2: Use Pomodoro Timer with Linked Profile**
    1. User navigates to Timer screen.
    2. User enables "Link Blocking Profile" and selects an existing profile.
    3. User starts the focus timer.
    4. System automatically activates the linked blocking profile for the duration of the focus timer.
    5. When focus timer ends, system automatically deactivates the blocking profile.

- **UC-3: Review Usage Insights**
    1. User navigates to Insights screen.
    2. System displays charts and statistics about app usage.

---
