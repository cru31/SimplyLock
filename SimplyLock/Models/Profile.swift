import SwiftUI
import FamilyControls

public struct Profile: Identifiable, Codable {
    public let id: UUID
    public var name: String
    public var iconName: String
    public var codableIconBackgroundColor: CodableColor // Store CodableColor
    public var description: String
    public var activitySelection: FamilyActivitySelection
    public var strictMode: Bool
    public var isSystem: Bool

    // Computed property for external convenience
    public var iconBackgroundColor: Color {
        get { codableIconBackgroundColor.swiftUIColor }
        set { codableIconBackgroundColor = CodableColor(color: newValue) }
    }
    
    public var appCount: Int {
        activitySelection.applicationTokens.count + activitySelection.categoryTokens.count
    }
    
    public var websiteCount: Int {
        activitySelection.webDomainTokens.count
    }
    
    public init(id: UUID = UUID(), name: String, iconName: String, iconBackgroundColor: Color, description: String, activitySelection: FamilyActivitySelection = FamilyActivitySelection(), strictMode: Bool, isSystem: Bool) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.codableIconBackgroundColor = CodableColor(color: iconBackgroundColor) // Initialize with Color
        self.description = description
        self.activitySelection = activitySelection
        self.strictMode = strictMode
        self.isSystem = isSystem
    }

    // Nested CodableColor struct
    public struct CodableColor: Codable {
        public var red: Double
        public var green: Double
        public var blue: Double
        public var alpha: Double

        public init(color: Color) {
            let uiColor = UIColor(color)
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            var a: CGFloat = 0
            uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
            self.red = Double(r)
            self.green = Double(g)
            self.blue = Double(b)
            self.alpha = Double(a)
        }

        public var swiftUIColor: Color {
            Color(red: red, green: green, blue: blue, opacity: alpha)
        }
    }
    
    // Required for Codable conformance, as FamilyActivitySelection might not be auto-codable in all contexts
    enum CodingKeys: String, CodingKey {
        case id, name, iconName, codableIconBackgroundColor, description, activitySelection, strictMode, isSystem
    }
    
    // 샘플 프로필 데이터
    public static let samples = [
        Profile(
            name: "완전 집중",
            iconName: "lock.fill",
            iconBackgroundColor: .purple, // Still use Color here, init handles conversion
            description: "모든 SNS 및 게임 앱 차단",
            strictMode: true,
            isSystem: true
        ),
        Profile(
            name: "SNS 차단",
            iconName: "iphone",
            iconBackgroundColor: .blue,
            description: "소셜 미디어 앱 및 웹사이트 차단",
            strictMode: false,
            isSystem: true
        ),
        Profile(
            name: "학습 모드",
            iconName: "person.fill",
            iconBackgroundColor: .green,
            description: "학습에 방해되는 앱 및 웹사이트 차단",
            strictMode: false,
            isSystem: true
        ),
        Profile(
            name: "성인 콘텐츠 차단",
            iconName: "shield.fill",
            iconBackgroundColor: .red,
            description: "성인 콘텐츠 웹사이트 및 앱 차단",
            strictMode: true,
            isSystem: true
        ),
        Profile(
            name: "수업 시간",
            iconName: "clock.fill",
            iconBackgroundColor: .yellow,
            description: "커스텀 차단 프로필",
            strictMode: false,
            isSystem: false
        )
    ]
}
