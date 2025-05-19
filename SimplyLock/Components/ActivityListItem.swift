import SwiftUI

struct ActivityListItem: View {
    let activity: Activity
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            HStack(spacing: 12) {
                // 활동 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: theme.cornerRadius / 1.5)
                        .fill(activity.iconBackgroundColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: activity.iconName)
                        .font(.system(size: 18))
                        .foregroundColor(activity.iconBackgroundColor)
                }
                
                // 활동 내용 및 시간
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.primaryTextColor)
                    
                    Text(activity.time)
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryTextColor)
                }
                
                Spacer()
                
                // 상태 표시 (있는 경우)
                if let status = activity.status {
                    Text(status.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status.color.opacity(0.2))
                        .foregroundColor(status.color)
                        .cornerRadius(theme.cornerRadius / 2)
                }
            }
            .padding(.horizontal, 16) 
            .padding(.vertical, 12)
        }
    }
}

struct ActivityList: View {
    let activities: [Activity]
    let title: String
    var seeAllAction: (() -> Void)? = nil
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        withTheme { theme in
            VStack(alignment: .leading, spacing: 12) {
                if !title.isEmpty {
                    HStack {
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(theme.primaryTextColor)
                        
                        Spacer()
                        
                        if let action = seeAllAction {
                            Button(action: action) {
                                HStack(spacing: 4) {
                                    Text("모두 보기")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(theme.primaryColor)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.primaryColor)
                                }
                            }
                        }
                    }
                }
                
                VStack(spacing: 0) {
                    ForEach(activities) { activity in
                        ActivityListItem(activity: activity)
                        
                        if activity.id != activities.last?.id {
                            Divider()
                                .background(theme.tertiaryTextColor.opacity(0.3))
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .fill(theme.cardBackgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius)
                        .stroke(theme.tertiaryTextColor.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    VStack {
        ActivityList(
            activities: Activity.samples,
            title: "최근 활동",
            seeAllAction: {}
        )
        .padding()
        
        ActivityList(
            activities: Activity.sessionHistory.prefix(3).map { $0 },
            title: "세션 기록",
            seeAllAction: {}
        )
        .padding()
    }
    .background(Color(.systemGray6))
    .environmentObject(ThemeManager.shared)
}
