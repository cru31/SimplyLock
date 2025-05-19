import SwiftUI

struct InsightsView: View {
    @State private var timeRange: String = "today"
    let usageData = UsageData.sample
    @EnvironmentObject private var themeManager: ThemeManager
    
    let timeRanges = [
        (id: "today", label: "오늘"),
        (id: "week", label: "이번 주"),
        (id: "month", label: "이번 달")
    ]
    
    var body: some View {
        withTheme { theme in
            ScrollView {
                VStack(spacing: 16) {
                    // 헤더 영역
                    HStack {
                        Text("인사이트")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Button(action: {}) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.secondaryTextColor)
                                    .padding(8)
                                    .background(theme.buttonBackgroundColor)
                                    .clipShape(Circle())
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.secondaryTextColor)
                                    .padding(8)
                                    .background(theme.buttonBackgroundColor)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    // 시간 범위 선택
                    TimeRangeSelector(
                        selectedRange: $timeRange,
                        ranges: timeRanges
                    )
                    
                    // 스크린 타임 차트
                    UsageSummaryCard(usageData: usageData)
                    
                    // 카테고리별 사용 분석
                    CategoryBreakdownCard(categories: usageData.categories)
                    
                    // 가장 많이 사용한 앱
                    TopAppsCard(apps: usageData.topApps)
                    
                    // 차단 효과 분석
                    BlockingEffectivenessCard(blocking: usageData.blocking)
                    
                    // 목표 섹션
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("목표")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(theme.primaryTextColor)
                            
                            Spacer()
                            
                            Button(action: {}) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12))
                                    
                                    Text("새 목표")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(theme.primaryColor)
                                .foregroundColor(.white)
                                .cornerRadius(theme.cornerRadius * 0.7)
                            }
                        }
                        
                        GoalProgressCard(goal: Goal.sample)
                    }
                }
                .padding()
            }
            .background(theme.backgroundColor)
        }
    }
}


struct UsageChart: View {
    let data: [Double]
    
    var body: some View {
        withTheme { theme in
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<data.count, id: \.self) { index in
                        if let maxValue = data.max() {
                            let height = maxValue > 0 ? CGFloat(data[index] / maxValue) * geometry.size.height : 0
                            
                            Rectangle()
                                .fill(theme.primaryColor)
                                .frame(width: (geometry.size.width - CGFloat(data.count * 2)) / CGFloat(data.count), height: height)
                                .cornerRadius(2)
                        }
                    }
                }
            }
        }
    }
}

struct ProgressBar: View {
    let value: Double  // 0.0 ~ 1.0
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(color)
                    .frame(width: geometry.size.width * CGFloat(value))
                    .cornerRadius(4)
            }
        }
    }
}



struct UsageDetailView: View {
    let category: UsageCategory
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 16) {
                Text(category.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(theme.primaryTextColor)
                
                // 상세 통계 및 차트
                Text("상세 통계 영역")
                    .foregroundColor(theme.primaryTextColor)
                
                // 카테고리에 속한 앱 목록
                Text("앱 목록 영역")
                    .foregroundColor(theme.primaryTextColor)
            }
            .padding()
            .background(theme.backgroundColor)
        }
    }
}

struct GoalCreationView: View {
    @Binding var isPresented: Bool
    @State private var goalTitle: String = ""
    @State private var goalTarget: String = ""
    @State private var goalType: String = "screen_time"
    @State private var targetValue: Int = 240 // 4시간(분 단위)
    @EnvironmentObject private var themeManager: ThemeManager
    
    let goalTypes = [
        (id: "screen_time", label: "스크린 타임 감소"),
        (id: "app_usage", label: "앱 사용 시간 제한"),
        (id: "block_count", label: "차단 시도 감소")
    ]
    
    var body: some View {
        withTheme { theme in
            NavigationView {
                Form {
                    Section(header: Text("목표 정보").foregroundColor(theme.secondaryTextColor)) {
                        TextField("목표 제목", text: $goalTitle)
                            .foregroundColor(theme.primaryTextColor)
                        
                        Picker("목표 유형", selection: $goalType) {
                            ForEach(goalTypes, id: \.id) { type in
                                Text(type.label).tag(type.id)
                                    .foregroundColor(theme.primaryTextColor)
                            }
                        }
                        .foregroundColor(theme.primaryTextColor)
                    }
                    
                    Section(header: Text("목표 설정").foregroundColor(theme.secondaryTextColor)) {
                        if goalType == "screen_time" {
                            HStack {
                                Text("일일 스크린 타임")
                                    .foregroundColor(theme.primaryTextColor)
                                Spacer()
                                Text("\(targetValue / 60)시간 \(targetValue % 60)분 이하")
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(targetValue) },
                                set: { targetValue = Int($0) }
                            ), in: 60...720, step: 15)
                            .accentColor(theme.primaryColor)
                        } else if goalType == "app_usage" {
                            Text("앱 선택")
                                .foregroundColor(theme.primaryTextColor)
                            // 앱 선택 UI
                        } else if goalType == "block_count" {
                            HStack {
                                Text("일일 차단 시도")
                                    .foregroundColor(theme.primaryTextColor)
                                Spacer()
                                Text("\(targetValue)회 이하")
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(targetValue) },
                                set: { targetValue = Int($0) }
                            ), in: 5...50, step: 5)
                            .accentColor(theme.primaryColor)
                        }
                    }
                }
                .background(theme.backgroundColor)
                .navigationBarTitle("새 목표", displayMode: .inline)
                .navigationBarItems(
                    leading: Button("취소") {
                        isPresented = false
                    }
                        .foregroundColor(theme.primaryColor),
                    trailing: Button("저장") {
                        saveGoal()
                    }
                        .disabled(goalTitle.isEmpty)
                        .foregroundColor(goalTitle.isEmpty ? theme.secondaryTextColor : theme.primaryColor)
                )
                .accentColor(theme.primaryColor)
            }
            .preferredColorScheme(theme.colorScheme)
        }
    }
    
    private func saveGoal() {
        // 목표 저장 로직
        isPresented = false
    }
}

#Preview {
    InsightsView()
        .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct InsightsViewDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return InsightsView()
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
    }
}
