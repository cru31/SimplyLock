import SwiftUI

struct QuickActionButton: View {
    let iconName: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isActive ? theme.primaryColor : theme.secondaryTextColor)
                    
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isActive ? theme.primaryColor : theme.secondaryTextColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(isActive ? theme.primaryColor.opacity(0.1) : theme.secondaryBackgroundColor)
                )
            }
        }
    }
}

struct QuickActionGrid: View {
    @Binding var strictMode: Bool
    let onPomodoroTap: () -> Void
    let onEmergencyTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            QuickActionButton(
                iconName: "lock.fill",
                title: "Strict Mode",
                isActive: strictMode
            ) {
                strictMode.toggle()
            }
            
            QuickActionButton(
                iconName: "timer",
                title: "뽀모도로",
                isActive: false,
                action: onPomodoroTap
            )
            
            QuickActionButton(
                iconName: "exclamationmark.triangle",
                title: "긴급 액세스",
                isActive: false,
                action: onEmergencyTap
            )
        }
    }
}

struct TipCard: View {
    let tip: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("오늘의 팁")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.warningColor.opacity(0.8))
                    
                    Text(tip)
                        .font(.system(size: 14))
                        .foregroundColor(theme.primaryTextColor.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.warningColor.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.warningColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// 라이트 모드 프리뷰
#Preview {
    VStack(spacing: 16) {
        QuickActionGrid(
            strictMode: .constant(true),
            onPomodoroTap: {},
            onEmergencyTap: {}
        )
        
        TipCard(tip: "Strict Mode를 활성화하면 설정한 시간 동안 차단을 해제할 수 없어요. 중요한 일이 있을 때는 '긴급 액세스'를 사용하세요.")
    }
    .padding()
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct ActionComponentsDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return VStack(spacing: 16) {
            QuickActionGrid(
                strictMode: .constant(true),
                onPomodoroTap: {},
                onEmergencyTap: {}
            )
            
            TipCard(tip: "Strict Mode를 활성화하면 설정한 시간 동안 차단을 해제할 수 없어요. 중요한 일이 있을 때는 '긴급 액세스'를 사용하세요.")
        }
        .padding()
        .background(Color.black)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}
