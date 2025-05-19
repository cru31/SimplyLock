import Foundation
import SwiftUI

struct AutomationRule: Identifiable {
    let id = UUID()
    let type: RuleType
    let profileId: Int
    var isEnabled: Bool = true
    
    enum RuleType {
        case time(TimeRule)
        case location(LocationRule)
    }
    
    struct TimeRule {
        let days: [Weekday]
        let startTime: Date
        let endTime: Date
        
        enum Weekday: Int, CaseIterable {
            case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
            
            var shortName: String {
                switch self {
                case .sunday: return "일"
                case .monday: return "월"
                case .tuesday: return "화"
                case .wednesday: return "수"
                case .thursday: return "목"
                case .friday: return "금"
                case .saturday: return "토"
                }
            }
        }
    }
    
    struct LocationRule {
        let name: String
        let latitude: Double
        let longitude: Double
        let radius: Double // 미터 단위
    }
    
    static let sampleTimeRules = [
        AutomationRule(
            type: .time(
                TimeRule(
                    days: [.monday, .tuesday, .wednesday, .thursday, .friday],
                    startTime: Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
                    endTime: Calendar.current.date(from: DateComponents(hour: 15, minute: 0)) ?? Date()
                )
            ),
            profileId: 3
        ),
        AutomationRule(
            type: .time(
                TimeRule(
                    days: [.monday, .tuesday, .wednesday, .thursday, .friday],
                    startTime: Calendar.current.date(from: DateComponents(hour: 23, minute: 0)) ?? Date(),
                    endTime: Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
                )
            ),
            profileId: 4
        )
    ]
    
    static let sampleLocationRules = [
        AutomationRule(
            type: .location(
                LocationRule(
                    name: "학교",
                    latitude: 37.5665,
                    longitude: 126.9780,
                    radius: 200
                )
            ),
            profileId: 3
        ),
        AutomationRule(
            type: .location(
                LocationRule(
                    name: "도서관",
                    latitude: 37.5718,
                    longitude: 126.9765,
                    radius: 100
                )
            ),
            profileId: 1
        )
    ]
}
