import SwiftUI

struct HourlyUsageChart: View {
    let data: [Double]
    
    var body: some View {
        withTheme { theme in
            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: max(1, geometry.size.width / CGFloat(data.count) * 0.2)) {
                    ForEach(0..<data.count, id: \.self) { index in
                        let value = data[index]
                        let maxValue = data.max() ?? 1.0
                        let height = value > 0 ? max(4, (value / maxValue) * geometry.size.height) : 0
                        
                        Rectangle()
                            .fill(theme.primaryColor)
                            .frame(
                                width: max(4, (geometry.size.width / CGFloat(data.count)) * 0.8),
                                height: height
                            )
                            .cornerRadius(2)
                    }
                }
            }
        }
    }
}

struct CategoryProgressBar: View {
    let category: UsageCategory
    
    var body: some View {
        withTheme { theme in
            VStack(spacing: 4) {
                HStack {
                    Text(category.name)
                        .font(.system(size: 14))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Text("\(category.time) (\(category.percent)%)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 2)
                            .fill(theme.secondaryBackgroundColor)
                            .frame(height: 8)
                        
                        // Progress - 카테고리 색상 유지 (시각적 구분을 위해)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(category.color)
                            .frame(width: geometry.size.width * CGFloat(category.percent) / 100, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

struct AppUsageRow: View {
    let app: AppUsage
    
    var body: some View {
        withTheme { theme in
            HStack {
                // 앱 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(app.color) // 앱 고유 색상 유지
                        .frame(width: 40, height: 40)
                    
                    Text(app.icon)
                        .font(.system(size: 20))
                }
                
                // 앱 이름과 사용시간
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(app.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        Text(app.time)
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    // 사용 비율 표시 바
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.secondaryBackgroundColor)
                                .frame(height: 4)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 2)
                                .fill(theme.primaryColor)
                                .frame(width: geometry.size.width * CGFloat(app.percentage), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
        }
    }
}

struct UsageSummaryCard: View {
    let usageData: UsageData
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("스크린 타임")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Text(usageData.totalScreenTime)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(theme.primaryTextColor)
                }
                
                // 차트
                HourlyUsageChart(data: usageData.hourlyUsage)
                    .frame(height: 96)
                    .padding(.vertical, 8)
                
                // 시간 레이블
                HStack {
                    Text("오전 6시")
                        .font(.system(size: 12))
                        .foregroundColor(theme.tertiaryTextColor)
                    
                    Spacer()
                    
                    Text("오후 12시")
                        .font(.system(size: 12))
                        .foregroundColor(theme.tertiaryTextColor)
                    
                    Spacer()
                    
                    Text("오후 6시")
                        .font(.system(size: 12))
                        .foregroundColor(theme.tertiaryTextColor)
                    
                    Spacer()
                    
                    Text("현재")
                        .font(.system(size: 12))
                        .foregroundColor(theme.tertiaryTextColor)
                }
                
                Divider()
                    .background(theme.tertiaryTextColor.opacity(0.2))
                    .padding(.vertical, 8)
                
                // 전일 대비
                HStack {
                    HStack {
                        Text("어제")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                        
                        Text("6시간 5분")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(theme.primaryTextColor)
                    }
                    
                    Spacer()
                    
                    Text("-\(usageData.comparisonWithYesterday)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.successColor)
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct CategoryBreakdownCard: View {
    let categories: [UsageCategory]
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("카테고리별 사용")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("상세보기")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(categories) { category in
                        CategoryProgressBar(category: category)
                    }
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct TopAppsCard: View {
    let apps: [AppUsage]
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("가장 많이 사용한 앱")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("모두 보기")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                }
                
                VStack(spacing: 12) {
                    ForEach(apps) { app in
                        AppUsageRow(app: app)
                    }
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

struct BlockingEffectivenessCard: View {
    let blocking: BlockingStats
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("차단 효과 분석")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        HStack(spacing: 4) {
                            Text("상세보기")
                                .font(.system(size: 14))
                                .foregroundColor(theme.primaryColor)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                }
                
                // 주요 통계 카드
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(blocking.attemptsCount)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(theme.primaryColor)
                        
                        Text("차단된 접근 시도")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.secondaryBackgroundColor)
                    .cornerRadius(theme.cornerRadius)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(blocking.timesSaved)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(theme.successColor)
                        
                        Text("절약된 시간")
                            .font(.system(size: 14))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.secondaryBackgroundColor)
                    .cornerRadius(theme.cornerRadius)
                }
                
                Divider()
                    .background(theme.tertiaryTextColor.opacity(0.2))
                    .padding(.vertical, 8)
                
                HStack {
                    Text("가장 많이 차단된 앱:")
                        .font(.system(size: 14))
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Text(blocking.mostBlocked)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                }
            }
            .padding()
            .background(theme.cardBackgroundColor)
            .cornerRadius(theme.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: theme.cornerRadius)
                    .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
            )
        }
    }
}


// 라이트 모드 프리뷰
#Preview {
    VStack(spacing: 16) {
        UsageSummaryCard(usageData: UsageData.sample)
        
        CategoryBreakdownCard(categories: UsageData.sample.categories)
        
        TopAppsCard(apps: UsageData.sample.topApps)
        
        BlockingEffectivenessCard(blocking: UsageData.sample.blocking)
    }
    .padding()
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}

// 다크 모드 프리뷰
struct InsightsComponentsDarkPreview: PreviewProvider {
    static var previews: some View {
        let themeManager = ThemeManager.shared
        
        // 다크 모드로 테마 변경
        let _ = themeManager.setTheme(id: "default.dark")
        
        return VStack(spacing: 16) {
            UsageSummaryCard(usageData: UsageData.sample)
            
            CategoryBreakdownCard(categories: UsageData.sample.categories)
            
            TopAppsCard(apps: UsageData.sample.topApps)
            
            BlockingEffectivenessCard(blocking: UsageData.sample.blocking)
        }
        .padding()
        .background(Color.black)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
    }
}
