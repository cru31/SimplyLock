import SwiftUI
import FamilyControls // Required for Profile's activitySelection

struct ProfilesView: View {
    @State private var activeProfileId: UUID? = Profile.samples.first(where: { $0.isSystem })?.id // Default to first system profile
    @State private var showingProfileEditor = false
    @State private var editingProfile: Profile? = nil
    @State private var timeBasedAutomation = true
    @State private var locationBasedAutomation = false
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var profileStore = ProfileStore()
    @EnvironmentObject private var blockManager: BlockManager // Added BlockManager
    
    // State variables for activation flow
    @State private var showDurationPickerForProfile: Profile? = nil
    @State private var selectedDuration: TimeInterval = 1800 // Default to 30 minutes
    
    let systemProfiles = Profile.samples.filter { $0.isSystem }
    // Removed: let customProfiles = Profile.samples.filter { !$0.isSystem }
    
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
                            editingProfile = nil // Ensure we're creating a new profile
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
                                        // System profiles are not editable in this manner
                                        showProfileOptions(profile: profile)
                                    }
                                )
                            }
                        }
                    }
                    
                    // 사용자 정의 프로필 섹션
                    // Updated to use profileStore.customProfiles
                    if !profileStore.customProfiles.filter({ !$0.isSystem }).isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("사용자 정의 프로필")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(theme.primaryTextColor)
                            
                            VStack(spacing: 12) {
                                ForEach(profileStore.customProfiles.filter { !$0.isSystem }) { profile in
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
                    ProfileEditorView(profile: profile, isPresented: $showingProfileEditor, profileStore: profileStore)
                } else {
                    ProfileEditorView(isPresented: $showingProfileEditor, profileStore: profileStore)
                }
            }
            // Add sheet for DurationPickerView
            // Using .sheet(item: $showDurationPickerForProfile) for Profile which is Identifiable
            .sheet(item: $showDurationPickerForProfile) { profileToActivate in
                DurationPickerView(
                    selectedDuration: $selectedDuration,
                    profileToActivate: profileToActivate,
                    onStart: {
                        let blockProfile = BlockProfile(
                            id: profileToActivate.id,
                            name: profileToActivate.name,
                            selection: profileToActivate.activitySelection,
                            duration: selectedDuration,
                            isPreset: profileToActivate.isSystem
                        )
                        Task {
                            await blockManager.startBlocking(with: blockProfile)
                        }
                        showDurationPickerForProfile = nil // Dismiss sheet
                        // activeProfileId is already set from toggleProfile
                    },
                    onCancel: {
                        // If the activation was cancelled, and the profile wasn't already active
                        // (i.e., activeProfileId was set to this profile in anticipation),
                        // then clear activeProfileId.
                        if activeProfileId == profileToActivate.id {
                            activeProfileId = nil
                        }
                        showDurationPickerForProfile = nil // Dismiss sheet
                    }
                )
                .environmentObject(themeManager) // Pass ThemeManager
            }
        }
    }
    
    private func toggleProfile(id: UUID) {
        if activeProfileId == id {
            // Deactivating the current profile
            blockManager.stopBlocking()
            activeProfileId = nil
            showDurationPickerForProfile = nil // Ensure picker is dismissed
        } else {
            // Activating a new profile or switching
            // If another profile was active, stop it first.
            if activeProfileId != nil {
                 blockManager.stopBlocking()
            }

            // Find the profile to activate
            let allProfiles = systemProfiles + profileStore.customProfiles
            if let profileToActivate = allProfiles.first(where: { $0.id == id }) {
                activeProfileId = id // Set the new intended active profile
                self.selectedDuration = 1800 // Reset to default duration for new selection
                showDurationPickerForProfile = profileToActivate // Trigger duration picker
            } else {
                // Profile not found - should not happen if UI is correct
                print("Error: Profile with id \(id) not found for activation.")
                activeProfileId = nil // Reset active profile
                showDurationPickerForProfile = nil // Ensure picker is not shown
            }
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

// MARK: - DurationPickerView Definition

struct DurationPickerView: View {
    @Binding var selectedDuration: TimeInterval
    let profileToActivate: Profile
    var onStart: () -> Void
    var onCancel: () -> Void // Added for explicit cancel action
    
    @Environment(\.dismiss) var dismiss // For dismissing the sheet
    @EnvironmentObject var themeManager: ThemeManager
    
    // Predefined durations (in seconds)
    private let presetDurations: [TimeInterval] = [
        1800, // 30 min
        3600, // 1 hour
        7200, // 2 hours
        10800, // 3 hours
        14400 // 4 hours
    ]
    
    private func formatDuration(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: interval) ?? ""
    }
    
    var body: some View {
        withTheme { theme in
            NavigationView { // Provides structure and a title bar
                VStack(spacing: 24) {
                    Picker("Select Duration", selection: $selectedDuration) {
                        ForEach(presetDurations, id: \.self) { duration in
                            Text(formatDuration(duration)).tag(duration)
                                .foregroundColor(theme.primaryTextColor)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.cardBackgroundColor)
                    .cornerRadius(theme.cornerRadius)
                    .padding(.horizontal)

                    HStack(spacing: 15) {
                        Button(action: {
                            onCancel() // Call the cancel handler, which should dismiss
                        }) {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(theme.primaryColor)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(theme.buttonBackgroundColor)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: theme.shadowColor.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                        
                        Button(action: {
                            onStart() // Call the start handler, which should dismiss
                        }) {
                            Text("Start Blocking")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(theme.primaryColor)
                                .cornerRadius(theme.cornerRadius)
                                .shadow(color: theme.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(theme.backgroundColor.ignoresSafeArea())
                .navigationTitle("Set Duration for \"\(profileToActivate.name)\"")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            onCancel()
                        }
                        .foregroundColor(theme.primaryColor)
                    }
                    // Optional: Add a Start button to the toolbar as well, or rely on the main one.
                    // ToolbarItem(placement: .navigationBarTrailing) {
                    //     Button("Start") {
                    //        onStart()
                    //     }
                    //     .foregroundColor(theme.primaryColor)
                    // }
                }
            }
            .preferredColorScheme(theme.colorScheme) // Adapt to theme
        }
    }
}

struct ProfileEditorView: View {
    @State private var profileName: String
    @State private var description: String
    @State private var iconName: String // Default icon
    @State private var iconColor: Color // Default color
    @State private var strictMode: Bool
    // activitySelection will be managed for new profiles; existing profiles load it.
    @State private var activitySelection = FamilyActivitySelection()
    
    @State private var selectedApps: [String] = [] // Placeholder for UI, not directly saved
    @State private var selectedWebsites: [String] = [] // Placeholder for UI, not directly saved
    @State private var showAppSelection = false // This might be removable if FamilyActivityPicker is the sole method
    @State private var isPickerPresented = false // For presenting FamilyActivityPicker
    @EnvironmentObject private var themeManager: ThemeManager
    
    @Binding var isPresented: Bool
    var profileStore: ProfileStore // Added profileStore
    
    private var isExistingProfile: Bool
    private var profileId: UUID? // Changed to UUID
    
    // 새 프로필 생성 이니셜라이저
    init(isPresented: Binding<Bool>, profileStore: ProfileStore) {
        self._isPresented = isPresented
        self.profileStore = profileStore
        self._profileName = State(initialValue: "")
        self._description = State(initialValue: "")
        self._iconName = State(initialValue: "lock.fill")
        self._iconColor = State(initialValue: .blue)
        self._strictMode = State(initialValue: false)
        self.isExistingProfile = false
        self.profileId = nil
        // activitySelection is already initialized with default
    }
    
    // 기존 프로필 편집 이니셜라이저
    init(profile: Profile, isPresented: Binding<Bool>, profileStore: ProfileStore) {
        self._isPresented = isPresented
        self.profileStore = profileStore
        self._profileName = State(initialValue: profile.name)
        self._description = State(initialValue: profile.description)
        self._iconName = State(initialValue: profile.iconName)
        self._iconColor = State(initialValue: profile.iconBackgroundColor) // Uses the computed property
        self._strictMode = State(initialValue: profile.strictMode)
        self._activitySelection = State(initialValue: profile.activitySelection) // Load existing selection
        self.isExistingProfile = true
        self.profileId = profile.id
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
                        Button(action: {
                            isPickerPresented = true
                        }) {
                            HStack {
                                Text("차단할 앱 및 웹사이트 선택")
                                    .foregroundColor(theme.primaryTextColor) // Ensure text color matches form style
                                Spacer()
                                Text("\(activitySelection.applicationTokens.count + activitySelection.categoryTokens.count) 앱, \(activitySelection.webDomainTokens.count) 웹사이트")
                                    .foregroundColor(theme.secondaryTextColor)
                                Image(systemName: "chevron.right") // Optional: for disclosure indicator
                                    .foregroundColor(.gray.opacity(0.5))
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
            .sheet(isPresented: $isPickerPresented) {
                FamilyActivityPicker(selection: $activitySelection, title: Text("앱 및 웹사이트 선택"))
            }
            .preferredColorScheme(theme.colorScheme)
        }
    }
    
    private func saveProfile() {
        if isExistingProfile {
            // Update existing profile
            guard let existingProfileId = profileId,
                  let index = profileStore.customProfiles.firstIndex(where: { $0.id == existingProfileId }) else {
                print("Error: Could not find profile to update.")
                isPresented = false
                return
            }
            
            var updatedProfile = profileStore.customProfiles[index]
            updatedProfile.name = profileName
            updatedProfile.description = description
            updatedProfile.iconName = iconName
            updatedProfile.iconBackgroundColor = iconColor // This uses the setter that updates codableIconBackgroundColor
            updatedProfile.strictMode = strictMode
            updatedProfile.activitySelection = activitySelection // Update activity selection
            
            profileStore.updateProfile(updatedProfile)
            
        } else {
            // Create new profile
            let newProfile = Profile(
                name: profileName,
                iconName: iconName,
                iconBackgroundColor: iconColor, // Initializer handles CodableColor conversion
                description: description,
                activitySelection: activitySelection, // Initially empty or from picker
                strictMode: strictMode,
                isSystem: false
            )
            profileStore.addProfile(newProfile)
        }
        isPresented = false
    }
    
    private func deleteProfile() {
        guard let profileToDeleteId = profileId,
              let profileToDelete = profileStore.customProfiles.first(where: { $0.id == profileToDeleteId }) else {
            print("Error: Could not find profile to delete.")
            isPresented = false
            return
        }
        profileStore.deleteProfile(profileToDelete)
        isPresented = false
    }
}

#Preview {
    ProfilesView()
        .environmentObject(ThemeManager.shared)
        // .environmentObject(ProfileStore()) // For preview if needed
}

// 다크 모드 프리뷰
struct ProfilesViewDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return ProfilesView()
            .environmentObject(themeManager)
            // .environmentObject(ProfileStore()) // For preview if needed
            .preferredColorScheme(.dark)
    }
}
