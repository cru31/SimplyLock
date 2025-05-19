import SwiftUI

struct Profile: Identifiable {
    let id: Int
    let name: String
    let iconName: String
    let iconBackgroundColor: Color
    let description: String
    let appCount: Int
    let websiteCount: Int
    let strictMode: Bool
    let isSystem: Bool
    
    // 샘플 프로필 데이터
    static let samples = [
        Profile(
            id: 1,
            name: "완전 집중",
            iconName: "lock.fill",
            iconBackgroundColor: .purple,
            description: "모든 SNS 및 게임 앱 차단",
            appCount: 14,
            websiteCount: 22,
            strictMode: true,
            isSystem: true
        ),
        Profile(
            id: 2,
            name: "SNS 차단",
            iconName: "iphone",
            iconBackgroundColor: .blue,
            description: "소셜 미디어 앱 및 웹사이트 차단",
            appCount: 8,
            websiteCount: 12,
            strictMode: false,
            isSystem: true
        ),
        Profile(
            id: 3,
            name: "학습 모드",
            iconName: "person.fill",
            iconBackgroundColor: .green,
            description: "학습에 방해되는 앱 및 웹사이트 차단",
            appCount: 10,
            websiteCount: 15,
            strictMode: false,
            isSystem: true
        ),
        Profile(
            id: 4,
            name: "성인 콘텐츠 차단",
            iconName: "shield.fill",
            iconBackgroundColor: .red,
            description: "성인 콘텐츠 웹사이트 및 앱 차단",
            appCount: 5,
            websiteCount: 35,
            strictMode: true,
            isSystem: true
        ),
        Profile(
            id: 5,
            name: "수업 시간",
            iconName: "clock.fill",
            iconBackgroundColor: .yellow,
            description: "커스텀 차단 프로필",
            appCount: 12,
            websiteCount: 8,
            strictMode: false,
            isSystem: false
        )
    ]
}
