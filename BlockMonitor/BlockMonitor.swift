//
//  BlockMonitor.swift
//  SimplyLock (BlockMonitor Extension)
//
//  Created 2025-05-02
//  스크린 타임 DeviceActivityMonitor 구현
//

import DeviceActivity

/// DeviceActivityMonitor는 **클래스**를 상속해야 합니다.
/// `BlockManager.swift` 파일은 같은 타깃에 포함되어 있으므로 `import` 필요 없음.
final class BlockMonitor: DeviceActivityMonitor {
    
    /// 차단 세션 시작 – Extension이 활성화되는 즉시 호출됨
    override func intervalDidStart(for activity: DeviceActivityName) {
        // DeviceActivityMonitor는 백그라운드에서 호출되므로 MainActor 전환 필요
        Task { @MainActor in                         // ② MainActor 블록
            if let profile = BlockManager.shared.profiles.first {
                try? await BlockManager.shared.startBlocking(with: profile)
            }
        }
    }
    
    /// 세션 종료 – 예약된 간격이 끝나면 호출
    override func intervalDidEnd(for activity: DeviceActivityName) {
        Task { @MainActor in
            BlockManager.shared.stopBlocking()
        }
    }
}
