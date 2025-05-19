import SwiftUI

struct UsageCategory: Identifiable {
    let id = UUID()
    let name: String
    let percent: Int
    let time: String
    let color: Color
}

struct AppUsage: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    let icon: String
    let color: LinearGradient
    let percentage: Double
}

struct BlockingStats {
    let attemptsCount: Int
    let timesSaved: String
    let mostBlocked: String
}

struct UsageData {
    let hourlyUsage: [Double]
    let categories: [UsageCategory]
    let topApps: [AppUsage]
    let blocking: BlockingStats
    let totalScreenTime: String
    let comparisonWithYesterday: String
    let isReduction: Bool
    
    static let sample = UsageData(
        hourlyUsage: [0.2, 0.5, 0.8, 1.2, 0.7, 0.3, 0.9, 1.5, 0.6, 0.4, 0.2, 0.1],
        categories: [
            UsageCategory(name: "소셜", percent: 45, time: "2시간 15분", color: .blue),
            UsageCategory(name: "엔터테인먼트", percent: 25, time: "1시간 15분", color: .purple),
            UsageCategory(name: "생산성", percent: 15, time: "45분", color: .green),
            UsageCategory(name: "기타", percent: 15, time: "45분", color: .gray)
        ],
        topApps: [
            AppUsage(
                name: "인스타그램", 
                time: "1시간 20분", 
                icon: "📱", 
                color: LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing),
                percentage: 0.7
            ),
            AppUsage(
                name: "유튜브", 
                time: "58분", 
                icon: "📺", 
                color: LinearGradient(colors: [.red, .yellow], startPoint: .leading, endPoint: .trailing),
                percentage: 0.5
            ),
            AppUsage(
                name: "카카오톡", 
                time: "45분", 
                icon: "💬", 
                color: LinearGradient(colors: [.yellow, Color(UIColor.systemYellow.withAlphaComponent(0.7))], startPoint: .leading, endPoint: .trailing),
                percentage: 0.3
            )
        ],
        blocking: BlockingStats(
            attemptsCount: 18,
            timesSaved: "1시간 45분",
            mostBlocked: "인스타그램"
        ),
        totalScreenTime: "5시간 13분",
        comparisonWithYesterday: "52분",
        isReduction: true
    )
    
    // 홈 화면용 간소화된 데이터
    static let homeSample = UsageData(
        hourlyUsage: [],
        categories: [],
        topApps: [],
        blocking: BlockingStats(
            attemptsCount: 12,
            timesSaved: "",
            mostBlocked: "주로 소셜 미디어 앱"
        ),
        totalScreenTime: "3시간 12분",
        comparisonWithYesterday: "45분",
        isReduction: true
    )
}

struct Goal: Identifiable {
    let id = UUID()
    let title: String
    let target: String
    let progress: Int
    
    static let sample = Goal(
        title: "일일 스크린 타임 감소",
        target: "목표: 4시간 이하",
        progress: 80
    )
}
