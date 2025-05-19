import SwiftUI

struct HomeView: View {
    @State private var strictMode = false
    @State private var showPomodoro = false
    @State private var showEmergency = false
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            ScrollView {
                VStack(spacing: 16) {
                    // 헤더 영역
                    HStack {
                        Text("앱블록")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 20))
                                .foregroundColor(theme.secondaryTextColor)
                                .padding(8)
                                .background(theme.buttonBackgroundColor)
                                .clipShape(Circle())
                        }
                    }
                    
                    // 현재 상태 카드
                    StatusCard(
                        title: "현재 상태",
                        subtitle: "학습 모드 활성화 중",
                        iconName: "lock.shield.fill",
                        tags: ["SNS 차단", "게임 차단", "+2개"],
                        backgroundColor: Color.blue.opacity(0.2),  // 다크 모드에서는 약간 더 진하게
                        iconColor: .blue,
                        textColor: .blue
                    )
                    
                    
                    // 빠른 액션 버튼 그룹
                    QuickActionGrid(
                        strictMode: $strictMode,
                        onPomodoroTap: showPomodoroSettings,
                        onEmergencyTap: showEmergencyAccess
                    )
                    
                    // 오늘의 통계 요약
                    VStack(alignment: .leading, spacing: 12) {
                        Text("오늘의 통계")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        HStack(spacing: 12) {
                            StatCard(
                                title: "스크린 타임",
                                value: UsageData.homeSample.totalScreenTime,
                                iconName: "clock",
                                subtitle: "어제보다 \(UsageData.homeSample.comparisonWithYesterday) 감소"
                            )
                            
                            StatCard(
                                title: "차단 시도",
                                value: "\(UsageData.homeSample.blocking.attemptsCount)회",
                                iconName: "shield.fill",
                                subtitle: UsageData.homeSample.blocking.mostBlocked
                            )
                        }
                    }
                    
                    // 목표 진행률
                    VStack(alignment: .leading, spacing: 12) {
                        Text("목표 진행률")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        GoalProgressCard(goal: Goal.sample)
                    }
                    
                    // 최근 활동
                    ActivityList(
                        activities: Activity.samples,
                        title: "최근 활동"
                    )
                    
                    // 앱 팁
                    TipCard(tip: "Strict Mode를 활성화하면 설정한 시간 동안 차단을 해제할 수 없어요. 중요한 일이 있을 때는 '긴급 액세스'를 사용하세요.")
                }
                .padding()
            }
            .background(theme.backgroundColor)
            .sheet(isPresented: $showPomodoro) {
                PomodoroSettings(isPresented: $showPomodoro)
            }
            .sheet(isPresented: $showEmergency) {
                EmergencyAccessView(isPresented: $showEmergency)
            }
        }
        //.adaptToThemeColorScheme()
    }
    
    func showPomodoroSettings() {
        showPomodoro = true
    }
    
    func showEmergencyAccess() {
        showEmergency = true
    }
}

struct PomodoroSettings: View {
    @Binding var isPresented: Bool
    @State private var focusDuration = 25
    @State private var breakDuration = 5
    @State private var longBreakDuration = 15
    @State private var sessionCount = 4
    @State private var selectedProfile: Profile?
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            VStack(spacing: 16) {
                HStack {
                    Text("뽀모도로 설정")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                
                Divider()
                    .background(theme.tertiaryTextColor.opacity(0.2))
                
                Group {
                    // 집중 시간 설정
                    HStack {
                        Text("집중 시간")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Stepper("\(focusDuration)분", value: $focusDuration, in: 5...60, step: 5)
                            .frame(width: 120)
                            .foregroundColor(theme.primaryTextColor)
                    }
                    
                    // 휴식 시간 설정
                    HStack {
                        Text("휴식 시간")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Stepper("\(breakDuration)분", value: $breakDuration, in: 1...30, step: 1)
                            .frame(width: 120)
                            .foregroundColor(theme.primaryTextColor)
                    }
                    
                    // 긴 휴식 시간 설정
                    HStack {
                        Text("긴 휴식 시간")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Stepper("\(longBreakDuration)분", value: $longBreakDuration, in: 5...60, step: 5)
                            .frame(width: 120)
                            .foregroundColor(theme.primaryTextColor)
                    }
                    
                    // 세션 카운트 설정
                    HStack {
                        Text("세션 수")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Stepper("\(sessionCount)회", value: $sessionCount, in: 1...10, step: 1)
                            .frame(width: 120)
                            .foregroundColor(theme.primaryTextColor)
                    }
                }
                
                Divider()
                    .background(theme.tertiaryTextColor.opacity(0.2))
                
                // 차단 프로필 연결
                HStack {
                    Text("차단 프로필")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Menu {
                        ForEach(Profile.samples) { profile in
                            Button(profile.name) {
                                selectedProfile = profile
                            }
                        }
                        
                        Button("연결 안함") {
                            selectedProfile = nil
                        }
                    } label: {
                        HStack {
                            Text(selectedProfile?.name ?? "선택")
                                .foregroundColor(theme.primaryColor)
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                }
                
                Spacer()
                
                // 저장 버튼
                Button(action: { isPresented = false }) {
                    Text("저장")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.primaryColor)
                        .cornerRadius(theme.cornerRadius)
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(20)
            .frame(maxWidth: 360)
            .shadow(color: Color.black.opacity(theme.colorScheme == .dark ? 0.3 : 0.1), radius: 20, x: 0, y: 10)
        }
    }
}

struct EmergencyAccessView: View {
    @Binding var isPresented: Bool
    @State private var reason = ""
    @State private var duration = 15
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            VStack(spacing: 16) {
                HStack {
                    Text("긴급 액세스")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ 긴급 액세스를 요청하시겠습니까?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Text("차단된 앱에 일시적으로 접근이 필요한 경우에만 사용하세요. 긴급 액세스 기록이 저장됩니다.")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                }
                
                Divider()
                    .background(theme.tertiaryTextColor.opacity(0.2))
                
                // 사유 입력
                VStack(alignment: .leading, spacing: 8) {
                    Text("액세스 사유")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    TextField("사유를 입력하세요", text: $reason)
                        .padding()
                        .foregroundColor(theme.primaryTextColor)
                        .background(theme.buttonBackgroundColor)
                        .cornerRadius(8)
                }
                
                // 액세스 시간 설정
                VStack(alignment: .leading, spacing: 8) {
                    Text("액세스 시간")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Picker("액세스 시간", selection: $duration) {
                        Text("5분").tag(5)
                        Text("15분").tag(15)
                        Text("30분").tag(30)
                        Text("1시간").tag(60)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .accentColor(theme.primaryColor)
                }
                
                Spacer()
                
                // 액세스 요청 버튼
                Button(action: { isPresented = false }) {
                    Text("긴급 액세스 요청")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(theme.errorColor)
                        .cornerRadius(theme.cornerRadius)
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(20)
            .frame(maxWidth: 360)
            .shadow(color: Color.black.opacity(theme.colorScheme == .dark ? 0.3 : 0.1), radius: 20, x: 0, y: 10)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct HomeViewDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return HomeView()
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
    }
}
