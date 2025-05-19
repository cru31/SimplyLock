import SwiftUI

struct ProfilesView: View {
    @State private var activeProfileId: Int? = 1
    @State private var showingProfileEditor = false
    @State private var editingProfile: Profile? = nil
    @State private var timeBasedAutomation = true
    @State private var locationBasedAutomation = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    let systemProfiles = Profile.samples.filter { $0.isSystem }
    let customProfiles = Profile.samples.filter { !$0.isSystem }
    
    var body: some View {
        withTheme { theme in
            ScrollView {
                VStack(spacing: 16) {
                    // 헤더 영역
                    HStack {
                        Text("프로필")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Button(action: {
                            editingProfile = nil
                            showingProfileEditor = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(theme.primaryColor)
                                .clipShape(Circle())
                        }
                    }
                    
                    // 기본 프로필 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("기본 프로필")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        VStack(spacing: 12) {
                            ForEach(systemProfiles) { profile in
                                ProfileCard(
                                    profile: profile,
                                    isActive: activeProfileId == profile.id,
                                    onToggle: {
                                        toggleProfile(id: profile.id)
                                    },
                                    onEdit: {
                                        showProfileOptions(profile: profile)
                                    }
                                )
                            }
                        }
                    }
                    
                    // 사용자 정의 프로필 섹션
                    if !customProfiles.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("사용자 정의 프로필")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(theme.primaryTextColor)
                            
                            VStack(spacing: 12) {
                                ForEach(customProfiles) { profile in
                                    ProfileCard(
                                        profile: profile,
                                        isActive: activeProfileId == profile.id,
                                        onToggle: {
                                            toggleProfile(id: profile.id)
                                        },
                                        onEdit: {
                                            editingProfile = profile
                                            showingProfileEditor = true
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    // 자동 전환 설정 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        Text("자동 전환 설정")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        VStack(spacing: 0) {
                            // 시간 기반 전환
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack {
                                        Image(systemName: "clock")
                                            .font(.system(size: 18))
                                            .foregroundColor(theme.secondaryTextColor)
                                        
                                        Text("시간 기반 전환")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(theme.primaryTextColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $timeBasedAutomation)
                                        .labelsHidden()
                                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                                }
                                
                                if timeBasedAutomation {
                                    VStack(spacing: 4) {
                                        HStack {
                                            Text("평일 9:00 AM - 3:00 PM")
                                                .font(.system(size: 14))
                                                .foregroundColor(theme.secondaryTextColor)
                                            
                                            Spacer()
                                            
                                            Text("학습 모드")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(theme.primaryColor)
                                        }
                                        
                                        HStack {
                                            Text("평일 11:00 PM - 6:00 AM")
                                                .font(.system(size: 14))
                                                .foregroundColor(theme.secondaryTextColor)
                                            
                                            Spacer()
                                            
                                            Text("수면 모드")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(theme.primaryColor)
                                        }
                                    }
                                    .padding(.leading, 28)
                                }
                            }
                            .padding()
                            
                            Divider()
                                .background(theme.tertiaryTextColor.opacity(0.2))
                            
                            // 위치 기반 전환
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack {
                                        Image(systemName: "location")
                                            .font(.system(size: 18))
                                            .foregroundColor(theme.secondaryTextColor)
                                        
                                        Text("위치 기반 전환")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(theme.primaryTextColor)
                                    }
                                    
                                    Spacer()
                                    
                                    Toggle("", isOn: $locationBasedAutomation)
                                        .labelsHidden()
                                        .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                                }
                            }
                            .padding()
                            
                            // 자동 전환 규칙 설정 버튼
                            Button(action: showAutomationRules) {
                                Text("자동 전환 규칙 설정")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(theme.primaryColor)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(theme.buttonBackgroundColor)
                                    .cornerRadius(theme.cornerRadius)
                            }
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
            .sheet(isPresented: $showingProfileEditor) {
                if let profile = editingProfile {
                    ProfileEditorView(profile: profile, isPresented: $showingProfileEditor)
                } else {
                    ProfileEditorView(isPresented: $showingProfileEditor)
                }
            }
        }
    }
    
    private func toggleProfile(id: Int) {
        if activeProfileId == id {
            activeProfileId = nil
        } else {
            activeProfileId = id
        }
    }
    
    private func showProfileOptions(profile: Profile) {
        // 프로필 옵션 메뉴 표시 (ActionSheet나 컨텍스트 메뉴로 구현 가능)
        print("Show options for profile: \(profile.name)")
    }
    
    private func showAutomationRules() {
        // 자동 전환 규칙 설정 화면으로 이동
        print("Show automation rules")
    }
}

struct ProfileEditorView: View {
    @State private var profileName: String
    @State private var description: String
    @State private var iconName: String
    @State private var iconColor: Color
    @State private var strictMode: Bool
    @State private var selectedApps: [String] = []
    @State private var selectedWebsites: [String] = []
    @State private var showAppSelection = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Binding var isPresented: Bool
    
    private var isExistingProfile: Bool
    private var profileId: Int?
    
    // 새 프로필 생성 이니셜라이저
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._profileName = State(initialValue: "")
        self._description = State(initialValue: "")
        self._iconName = State(initialValue: "lock.fill")
        self._iconColor = State(initialValue: .blue)
        self._strictMode = State(initialValue: false)
        self.isExistingProfile = false
        self.profileId = nil
    }
    
    // 기존 프로필 편집 이니셜라이저
    init(profile: Profile, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._profileName = State(initialValue: profile.name)
        self._description = State(initialValue: profile.description)
        self._iconName = State(initialValue: profile.iconName)
        self._iconColor = State(initialValue: profile.iconBackgroundColor)
        self._strictMode = State(initialValue: profile.strictMode)
        self.isExistingProfile = true
        self.profileId = profile.id
        
        // 실제 구현에서는 여기서 프로필의 앱 및 웹사이트 목록을 로드해야 함
    }
    
    var body: some View {
        withTheme { theme in
            NavigationView {
                Form {
                    Section(header: Text("프로필 정보").foregroundColor(theme.secondaryTextColor)) {
                        TextField("프로필 이름", text: $profileName)
                            .foregroundColor(theme.primaryTextColor)
                        
                        TextField("설명", text: $description)
                            .foregroundColor(theme.primaryTextColor)
                        
                        // 아이콘 선택기 (간단한 구현)
                        HStack {
                            Text("아이콘")
                                .foregroundColor(theme.primaryTextColor)
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(iconColor)
                                    .frame(width: 30, height: 30)
                                
                                Image(systemName: iconName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // 색상 선택기 (간단한 구현)
                        HStack {
                            Text("색상")
                                .foregroundColor(theme.primaryTextColor)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                ForEach([Color.blue, Color.purple, Color.green, Color.red, Color.yellow], id: \.self) { color in
                                    Circle()
                                        .fill(color)
                                        .frame(width: 24, height: 24)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: iconColor == color ? 2 : 0)
                                        )
                                        .onTapGesture {
                                            iconColor = color
                                        }
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("차단 설정").foregroundColor(theme.secondaryTextColor)) {
                        NavigationLink(
                            destination: Text("앱 선택 화면")
                                .foregroundColor(theme.primaryTextColor)
                        ) {
                            HStack {
                                Text("앱 차단")
                                    .foregroundColor(theme.primaryTextColor)
                                
                                Spacer()
                                
                                Text("\(selectedApps.count)개 선택됨")
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                        }
                        
                        NavigationLink(
                            destination: Text("웹사이트 선택 화면")
                                .foregroundColor(theme.primaryTextColor)
                        ) {
                            HStack {
                                Text("웹사이트 차단")
                                    .foregroundColor(theme.primaryTextColor)
                                
                                Spacer()
                                
                                Text("\(selectedWebsites.count)개 선택됨")
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                        }
                    }
                    
                    Section(header: Text("추가 설정").foregroundColor(theme.secondaryTextColor)) {
                        Toggle("Strict Mode", isOn: $strictMode)
                            .foregroundColor(theme.primaryTextColor)
                            .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                        
                        if strictMode {
                            Text("활성화 중에는 차단을 해제할 수 없습니다")
                                .font(.caption)
                                .foregroundColor(theme.errorColor)
                        }
                    }
                    
                    if isExistingProfile {
                        Section {
                            Button(action: deleteProfile) {
                                Text("프로필 삭제")
                                    .foregroundColor(theme.errorColor)
                            }
                        }
                    }
                }
                .background(theme.backgroundColor)
                .navigationBarTitle(isExistingProfile ? "프로필 편집" : "새 프로필", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("취소") {
                        isPresented = false
                    }
                        .foregroundColor(theme.primaryColor),
                    
                    trailing: Button("저장") {
                        saveProfile()
                    }
                        .foregroundColor(theme.primaryColor)
                        .disabled(profileName.isEmpty)
                )
                .accentColor(theme.primaryColor)
            }
            .preferredColorScheme(theme.colorScheme)
        }
    }
    
    private func saveProfile() {
        // 프로필 저장 로직
        isPresented = false
    }
    
    private func deleteProfile() {
        // 프로필 삭제 로직
        isPresented = false
    }
}

#Preview {
    ProfilesView()
        .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct ProfilesViewDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return ProfilesView()
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
    }
}
