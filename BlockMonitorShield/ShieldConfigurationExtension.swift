import ManagedSettings
import ManagedSettingsUI
import UIKit

final class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    private let shared = UserDefaults(suiteName: "group.io.cru31.SimplyLock")!
    
    override func configuration(shielding application: Application)
    -> ShieldConfiguration {
        
        // 번들 ID
        let bundleID = application.bundleIdentifier ?? "unknown"
        
        // ApplicationToken → Data → Base64(String) 저장
        if let tokenData = try? JSONEncoder().encode(application.token) {
            shared.set(tokenData.base64EncodedString(), forKey: bundleID)
        }
        
        // 라벨 + 색깔
        let title = ShieldConfiguration.Label(
            text: "\(application.localizedDisplayName ?? "앱") 차단됨",
            color: .white
        )
        
        let subtitle = ShieldConfiguration.Label(
            text: "집중 시간이 끝나면 다시 사용할 수 있어요",
            color: .secondaryLabel
        )
        
        return ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterialDark,
            icon: UIImage(systemName: "lock.shield.fill"),
            title: title,
            subtitle: subtitle
        )
    }
    
    // 나머지 오버라이드는 기본 구현 사용
    override func configuration(shielding application: Application,
                                in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        ShieldConfiguration()
    }
    override func configuration(shielding webDomain: WebDomain,
                                in category: ActivityCategory) -> ShieldConfiguration {
        ShieldConfiguration()
    }
}
