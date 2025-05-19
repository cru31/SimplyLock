import SwiftUI

struct ProfileCard: View {
    let profile: Profile
    var isActive: Bool
    var onToggle: () -> Void
    var onEdit: () -> Void
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    // 프로필 아이콘
                    ZStack {
                        RoundedRectangle(cornerRadius: theme.cornerRadius / 1.5)
                            .fill(profile.iconBackgroundColor)
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: profile.iconName)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                    
                    // 프로필 이름과 설명
                    VStack(alignment: .leading, spacing: 2) {
                        Text(profile.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Text(profile.description)
                            .font(.system(size: 12))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    // 토글 버튼과 편집 버튼
                    HStack {
                        // 토글 스위치
                        Toggle("", isOn: Binding(
                            get: { isActive },
                            set: { _ in onToggle() }
                        ))
                        .labelsHidden()
                        .toggleStyle(CustomToggleStyle(theme: theme, isOn: isActive))
                        
                        // 편집 또는 더보기 버튼
                        Button(action: onEdit) {
                            Image(systemName: profile.isSystem ? "ellipsis" : "pencil")
                                .foregroundColor(theme.secondaryTextColor)
                                .font(.system(size: 18))
                        }
                    }
                }
                .padding(.bottom, 12)
                
                // 앱 및 웹사이트 카운트, 스트릭트 모드 표시
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "iphone")
                            .font(.system(size: 14))
                            .foregroundColor(theme.tertiaryTextColor)
                        Text("\(profile.appCount)개 앱")
                            .font(.system(size: 12))
                            .foregroundColor(theme.tertiaryTextColor)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 14))
                            .foregroundColor(theme.tertiaryTextColor)
                        Text("\(profile.websiteCount)개 사이트")
                            .font(.system(size: 12))
                            .foregroundColor(theme.tertiaryTextColor)
                    }
                    
                    if profile.strictMode {
                        HStack(spacing: 4) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14))
                                .foregroundColor(theme.errorColor)
                            Text("Strict Mode")
                                .font(.system(size: 12))
                                .foregroundColor(theme.errorColor)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.cardBackgroundColor)
                    .shadow(
                        color: isActive ? theme.primaryColor.opacity(0.2) : theme.tertiaryTextColor.opacity(0.1),
                        radius: isActive ? 4 : 2,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(
                        isActive ? theme.primaryColor : theme.tertiaryTextColor.opacity(0.2),
                        lineWidth: isActive ? 2 : 1
                    )
            )
        }
    }
}
#Preview {
    VStack(spacing: 16) {
        ProfileCard(
            profile: Profile.samples[0],
            isActive: true,
            onToggle: {},
            onEdit: {}
        )
        ProfileCard(
            profile: Profile.samples[1],
            isActive: false,
            onToggle: {},
            onEdit: {}
        )
    }
    .padding()
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}

// 미리보기용 다크 모드 지원
struct ProfileCardDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return VStack(spacing: 16) {
            ProfileCard(
                profile: Profile.samples[0],
                isActive: true,
                onToggle: {},
                onEdit: {}
            )
            
            ProfileCard(
                profile: Profile.samples[1],
                isActive: false,
                onToggle: {},
                onEdit: {}
            )
        }
        .padding()
        .background(Color.black)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}
