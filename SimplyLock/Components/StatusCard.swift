import SwiftUI
// import ThemeManager // ThemeManager가 별도 모듈이라면 추가

/// 확장된 StatusCard로 프로필 선택 시트 기능 추가
struct StatusCard: View {
    @EnvironmentObject private var blockManager: BlockManager
    @Environment(\.themeManager) private var themeManager
    
    @State private var elapsedTimeText: String = "00:00:00"
    @State private var timer: Timer? = nil
    @State private var showProfileSelection = false
    
    var body: some View {
        withTheme { theme in
            cardContentView(theme: theme)
                .background(theme.cardBackgroundColor)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(
                            blockManager.isBlocking ? theme.primaryColor : Color.clear,
                            lineWidth: blockManager.isBlocking ? 2 : 0
                        )
                )
                .animation(Animation.easeInOut(duration: 0.3), value: blockManager.isBlocking)
                .onAppear(perform: startTimer)
                .onDisappear(perform: stopTimer)
                .onChange(of: blockManager.isBlocking) { _, isBlocking in
                    if isBlocking {
                        startTimer()
                    } else {
                        stopTimer()
                        elapsedTimeText = "00:00:00"
                    }
                }
                .sheet(isPresented: $showProfileSelection) {
                    ProfileSelectionSheet(
                        isPresented: $showProfileSelection,
                        onSelectProfile: { profile in
                            blockManager.setCurrentProfile(profile)
                            activateProfile(profile)
                        }
                    )
                }
        }
    }
    
    // MARK: - 메인 카드 컨텐츠
    private func cardContentView(theme: AppTheme) -> some View {
        VStack(spacing: 0) {
            headerView(theme: theme)
            actionView(theme: theme)
        }
    }
    
    // MARK: - 상단 헤더 뷰
    private func headerView(theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("현재 상태")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(theme.primaryTextColor)
                
                Spacer()
                
                statusBadge(theme: theme)
            }
            
            if let activeProfile = blockManager.activeProfile {
                profileInfoView(for: activeProfile)
            } else {
                inactiveStateView
            }
        }
        .padding()
        .background(theme.cardBackgroundColor)
        .cornerRadius(15, corners: [.topLeft, .topRight])
    }
    
    // MARK: - 하단 액션 뷰
    private func actionView(theme: AppTheme) -> some View {
        HStack {
            Spacer()
            
            if blockManager.isBlocking {
                Button(action: {
                    blockManager.stopBlocking()
                }) {
                    Text("종료하기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(theme.errorColor)
                        .cornerRadius(20)
                }
            } else {
                activateButton
            }
            
            Spacer()
        }
        .padding(.vertical, 12)
        .background(theme.cardBackgroundColor.opacity(0.9))
        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - 활성화 버튼 뷰
    private var activateButton: some View {
        withTheme { theme in
            Group {
                if let currentProfile = blockManager.currentProfile {
                    Button(action: {
                        activateProfile(currentProfile)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            
                            Text("\(currentProfile.name) 시작")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(theme.primaryColor)
                        .cornerRadius(20)
                    }
                } else {
                    Button(action: {
                        showProfileSelection = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 12))
                            
                            Text("프로필 선택 및 시작")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(theme.primaryColor)
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    // MARK: - 상태 배지 뷰
    private func statusBadge(theme: AppTheme) -> some View {
        HStack(spacing: 5) {
            Circle()
                .fill(blockManager.isBlocking ? theme.successColor : theme.secondaryTextColor.opacity(0.5))
                .frame(width: 8, height: 8)
                .opacity(blockManager.isBlocking ? 1.0 : 0.7)
            
            Text(blockManager.isBlocking ? "활성화 중" : "비활성화")
                .font(.system(size: 14, weight: blockManager.isBlocking ? .semibold : .regular))
                .foregroundColor(blockManager.isBlocking ? theme.successColor : theme.secondaryTextColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            (blockManager.isBlocking ? theme.successColor : theme.secondaryTextColor)
                .opacity(0.1)
                .cornerRadius(12)
        )
    }
    
    // MARK: - 활성 프로필 정보 뷰
    private func profileInfoView(for profile: BlockProfile) -> some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(theme.primaryColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.primaryColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Text("차단 중: \(profile.selection.applicationTokens.count)개 앱, \(profile.selection.webDomainTokens.count)개 웹사이트")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(theme.primaryColor)
                        
                        Text("경과 시간:")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                        
                        Text(elapsedTimeText)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(theme.primaryColor)
                        
                        Text("남은 시간:")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                        
                        Text(formatTimeInterval(blockManager.timeRemaining))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - 비활성 상태 뷰
    private var inactiveStateView: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                if let currentProfile = blockManager.currentProfile {
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(theme.secondaryTextColor.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "lock.open")
                                .font(.system(size: 20))
                                .foregroundColor(theme.secondaryTextColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(currentProfile.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.primaryTextColor)
                            
                            Text("선택됨: \(currentProfile.selection.applicationTokens.count)개 앱, \(currentProfile.selection.webDomainTokens.count)개 웹사이트")
                                .font(.system(size: 14))
                                .foregroundColor(theme.secondaryTextColor)
                        }
                        
                        Spacer()
                    }
                    
                    Text("아래 버튼을 눌러 차단을 시작하세요")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                        .padding(.top, 4)
                } else {
                    HStack(alignment: .center, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(theme.secondaryTextColor.opacity(0.1))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "lock.open")
                                .font(.system(size: 20))
                                .foregroundColor(theme.secondaryTextColor)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("차단 프로필이 선택되지 않았습니다")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.primaryTextColor)
                            
                            Text("아래 버튼으로 프로필을 선택하고 차단을 시작하세요")
                                .font(.system(size: 14))
                                .foregroundColor(theme.secondaryTextColor)
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - 타이머 및 활성화 기능
    private func activateProfile(_ profile: BlockProfile) {
        Task {
            do {
                try await blockManager.startBlocking(with: profile)
            } catch {
                print("Failed to start blocking: \(error)")
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        updateElapsedTime()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateElapsedTime()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard blockManager.isBlocking,
              let expirationDate = blockManager.expirationDate,
              let activeProfile = blockManager.activeProfile else {
            elapsedTimeText = "00:00:00"
            return
        }
        
        let duration = activeProfile.duration
        let remaining = blockManager.timeRemaining
        let elapsed = duration - remaining
        
        elapsedTimeText = formatTimeInterval(elapsed)
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) % 3600 / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

// MARK: - 헬퍼 익스텐션
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - 프리뷰
struct StatusCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusCard()
                .environmentObject(ThemeManager.shared)
                .previewLayout(.sizeThatFits)
                .padding()
            
            StatusCard()
                .environmentObject(ThemeManager.shared)
                .previewLayout(.sizeThatFits)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
