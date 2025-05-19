//
//  AppTheme.swift
//  SimplyLock
//
//  Created by Duk-Jun Kim on 5/17/25.
//


import SwiftUI
import Combine
import UIKit

extension Color {
    static func toRGB(_ uiColor: UIColor, for userInterfaceStyle: UIUserInterfaceStyle) -> Color {
        let traitCollection = UITraitCollection(userInterfaceStyle: userInterfaceStyle)
        let resolvedColor = uiColor.resolvedColor(with: traitCollection)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if resolvedColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return Color(red: red, green: green, blue: blue, opacity: alpha)
        }
        // 기본값 (검정)
        return Color(red: 0, green: 0, blue: 0, opacity: 1)
    }
}

// 개별 테마의 기본 프로토콜
protocol AppTheme {
    var id: String { get }
    var name: String { get }
    
    // 기본 색상
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    var secondaryBackgroundColor: Color { get }
    var cardBackgroundColor: Color { get }
    
    // 버튼 관련 색상
    var buttonBackgroundColor: Color { get } // 기본 버튼 배경색
    var buttonPressedBackgroundColor: Color { get } // 버튼 눌림 상태 배경색
    var disabledButtonBackgroundColor: Color { get } // 비활성화된 버튼 배경색
    
    // 액션 버튼 색상 (예: 주요 액션 버튼)
    var primaryButtonBackgroundColor: Color { get } // 주요 버튼 배경색
    var primaryButtonPressedBackgroundColor: Color { get } // 주요 버튼 눌림 상태 배경색
    
    // 텍스트 스타일
    var primaryTextColor: Color { get }
    var secondaryTextColor: Color { get }
    var tertiaryTextColor: Color { get }
    
    // 요소별 스타일
    var successColor: Color { get }
    var warningColor: Color { get }
    var errorColor: Color { get }
    
    // 메트릭
    var cornerRadius: CGFloat { get }
    var standardPadding: CGFloat { get }
    var smallPadding: CGFloat { get }
    var standardIconSize: CGFloat { get }
    
    var colorScheme: ColorScheme? { get }
    
    func cardStyle(isSelected: Bool) -> CardStyle
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo
}

// 카드 스타일 정보
struct CardStyle {
    let backgroundColor: Color
    let borderColor: Color
    let shadowRadius: CGFloat
    let shadowOpacity: Double
}

// 버튼 타입
enum ButtonType {
    case primary
    case secondary
    case destructive
    case plain
}

// 버튼 스타일 정보
struct ButtonStyleInfo {
    let backgroundColor: Color
    let foregroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    let cornerRadius: CGFloat
    let font: Font
    
    // 버튼 상태에 따른 스타일 변형
    func pressedStyle() -> ButtonStyleInfo {
        ButtonStyleInfo(
            backgroundColor: backgroundColor.opacity(0.8),
            foregroundColor: foregroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth,
            cornerRadius: cornerRadius,
            font: font
        )
    }
    
    func disabledStyle() -> ButtonStyleInfo {
        ButtonStyleInfo(
            backgroundColor: backgroundColor.opacity(0.4),
            foregroundColor: foregroundColor.opacity(0.6),
            borderColor: borderColor?.opacity(0.4),
            borderWidth: borderWidth,
            cornerRadius: cornerRadius,
            font: font
        )
    }
}

// 토글 스타일 정보
struct ToggleStyleInfo {
    let backgroundColor: Color
    let thumbColor: Color
    let borderColor: Color?
    let width: CGFloat
    let height: CGFloat
}

class ThemeManager: ObservableObject {
    // 싱글턴 인스턴스
    static let shared = ThemeManager()
    
    // 등록된 모든 테마
    private var themes: [String: AppTheme] = [:]
    
    // 현재 테마 ID
    @Published private(set) var currentThemeId: String
    
    // 시스템 다크 모드 추적
    @Published private(set) var systemColorScheme: ColorScheme = .light
    
    // UserDefaults 키
    private let themeIdKey = "app.simplylock.selectedThemeId"
    
    // 초기화
    private init() {
        
        
        // 초기 시스템 색상 스킴 확인
        let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
        systemColorScheme = isDarkMode ? .dark : .light
        
        // 초기 테마 ID 설정
        currentThemeId = isDarkMode ? "default.dark" : "default.light"
        
        // 저장 프로퍼티가 모두 초기화된 후 테마 등록 및 설정 진행
        setupThemes()
        loadSavedTheme()
    }
    
    // 테마 등록 및 설정
    private func setupThemes() {
        // 모든 테마 등록
        registerDefaultThemes()
        registerBlueThemes()
        registerGreenThemes()
        registerPurpleThemes()
        // 추가 테마가 있다면 여기에 더 등록할 수 있습니다
    }
    
    // 기본 테마 등록
    private func registerDefaultThemes() {
        registerTheme(DefaultLightTheme())
        registerTheme(DefaultDarkTheme())
    }
    
    // 블루 테마 등록
    private func registerBlueThemes() {
        registerTheme(BlueLightTheme())
        registerTheme(BlueDarkTheme())
    }
    
    // 그린 테마 등록
    private func registerGreenThemes() {
        registerTheme(GreenLightTheme())
        registerTheme(GreenDarkTheme())
    }
    
    // 퍼플 테마 등록
    private func registerPurpleThemes() {
        registerTheme(PurpleLightTheme())
        registerTheme(PurpleDarkTheme())
    }
    
    // 저장된 테마 로드
    private func loadSavedTheme() {
        if let savedThemeId = UserDefaults.standard.string(forKey: themeIdKey),
           themes[savedThemeId] != nil {
            currentThemeId = savedThemeId
            print("Loaded saved theme: \(savedThemeId)")
        } else {
            // 저장된 테마가 없거나 유효하지 않은 경우 시스템 설정에 따라 기본 테마 설정
            let isDarkMode = systemColorScheme == .dark
            let defaultThemeId = isDarkMode ? "default.dark" : "default.light"
            currentThemeId = defaultThemeId
            print("No saved theme found, using default: \(defaultThemeId)")
        }
    }
    
    // 테마 등록
    func registerTheme(_ theme: AppTheme) {
        themes[theme.id] = theme
    }
    
    // 현재 테마 설정
    func setTheme(id: String) {
        guard themes[id] != nil else {
            print("Theme with id \(id) not found")
            return
        }
        
        currentThemeId = id
        UserDefaults.standard.set(id, forKey: themeIdKey)
    }
    
    // 현재 테마 가져오기
    var currentTheme: AppTheme {
        guard let theme = themes[currentThemeId] else {
            // 만약 현재 ID에 해당하는 테마가 없으면 기본 테마 반환
            return themes["default.light"] ?? DefaultLightTheme()
        }
        return theme
    }
    
    // 사용 가능한 모든 테마 가져오기
    var availableThemes: [AppTheme] {
        return Array(themes.values)
    }
    
    // 시스템 다크 모드 설정
    func updateSystemColorScheme(_ colorScheme: ColorScheme) {
        systemColorScheme = colorScheme
    }
    
    // 테마가 다크 모드를 사용하는지 확인
    var effectiveColorScheme: ColorScheme? {
        return currentTheme.colorScheme
    }
    
    // 현재 테마 계열에 맞는 다크/라이트 테마로 업데이트
    func updateThemeForDarkMode(isDark: Bool) {
        let themeParts = currentThemeId.split(separator: ".")
        if themeParts.count >= 2 {
            let themeBase = String(themeParts[0])
            let newThemeId = isDark ? "\(themeBase).dark" : "\(themeBase).light"
            
            if newThemeId != currentThemeId && availableThemes.contains(where: { $0.id == newThemeId }) {
                print("Updating theme to: \(newThemeId) based on system dark mode: \(isDark)")
                setTheme(id: newThemeId)
            }
        }
    }
}

// 기본 라이트 테마 구현
struct DefaultLightTheme: AppTheme {
    let id = "default.light"
    let name = "기본 라이트"
    
    // 색상
    let primaryColor = Color.toRGB(.systemBlue, for: .light)
    let secondaryColor = Color.toRGB(.systemIndigo, for: .light)
    let accentColor = Color.toRGB(.systemBlue, for: .light)
    let backgroundColor = Color.toRGB(.systemBackground, for: .light)
    let secondaryBackgroundColor = Color.toRGB(.secondarySystemBackground, for: .light)
    let cardBackgroundColor = Color(white: 0.92, opacity: 0.5) // 흐린 색
    
    // 버튼 관련 색상
    let buttonBackgroundColor = Color(white: 0.87) // 더 밝은 배경색
    let buttonPressedBackgroundColor = Color(white: 0.82) // 눌렸을 때 약간 어두운 색
    let disabledButtonBackgroundColor = Color(white: 0.84, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor: Color = Color.blue
    let primaryButtonPressedBackgroundColor: Color = Color.blue.opacity(0.8) // 눌렸을 때 더 어두운 파란색

    
    // 텍스트 색상
    let primaryTextColor = Color.toRGB(.label, for: .light)
    let secondaryTextColor = Color.toRGB(.secondaryLabel, for: .light)
    let tertiaryTextColor = Color.toRGB(.tertiaryLabel, for: .light)
    
    // 상태 색상
    let successColor = Color.green
    let warningColor = Color.yellow
    let errorColor = Color.red
    
    // 메트릭
    let cornerRadius: CGFloat = 12
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정 (nil은 시스템 설정 따름)
    let colorScheme: ColorScheme? = .light
    
    // 카드 스타일
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.2
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color.toRGB(.systemGray, for: .light),
                shadowRadius: 1,
                shadowOpacity: 0.1
            )
        }
    }
    
    // 버튼 스타일
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: Color.toRGB(.systemGray5, for: .light),
                foregroundColor: primaryTextColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    // 토글 스타일
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color.toRGB(.systemGray5, for: .light),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 기본 다크 테마 구현
struct DefaultDarkTheme: AppTheme {
    let id = "default.dark"
    let name = "기본 다크"
    
    // 색상
    let primaryColor = Color.toRGB(.systemBlue, for: .dark)
    let secondaryColor = Color.toRGB(.systemIndigo, for: .dark)
    let accentColor = Color.toRGB(.systemBlue, for: .dark)
    let backgroundColor = Color.black
    let secondaryBackgroundColor = Color.toRGB(.secondarySystemBackground, for: .dark)
    let cardBackgroundColor = Color.toRGB(.secondarySystemBackground, for: .dark)
   
    // 버튼 관련 색상 - 더 어둡게 조정
    let buttonBackgroundColor = Color(white: 0.2) // 더 어두운 배경색
    let buttonPressedBackgroundColor = Color(white: 0.16) // 눌렸을 때 더 어두운 색
    let disabledButtonBackgroundColor = Color(white: 0.18, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor: Color = Color.blue
    let primaryButtonPressedBackgroundColor: Color = Color.blue.opacity(0.7) // 눌렸을 때 더 어두운 파란색
    
    // 텍스트 색상
    let primaryTextColor = Color.toRGB(.label, for: .dark)
    let secondaryTextColor = Color.toRGB(.secondaryLabel, for: .dark)
    let tertiaryTextColor = Color.toRGB(.tertiaryLabel, for: .dark)
    
    // 상태 색상
    let successColor = Color.green
    let warningColor = Color.yellow
    let errorColor = Color.red
    
    // 메트릭
    let cornerRadius: CGFloat = 12
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .dark
    
    // 카드 스타일
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.4
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color.toRGB(.systemGray5, for: .dark),
                shadowRadius: 1,
                shadowOpacity: 0.2
            )
        }
    }
    
    // 버튼 스타일
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: Color.toRGB(.systemGray5, for: .dark),
                foregroundColor: primaryTextColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    // 토글 스타일
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color.toRGB(.systemGray3, for: .dark),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}
// 블루 라이트 테마
struct BlueLightTheme: AppTheme {
    let id = "blue.light"
    let name = "블루 라이트"
    
    // 기본 색상
    let primaryColor = Color(red: 0.0, green: 0.5, blue: 0.9)
    let secondaryColor = Color(red: 0.3, green: 0.7, blue: 1.0)
    let accentColor = Color(red: 0.0, green: 0.6, blue: 1.0)
    let backgroundColor = Color.white
    let secondaryBackgroundColor = Color(red: 0.95, green: 0.97, blue: 1.0)
    let cardBackgroundColor = Color.white
    
    // 버튼 관련 색상
    let buttonBackgroundColor = Color(red: 0.95, green: 0.97, blue: 1.0) // 더 밝은 파란 회색
    let buttonPressedBackgroundColor = Color(red: 0.9, green: 0.94, blue: 0.98) // 눌렸을 때 약간 어두운 색
    let disabledButtonBackgroundColor = Color(red: 0.93, green: 0.96, blue: 0.99, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor = Color(red: 0.0, green: 0.5, blue: 0.9)
    let primaryButtonPressedBackgroundColor = Color(red: 0.0, green: 0.4, blue: 0.8)
    
    // 텍스트 색상
    let primaryTextColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    let secondaryTextColor = Color(red: 0.3, green: 0.3, blue: 0.3)
    let tertiaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // 상태 색상
    let successColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    // 메트릭
    let cornerRadius: CGFloat = 14
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .light
    
    // 기존 함수들
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.2
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color(red: 0.9, green: 0.9, blue: 0.95),
                shadowRadius: 1,
                shadowOpacity: 0.1
            )
        }
    }
    
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: secondaryBackgroundColor,
                foregroundColor: primaryColor,
                borderColor: primaryColor,
                borderWidth: 1,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color(red: 0.9, green: 0.9, blue: 0.9),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 블루 다크 테마
struct BlueDarkTheme: AppTheme {
    let id = "blue.dark"
    let name = "블루 다크"
    
    // 기본 색상
    let primaryColor = Color(red: 0.1, green: 0.6, blue: 1.0)
    let secondaryColor = Color(red: 0.4, green: 0.7, blue: 1.0)
    let accentColor = Color(red: 0.2, green: 0.7, blue: 1.0)
    let backgroundColor = Color(red: 0.05, green: 0.05, blue: 0.1)
    let secondaryBackgroundColor = Color(red: 0.1, green: 0.1, blue: 0.15)
    let cardBackgroundColor = Color(red: 0.15, green: 0.15, blue: 0.2)
    
    // 버튼 관련 색상 - 더 어둡게 조정
    let buttonBackgroundColor = Color(red: 0.15, green: 0.18, blue: 0.25) // 더 어두운 파란 회색
    let buttonPressedBackgroundColor = Color(red: 0.12, green: 0.15, blue: 0.2) // 눌렸을 때 더 어두운 색
    let disabledButtonBackgroundColor = Color(red: 0.14, green: 0.16, blue: 0.22, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor = Color(red: 0.1, green: 0.6, blue: 1.0)
    let primaryButtonPressedBackgroundColor = Color(red: 0.05, green: 0.5, blue: 0.9)
    
    // 텍스트 색상
    let primaryTextColor = Color.white
    let secondaryTextColor = Color(red: 0.8, green: 0.8, blue: 0.85)
    let tertiaryTextColor = Color(red: 0.6, green: 0.6, blue: 0.7)
    
    // 상태 색상
    let successColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    // 메트릭
    let cornerRadius: CGFloat = 14
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .dark
    
    // 기존 함수들
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.5
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color(red: 0.2, green: 0.2, blue: 0.25),
                shadowRadius: 1,
                shadowOpacity: 0.3
            )
        }
    }
    
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: secondaryBackgroundColor,
                foregroundColor: primaryColor,
                borderColor: primaryColor,
                borderWidth: 1,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color(red: 0.3, green: 0.3, blue: 0.35),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 그린 라이트 테마
struct GreenLightTheme: AppTheme {
    let id = "green.light"
    let name = "그린 라이트"
    
    // 기본 색상
    let primaryColor = Color(red: 0.0, green: 0.7, blue: 0.3)
    let secondaryColor = Color(red: 0.3, green: 0.8, blue: 0.4)
    let accentColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let backgroundColor = Color.white
    let secondaryBackgroundColor = Color(red: 0.95, green: 1.0, blue: 0.97)
    let cardBackgroundColor = Color.white
    
    // 버튼 관련 색상
    let buttonBackgroundColor = Color(red: 0.95, green: 0.99, blue: 0.96) // 더 밝은 초록 회색
    let buttonPressedBackgroundColor = Color(red: 0.9, green: 0.97, blue: 0.92) // 눌렸을 때 약간 어두운 색
    let disabledButtonBackgroundColor = Color(red: 0.93, green: 0.98, blue: 0.94, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor = Color(red: 0.0, green: 0.7, blue: 0.3)
    let primaryButtonPressedBackgroundColor = Color(red: 0.0, green: 0.6, blue: 0.25)
    
    // 텍스트 색상
    let primaryTextColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    let secondaryTextColor = Color(red: 0.3, green: 0.3, blue: 0.3)
    let tertiaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // 상태 색상
    let successColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    // 메트릭
    let cornerRadius: CGFloat = 14
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .light
    
    // 기존 함수들
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.2
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color(red: 0.9, green: 0.95, blue: 0.9),
                shadowRadius: 1,
                shadowOpacity: 0.1
            )
        }
    }
    
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: secondaryBackgroundColor,
                foregroundColor: primaryColor,
                borderColor: primaryColor,
                borderWidth: 1,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color(red: 0.9, green: 0.9, blue: 0.9),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 그린 다크 테마
struct GreenDarkTheme: AppTheme {
    let id = "green.dark"
    let name = "그린 다크"
    
    // 기본 색상
    let primaryColor = Color(red: 0.1, green: 0.8, blue: 0.4)
    let secondaryColor = Color(red: 0.3, green: 0.9, blue: 0.5)
    let accentColor = Color(red: 0.2, green: 0.9, blue: 0.5)
    let backgroundColor = Color(red: 0.05, green: 0.1, blue: 0.05)
    let secondaryBackgroundColor = Color(red: 0.1, green: 0.15, blue: 0.1)
    let cardBackgroundColor = Color(red: 0.15, green: 0.2, blue: 0.15)
    
    // 버튼 관련 색상 - 더 어둡게 조정
    let buttonBackgroundColor = Color(red: 0.15, green: 0.22, blue: 0.18) // 더 어두운 초록 회색
    let buttonPressedBackgroundColor = Color(red: 0.12, green: 0.18, blue: 0.14) // 눌렸을 때 더 어두운 색
    let disabledButtonBackgroundColor = Color(red: 0.14, green: 0.2, blue: 0.16, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor = Color(red: 0.1, green: 0.8, blue: 0.4)
    let primaryButtonPressedBackgroundColor = Color(red: 0.05, green: 0.7, blue: 0.35)
    
    // 텍스트 색상
    let primaryTextColor = Color.white
    let secondaryTextColor = Color(red: 0.8, green: 0.85, blue: 0.8)
    let tertiaryTextColor = Color(red: 0.6, green: 0.7, blue: 0.6)
    
    // 상태 색상
    let successColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    // 메트릭
    let cornerRadius: CGFloat = 14
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .dark
    
    // 기존 함수들
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.5
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color(red: 0.2, green: 0.25, blue: 0.2),
                shadowRadius: 1,
                shadowOpacity: 0.3
            )
        }
    }
    
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: secondaryBackgroundColor,
                foregroundColor: primaryColor,
                borderColor: primaryColor,
                borderWidth: 1,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color(red: 0.3, green: 0.35, blue: 0.3),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 퍼플 라이트 테마
struct PurpleLightTheme: AppTheme {
    let id = "purple.light"
    let name = "퍼플 라이트"
    
    // 기본 색상
    let primaryColor = Color(red: 0.55, green: 0.0, blue: 0.9)
    let secondaryColor = Color(red: 0.75, green: 0.3, blue: 1.0)
    let accentColor = Color(red: 0.65, green: 0.2, blue: 0.95)
    let backgroundColor = Color.white
    let secondaryBackgroundColor = Color(red: 0.97, green: 0.95, blue: 1.0)
    let cardBackgroundColor = Color.white
    
    // 버튼 관련 색상
    let buttonBackgroundColor = Color(red: 0.97, green: 0.95, blue: 0.99) // 더 밝은 보라 회색
    let buttonPressedBackgroundColor = Color(red: 0.94, green: 0.9, blue: 0.97) // 눌렸을 때 약간 어두운 색
    let disabledButtonBackgroundColor = Color(red: 0.96, green: 0.93, blue: 0.98, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor = Color(red: 0.55, green: 0.0, blue: 0.9)
    let primaryButtonPressedBackgroundColor = Color(red: 0.45, green: 0.0, blue: 0.8)
    
    // 텍스트 색상
    let primaryTextColor = Color(red: 0.1, green: 0.1, blue: 0.1)
    let secondaryTextColor = Color(red: 0.3, green: 0.3, blue: 0.3)
    let tertiaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // 상태 색상
    let successColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    // 메트릭
    let cornerRadius: CGFloat = 14
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .light
    
    // 기존 함수들
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.2
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color(red: 0.9, green: 0.9, blue: 0.95),
                shadowRadius: 1,
                shadowOpacity: 0.1
            )
        }
    }
    
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: secondaryBackgroundColor,
                foregroundColor: primaryColor,
                borderColor: primaryColor,
                borderWidth: 1,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color(red: 0.9, green: 0.9, blue: 0.9),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 퍼플 다크 테마
struct PurpleDarkTheme: AppTheme {
    let id = "purple.dark"
    let name = "퍼플 다크"
    
    // 기본 색상
    let primaryColor = Color(red: 0.7, green: 0.35, blue: 1.0)
    let secondaryColor = Color(red: 0.8, green: 0.5, blue: 1.0)
    let accentColor = Color(red: 0.75, green: 0.4, blue: 1.0)
    let backgroundColor = Color(red: 0.1, green: 0.05, blue: 0.15)
    let secondaryBackgroundColor = Color(red: 0.15, green: 0.1, blue: 0.2)
    let cardBackgroundColor = Color(red: 0.2, green: 0.15, blue: 0.25)
    
    // 버튼 관련 색상 - 더 어둡게 조정
    let buttonBackgroundColor = Color(red: 0.18, green: 0.14, blue: 0.22) // 더 어두운 보라 회색
    let buttonPressedBackgroundColor = Color(red: 0.15, green: 0.11, blue: 0.18) // 눌렸을 때 더 어두운 색
    let disabledButtonBackgroundColor = Color(red: 0.16, green: 0.13, blue: 0.2, opacity: 0.5) // 흐린 색
    
    // 주요 버튼 색상
    let primaryButtonBackgroundColor = Color(red: 0.7, green: 0.35, blue: 1.0)
    let primaryButtonPressedBackgroundColor = Color(red: 0.6, green: 0.3, blue: 0.9)
    
    // 텍스트 색상
    let primaryTextColor = Color.white
    let secondaryTextColor = Color(red: 0.85, green: 0.8, blue: 0.9)
    let tertiaryTextColor = Color(red: 0.7, green: 0.6, blue: 0.75)
    
    // 상태 색상
    let successColor = Color(red: 0.0, green: 0.8, blue: 0.4)
    let warningColor = Color(red: 1.0, green: 0.75, blue: 0.0)
    let errorColor = Color(red: 1.0, green: 0.2, blue: 0.2)
    
    // 메트릭
    let cornerRadius: CGFloat = 14
    let standardPadding: CGFloat = 16
    let smallPadding: CGFloat = 8
    let standardIconSize: CGFloat = 24
    
    // 다크 모드 설정
    let colorScheme: ColorScheme? = .dark
    
    // 기존 함수들
    func cardStyle(isSelected: Bool) -> CardStyle {
        if isSelected {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: primaryColor,
                shadowRadius: 2,
                shadowOpacity: 0.5
            )
        } else {
            return CardStyle(
                backgroundColor: cardBackgroundColor,
                borderColor: Color(red: 0.25, green: 0.2, blue: 0.3),
                shadowRadius: 1,
                shadowOpacity: 0.3
            )
        }
    }
    
    func buttonStyle(type: ButtonType) -> ButtonStyleInfo {
        switch type {
        case .primary:
            return ButtonStyleInfo(
                backgroundColor: primaryColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .secondary:
            return ButtonStyleInfo(
                backgroundColor: secondaryBackgroundColor,
                foregroundColor: primaryColor,
                borderColor: primaryColor,
                borderWidth: 1,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .destructive:
            return ButtonStyleInfo(
                backgroundColor: errorColor,
                foregroundColor: .white,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        case .plain:
            return ButtonStyleInfo(
                backgroundColor: .clear,
                foregroundColor: primaryColor,
                borderColor: nil,
                borderWidth: 0,
                cornerRadius: cornerRadius,
                font: .headline
            )
        }
    }
    
    func toggleStyle(isOn: Bool) -> ToggleStyleInfo {
        if isOn {
            return ToggleStyleInfo(
                backgroundColor: primaryColor,
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        } else {
            return ToggleStyleInfo(
                backgroundColor: Color(red: 0.3, green: 0.25, blue: 0.35),
                thumbColor: .white,
                borderColor: nil,
                width: 50,
                height: 30
            )
        }
    }
}

// 테마 매니저를 접근하기 쉽게 하는 환경 값
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
// View 확장 - 테마 스타일 적용 (읽기 전용)
extension View {
    // 테마 스타일 적용 (읽기 전용) - 유지
    func withTheme<StyledContent: View>(_ styleBuilder: @escaping (AppTheme) -> StyledContent) -> some View {
        modifier(ThemeStyleModifier(styleBuilder: styleBuilder))
    }

}

// 테마 스타일을 적용하는 모디파이어 (읽기 전용)
struct ThemeStyleModifier<StyledContent: View>: ViewModifier {
    @Environment(\.themeManager) var themeManager
    let styleBuilder: (AppTheme) -> StyledContent
    
    func body(content: Content) -> some View {
        styleBuilder(themeManager.currentTheme)
    }
}

extension View {
    func adaptToThemeColorScheme() -> some View {
        modifier(ThemeColorSchemeAdapterModifier())
    }
}
struct ThemeColorSchemeAdapterModifier: ViewModifier {
    @Environment(\.themeManager) var themeManager
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.effectiveColorScheme)
    }
}
