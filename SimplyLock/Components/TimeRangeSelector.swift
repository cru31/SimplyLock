import SwiftUI

struct TimeRangeSelector: View {
    @Binding var selectedRange: String
    let ranges: [(id: String, label: String)]
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            HStack(spacing: 0) {
                ForEach(ranges, id: \.id) { range in
                    Button(action: {
                        selectedRange = range.id
                    }) {
                        Text(range.label)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                selectedRange == range.id
                                ? theme.cardBackgroundColor
                                : Color.clear
                            )
                            .foregroundColor(
                                selectedRange == range.id
                                ? theme.primaryColor
                                : theme.secondaryTextColor
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .cornerRadius(theme.cornerRadius / 2)
                }
            }
            .padding(4)
            .background(theme.secondaryBackgroundColor)
            .cornerRadius(theme.cornerRadius / 2)
            .animation(.easeInOut(duration: 0.2), value: selectedRange)
        }
    }
}

struct TimerModeSelector: View {
    @Binding var isBreak: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            HStack(spacing: 8) {
                Button(action: {
                    if isBreak {
                        isBreak = false
                    }
                }) {
                    Text("집중")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            !isBreak
                            ? theme.primaryColor
                            : theme.secondaryBackgroundColor
                        )
                        .foregroundColor(
                            !isBreak
                            ? theme.cardBackgroundColor
                            : theme.secondaryTextColor
                        )
                        .cornerRadius(theme.cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: {
                    if !isBreak {
                        isBreak = true
                    }
                }) {
                    Text("휴식")
                        .font(.system(size: 14, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            isBreak
                            ? theme.successColor
                            : theme.secondaryBackgroundColor
                        )
                        .foregroundColor(
                            isBreak
                            ? theme.cardBackgroundColor
                            : theme.secondaryTextColor
                        )
                        .cornerRadius(theme.cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .animation(.easeInOut(duration: 0.2), value: isBreak)
        }
    }
}

// 라이트 모드 프리뷰
#Preview {
    VStack(spacing: 32) {
        TimeRangeSelector(
            selectedRange: .constant("today"),
            ranges: [
                (id: "today", label: "오늘"),
                (id: "week", label: "이번 주"),
                (id: "month", label: "이번 달")
            ]
        )
        
        TimerModeSelector(isBreak: .constant(false))
        
        TimerModeSelector(isBreak: .constant(true))
    }
    .padding()
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct SelectorComponentsDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return VStack(spacing: 32) {
            TimeRangeSelector(
                selectedRange: .constant("today"),
                ranges: [
                    (id: "today", label: "오늘"),
                    (id: "week", label: "이번 주"),
                    (id: "month", label: "이번 달")
                ]
            )
            
            TimerModeSelector(isBreak: .constant(false))
            
            TimerModeSelector(isBreak: .constant(true))
        }
        .padding()
        .background(Color.black)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}

// 블루 테마 프리뷰
struct SelectorComponentsBlueThemePreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 블루 테마로 변경
        let _ = themeManager.setTheme(id: "blue.light")
        
        return VStack(spacing: 32) {
            TimeRangeSelector(
                selectedRange: .constant("today"),
                ranges: [
                    (id: "today", label: "오늘"),
                    (id: "week", label: "이번 주"),
                    (id: "month", label: "이번 달")
                ]
            )
            
            TimerModeSelector(isBreak: .constant(false))
            
            TimerModeSelector(isBreak: .constant(true))
        }
        .padding()
        .background(Color(.systemGray6))
        .environmentObject(themeManager)
    }
}
