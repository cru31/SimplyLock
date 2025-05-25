import SwiftUI

struct PermissionGuideView: View {
    let requiredManagers: [PermissionManagerProtocol]
    let optionalManagers: [PermissionManagerProtocol]
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var coordinator: PermissionCoordinator
    @State private var showPermissionSheet = false
    @State private var activePermissionType: PermissionType?
    
    var body: some View {
        print("PermissionGuideView body called at \(Date())"); return
        withTheme { theme in // withTheme과 AppTheme는 정의되지 않음; 기존 로직 유지
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 24) {
                            headerSection(theme: theme)
                            permissionSection(
                                title: "Required Permissions",
                                managers: requiredManagers,
                                theme: theme
                            )
                            permissionSection(
                                title: "Optional Permissions",
                                managers: optionalManagers,
                                theme: theme
                            )
                        }
                        .padding()
                        .opacity(coordinator.isCheckingPermissions ? 0.3 : 1.0)
                        .disabled(coordinator.isCheckingPermissions)
                    }
                    .background(theme.backgroundColor.ignoresSafeArea())
                    
                    if coordinator.isCheckingPermissions {
                        loadingOverlay(theme: theme)
                    }
                }
                .navigationTitle("App Permission Settings")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showPermissionSheet, onDismiss: {
                    print("Permission sheet dismissed, activePermissionType: \(activePermissionType?.rawValue ?? "nil") at \(Date())")
                    activePermissionType = nil
                }) {
                    if let type = activePermissionType {
                        PermissionDetailView(permissionType: type)
                            .environmentObject(coordinator)
                    } else {
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryColor))
                                .scaleEffect(1.5)
                            Text("Loading permission details...")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(theme.secondaryTextColor)
                                .multilineTextAlignment(.center)
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(theme.secondaryBackgroundColor.ignoresSafeArea())
                    }
                }
                .onAppear {
                    Task {
                        await coordinator.checkAllPermissions()
                    }
                }
            }
        }
    }
    
    private func loadingOverlay(theme: AppTheme) -> some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryColor))
                    .scaleEffect(1.5)
                
                Text(coordinator.loadingMessage)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(theme.primaryTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .fill(theme.cardBackgroundColor)
                    .shadow(radius: 10)
            )
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.easeInOut(duration: 0.2), value: coordinator.isCheckingPermissions)
    }
    
    private func headerSection(theme: AppTheme) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(theme.primaryColor)
                .padding()
                .background(
                    Circle()
                        .fill(theme.primaryColor.opacity(0.1))
                        .frame(width: 120, height: 120)
                )
            
            Text("Permission Settings for SimplyLock")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(theme.primaryTextColor)
                .multilineTextAlignment(.center)
            
            Text("Please configure the permissions below to use all app features.")
                .font(.system(size: 16))
                .foregroundColor(theme.secondaryTextColor)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }
    
    private func permissionSection(title: String, managers: [PermissionManagerProtocol], theme: AppTheme) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(theme.primaryTextColor)
            
            VStack(spacing: 0) {
                ForEach(managers, id: \.permissionType) { manager in
                    permissionRow(manager: manager, theme: theme)
                    
                    if manager.permissionType != managers.last?.permissionType {
                        Divider()
                            .background(theme.tertiaryTextColor.opacity(0.2))
                    }
                }
            }
            .background(theme.cardBackgroundColor)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    enum PermissionStatus {
        case notGranted
        case granted
        case loading
    }
    
    private func permissionStatus(for manager: PermissionManagerProtocol) -> PermissionStatus {
        if manager.isCurrentlyLoading {
            return .loading
        }
        switch manager.currentStatus {
        case .authorized, .provisional:
            return .granted
        case .notDetermined, .denied:
            return .notGranted
        }
    }
    
    private func permissionRow(manager: PermissionManagerProtocol, theme: AppTheme) -> some View {
        Button(action: {
            print("Tapped permission: \(manager.permissionType) at \(Date())")
            Task {
                await manager.checkAuthorizationStatus()
                await MainActor.run {
                    if manager.currentStatus != .authorized && !manager.isCurrentlyLoading {
                        print("Permission \(manager.permissionType) needs request, opening sheet at \(Date())")
                        activePermissionType = manager.permissionType
                        showPermissionSheet = true
                    } else {
                        print("Permission \(manager.permissionType) already authorized or loading, status: \(manager.currentStatus) at \(Date())")
                    }
                }
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(theme.primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    if manager.isCurrentlyLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.primaryColor))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: manager.systemImageName)
                            .font(.system(size: 20))
                            .foregroundColor(theme.primaryColor)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(manager.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Text(manager.isCurrentlyLoading ? "Checking permission..." : manager.permissionDescription)
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Group {
                    switch permissionStatus(for: manager) {
                    case .granted:
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(theme.successColor)
                    case .loading:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: theme.secondaryTextColor))
                            .scaleEffect(0.8)
                    case .notGranted:
                        Image(systemName: "chevron.right")
                            .foregroundColor(theme.secondaryTextColor)
                    }
                }
                .font(.system(size: 18))
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(coordinator.isCheckingPermissions || manager.isCurrentlyLoading)
    }
}
