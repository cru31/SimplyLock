# Software Design Document: SimplyLock

## 1. Introduction

### 1.1 Purpose
This document provides a description of the software design for the SimplyLock iOS application. It details the system architecture, data design, component design, and user interface (UI) design considerations.

### 1.2 Scope
The design covers the core functionalities of SimplyLock, including profile management, session blocking, the Pomodoro timer, usage insights, and application settings. It focuses on the client-side iOS application.

## 2. System Overview

### 2.1 Architecture
SimplyLock primarily follows a **Model-View-ViewModel (MVVM)** like architecture, leveraging SwiftUI's declarative nature.
- **Models:** Represent the application's data (e.g., `Profile`, `BlockProfile`, `UsageData`). These are simple structs or classes, often Codable for persistence.
- **Views:** SwiftUI views responsible for the UI presentation (e.g., `HomeView`, `ProfilesView`, `TimerView`). They observe state changes from ViewModels or shared model objects.
- **ViewModels/Managers:** These objects encapsulate business logic, data manipulation, and interaction with system services. Examples include `BlockManager` (manages blocking via Screen Time API), `ProfileStore` (manages persistence of UI profiles), `ThemeManager`, and `PermissionCoordinator`. `ObservableObject` is heavily used to publish changes to the UI.

### 2.2 Key Components
- **User Interface (SwiftUI):** The entire UI is built using SwiftUI.
- **Data Managers:**
    - `BlockManager`: Central class for interacting with `FamilyControls` and `ManagedSettings` to apply and manage blocking rules. Handles the lifecycle of `BlockProfile` (engine model).
    - `ProfileStore`: Manages the persistence (CRUD operations) of user-created `Profile` objects (UI model) using `UserDefaults`.
    - `ThemeManager`: Manages app themes (light/dark modes, custom themes).
    - `PermissionCoordinator`: Manages requests and status for necessary permissions (Screen Time, Notifications, Location).
- **Data Storage:**
    - `UserDefaults`: Used for storing `BlockProfile` (by `BlockManager`) and custom `Profile` configurations (by `ProfileStore`), and simple app settings. App group `UserDefaults` are used where data needs to be shared with extensions.
    - `Bundle`: For default resources like `DefaultProfiles.json`.
- **Screen Time API Integration:**
    - `FamilyControls`: Provides `FamilyActivityPicker` for app/website selection. `FamilyActivitySelection` is used in data models.
    - `ManagedSettings`: The `ManagedSettingsStore` is used by `BlockManager` to apply restrictions on apps and web domains.
    - `DeviceActivity`: The `DeviceActivityMonitor` extension (`BlockMonitor.swift`) is used to start/stop blocking sessions based on schedules (for future automation features).
- **App Extensions:**
    - `BlockMonitor` (Device Activity Monitor Extension): Responds to scheduled events to activate/deactivate blocking.
    - `BlockMonitorShield` (Shield Configuration Extension): Customizes the UI shown to the user when a blocked app is launched.

## 3. Data Design

### 3.1 Key Data Models

-   **`Profile` (`SimplyLock/Models/Profile.swift`):**
    *   **Description:** Represents a user-configurable blocking profile template (UI model).
    *   **Key Properties:** `id (UUID)`, `name (String)`, `iconName (String)`, `codableIconBackgroundColor (CodableColor)`, `description (String)`, `activitySelection (FamilyActivitySelection)`, `strictMode (Bool)`, `isSystem (Bool)`.
    *   **Persistence:** Custom profiles are stored in `UserDefaults` via `ProfileStore`. System profiles are typically predefined (e.g., from `Profile.samples`).
    *   **Codable:** Conforms to `Codable` for persistence. `Color` is handled via a custom `CodableColor` struct.

-   **`BlockProfile` (`Shared/BlockManager.swift`):**
    *   **Description:** Represents an active or schedulable blocking rule (engine model).
    *   **Key Properties:** `id (UUID)`, `name (String)`, `selection (FamilyActivitySelection)`, `duration (TimeInterval)`, `createdAt (Date)`, `isPreset (Bool)`.
    *   **Persistence:** Stored in app group `UserDefaults` by `BlockManager` to track active/recent blocking configurations.
    *   **Codable:** Conforms to `Codable`.

-   **`FamilyActivitySelection` (Apple Framework):**
    *   **Description:** Stores selections of applications, application categories, and web domains made by the user via `FamilyActivityPicker`.
    *   **Used In:** `Profile` and `BlockProfile`.
    *   **Codable:** Inherently `Codable`.

-   **`Activity` (`SimplyLock/Models/Activity.swift`):** (Placeholder/Sample)
    *   **Description:** Represents a user activity or event (e.g., profile activation, timer session).
    *   **Note:** Current implementation uses sample data.

-   **`UsageData` (`SimplyLock/Models/UsageData.swift`):** (Placeholder/Sample)
    *   **Description:** Encapsulates data for the Insights screen (e.g., screen time, category usage).
    *   **Note:** Current implementation uses sample data. Actual data would be derived from `DeviceActivityCenter`.

### 3.2 Persistence Mechanisms
-   **`UserDefaults`:**
    *   Primary storage for `Profile` (custom ones) and `BlockProfile` lists.
    *   Suitable for relatively small amounts of structured data.
    *   App group `UserDefaults` are used to share data between the main app and its extensions (e.g., `BlockManager`'s data).
-   **Bundle Resources:**
    *   `DefaultProfiles.json`: Contains predefined `BlockProfile` configurations.
    *   `BundleHostsMappings.json`: Potentially for mapping hostnames (not fully explored).

## 4. Component Design

### 4.1 Managers

-   **`BlockManager.swift`:**
    *   **Responsibilities:**
        *   Manages a list of `BlockProfile` objects (loaded from its UserDefaults).
        *   Provides methods to `startBlocking(with: BlockProfile)` and `stopBlocking()`.
        *   Interacts with `ManagedSettingsStore` to apply/clear blocking rules.
        *   Manages the timer for active blocking sessions (`timeRemaining`, `expirationDate`).
        *   Publishes its state (`isBlocking`, `activeProfile`, `timeRemaining`) for UI updates.
    *   **Key Interactions:** `ManagedSettingsStore`, `FamilyActivitySelection`, `BlockProfile` model.

-   **`ProfileStore.swift`:**
    *   **Responsibilities:**
        *   Manages the list of custom `Profile` objects (UI model).
        *   Handles CRUD operations (add, update, delete) for custom profiles.
        *   Persists `customProfiles` to `UserDefaults` by encoding/decoding.
        *   Publishes `customProfiles` for UI updates.
    *   **Key Interactions:** `Profile` model, `UserDefaults`.

-   **`ThemeManager.swift`:**
    *   **Responsibilities:** Manages the application's current theme, available themes, and system theme adaptation.
    *   **Key Interactions:** `AppTheme` struct, `UserDefaults` (for selected theme persistence).

-   **`PermissionCoordinator.swift`:**
    *   **Responsibilities:** Manages and checks the status of required permissions (Screen Time, Notifications, Location). Provides a unified interface for permission requests.
    *   **Key Interactions:** `ScreenTimePermissionManager`, `NotificationPermissionManager`, `LocationPermissionManager`.

### 4.2 App Extensions

-   **`BlockMonitor.swift` (`DeviceActivityMonitor`):**
    *   **Responsibilities:**
        *   Responds to `intervalDidStart` and `intervalDidEnd` for scheduled device activities.
        *   In `intervalDidStart`, retrieves a `profileID` from the event's `userInfo`.
        *   Fetches the corresponding `BlockProfile` from `BlockManager.shared.getProfile(byId:)`.
        *   Calls `BlockManager.shared.startBlocking()` with the fetched profile.
        *   In `intervalDidEnd`, calls `BlockManager.shared.stopBlocking()`.
    *   **Key Interactions:** `DeviceActivityName`, `DeviceActivityEvent`, `BlockManager`.

-   **`ShieldConfigurationExtension.swift` (`BlockMonitorShield`):**
    *   **Responsibilities:** Provides custom UI content (e.g., view with app icon, name, and a message) when a user attempts to open a blocked application or website.
    *   **Key Interactions:** `ShieldConfigurationDataSource`.

### 4.3 UI Views (High-Level)
The application uses a tab-based navigation structure (`MainTabView.swift`).

-   **`HomeView.swift`:** Dashboard showing current blocking status, quick actions (Pomodoro, Emergency Access - placeholders), stats, and recent activity.
-   **`ProfilesView.swift`:** Displays system and custom profiles. Allows creation, editing (via `ProfileEditorView`), and activation of profiles. `ProfileEditorView` uses `FamilyActivityPicker` for app/website selection.
-   **`TimerView.swift`:** Implements a Pomodoro timer. Allows linking a blocking profile to focus sessions.
-   **`InsightsView.swift`:** Displays app usage statistics and goals (currently with sample data).
-   **`SettingsView.swift`:** Provides options for theme, notifications, language, etc.

## 5. UI Design (Brief Overview)

### 5.1 Navigation
-   **Main Navigation:** `TabView` with five tabs: Home, Profiles, Insights, Timer, Settings.
-   **Profile Creation/Editing:** Modal sheet (`ProfileEditorView`) presented from `ProfilesView`.
-   **App/Website Selection:** Modal sheet (`FamilyActivityPicker`) presented from `ProfileEditorView`.
-   **Duration Selection (for Profile Activation):** Modal sheet presented from `ProfilesView`.

### 5.2 Reusable Components
-   `ProfileCard.swift`: Displays individual profile information in lists.
-   `StatusCard.swift`: Shows current blocking status on the Home screen.
-   Various UI components for stats, timer display, settings rows, etc., are found in `SimplyLock/Components/`.

### 5.3 Theme
-   The app supports light and dark modes, managed by `ThemeManager`.
-   UI elements are styled using a theme-aware approach, typically through an `AppTheme` object passed via the environment.

---
