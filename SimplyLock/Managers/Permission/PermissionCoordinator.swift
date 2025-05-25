import Combine
import FamilyControls
import CoreLocation
import UserNotifications
import SwiftUI
import Foundation

// MARK: - Permission Type
enum PermissionType: String, CaseIterable {
    case location
    case screenTime
    case notification
}

// MARK: - Authorization Status
enum AuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case provisional
}

@MainActor
class PermissionCoordinator: ObservableObject {
    @Published var isCheckingPermissions = false
    @Published var loadingMessage = "Checking permissions..."
    private var managers: [PermissionType: PermissionManagerProtocol] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    var allStatusesReady: Bool {
        managers.values.allSatisfy { $0.isStatusReady() }
    }
    
    init() {
        managers[.screenTime] = ScreenTimePermissionManager()
        managers[.location] = LocationPermissionManager()
        managers[.notification] = NotificationPermissionManager()
        
        for manager in managers.values {
            Publishers.CombineLatest(manager.isChecking, manager.isRequestingAuth)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isChecking, isRequestingAuth in
                    self?.updateLoadingState()
                }
                .store(in: &cancellables)
        }
    }
    
    func manager(for type: PermissionType) -> PermissionManagerProtocol? {
        managers[type]
    }
    
    func shouldShowPermissionGuide() -> Bool {
        managers.values.contains { $0.currentStatus != .authorized }
    }
    
    func checkAllPermissions() async {
        await MainActor.run {
            self.isCheckingPermissions = true
            self.loadingMessage = "Checking permissions..."
        }
        await withTaskGroup(of: Void.self) { group in
            for manager in managers.values {
                group.addTask {
                    await self.checkPermissionWithTimeout(manager: manager)
                }
            }
        }
        await MainActor.run {
            self.isCheckingPermissions = false
            self.loadingMessage = "Permissions checked"
        }
    }
    
    func requestPermission(for type: PermissionType) async throws {
        guard let manager = managers[type] else {
            throw PermissionError.managerNotFound
        }
        try await manager.requestAuthorization()
    }
    
    private func checkPermissionWithTimeout(manager: PermissionManagerProtocol) async {
        do {
            try await withTimeout(seconds: 15.0) {
                await manager.checkAuthorizationStatus()
            }
        } catch {
            print("Timeout or error checking permission \(manager.permissionType): \(error) at \(Date())")
            // 타임아웃 후 상태 재확인
            await manager.checkAuthorizationStatus()
        }
    }
    
    private func updateLoadingState() {
        let isAnyChecking = managers.values.contains { $0.isCurrentlyChecking }
        let isAnyRequesting = managers.values.contains { $0.isCurrentlyRequestingAuth }
        let isLoading = isAnyChecking || isAnyRequesting
        DispatchQueue.main.async {
            self.isCheckingPermissions = isLoading
            if isAnyChecking {
                self.loadingMessage = "Checking permissions..."
            } else if isAnyRequesting {
                self.loadingMessage = "Requesting permission..."
            } else {
                self.loadingMessage = "Permissions checked"
            }
        }
    }
}

enum PermissionError: Error {
    case managerNotFound
    case timeout
    case denied
}

func withTimeout(seconds: TimeInterval, operation: @escaping () async throws -> Void) async throws {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
        var didComplete = false
        let task = Task {
            do {
                try await operation()
                if !didComplete {
                    didComplete = true
                    continuation.resume()
                }
            } catch {
                if !didComplete {
                    didComplete = true
                    continuation.resume(throwing: error)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if !didComplete {
                didComplete = true
                task.cancel()
                continuation.resume(throwing: PermissionError.timeout)
            }
        }
    }
}
