import SwiftUI

struct TimerView: View {
    @State private var isRunning = false
    @State private var timeLeft = 25 * 60 // 25분(초 단위)
    @State private var isBreak = false
    @State private var sessionsCompleted = 2
    @State private var showSettings = false
    @State private var linkedProfileActive = true
    @EnvironmentObject private var themeManager: ThemeManager
    
    // Added EnvironmentObjects
    @EnvironmentObject var blockManager: BlockManager
    @EnvironmentObject var profileStore: ProfileStore

    // State for Linked Profile
    @State private var linkedProfileID: UUID? = nil
    @State private var showingProfileSelectionSheet = false
    
    // 세션 기록 데이터
    let sessionHistory = Activity.sessionHistory
    
    // 현재 타이머의 총 시간
    var totalTime: Int {
        isBreak ? 5 * 60 : 25 * 60
    }
    
    var body: some View {
        withTheme { theme in
            ScrollView {
                VStack(spacing: 16) {
                    // 헤더 영역
                    HStack {
                        Text("타이머")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20))
                                .foregroundColor(theme.secondaryTextColor)
                                .padding(8)
                                .background(theme.buttonBackgroundColor)
                                .clipShape(Circle())
                        }
                    }
                    
                    // 타이머 영역
                    VStack(spacing: 16) {
                        // 모드 선택기
                        TimerModeSelector(isBreak: $isBreak)
                        
                        // 타이머 디스플레이
                        TimerDisplay(
                            timeLeft: timeLeft,
                            totalTime: totalTime,
                            isBreak: isBreak
                        )
                        .frame(maxWidth: .infinity) // 최대 너비로 확장
                        .frame(height: 256)
                        .padding(.vertical, 24)
                        
                        // 타이머 컨트롤
                        TimerControls(
                            isRunning: isRunning,
                            onReset: resetTimer,
                            onToggle: toggleTimer,
                            onNotification: toggleNotifications
                        )
                    }
                    .padding(.vertical, 24)
                    .padding(.horizontal)
                    .background(theme.cardBackgroundColor)
                    .cornerRadius(theme.cornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.cornerRadius)
                            .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                    )
                    
                    // 세션 진행 상황
                    VStack(alignment: .leading, spacing: 12) {
                        Text("오늘의 진행 상황")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        SessionProgress(completed: sessionsCompleted, total: 4)
                            .padding()
                            .background(theme.cardBackgroundColor)
                            .cornerRadius(theme.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: theme.cornerRadius)
                                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // 차단 프로필 연동
                    VStack(alignment: .leading, spacing: 12) {
                        Text("차단 프로필 연동")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text("차단 프로필 연동")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(theme.primaryTextColor)
                                
                                Spacer()
                                
                                Toggle("", isOn: $linkedProfileActive)
                                    .labelsHidden()
                                    .toggleStyle(CustomToggleStyle(theme: theme, isOn: linkedProfileActive))
                                    .onChange(of: linkedProfileActive) { _, newValue in
                                        if !newValue && isRunning && blockManager.isBlocking {
                                            // If toggle is turned off, timer is running, and a block is active
                                            print("TimerView: Linked profile toggle turned off. Stopping block.")
                                            blockManager.stopBlocking()
                                        }
                                    }
                            }
                            
                            if linkedProfileActive {
                                Button(action: {
                                    if linkedProfileActive { // Only show if toggle is on
                                        showingProfileSelectionSheet = true
                                    }
                                }) {
                                    HStack {
                                        // 프로필 아이콘 (Dynamic based on selected profile)
                                        let currentProfile = getCurrentLinkedProfile()
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(currentProfile?.iconBackgroundColor ?? theme.secondaryTextColor.opacity(0.3))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: currentProfile?.iconName ?? "questionmark.circle")
                                                .font(.system(size: 16))
                                                .foregroundColor(currentProfile != nil ? .white : theme.secondaryTextColor)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(currentProfile?.name ?? "프로필 선택")
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(theme.primaryTextColor)
                                            
                                            Text(currentProfile != nil ? "타이머 실행 중 활성화" : "탭하여 프로필 선택")
                                                .font(.system(size: 12))
                                                .foregroundColor(theme.secondaryTextColor)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(theme.secondaryTextColor)
                                    }
                                    .padding()
                                    .background(theme.buttonBackgroundColor)
                                    .cornerRadius(theme.cornerRadius)
                                }
                                .disabled(!linkedProfileActive) // Disable button if toggle is off
                            }
                        }
                        .padding()
                        .background(theme.cardBackgroundColor)
                        .cornerRadius(theme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.cornerRadius)
                                .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // 세션 기록
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("세션 기록")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(theme.primaryTextColor)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Text("모두 보기")
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.primaryColor)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(theme.primaryColor)
                                }
                            }
                        }
                        
                        ActivityList(activities: Array(sessionHistory.prefix(3)), title: "")
                    }
                }
                .padding()
            }
            .background(theme.backgroundColor)
            .sheet(isPresented: $showSettings) {
                TimerSettingsView(isPresented: $showSettings)
            }
            .sheet(isPresented: $showingProfileSelectionSheet) {
                // Inline Profile Selection Sheet
                NavigationView {
                    List {
                        Section(header: Text("기본 프로필").foregroundColor(themeManager.currentTheme.secondaryTextColor)) {
                            ForEach(Profile.samples.filter { $0.isSystem }) { profile in
                                Button(action: {
                                    linkedProfileID = profile.id
                                    showingProfileSelectionSheet = false
                                }) {
                                    profileRow(profile: profile, theme: themeManager.currentTheme)
                                }
                            }
                        }
                        
                        Section(header: Text("사용자 정의 프로필").foregroundColor(themeManager.currentTheme.secondaryTextColor)) {
                            if profileStore.customProfiles.filter({ !$0.isSystem }).isEmpty {
                                Text("사용자 정의 프로필이 없습니다.")
                                    .foregroundColor(themeManager.currentTheme.secondaryTextColor)
                            } else {
                                ForEach(profileStore.customProfiles.filter { !$0.isSystem }) { profile in
                                    Button(action: {
                                        linkedProfileID = profile.id
                                        showingProfileSelectionSheet = false
                                    }) {
                                        profileRow(profile: profile, theme: themeManager.currentTheme)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
                    .navigationTitle("프로필 선택")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("취소") {
                                showingProfileSelectionSheet = false
                            }
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                }
                .environmentObject(themeManager) // Ensure theme is available in the sheet
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
            }
        }
    }

    private func profileRow(profile: Profile, theme: AppTheme) -> some View {
        HStack {
            ZStack {
                Circle()
                    .fill(profile.iconBackgroundColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: profile.iconName)
                    .foregroundColor(profile.iconBackgroundColor)
            }
            VStack(alignment: .leading) {
                Text(profile.name)
                    .foregroundColor(theme.primaryTextColor)
                Text("\(profile.appCount) 앱, \(profile.websiteCount) 웹사이트")
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
            Spacer()
            if linkedProfileID == profile.id {
                Image(systemName: "checkmark")
                    .foregroundColor(theme.primaryColor)
            }
        }
        .contentShape(Rectangle()) // Make the whole row tappable
    }

    private func getCurrentLinkedProfile() -> Profile? {
        guard let id = linkedProfileID else { return nil }
        if let profile = profileStore.customProfiles.first(where: { $0.id == id }) {
            return profile
        }
        return Profile.samples.first(where: { $0.id == id })
    }
    
    private func toggleTimer() {
        isRunning.toggle()
        
        if isRunning {
            // Timer starts
            if linkedProfileActive, let profileID = linkedProfileID {
                if let profileToBlock = getCurrentLinkedProfile() { // Use helper to get full Profile
                    let blockProfile = BlockProfile(
                        id: profileToBlock.id, // Use original profile ID for consistency if needed
                        name: "Timer: \(profileToBlock.name)",
                        selection: profileToBlock.activitySelection,
                        duration: TimeInterval(timeLeft), // Use current timeLeft for duration
                        isPreset: profileToBlock.isSystem
                    )
                    Task {
                        print("TimerView: Starting block with profile '\(blockProfile.name)' for \(blockProfile.duration) seconds.")
                        try? await blockManager.startBlocking(with: blockProfile)
                    }
                } else {
                     print("TimerView Error: Could not find profile with ID \(profileID) to start blocking.")
                }
            }
        } else {
            // Timer stops or is paused
            if blockManager.isBlocking {
                print("TimerView: Stopping block as timer is no longer running.")
                blockManager.stopBlocking()
            }
        }
        // 실제 구현에서는 Timer를 사용하여 timeLeft를 업데이트
    }
    
    private func resetTimer() {
        isRunning = false
        timeLeft = isBreak ? 5 * 60 : 25 * 60 // Reset to current mode's full time
        
        if blockManager.isBlocking {
            print("TimerView: Stopping block due to timer reset.")
            blockManager.stopBlocking()
        }
    }
    
    private func toggleNotifications() {
        // 알림 설정 토글
    }
}
struct CustomToggleStyle: ToggleStyle {
    let theme: AppTheme
    let isOn: Bool // 원래 코드에 있으니까 유지
    
    func makeBody(configuration: Configuration) -> some View {
        let toggleInfo = theme.toggleStyle(isOn: configuration.isOn)
        
        return HStack {
            configuration.label
            
            ZStack {
                Capsule()
                    .fill(configuration.isOn ? theme.primaryColor : Color.gray.opacity(0.3))
                    .frame(width: toggleInfo.width, height: toggleInfo.height)
                
                // 썸의 위치를 offset으로 직접 제어
                Circle()
                    .fill(toggleInfo.thumbColor)
                    .frame(width: toggleInfo.height - 4, height: toggleInfo.height - 4)
                    .shadow(radius: 1)
                    .padding(2)
                    .offset(x: configuration.isOn ? (toggleInfo.width - toggleInfo.height) / 2 : -(toggleInfo.width - toggleInfo.height) / 2)
                    .animation(.spring(), value: configuration.isOn) // 부드러운 애니메이션
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

struct TimerSettingsView: View {
    @Binding var isPresented: Bool
    @State private var focusDuration = 25
    @State private var breakDuration = 5
    @State private var longBreakDuration = 15
    @State private var sessionsBeforeLongBreak = 4
    @State private var autoStartBreaks = true
    @State private var autoStartSessions = false
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject var profileStore: ProfileStore // Added for future use
    
    var body: some View {
        withTheme { theme in
            NavigationView {
                Form {
                    Section(header: Text("타이머 시간").foregroundColor(theme.secondaryTextColor)) {
                        Stepper("집중 시간: \(focusDuration)분", value: $focusDuration, in: 5...60, step: 5)
                            .foregroundColor(theme.primaryTextColor)
                        
                        Stepper("휴식 시간: \(breakDuration)분", value: $breakDuration, in: 1...30)
                            .foregroundColor(theme.primaryTextColor)
                        
                        Stepper("긴 휴식 시간: \(longBreakDuration)분", value: $longBreakDuration, in: 5...60, step: 5)
                            .foregroundColor(theme.primaryTextColor)
                        
                        Stepper("긴 휴식 전 세션 수: \(sessionsBeforeLongBreak)", value: $sessionsBeforeLongBreak, in: 2...8)
                            .foregroundColor(theme.primaryTextColor)
                    }
                    
                    Section(header: Text("자동화").foregroundColor(theme.secondaryTextColor)) {
                        Toggle("휴식 자동 시작", isOn: $autoStartBreaks)
                            .foregroundColor(theme.primaryTextColor)
                            .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                        
                        Toggle("집중 세션 자동 시작", isOn: $autoStartSessions)
                            .foregroundColor(theme.primaryTextColor)
                            .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                    }
                    
                    Section(header: Text("알림").foregroundColor(theme.secondaryTextColor)) {
                        Toggle("소리 알림", isOn: $soundEnabled)
                            .foregroundColor(theme.primaryTextColor)
                            .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                        
                        Toggle("진동 알림", isOn: $vibrationEnabled)
                            .foregroundColor(theme.primaryTextColor)
                            .toggleStyle(SwitchToggleStyle(tint: theme.primaryColor))
                    }
                    
                    Section(header: Text("차단 프로필").foregroundColor(theme.secondaryTextColor)) {
                        NavigationLink(
                            destination: Text("차단 프로필 선택 화면")
                                .foregroundColor(theme.primaryTextColor)
                        ) {
                            Text("타이머 실행 시 활성화할 프로필")
                                .foregroundColor(theme.primaryTextColor)
                        }
                    }
                }
                .background(theme.backgroundColor)
                .navigationBarTitle("타이머 설정", displayMode: .inline)
                .navigationBarItems(
                    trailing: Button("완료") {
                        isPresented = false
                    }
                        .foregroundColor(theme.primaryColor)
                )
                .accentColor(theme.primaryColor) // Form 컨트롤 색상
            }
            .background(theme.backgroundColor)
            .preferredColorScheme(theme.colorScheme)
        }
    }
}

struct SessionHistoryView: View {
    let sessions = Activity.sessionHistory
    
    var body: some View {
        withTheme { theme in
            List {
                ForEach(sessions) { session in
                    ActivityListItem(activity: session)
                }
            }
            .navigationBarTitle("세션 기록", displayMode: .inline)
            .background(theme.backgroundColor)
        }
    }
}


#Preview {
    TimerView()
        .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct TimerViewDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return TimerView()
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
    }
}
