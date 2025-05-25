import SwiftUI
import FamilyControls // Required for Profile which uses FamilyActivitySelection

public class ProfileStore: ObservableObject {
    @Published public var customProfiles: [Profile] = []
    
    private let userDefaultsKey = "customUserProfiles"
    
    public init() {
        loadCustomProfiles()
    }
    
    public func loadCustomProfiles() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            customProfiles = try decoder.decode([Profile].self, from: data)
        } catch {
            print("Error decoding custom profiles: \(error)")
            // Optionally, handle the error more gracefully, e.g., by resetting to default or migrating
        }
    }
    
    public func saveCustomProfiles() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(customProfiles)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding custom profiles: \(error)")
        }
    }
    
    public func addProfile(_ profile: Profile) {
        // Ensure we don't add system profiles or duplicates by ID if that's a concern
        if !profile.isSystem && !customProfiles.contains(where: { $0.id == profile.id }) {
            customProfiles.append(profile)
            saveCustomProfiles()
        }
    }
    
    public func updateProfile(_ profile: Profile) {
        guard !profile.isSystem else {
            print("System profiles cannot be updated.")
            return
        }
        if let index = customProfiles.firstIndex(where: { $0.id == profile.id }) {
            customProfiles[index] = profile
            saveCustomProfiles()
        }
    }
    
    public func deleteProfile(_ profile: Profile) {
        guard !profile.isSystem else {
            print("System profiles cannot be deleted.")
            return
        }
        customProfiles.removeAll { $0.id == profile.id }
        saveCustomProfiles()
    }

    // Optional: A method to delete a profile by its ID directly
    public func deleteProfile(id: UUID) {
        if let profileToDelete = customProfiles.first(where: { $0.id == id && !$0.isSystem }) {
            deleteProfile(profileToDelete)
        } else if customProfiles.first(where: { $0.id == id && $0.isSystem }) != nil {
             print("System profiles cannot be deleted by ID.")
        }
    }
}
