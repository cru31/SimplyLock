import Combine

// MARK: - Permission Manager Protocol
@MainActor
protocol PermissionManagerProtocol {
    var permissionType: PermissionType { get }
    var name: String { get }
    var permissionDescription: String { get }
    var systemImageName: String { get }
    var authorizationStatus: AnyPublisher<AuthorizationStatus, Never> { get }
    var currentStatus: AuthorizationStatus { get }
    var isLoading: AnyPublisher<Bool, Never> { get }
    var isCurrentlyLoading: Bool { get }
    var isChecking: AnyPublisher<Bool, Never> { get }
    var isCurrentlyChecking: Bool { get }
    var isRequestingAuth: AnyPublisher<Bool, Never> { get }
    var isCurrentlyRequestingAuth: Bool { get }
    
    func requestAuthorization() async throws
    func checkAuthorizationStatus() async
    func isStatusReady() -> Bool
}
