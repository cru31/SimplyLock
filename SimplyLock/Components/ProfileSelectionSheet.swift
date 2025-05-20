//
//  ProfileSelectionSheet.swift
//  SimplyLock
//
//  Created by Duk-Jun Kim on 5/20/25.
//


import SwiftUI

/// 프로필 선택 시트 뷰
struct ProfileSelectionSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var blockManager: BlockManager
    @Environment(\.themeManager) private var themeManager
    
    var onSelectProfile: (BlockProfile) -> Void
    
    var body: some View {
        withTheme { theme in
            NavigationView {
                List {
                    ForEach(blockManager.profiles, id: \.id) { profile in
                        Button(action: {
                            onSelectProfile(profile)
                            isPresented = false
                        }) {
                            HStack(spacing: 14) {
                                // 프로필 아이콘
                                ZStack {
                                    Circle()
                                        .fill(theme.primaryColor.opacity(0.1))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "lock.shield")
                                        .font(.system(size: 18))
                                        .foregroundColor(theme.primaryColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(profile.name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(theme.primaryTextColor)
                                    
                                    Text("차단 대상: \(profile.selection.applicationTokens.count)개 앱, \(profile.selection.webDomainTokens.count)개 웹사이트")
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.secondaryTextColor)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(theme.tertiaryTextColor)
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    if blockManager.profiles.isEmpty {
                        VStack(spacing: 12) {
                            Text("등록된 프로필이 없습니다")
                                .font(.system(size: 16))
                                .foregroundColor(theme.secondaryTextColor)
                                .padding(.top, 30)
                            
                            Text("설정 탭에서 새 프로필을 추가해주세요")
                                .font(.system(size: 14))
                                .foregroundColor(theme.tertiaryTextColor)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .background(theme.backgroundColor.ignoresSafeArea())
                .navigationTitle("프로필 선택")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("취소") {
                            isPresented = false
                        }
                    }
                }
            }
        }
    }
}
