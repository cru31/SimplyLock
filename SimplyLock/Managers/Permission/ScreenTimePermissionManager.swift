import FamilyControls
import Combine
import Foundation

// MARK: - Screen Time Permission Manager
@MainActor
class ScreenTimePermissionManager: PermissionManagerProtocol {
    // MARK: - Properties
    let permissionType: PermissionType = .screenTime
    let name: String = "Screen Time"
    let permissionDescription: String = "Allows the app to manage and monitor screen time usage."
    let systemImageName: String = "hourglass"
    
    private let authorizationCenter: AuthorizationCenter
    private let authorizationStatusSubject = CurrentValueSubject<AuthorizationStatus, Never>(.notDetermined)
    private let isCheckingSubject = CurrentValueSubject<Bool, Never>(false)
    private let isRequestingAuthSubject = CurrentValueSubject<Bool, Never>(false)
    
    var authorizationStatus: AnyPublisher<AuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    
    var currentStatus: AuthorizationStatus {
        authorizationStatusSubject.value
    }
    
    var isLoading: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isCheckingSubject, isRequestingAuthSubject)
            .map { $0 || $1 }
            .eraseToAnyPublisher()
    }
    
    var isCurrentlyLoading: Bool {
        isCheckingSubject.value || isRequestingAuthSubject.value
    }
    
    var isChecking: AnyPublisher<Bool, Never> {
        isCheckingSubject.eraseToAnyPublisher()
    }
    
    var isCurrentlyChecking: Bool {
        isCheckingSubject.value
    }
    
    var isRequestingAuth: AnyPublisher<Bool, Never> {
        isRequestingAuthSubject.eraseToAnyPublisher()
    }
    
    var isCurrentlyRequestingAuth: Bool {
        isRequestingAuthSubject.value
    }
    
    // MARK: - Initialization
    init(authorizationCenter: AuthorizationCenter = .shared) {
        self.authorizationCenter = authorizationCenter
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Protocol Methods
    func requestAuthorization() async throws {
        guard !isCurrentlyRequestingAuth else {
            print("Screen time permission request ignored: Already requesting (\(permissionType.rawValue)) at \(Date())")
            return
        }
        
        isRequestingAuthSubject.send(true)
        defer { isRequestingAuthSubject.send(false) }
        
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            print("Screen time permission request succeeded at \(Date())")
        } catch let error as FamilyControlsError {
            print("Screen time permission request failed with FamilyControlsError: \(error) (code: \(error.errorCode)) at \(Date())")
            // 상태 재확인
            await checkAuthorizationStatus()
            if currentStatus != .authorized {
                throw ScreenTimePermissionError.authorizationFailed(error: error)
            }
            return
        } catch {
            print("Screen time permission request failed with unknown error: \(error.localizedDescription) at \(Date())")
            await checkAuthorizationStatus()
            if currentStatus != .authorized {
                throw ScreenTimePermissionError.authorizationFailed(error: error)
            }
            return
        }
        
        // 성공 시 상태 재확인
        await checkAuthorizationStatus()
        if currentStatus != .authorized {
            print("Screen time permission request succeeded but status is \(currentStatus) at \(Date())")
            throw ScreenTimePermissionError.authorizationFailed(error: NSError(domain: "ScreenTime", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected status after authorization"]))
        }
    }
    
    func checkAuthorizationStatus() async {
        // isCurrentlyChecking 체크 제거로 강제 갱신
        isCheckingSubject.send(true)
        defer { isCheckingSubject.send(false) }
        
        let status: AuthorizationStatus
        switch authorizationCenter.authorizationStatus {
        case .notDetermined:
            status = .notDetermined
        case .approved:
            status = .authorized
        case .denied:
            status = .denied
        @unknown default:
            status = .notDetermined
        }
        
        print("Screen time permission status checked: \(status) at \(Date())")
        authorizationStatusSubject.send(status)
    }
    
    func isStatusReady() -> Bool {
        return currentStatus == .authorized
    }
}

// MARK: - Error
enum ScreenTimePermissionError: LocalizedError {
    case authorizationFailed(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed(let error):
            return "Failed to request screen time permission: \(error.localizedDescription). Please check Settings > Screen Time."
        }
    }
}
