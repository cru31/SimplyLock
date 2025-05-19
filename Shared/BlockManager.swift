//
//  BlockManager.swift
//  SimplyLock (Shared)
//
//  Rev 2025‑05‑03 — App & Extension 공용 버전
//  - App Group(UserDefaults) 로 프로필 영속화
//  - @MainActor 유지 → 스레드 안전 (Extension에서는 Task { @MainActor in … } 로 호출)
//  - 카테고리 전체 차단 지원
//

import Foundation
import FamilyControls           // FamilyActivitySelection
import ManagedSettings
import Combine

// MARK: - 모델
public struct BlockProfile: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var selection: FamilyActivitySelection
    public var duration: TimeInterval          // 초 단위
    public var createdAt: Date
    public fileprivate(set) var isPreset: Bool // 파일 내부에서만 씀
    
    public init(id: UUID = .init(),
                name: String,
                selection: FamilyActivitySelection,
                duration: TimeInterval,
                isPreset: Bool = false) {
        self.id        = id
        self.name      = name
        self.selection = selection
        self.duration  = duration
        self.createdAt = .init()
        self.isPreset  = isPreset
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, selection, duration, createdAt, isPreset
    }
}

@MainActor
public final class BlockManager: ObservableObject {
    
    // ───────── 상태 ─────────
    @Published public private(set) var profiles: [BlockProfile] = []
    @Published public private(set) var currentProfile: BlockProfile?
    @Published public private(set) var activeProfile:  BlockProfile?
    @Published public private(set) var isBlocking = false
    @Published public private(set) var expirationDate: Date?
    @Published public private(set) var timeRemaining: TimeInterval = 0
    
    // ───────── 내부 ─────────
    private let store  = ManagedSettingsStore()
    private var timer: AnyCancellable?
    
    private let shared = UserDefaults(suiteName: "group.io.cru31.SimplyLock")
    private let keyProfiles = "BlockProfiles"
    private let keyCurrent  = "CurrentProfileID"
    
    public static let shared = BlockManager()
    private init() {
        loadProfiles()
        loadCurrentProfile()
    }
    
    // MARK: - CRUD
    public func addProfile(_ p: BlockProfile) {
        profiles.append(p)
        saveProfiles()
    }
    
    public func addPresetProfileList(_ presets: [BlockProfile]) {
        profiles.append(contentsOf: presets.map { var pp = $0; pp.isPreset = true; return pp })
        saveProfiles()
    }
    
    public func updateProfile(_ p: BlockProfile) {
        if let i = profiles.firstIndex(of: p) {
            profiles[i] = p
            saveProfiles()
        }
    }
    
    public func deleteProfile(_ p: BlockProfile) {
        profiles.removeAll { $0.id == p.id }
        if currentProfile?.id == p.id { setCurrentProfile(nil) }
        saveProfiles()
    }
    
    public func setCurrentProfile(_ p: BlockProfile?) {
        currentProfile = p
        shared?.set(p?.id.uuidString, forKey: keyCurrent)
    }
    
    // MARK: - 차단 제어
    public func startBlocking(with p: BlockProfile) async throws {
        guard #available(iOS 16.0, *) else { return }
        
        store.clearAllSettings()
        
        // ① 앱·도메인 토큰 차단
        store.shield.applications = p.selection.applicationTokens
        store.shield.webDomains   = p.selection.webDomainTokens
        
        // ② 카테고리 전체 차단
        let cats = p.selection.categoryTokens               // ← 하나뿐인 카테고리 토큰 Set
        if !cats.isEmpty {
            store.shield.applicationCategories = .specific(cats)   // ✅ 래핑
            store.shield.webDomainCategories   = .specific(cats)   // ✅ 동일 세트 재사용
        }
        
        // ③ 타이머·상태 갱신 (변경 없음)
        activeProfile  = p
        isBlocking     = true
        expirationDate = Date().addingTimeInterval(p.duration)
        timeRemaining  = p.duration
        
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.tick() }
    }
    
    private func tick() {
        guard let exp = expirationDate else { return }
        timeRemaining = max(0, exp.timeIntervalSinceNow)
        if timeRemaining <= 0 { stopBlocking() }
    }
    
    public func stopBlocking() {
        store.clearAllSettings()
        timer?.cancel(); timer = nil
        
        isBlocking     = false
        activeProfile  = nil
        expirationDate = nil
        timeRemaining  = 0
    }
    
    // MARK: - 영속성
    private func saveProfiles() {
        if let data = try? JSONEncoder().encode(profiles) {
            shared?.set(data, forKey: keyProfiles)
        }
    }
    
    private func loadProfiles() {
        guard let data = shared?.data(forKey: keyProfiles),
              let decoded = try? JSONDecoder().decode([BlockProfile].self, from: data)
        else { return }
        profiles = decoded
    }
    
    private func loadCurrentProfile() {
        guard let idStr = shared?.string(forKey: keyCurrent),
              let uuid  = UUID(uuidString: idStr),
              let prof  = profiles.first(where: { $0.id == uuid })
        else { return }
        currentProfile = prof
    }
}
