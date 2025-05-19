import SwiftUI

struct SettingsView: View {
    @State private var darkMode = false
    @EnvironmentObject private var themeManager: ThemeManager
    let settings = SettingsSectionModel.allSections
    
    var body: some View {
        withTheme { theme in
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더 영역
                    HStack {
                        Text("설정")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                    }
                    
                    // 설정 섹션들
                    ForEach(settings) { section in
                        SettingsSection(
                            section: section,
                            onToggle: { index, newValue in
                                toggleSetting(section: section.title, index: index, newValue: newValue)
                            }
                        )
                    }
                    
                    // 앱 버전 정보
                    VStack(alignment: .leading, spacing: 12) {
                        Text("정보")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        VStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("앱 버전")
                                    .font(.system(size: 14))
                                    .foregroundColor(theme.secondaryTextColor)
                                
                                Text("SimplyLock v1.2.3")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(theme.primaryTextColor)
                            }
                            .padding()
                            
                            Divider()
                                .background(theme.tertiaryTextColor.opacity(0.2))
                            
                            Button(action: showPrivacyPolicy) {
                                HStack {
                                    Text("개인정보 처리방침")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(theme.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.secondaryTextColor)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                            
                            Divider()
                                .background(theme.tertiaryTextColor.opacity(0.2))
                            
                            Button(action: showTermsOfService) {
                                HStack {
                                    Text("이용약관")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(theme.primaryTextColor)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.secondaryTextColor)
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding()
                        }
                        .background(theme.cardBackgroundColor)
                        .cornerRadius(theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding()
            }
            .background(theme.backgroundColor)
        }
    }
    
    private func toggleSetting(section: String, index: Int, newValue: Bool) {
        // 설정 변경 처리 로직
        switch section {
        case "일반 설정":
            if index == 0 {
                darkMode = newValue
                // 다크 모드 전환 처리
                if let currentTheme = themeManager.currentTheme as? AppTheme {
                    // 현재 테마 계열 유지하면서 다크/라이트 모드 전환
                    let themeParts = themeManager.currentThemeId.split(separator: ".")
                    if themeParts.count >= 2 {
                        let themeBase = String(themeParts[0])
                        let newThemeId = newValue ? "\(themeBase).dark" : "\(themeBase).light"
                        themeManager.setTheme(id: newThemeId)
                    }
                }
            }
        default:
            break
        }
    }
    
    private func showPrivacyPolicy() {
        // 개인정보 처리방침 화면 표시
    }
    
    private func showTermsOfService() {
        // 이용약관 화면 표시
    }
}

struct SettingIcon: View {
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.1))
                .frame(width: 32, height: 32)
            
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
        }
    }
}

struct LanguageSettingsView: View {
    @State private var selectedLanguage = "한국어"
    let languages = ["한국어", "English", "日本語", "中文(简体)", "Español"]
    
    var body: some View {
        withTheme { theme in
            List {
                ForEach(languages, id: \.self) { language in
                    Button(action: {
                        selectedLanguage = language
                    }) {
                        HStack {
                            Text(language)
                                .foregroundColor(theme.primaryTextColor)
                            
                            Spacer()
                            
                            if language == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundColor(theme.primaryColor)
                            }
                        }
                    }
                    .foregroundColor(theme.primaryTextColor)
                }
            }
            .background(theme.backgroundColor)
            .navigationBarTitle("언어 설정", displayMode: .inline)
        }
    }
}

struct NotificationSettingsView: View {
    @State private var allNotificationsEnabled = true
    @State private var sessionStartEnabled = true
    @State private var sessionEndEnabled = true
    @State private var goalAchievedEnabled = true
    @State private var blockAttemptsEnabled = true
    @State private var reminderEnabled = false
    
    var body: some View {
        withTheme { theme in
            Form {
                Section {
                    Toggle("모든 알림", isOn: $allNotificationsEnabled)
                        .foregroundColor(theme.primaryTextColor)
                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                }
                
                Section(header: Text("타이머 알림").foregroundColor(theme.secondaryTextColor)) {
                    Toggle("세션 시작", isOn: $sessionStartEnabled)
                        .foregroundColor(theme.primaryTextColor)
                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                    
                    Toggle("세션 종료", isOn: $sessionEndEnabled)
                        .foregroundColor(theme.primaryTextColor)
                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                }
                
                Section(header: Text("사용 분석 알림").foregroundColor(theme.secondaryTextColor)) {
                    Toggle("목표 달성", isOn: $goalAchievedEnabled)
                        .foregroundColor(theme.primaryTextColor)
                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                    
                    Toggle("차단 시도", isOn: $blockAttemptsEnabled)
                        .foregroundColor(theme.primaryTextColor)
                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                }
                
                Section(header: Text("집중 리마인더").foregroundColor(theme.secondaryTextColor)) {
                    Toggle("집중 리마인더", isOn: $reminderEnabled)
                        .foregroundColor(theme.primaryTextColor)
                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                    
                    if reminderEnabled {
                        HStack {
                            Text("주기")
                                .foregroundColor(theme.primaryTextColor)
                            
                            Spacer()
                            
                            Text("1시간마다")
                                .foregroundColor(theme.secondaryTextColor)
                        }
                    }
                }
            }
            .background(theme.backgroundColor)
            .navigationBarTitle("알림 설정", displayMode: .inline)
            .accentColor(theme.primaryColor)
        }
    }
}

struct AccountInfoView: View {
    @State private var email = "user@example.com"
    @State private var name = "사용자"
    
    var body: some View {
        withTheme { theme in
            Form {
                Section(header: Text("계정 정보").foregroundColor(theme.secondaryTextColor)) {
                    HStack {
                        Text("이름")
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Text(name)
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    HStack {
                        Text("이메일")
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Text(email)
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                
                Section {
                    Button(action: {}) {
                        Text("로그아웃")
                            .foregroundColor(theme.errorColor)
                    }
                    
                    Button(action: {}) {
                        Text("계정 삭제")
                            .foregroundColor(theme.errorColor)
                    }
                }
            }
            .background(theme.backgroundColor)
            .navigationBarTitle("계정 정보", displayMode: .inline)
        }
    }
}

struct SubscriptionManagementView: View {
    @State private var isSubscribed = true
    let subscriptionExpiry = "2025년 12월 31일"
    
    var body: some View {
        withTheme { theme in
            ScrollView {
                VStack(spacing: 24) {
                    // 구독 상태 카드
                    VStack(spacing: 8) {
                        Text("SimplyLock 프리미엄")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Text(isSubscribed ? "활성화됨" : "비활성화됨")
                            .font(.system(size: 18))
                            .foregroundColor(isSubscribed ? theme.successColor : theme.errorColor)
                        
                        if isSubscribed {
                            Text("다음 갱신일: \(subscriptionExpiry)")
                                .font(.system(size: 14))
                                .foregroundColor(theme.secondaryTextColor)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.primaryColor.opacity(0.1))
                    .cornerRadius(theme.cornerRadius)
                    
                    // 프리미엄 기능 목록
                    VStack(alignment: .leading, spacing: 16) {
                        Text("프리미엄 혜택")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            SubscriptionFeatureRow(
                                icon: "shield.fill",
                                title: "무제한 차단 프로필",
                                description: "원하는 만큼 프로필을 만들고 관리하세요"
                            )
                            
                            SubscriptionFeatureRow(
                                icon: "location.fill",
                                title: "위치 기반 자동화",
                                description: "특정 장소에 도착하면 자동으로 프로필 전환"
                            )
                            
                            SubscriptionFeatureRow(
                                icon: "chart.bar.fill",
                                title: "고급 인사이트 및 분석",
                                description: "더 자세한 사용 패턴 분석과 리포트"
                            )
                            
                            SubscriptionFeatureRow(
                                icon: "icloud.fill",
                                title: "클라우드 동기화",
                                description: "여러 기기에서 설정 동기화"
                            )
                        }
                        .padding()
                        .background(theme.cardBackgroundColor)
                        .cornerRadius(theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // 구독 관리 버튼
                    if isSubscribed {
                        Button(action: {}) {
                            Text("구독 관리")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.primaryColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.primaryColor.opacity(0.1))
                                .cornerRadius(theme.cornerRadius)
                        }
                    } else {
                        Button(action: {}) {
                            Text("프리미엄 구독하기")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(theme.primaryColor)
                                .cornerRadius(theme.cornerRadius)
                        }
                    }
                }
                .padding()
            }
            .background(theme.backgroundColor)
            .navigationBarTitle("구독 관리", displayMode: .inline)
        }
    }
}

struct SubscriptionFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        withTheme { theme in
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(theme.primaryColor)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}

// 설정 항목 모델
struct SettingsItemModel: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
    var subtitle: String? = nil
    var badge: String? = nil
    var destination: String? = nil
    var isToggle: Bool = false
    var isOn: Binding<Bool> = .constant(false)
    var iconColor: Color? = nil
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct SettingsViewDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return SettingsView()
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
    }
}
