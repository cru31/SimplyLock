import CoreLocation
import Combine
import Foundation

// MARK: - Location Delegate
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    private weak var manager: LocationPermissionManager?
    
    init(manager: LocationPermissionManager) {
        self.manager = manager
        super.init()
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            await self.manager?.handleAuthorizationChange(status: manager.authorizationStatus)
        }
    }
}

// MARK: - Location Permission Manager
@MainActor
class LocationPermissionManager: PermissionManagerProtocol {
    // MARK: - Properties
    let permissionType: PermissionType = .location
    let name: String = "Location"
    let permissionDescription: String = "Allows the app to access your location for personalized services."
    let systemImageName: String = "location.fill"
    
    private let locationManager: CLLocationManager
    private var delegate: LocationDelegate?
    private let authorizationStatusSubject: CurrentValueSubject<AuthorizationStatus, Never>
    private let isCheckingSubject: CurrentValueSubject<Bool, Never>
    private let isRequestingAuthSubject: CurrentValueSubject<Bool, Never>
    private var continuation: CheckedContinuation<Void, Error>?
    
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
    init(locationManager: CLLocationManager = .init()) {
        self.locationManager = locationManager
        self.authorizationStatusSubject = CurrentValueSubject(.notDetermined)
        self.isCheckingSubject = CurrentValueSubject(false)
        self.isRequestingAuthSubject = CurrentValueSubject(false)
        self.continuation = nil
        self.delegate = nil
        self.delegate = LocationDelegate(manager: self)
        self.locationManager.delegate = delegate
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Protocol Methods
    func requestAuthorization() async throws {
        guard !isCurrentlyLoading else { return }
        
        isRequestingAuthSubject.send(true)
        defer { isRequestingAuthSubject.send(false) }
        
        guard CLLocationManager.locationServicesEnabled() else {
            authorizationStatusSubject.send(.denied)
            throw LocationPermissionError.locationServicesDisabled
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let currentStatus = locationManager.authorizationStatus
            if currentStatus == .notDetermined {
                self.continuation = continuation
                locationManager.requestWhenInUseAuthorization()
            } else {
                let status = mapAuthorizationStatus(currentStatus)
                authorizationStatusSubject.send(status)
                continuation.resume(returning: ())
            }
        }
    }
    
    func checkAuthorizationStatus() async {
        guard !isCurrentlyLoading else { return }
        
        isCheckingSubject.send(true)
        defer { isCheckingSubject.send(false) }
        
        let status = mapAuthorizationStatus(locationManager.authorizationStatus)
        authorizationStatusSubject.send(status)
    }
    
    func isStatusReady() -> Bool {
        return currentStatus == .authorized || currentStatus == .provisional
    }
    
    // MARK: - Internal Methods
    func handleAuthorizationChange(status: CLAuthorizationStatus) async {
        let newStatus = mapAuthorizationStatus(status)
        authorizationStatusSubject.send(newStatus)
        
        if let continuation = continuation {
            if newStatus == .authorized || newStatus == .provisional {
                continuation.resume(returning: ())
            } else {
                continuation.resume(throwing: LocationPermissionError.authorizationDenied)
            }
            self.continuation = nil
        }
    }
    
    private func mapAuthorizationStatus(_ status: CLAuthorizationStatus) -> AuthorizationStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .denied
        case .authorizedAlways:
            return .authorized
        case .authorizedWhenInUse:
            if #available(iOS 14, *), locationManager.accuracyAuthorization == .reducedAccuracy {
                return .provisional
            }
            return .authorized
        @unknown default:
            return .notDetermined
        }
    }
}

// MARK: - Error
enum LocationPermissionError: LocalizedError {
    case locationServicesDisabled
    case authorizationDenied
    
    var errorDescription: String? {
        switch self {
        case .locationServicesDisabled:
            return "Location services are disabled on this device."
        case .authorizationDenied:
            return "Location permission was denied."
        }
    }
}
