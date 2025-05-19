import SwiftUI

struct SettingsRow: View {
    let item: SettingItem
    var onToggle: ((Bool) -> Void)? = nil
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            HStack {
                // 아이콘
                ZStack {
                    Circle()
                        .fill(theme.secondaryBackgroundColor)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: item.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(theme.secondaryTextColor)
                }
                
                // 라벨
                Text(item.label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.primaryTextColor)
                    .padding(.leading, 12)
                
                Spacer()
                
                // 배지 (있는 경우)
                if let badge = item.badge {
                    Text(badge)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(theme.primaryColor.opacity(0.1))
                        .foregroundColor(theme.primaryColor)
                        .cornerRadius(theme.cornerRadius / 2)
                        .padding(.trailing, 8)
                }
                
                // 토글 또는 화살표
                if item.toggle {
                    Toggle("", isOn: Binding(
                        get: { item.state },
                        set: { newValue in
                            onToggle?(newValue)
                        }
                    ))
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(theme.tertiaryTextColor)
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                if !item.toggle, let action = item.action {
                    action()
                }
            }
        }
    }
}

struct SettingsSection: View {
    let section: SettingsSectionModel
    var onToggle: ((Int, Bool) -> Void)? = nil
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 0) {
                Text(section.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(theme.primaryTextColor)
                    .padding(.bottom, 8)
                
                VStack(spacing: 0) {
                    ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                        SettingsRow(item: item) { newValue in
                            onToggle?(index, newValue)
                        }
                        
                        if index < section.items.count - 1 {
                            Divider()
                                .background(theme.tertiaryTextColor.opacity(0.2))
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
                .background(theme.cardBackgroundColor)
                .cornerRadius(theme.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: theme.tertiaryTextColor.opacity(0.05), radius: 2, x: 0, y: 1)
            }
        }
    }
}

// 라이트 모드 프리뷰
#Preview {
    VStack(spacing: 24) {
        SettingsSection(
            section: SettingsSectionModel.generalSettings
        )
        
        SettingsSection(
            section: SettingsSectionModel.permissionsSettings
        )
    }
    .padding()
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct SettingsComponentsDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return VStack(spacing: 24) {
            SettingsSection(
                section: SettingsSectionModel.generalSettings
            )
            
            SettingsSection(
                section: SettingsSectionModel.permissionsSettings
            )
        }
        .padding()
        .background(Color.black)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}
