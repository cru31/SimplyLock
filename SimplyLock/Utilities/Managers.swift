import Foundation
import SwiftUI
import Combine

class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = Profile.samples
    @Published var activeProfileId: Int? = 1
    
    static let shared = ProfileManager()
    
    private init() {}
    
    func activateProfile(id: Int) {
        if activeProfileId == id {
            activeProfileId = nil
        } else {
            activeProfileId = id
        }
        
        // 실제 구현에서는 여기서 앱 차단 기능을 활성화/비활성화
    }
    
    func getActiveProfile() -> Profile? {
        guard let id = activeProfileId else { return nil }
        return profiles.first { $0.id == id }
    }
    
    func getProfile(id: Int) -> Profile? {
        return profiles.first { $0.id == id }
    }
    
    func addProfile(name: String, description: String, iconName: String, iconColor: Color, strictMode: Bool, isSystem: Bool = false) -> Profile {
        let newId = (profiles.map { $0.id }.max() ?? 0) + 1
        
        let newProfile = Profile(
            id: newId,
            name: name,
            iconName: iconName,
            iconBackgroundColor: iconColor,
            description: description,
            appCount: 0,
            websiteCount: 0,
            strictMode: strictMode,
            isSystem: isSystem
        )
        
        profiles.append(newProfile)
        return newProfile
    }
    
    func deleteProfile(id: Int) {
        if activeProfileId == id {
            activeProfileId = nil
        }
        
        profiles.removeAll { $0.id == id }
    }
}

class UsageStatsManager: ObservableObject {
    @Published var usageData: UsageData = UsageData.sample
    @Published var goal: Goal = Goal.sample
    
    static let shared = UsageStatsManager()
    
    private init() {}
    
    func refreshData() {
        // 실제 구현에서는 여기서 사용 통계 데이터를 새로고침
    }
    
    func getDataForTimeRange(_ range: String) -> UsageData {
        // 실제 구현에서는 여기서 지정된 시간 범위에 대한 데이터를 반환
        return usageData
    }
    
    func updateGoal(title: String, target: String, progress: Int) {
        goal = Goal(title: title, target: target, progress: progress)
    }
}

class TimerManager: ObservableObject {
    @Published var timeLeft: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var isBreak: Bool = false
    @Published var sessionsCompleted: Int = 0
    @Published var totalSessions: Int = 4
    
    private var timer: Timer?
    private var focusDuration: Int = 25 * 60
    private var breakDuration: Int = 5 * 60
    private var longBreakDuration: Int = 15 * 60
    private var longBreakInterval: Int = 4
    
    static let shared = TimerManager()
    
    private init() {}
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, self.timeLeft > 0 else {
                self?.completeSession()
                return
            }
            
            self.timeLeft -= 1
        }
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        pauseTimer()
        timeLeft = isBreak ? breakDuration : focusDuration
    }
    
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func switchMode(toBreak: Bool) {
        pauseTimer()
        isBreak = toBreak
        
        if isBreak {
            timeLeft = (sessionsCompleted > 0 && sessionsCompleted % longBreakInterval == 0) ? longBreakDuration : breakDuration
        } else {
            timeLeft = focusDuration
        }
    }
    
    private func completeSession() {
        pauseTimer()
        
        if isBreak {
            // 휴식 시간 완료 후 집중 모드로 전환
            isBreak = false
            timeLeft = focusDuration
        } else {
            // 집중 시간 완료 후 세션 카운트 증가 및 휴식 모드로 전환
            sessionsCompleted += 1
            isBreak = true
            
            if sessionsCompleted % longBreakInterval == 0 {
                timeLeft = longBreakDuration
            } else {
                timeLeft = breakDuration
            }
        }
        
        // TODO: 알림 발생
    }
    
    func updateSettings(focusMinutes: Int, breakMinutes: Int, longBreakMinutes: Int, sessions: Int) {
        focusDuration = focusMinutes * 60
        breakDuration = breakMinutes * 60
        longBreakDuration = longBreakMinutes * 60
        longBreakInterval = sessions
        totalSessions = sessions
        
        // 현재 타이머가 진행 중이 아닐 때만 시간 업데이트
        if !isRunning {
            resetTimer()
        }
    }
}
