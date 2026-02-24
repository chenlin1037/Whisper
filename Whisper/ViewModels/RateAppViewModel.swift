//
//  RateAppViewModel.swift
//  Whisper
//
//  Created by luckly on 2026/2/23.
//


import SwiftUI
import StoreKit

@MainActor
class RateAppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedRating: Int = 0
    @Published var showThankYou:  Bool = false
    
    // MARK: - Dependencies
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Logic
    
    func submitReview(requestReviewAction: RequestReviewAction) {
        recordReviewCompleted()
        
        // 3. 如果评分 >= 4，触发系统评价弹窗
        if selectedRating >= 4 {
            requestReviewAction()
        }
        
        // 4. 显示感谢页面
        withAnimation {
            showThankYou = true
        }
    }
    
    // 记录评价状态
    private func recordReviewCompleted() {
        userDefaults.set(true, forKey: "has_reviewed")
        userDefaults.set(Date(), forKey: "last_review_date")
    }
    
    // 检查是否应该主动弹出评价提示（可选逻辑）
    static func shouldRequestReview() -> Bool {
        let count = UserDefaults.standard.integer(forKey: "app_launch_count")
        let alreadyReviewed = UserDefaults.standard.bool(forKey: "has_reviewed")
        return count >= 3 && !alreadyReviewed
    }
}
