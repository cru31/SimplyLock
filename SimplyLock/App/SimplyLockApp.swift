import SwiftUI
import UIKit

struct InitialLoadingView: View {
    let theme: AppTheme
    
    var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 60))
                    .foregroundColor(theme.primaryColor)
                
                Text("SimplyLock")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(theme.primaryTextColor)
                
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryColor))
                        .scaleEffect(1.2)
                    
                    Text("Initializing app...")
                        .font(.system(size: 16))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}

@main
struct SimplyLockApp: App {
    @StateObject private var blockManager = BlockManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var coordinator = PermissionCoordinator()
    @StateObject private var profileStore = ProfileStore() // Added ProfileStore
    
    @State private var showPermissionGuide = false
    @State private var isInitializing = true
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            Group { EmptyView() }
                .withTheme { theme in
                    AnyView(
                        ZStack {
                            MainTabView()
                                .environmentObject(themeManager)
                                .environmentObject(blockManager)
                                .environmentObject(coordinator)
                                .environmentObject(profileStore) // Injected ProfileStore
                                .onAppear {
                                    updateThemeBasedOnSystemColorScheme(colorScheme)
                                    Task {
                                        await performInitialSetup()
                                    }
                                }
                                .onChange(of: scenePhase) { _, newValue in
                                    if newValue == .active {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            updateThemeBasedOnSystemColorScheme(getSystemColorScheme())
                                        }
                                        Task {
                                            await checkPermissionsIfNeeded()
                                        }
                                    }
                                }
                                .opacity(isInitializing ? 0 : 1)
                                .disabled(isInitializing)
                            
                            if isInitializing {
                                InitialLoadingView(theme: theme)
                            }
                            
                            if showPermissionGuide && !isInitializing {
                                Color.black.opacity(0.4)
                                    .ignoresSafeArea()
                                    .transition(.opacity)
                                
                                PermissionGuideView(
                                    requiredManagers: [
                                        coordinator.manager(for: .screenTime)!
                                    ],
                                    optionalManagers: [
                                        coordinator.manager(for: .notification)!,
                                        coordinator.manager(for: .location)!
                                    ]
                                )
                                .environmentObject(coordinator)
                                .transition(.move(edge: .bottom))
                                .zIndex(1)
                                .onChange(of: coordinator.shouldShowPermissionGuide()) { _, shouldShow in
                                    withAnimation {
                                        showPermissionGuide = shouldShow
                                    }
                                }
                            }
                        }
                            .animation(.easeInOut, value: showPermissionGuide)
                            .animation(.easeInOut, value: isInitializing)
                            .adaptToThemeColorScheme()
                    )
                }
        }
    }
    
    private func performInitialSetup() async {
        print("Starting initial setup at \(Date())")
        do {
            try await withTimeout(seconds: 5.0) {
                await coordinator.checkAllPermissions()
            }
        } catch {
            print("Initial setup failed: \(error) at \(Date())")
        }
        await MainActor.run {
            print("Initial setup completed, showPermissionGuide: \(coordinator.shouldShowPermissionGuide()) at \(Date())")
            self.showPermissionGuide = self.coordinator.shouldShowPermissionGuide()
            self.isInitializing = false
        }
    }
    
    private func checkPermissionsIfNeeded() async {
        if !showPermissionGuide {
            await coordinator.checkAllPermissions()
            await MainActor.run {
                let shouldShow = self.coordinator.shouldShowPermissionGuide()
                if shouldShow != self.showPermissionGuide {
                    withAnimation {
                        self.showPermissionGuide = shouldShow
                    }
                }
            }
        }
    }
    
    private func getSystemColorScheme() -> ColorScheme {
        let style = UIScreen.main.traitCollection.userInterfaceStyle
        return style == .dark ? .dark : .light
    }
    
    private func updateThemeBasedOnSystemColorScheme(_ scheme: ColorScheme) {
        themeManager.updateSystemColorScheme(scheme)
        let isDark = (scheme == .dark)
        let currentThemeBase = themeManager.currentThemeId.split(separator: ".").first.map(String.init) ?? "default"
        let newSystemBasedThemeId = isDark ? "\(currentThemeBase).dark" : "\(currentThemeBase).light"
        
        let currentEffectiveColorScheme = themeManager.currentTheme.colorScheme ?? scheme
        if newSystemBasedThemeId != themeManager.currentThemeId && currentEffectiveColorScheme != scheme {
            if themeManager.availableThemes.contains(where: { $0.id == newSystemBasedThemeId }) {
                themeManager.setTheme(id: newSystemBasedThemeId)
            }
        }
    }
}
