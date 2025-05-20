import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let subtitle: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.secondaryTextColor)
                }
                .padding(.bottom, 8)
                
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(theme.primaryTextColor)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(theme.tertiaryTextColor)
                    .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.cardBackgroundColor)
                    .shadow(color: theme.primaryTextColor.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
            .onAppear {
                print("-------------------- StatCard body called, theme: \(themeManager.currentThemeId), title: \(title)")
            }
        }
    }
}

struct GoalProgressCard: View {
    let goal: Goal
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(goal.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Text(goal.target)
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    Text("\(goal.progress)%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(theme.successColor)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.tertiaryTextColor.opacity(0.2))
                            .frame(height: 8)
                        
                        // Progress
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.successColor)
                            .frame(width: geometry.size.width * CGFloat(goal.progress) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.cardBackgroundColor)
                    .shadow(color: theme.primaryTextColor.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
            .onAppear {
                print("-------------------- GoalProgressCard body called, theme: \(themeManager.currentThemeId), title: \(goal.title)")
            }
        }
    }
}

// 라이트 모드 프리뷰
#Preview {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            StatCard(
                title: "스크린 타임",
                value: "3시간 12분",
                iconName: "clock",
                subtitle: "어제보다 45분 감소"
            )
            
            StatCard(
                title: "차단 시도",
                value: "12회",
                iconName: "shield.fill",
                subtitle: "주로 소셜 미디어 앱"
            )
        }
        GoalProgressCard(goal: Goal.sample)
}
    .padding()
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct CardComponentsDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "스크린 타임",
                    value: "3시간 12분",
                    iconName: "clock",
                    subtitle: "어제보다 45분 감소"
                )
                
                StatCard(
                    title: "차단 시도",
                    value: "12회",
                    iconName: "shield.fill",
                    subtitle: "주로 소셜 미디어 앱"
                )
            }
            
            GoalProgressCard(goal: Goal.sample)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))  // 다크 모드용 배경색 조정
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}
