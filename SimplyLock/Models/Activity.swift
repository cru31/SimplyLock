import SwiftUI

struct Activity: Identifiable {
    let id = UUID()
    let iconName: String
    let iconBackgroundColor: Color
    let title: String
    let time: String
    let status: ActivityStatus?
    
    enum ActivityStatus: String {
        case completed = "완료"
        case interrupted = "중단"
        case blocked = "차단"
        case none
        
        var color: Color {
            switch self {
            case .completed:
                return .green
            case .interrupted, .blocked:
                return .red
            case .none:
                return .gray
            }
        }
    }
    
    // 샘플 활동 데이터
    static let samples = [
        Activity(
            iconName: "shield.fill", 
            iconBackgroundColor: .blue, 
            title: "학습 모드 활성화", 
            time: "30분 전",
            status: nil
        ),
        Activity(
            iconName: "timer", 
            iconBackgroundColor: .green, 
            title: "집중 세션 완료", 
            time: "2시간 전 | 25분 집중",
            status: .completed
        ),
        Activity(
            iconName: "exclamationmark.triangle.fill", 
            iconBackgroundColor: .red, 
            title: "인스타그램 차단 우회 시도", 
            time: "4시간 전",
            status: .blocked
        )
    ]
    
    // 타이머 세션 기록용 샘플 데이터
    static let sessionHistory = [
        Activity(
            iconName: "checkmark.square.fill", 
            iconBackgroundColor: .green, 
            title: "25분 집중 세션", 
            time: "오늘 13:20",
            status: .completed
        ),
        Activity(
            iconName: "checkmark.square.fill", 
            iconBackgroundColor: .green, 
            title: "25분 집중 세션", 
            time: "오늘 10:45",
            status: .completed
        ),
        Activity(
            iconName: "xmark", 
            iconBackgroundColor: .red, 
            title: "25분 집중 세션", 
            time: "어제 16:30",
            status: .interrupted
        ),
        Activity(
            iconName: "checkmark.square.fill", 
            iconBackgroundColor: .green, 
            title: "25분 집중 세션", 
            time: "어제 15:00",
            status: .completed
        ),
        Activity(
            iconName: "checkmark.square.fill", 
            iconBackgroundColor: .green, 
            title: "25분 집중 세션", 
            time: "어제 11:15",
            status: .completed
        )
    ]
}
