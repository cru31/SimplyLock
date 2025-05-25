import UserNotifications
import Combine
import Foundation

// MARK: - Notification Permission Manager
@MainActor
class NotificationPermissionManager: PermissionManagerProtocol {
    // MARK: - Properties
    let permissionType: PermissionType = .notification
    let name: String = "Notifications"
    let permissionDescription: String = "Allows the app to send you notifications for updates and alerts."
    let systemImageName: String = "bell.fill"
    
    private let notificationCenter: UNUserNotificationCenter
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
    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Protocol Methods
    func requestAuthorization() async throws {
        guard !isCurrentlyLoading else {
            print("Request ignored: Already loading for \(permissionType.rawValue) at \(Date())")
            return
        }
        
        isRequestingAuthSubject.send(true)
        defer { isRequestingAuthSubject.send(false) }
        
        // 현재 상태 확인
        await checkAuthorizationStatus()
        if currentStatus == .denied {
            print("Permission already denied for \(permissionType.rawValue) at \(Date())")
            throw NotificationPermissionError.authorizationDenied
        }
        
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .provisional])
            let status: AuthorizationStatus
            if granted {
                status = .authorized
            } else {
                // granted == false인 경우, provisional 권한 여부 확인
                let settings = await notificationCenter.notificationSettings()
                status = settings.authorizationStatus == .provisional ? .provisional : .denied
            }
            print("Notification permission request: granted=\(granted), status=\(status) at \(Date())")
            authorizationStatusSubject.send(status)
        } catch {
            print("Notification permission request failed: \(error.localizedDescription) at \(Date())")
            authorizationStatusSubject.send(.denied)
            throw error
        }
    }
    
    func checkAuthorizationStatus() async {
        guard !isCurrentlyLoading else {
            print("Check ignored: Already loading for \(permissionType.rawValue) at \(Date())")
            return
        }
        
        isCheckingSubject.send(true)
        defer { isCheckingSubject.send(false) }
        
        let settings = await notificationCenter.notificationSettings()
        let status: AuthorizationStatus
        
        switch settings.authorizationStatus {
        case .notDetermined:
            status = .notDetermined
        case .denied:
            status = .denied
        case .authorized:
            status = .authorized
        case .provisional:
            status = .provisional
        @unknown default:
            status = .notDetermined
        }
        
        print("Notification permission status checked: \(status) at \(Date())")
        authorizationStatusSubject.send(status)
    }
    
    func isStatusReady() -> Bool {
        return currentStatus == .authorized || currentStatus == .provisional
    }
}

// MARK: - Error
enum NotificationPermissionError: LocalizedError {
    case authorizationDenied
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Notification permission was denied."
        }
    }
}
