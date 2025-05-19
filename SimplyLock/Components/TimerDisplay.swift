import SwiftUI

struct TimerDisplay: View {
    let timeLeft: Int // 초 단위
    let totalTime: Int // 초 단위
    let isBreak: Bool
    
    // 시간을 mm:ss 형식으로 포맷팅
    var formattedTime: String {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 진행 정도 (0.0 ~ 1.0)
    var progress: Double {
        Double(timeLeft) / Double(totalTime)
    }
    
    var body: some View {
        withTheme { theme in
            ZStack {
                // 배경 원
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.1)
                    .foregroundColor(isBreak ? theme.successColor : theme.primaryColor)
                
                // 진행 원
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round
                    ))
                    .foregroundColor(isBreak ? theme.successColor : theme.primaryColor)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                // 중앙 텍스트
                VStack(spacing: 8) {
                    Text(formattedTime)
                        .font(.system(size: 48, weight: .bold))
                        .monospacedDigit()
                        .foregroundColor(theme.primaryTextColor)
                    
                    Text(isBreak ? "휴식 시간" : "집중 시간")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                }
            }
        }
    }
}

struct TimerControlButton: View {
    let iconName: String
    let isPrimary: Bool
    let size: CGFloat
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        withTheme { theme in
            Button(action: action) {
                ZStack {
                    // 버튼 배경
                    Circle()
                        .fill(backgroundColor(theme: theme))
                        .frame(width: size, height: size)
                    
                    // 버튼 테두리
                    Circle()
                        .stroke(theme.primaryTextColor.opacity(0.1), lineWidth: 1)
                        .frame(width: size, height: size)
                    
                    // 아이콘
                    Image(systemName: iconName)
                        .font(.system(size: size * 0.4))
                        .foregroundColor(iconColor(theme: theme))
                }
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
        }
    }
    
    // 배경색 결정
    private func backgroundColor(theme: AppTheme) -> Color {
        if isPrimary {
            return isPressed ? theme.primaryButtonPressedBackgroundColor : theme.primaryButtonBackgroundColor
        } else {
            return isPressed ? theme.buttonPressedBackgroundColor : theme.buttonBackgroundColor
        }
    }
    
    // 아이콘 색상 결정
    private func iconColor(theme: AppTheme) -> Color {
        if isPrimary {
            return .white
        } else {
            return theme.primaryTextColor
        }
    }
}

// 그리고 TimerControls 컴포넌트 수정
struct TimerControls: View {
    let isRunning: Bool
    let onReset: () -> Void
    let onToggle: () -> Void
    let onNotification: () -> Void
    
    var body: some View {
        HStack(spacing: 24) { // 간격 확대
            Spacer() // 좌측 여백
            
            // 리셋 버튼 - 일반 버튼
            TimerControlButton(
                iconName: "arrow.clockwise",
                isPrimary: false,
                size: 48,
                action: onReset
            )
            
            // 시작/일시정지 버튼 - 주요 버튼
            TimerControlButton(
                iconName: isRunning ? "pause.fill" : "play.fill",
                isPrimary: true,
                size: 64,
                action: onToggle
            )
            
            // 알림 버튼 - 일반 버튼
            TimerControlButton(
                iconName: "bell.fill",
                isPrimary: false,
                size: 48,
                action: onNotification
            )
            
            Spacer() // 우측 여백
        }
    }
}


struct SessionProgress: View {
    let completed: Int
    let total: Int
    
    var body: some View {
        withTheme { theme in
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(1...total, id: \.self) { session in
                        ZStack {
                            // 세션 원형 배경
                            Circle()
                                .fill(session <= completed
                                      ? theme.primaryColor
                                      : theme.buttonBackgroundColor) // 테마의 버튼 배경색 사용
                                .frame(width: 24, height: 24)
                            
                            // 세션 원형 테두리
                            Circle()
                                .stroke(theme.primaryTextColor.opacity(0.1), lineWidth: 1)
                                .frame(width: 24, height: 24)
                            
                            // 세션 번호
                            Text("\(session)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(session <= completed ? .white : theme.primaryTextColor)
                        }
                    }
                }
                
                HStack {
                    Text("\(completed)/\(total) 세션 완료")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Spacer()
                    
                    Text("목표: \(total) 세션")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                }
                .padding(.horizontal, 8)
            }
            .padding()
            .background(theme.backgroundColor) // 배경색 적용
            .cornerRadius(theme.cornerRadius)
        }
    }
}

// 전체 타이머 화면 컨테이너
struct TimerScreenContainer: View {
    let timeLeft: Int
    let totalTime: Int
    let isBreak: Bool
    let isRunning: Bool
    let completed: Int
    let total: Int
    let onReset: () -> Void
    let onToggle: () -> Void
    let onNotification: () -> Void
    
    var body: some View {
        withTheme { theme in
            VStack(spacing: 32) {
                TimerDisplay(
                    timeLeft: timeLeft,
                    totalTime: totalTime,
                    isBreak: isBreak
                )
                .frame(width: 256, height: 256)
                
                TimerControls(
                    isRunning: isRunning,
                    onReset: onReset,
                    onToggle: onToggle,
                    onNotification: onNotification
                )
                
                SessionProgress(completed: completed, total: total)
            }
            .padding()
            .background(theme.backgroundColor) // 전체 화면의 배경색 적용
        }
    }
}

// 라이트 모드 프리뷰
#Preview {
    TimerScreenContainer(
        timeLeft: 15 * 60,
        totalTime: 25 * 60,
        isBreak: false,
        isRunning: false,
        completed: 2,
        total: 4,
        onReset: {},
        onToggle: {},
        onNotification: {}
    )
    .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct TimerComponentsDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return TimerScreenContainer(
            timeLeft: 15 * 60,
            totalTime: 25 * 60,
            isBreak: false,
            isRunning: true,
            completed: 2,
            total: 4,
            onReset: {},
            onToggle: {},
            onNotification: {}
        )
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}
