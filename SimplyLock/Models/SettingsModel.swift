import SwiftUI

struct SettingItem: Identifiable {
    let id = UUID()
    let iconName: String
    let label: String
    let toggle: Bool
    var state: Bool = false
    let badge: String?
    let action: (() -> Void)?
    
    static func toggleItem(icon: String, label: String, state: Bool = false, action: (() -> Void)? = nil) -> SettingItem {
        SettingItem(iconName: icon, label: label, toggle: true, state: state, badge: nil, action: action)
    }
    
    static func navigationItem(icon: String, label: String, badge: String? = nil, action: (() -> Void)? = nil) -> SettingItem {
        SettingItem(iconName: icon, label: label, toggle: false, badge: badge, action: action)
    }
}

struct SettingsSectionModel: Identifiable {
    let id = UUID()
    let title: String
    let items: [SettingItem]
    
    static let generalSettings = SettingsSectionModel(
        title: "일반 설정",
        items: [
            SettingItem.toggleItem(icon: "sun.max.fill", label: "다크 모드", state: false),
            SettingItem.navigationItem(icon: "globe", label: "언어 설정"),
            SettingItem.navigationItem(icon: "bell", label: "알림 설정"),
            SettingItem.toggleItem(icon: "iphone", label: "앱 시작 시 자동 차단", state: true)
        ]
    )
    
    static let permissionsSettings = SettingsSectionModel(
        title: "권한 관리",
        items: [
            SettingItem.toggleItem(icon: "shield.fill", label: "Screen Time API 권한", state: true),
            SettingItem.toggleItem(icon: "bell", label: "알림 권한", state: true),
            SettingItem.toggleItem(icon: "location", label: "위치 권한", state: false)
        ]
    )
    
    static let accountSettings = SettingsSectionModel(
        title: "계정 및 구독",
        items: [
            SettingItem.navigationItem(icon: "person.fill", label: "계정 정보"),
            SettingItem.navigationItem(icon: "creditcard", label: "구독 관리", badge: "프리미엄"),
            SettingItem.navigationItem(icon: "info.circle", label: "결제 정보")
        ]
    )
    
    static let dataSettings = SettingsSectionModel(
        title: "데이터 관리",
        items: [
            SettingItem.navigationItem(icon: "cloud", label: "데이터 백업 및 복원"),
            SettingItem.navigationItem(icon: "tablet", label: "다중 기기 관리"),
            SettingItem.navigationItem(icon: "arrow.down.doc", label: "데이터 내보내기")
        ]
    )
    
    static let helpSettings = SettingsSectionModel(
        title: "도움말 및 지원",
        items: [
            SettingItem.navigationItem(icon: "questionmark.circle", label: "FAQ 및 문제 해결"),
            SettingItem.navigationItem(icon: "bubble.left", label: "고객 지원 문의")
        ]
    )
    
    static let infoSettings = SettingsSectionModel(
        title: "정보",
        items: [
            SettingItem.navigationItem(icon: "info.circle", label: "개인정보 처리방침"),
            SettingItem.navigationItem(icon: "doc.text", label: "이용약관")
        ]
    )
    
    static let allSections = [
        generalSettings,
        permissionsSettings,
        accountSettings,
        dataSettings,
        helpSettings,
        infoSettings
    ]
}
