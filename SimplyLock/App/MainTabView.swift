import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject private var themeManager: ThemeManager
    
    enum Tab {
        case home, profiles, insights, timer, settings
    }
    
    var body: some View {
        withTheme { theme in
            ZStack {
                theme.backgroundColor
                    .ignoresSafeArea()
                
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("홈", systemImage: "house.fill")
                        }
                        .tag(Tab.home)
                    
                    ProfilesView()
                        .tabItem {
                            Label("프로필", systemImage: "person.fill")
                        }
                        .tag(Tab.profiles)
                    
                    InsightsView()
                        .tabItem {
                            Label("인사이트", systemImage: "chart.bar.fill")
                        }
                        .tag(Tab.insights)
                    
                    TimerView()
                        .tabItem {
                            Label("타이머", systemImage: "timer")
                        }
                        .tag(Tab.timer)
                    
                    SettingsView()
                        .tabItem {
                            Label("설정", systemImage: "gearshape.fill")
                        }
                        .tag(Tab.settings)
                }
                .accentColor(theme.primaryColor) // 탭 아이템 강조 색상
                .id(themeManager.currentThemeId) // 테마 변경 시 강제 갱신
                .onAppear {
                    // 탭 바 시스템 스타일 오버라이드
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(theme.backgroundColor)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                    

                }
                .onChange(of: themeManager.currentThemeId) { _, newValue in
                    // 테마 변경 시 탭 바 배경 갱신
                    let appearance = UITabBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = UIColor(theme.backgroundColor)
                    UITabBar.appearance().standardAppearance = appearance
                    UITabBar.appearance().scrollEdgeAppearance = appearance
                    print("MainTabView theme changed to: \(newValue)")
                }
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ThemeManager.shared)
}
