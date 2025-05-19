import SwiftUI
import UIKit
@main
struct SimplyLockApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeManager)
                .onAppear {
                    // 앱 시작 시 테마 설정
                    updateThemeBasedOnSystemColorScheme(colorScheme)
                }

                .onChange(of: scenePhase) { _, newValue in
                    if newValue == .active {
                        // 앱 활성화 시 약간 지연 후 테마 업데이트
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            print("App activated, colorScheme: \(colorScheme)")
                            
                            let systemColorScheme = getSystemColorScheme()
                            print("Updating theme for colorScheme: \(systemColorScheme)")
                            
                            updateThemeBasedOnSystemColorScheme(systemColorScheme)
                        }
                    }
                }
        }
    }
    
    private func getSystemColorScheme() -> ColorScheme {
        let style = UIScreen.main.traitCollection.userInterfaceStyle
        print("UIScreen style: \(style == .dark ? "dark" : "light")")
        return style == .dark ? .dark : .light
    }
    
    private func updateThemeBasedOnSystemColorScheme(_ colorScheme: ColorScheme) {
        
        
        print("Updating theme for colorScheme: \(colorScheme)")
        themeManager.updateSystemColorScheme(colorScheme)
        
        let themeBase = themeManager.currentThemeId.split(separator: ".").first.map(String.init) ?? "default"
        let newThemeId: String
        switch colorScheme {
        case .dark:
            newThemeId = "\(themeBase).dark"
        case .light:
            newThemeId = "\(themeBase).light"
        @unknown default:
            newThemeId = "\(themeBase).light"
            print("Unknown color scheme, defaulting to light")
        }
        
        if newThemeId != themeManager.currentThemeId && themeManager.availableThemes.contains(where: { $0.id == newThemeId }) {
            themeManager.setTheme(id: newThemeId)
        }
    }
}
