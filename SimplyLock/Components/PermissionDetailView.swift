import SwiftUI
import UIKit

struct PermissionDetailView: View {
    let permissionType: PermissionType
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var coordinator: PermissionCoordinator
    @State private var isRequestingPermission = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    
    var body: some View {
        withTheme { theme in // withTheme and AppTheme not defined; keep as-is
            ZStack {
                VStack(spacing: 24) {
                    if let manager = coordinator.manager(for: permissionType) {
                        ZStack {
                            Circle()
                                .fill(theme.primaryColor.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryColor))
                                    .scaleEffect(1.5)
                            } else {
                                Image(systemName: manager.systemImageName)
                                    .font(.system(size: 40))
                                    .foregroundColor(theme.primaryColor)
                            }
                        }
                        .padding(.top, 40)
                        
                        Text("\(manager.name) Permission Required")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                            .multilineTextAlignment(.center)
                        
                        Text(getDetailDescription())
                            .font(.system(size: 16))
                            .foregroundColor(theme.secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer()
                        
                        Button(action: {
                            requestPermission()
                        }) {
                            HStack {
                                if isRequestingPermission {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Requesting...")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                } else {
                                    Text(getActionButtonText())
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(theme.primaryColor)
                            .cornerRadius(theme.cornerRadius)
                            .padding(.horizontal, 32)
                        }
                        .disabled(isRequestingPermission || manager.isCurrentlyLoading)
                        
                        if isOptionalPermission() {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Set Up Later")
                                    .font(.system(size: 16))
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                            .padding(.vertical, 8)
                            .disabled(isRequestingPermission || manager.isCurrentlyLoading)
                        }
                        
                        Spacer()
                            .frame(height: 40)
                    } else {
                        Text("Error: Permission not found for \(permissionType.rawValue)")
                            .foregroundColor(theme.primaryTextColor)
                    }
                }
                .background(theme.backgroundColor.ignoresSafeArea())
                .opacity(isRequestingPermission ? 0.6 : 1.0)
                .disabled(isRequestingPermission)
                
                if isRequestingPermission {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { /* Ignore taps during loading */ }
                }
            }
            .alert("Permission Request Failed", isPresented: $showError) {
                Button("Open Settings", role: .none) {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                    showError = false
                }
                Button("OK", role: .cancel) {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
            .alert("Permission Granted", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    showSuccess = false
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("\(permissionType.rawValue.capitalized) permission has been successfully granted.")
            }
        }
    }
    
    private func getDetailDescription() -> String {
        guard let manager = coordinator.manager(for: permissionType) else {
            return "Permission details not available."
        }
        switch manager.currentStatus {
        case .notDetermined:
            return "\(manager.permissionDescription) Please grant permission to continue."
        case .denied:
            return "Permission was previously denied. Please enable \(manager.name) in Settings > SimplyLock."
        case .authorized, .provisional:
            return "\(manager.name) permission is already granted."
        }
    }
    
    private func getActionButtonText() -> String {
        guard let manager = coordinator.manager(for: permissionType) else {
            return "Request Permission"
        }
        return manager.currentStatus == .denied ? "Open Settings" : "Request Permission"
    }
    
    private func isOptionalPermission() -> Bool {
        return permissionType == .notification
    }
    
    private func requestPermission() {
        guard let manager = coordinator.manager(for: permissionType) else {
            print("Error: No manager found for \(permissionType.rawValue) at \(Date())")
            showError = true
            errorMessage = "Permission not available."
            return
        }
        
        guard !isRequestingPermission && !manager.isCurrentlyLoading else {
            print("Request ignored: Already requesting or loading (\(permissionType.rawValue)) at \(Date())")
            return
        }
        
        isRequestingPermission = true
        Task {
            do {
                if manager.currentStatus == .denied {
                    print("Permission denied, opening settings (\(permissionType.rawValue)) at \(Date())")
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(settingsURL)
                    }
                    await MainActor.run {
                        isRequestingPermission = false
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    try await coordinator.requestPermission(for: permissionType)
                    // 추가 상태 확인
                    await manager.checkAuthorizationStatus()
                    await MainActor.run {
                        isRequestingPermission = false
                        if manager.currentStatus == .authorized {
                            showSuccess = true
                        } else {
                            showError = true
                            errorMessage = "Permission request completed but status is \(manager.currentStatus)."
                        }
                    }
                }
            } catch {
                print("Permission request failed (\(permissionType.rawValue)): \(error.localizedDescription) at \(Date())")
                // 에러 후 상태 재확인
                await manager.checkAuthorizationStatus()
                await MainActor.run {
                    isRequestingPermission = false
                    if manager.currentStatus == .authorized {
                        showSuccess = true
                    } else {
                        showError = true
                        errorMessage = getUserFriendlyErrorMessage(error: error)
                    }
                }
            }
        }
    }
    
    private func getUserFriendlyErrorMessage(error: Error) -> String {
        switch error {
        case LocationPermissionError.locationServicesDisabled:
            return "Location services are disabled. Please enable them in Settings > Privacy > Location Services."
        case LocationPermissionError.authorizationDenied:
            return "Location permission was denied. Please enable it in Settings > SimplyLock."
        case NotificationPermissionError.authorizationDenied:
            return "Notification permission was denied. Please enable it in Settings > SimplyLock."
        case ScreenTimePermissionError.authorizationFailed(let underlyingError):
            return "Failed to request screen time permission: \(underlyingError.localizedDescription). Please check Settings > Screen Time."
        case PermissionError.managerNotFound:
            return "Permission not available. Please try again or contact support."
        case PermissionError.timeout:
            return "Permission request timed out. Please try again or check Settings > Screen Time."
        default:
            return "An error occurred: \(error.localizedDescription). Please try again."
        }
    }
}
