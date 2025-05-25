import Foundation
import FamilyControls
import ManagedSettings
import Combine

// MARK: - 모델
public struct BlockProfile: Identifiable, Codable, Equatable {
    public let id: UUID
    public var name: String
    public var selection: FamilyActivitySelection
    public var duration: TimeInterval
    public var createdAt: Date
    public fileprivate(set) var isPreset: Bool
    
    public init(id: UUID = .init(),
                name: String,
                selection: FamilyActivitySelection,
                duration: TimeInterval,
                isPreset: Bool = false)
    {
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
    @Published public private(set) var profiles: [BlockProfile] = []
    @Published public private(set) var currentProfile: BlockProfile?
    @Published public private(set) var activeProfile: BlockProfile?
    @Published public private(set) var isBlocking = false
    @Published public private(set) var expirationDate: Date?
    @Published public private(set) var timeRemaining: TimeInterval = 0
    
    private let store = ManagedSettingsStore()
    private var timer: AnyCancellable?
    
    private let shared: UserDefaults?
    private let keyProfiles = "BlockProfiles"
    private let keyCurrent = "CurrentProfileID"
    
    public static let shared = BlockManager()
    
    private init() {
        // Initialize UserDefaults safely
        self.shared = UserDefaults(suiteName: "group.io.cru31.SimplyLock")
        if shared == nil {
            print("BlockManager: Failed to initialize UserDefaults for group.io.cru31.SimplyLock")
        }
        
        /*
        // Load default profiles first
        loadDefaultProfiles()
        
        // Delay UserDefaults access to ensure app group is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadProfiles()
            self.loadCurrentProfile()
        }
         */
    }
    
    // MARK: - Default Profiles
    private func loadDefaultProfiles() {
        guard let url = Bundle.main.url(forResource: "DefaultProfiles", withExtension: "json") else {
            print("BlockManager: DefaultProfiles.json not found in bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let defaultProfiles = try JSONDecoder().decode([BlockProfile].self, from: data)
            
            if profiles.isEmpty {
                profiles.append(contentsOf: defaultProfiles)
                saveProfiles()
            } else {
                for defaultProfile in defaultProfiles {
                    if !profiles.contains(where: { $0.id == defaultProfile.id }) {
                        profiles.append(defaultProfile)
                    }
                }
                saveProfiles()
            }
            print("BlockManager: Loaded \(defaultProfiles.count) default profiles")
        } catch {
            print("BlockManager: Failed to load DefaultProfiles.json: \(error)")
        }
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
        
        store.shield.applications = p.selection.applicationTokens
        store.shield.webDomains = p.selection.webDomainTokens
        
        let cats = p.selection.categoryTokens
        if !cats.isEmpty {
            store.shield.applicationCategories = .specific(cats)
            store.shield.webDomainCategories = .specific(cats)
        }
        
        activeProfile = p
        isBlocking = true
        expirationDate = Date().addingTimeInterval(p.duration)
        timeRemaining = p.duration
        
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
        timer?.cancel()
        timer = nil
        
        isBlocking = false
        activeProfile = nil
        expirationDate = nil
        timeRemaining = 0
    }
    
    // MARK: - 영속성
    private func saveProfiles() {
        guard let shared = shared else {
            print("BlockManager: UserDefaults not available for saving profiles")
            return
        }
        if let data = try? JSONEncoder().encode(profiles) {
            shared.set(data, forKey: keyProfiles)
            shared.synchronize() // Ensure data is written
        }
    }
    
    private func loadProfiles() {
        guard let shared = shared,
              let data = shared.data(forKey: keyProfiles),
              let decoded = try? JSONDecoder().decode([BlockProfile].self, from: data) else {
            print("BlockManager: No profiles found in UserDefaults")
            return
        }
        profiles = decoded
    }
    
    private func loadCurrentProfile() {
        guard let shared = shared,
              let idStr = shared.string(forKey: keyCurrent),
              let uuid = UUID(uuidString: idStr),
              let prof = profiles.first(where: { $0.id == uuid }) else {
            print("BlockManager: No current profile found")
            return
        }
        currentProfile = prof
    }
    
    // MARK: - Debug Reset
    public func resetUserDefaults() {
        guard let shared = shared else { return }
        shared.removePersistentDomain(forName: "group.io.cru31.SimplyLock")
        shared.synchronize()
        print("BlockManager: Reset UserDefaults for group.io.cru31.SimplyLock")
        profiles.removeAll()
        currentProfile = nil
        loadDefaultProfiles()
    }
}
