//
//  File.swift
//  CustomElementKit
//
//  Created by Xiangyu Wang on 4/1/25.
//

import Foundation
import UIKit
import StoreKit

public class ReviewController {
    public static var saveReview: ((String?, Bool, Int, String?) -> Void)? = nil
    
    public static func requestReview(limit: Bool = true, step: Int = 0, note: String? = nil, customVC: UIViewController? = nil, complete: @escaping () -> Void = {}) {
        if !UserDefaults.standard.bool(forKey: "RequestReview") || !limit {
            self.requestReviewInCurrentScene(step: step, note: note, customVC: customVC, complete: complete)
        } else {
            complete()
        }
    }
    
    public static func updateReviewAlertAppName(_ name: String) {
        self.appName = name
    }
    
    public static var appName: String = "AppName"
    
    public static func requestReviewInCurrentScene(step: Int = 0, note: String? = nil, customVC: UIViewController? = nil, complete: @escaping () -> Void = {}) {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            if let rootVC = (customVC ?? scene.windows.first?.rootViewController) {
                let topAlert = UIAlertController(title: NSLocalizedString("Enjoying \(ReviewController.appName)?", tableName: "UIBase", comment: "ReviewCheckAlertTitle"), message: NSLocalizedString("Hi there! We’d love to know if you’re having a great experience.", tableName: "UIBase", comment: "ReviewCheckAlertMsg"), preferredStyle: .alert)
                topAlert.addAction(UIAlertAction(title: NSLocalizedString("😥 Not Really", comment: "ReviewCheckAlertNo"), style: .default, handler: { _ in
                    let secondAlert = UIAlertController(title: NSLocalizedString("We’re sorry you’re not having a good time with \(ReviewController.appName).", tableName: "UIBase", comment: "ReviewCheckAlert2Title"), message: NSLocalizedString("Would you like to let us know how we can improve your experience? ", tableName: "UIBase", comment: "ReviewCheckAlert2Msg"), preferredStyle: .alert)
                    secondAlert.addAction(UIAlertAction(title: NSLocalizedString("Send feedback", tableName: "UIBase", comment: "ReviewCheckAlert2SendFeedback"), style: .default, handler: { _ in
                        let thirdAlert = UIAlertController(title: NSLocalizedString("Thanks for your feedback!", tableName: "UIBase", comment: "ReviewCheckAlert3Title"), message: nil, preferredStyle: .alert)
                        thirdAlert.addTextField { textField in
                            textField.placeholder = NSLocalizedString("feedback", tableName: "UIBase", comment: "ReviewCheckAlert3Placeholder")
                        }
                        thirdAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", tableName: "UIBase", comment: "ReviewCheckAlert3OK"), style: .default, handler: { _ in
                            ReviewController.saveReview?(thirdAlert.textFields?.first?.text, false, step, note)
                            UserDefaults.standard.set(true, forKey: "RequestReview")
                            complete()
                        }))
                        rootVC.present(thirdAlert, animated: true)
                    }))
                    secondAlert.addAction(UIAlertAction(title: NSLocalizedString("Maybe later", tableName: "UIBase", comment: "ReviewCheckAlert2MaybeLater"), style: .default, handler: { _ in
                        ReviewController.saveReview?("Maybe-Later", false, step, note)
                        complete()
                    }))
                    rootVC.present(secondAlert, animated: true)
                }))
                topAlert.addAction(UIAlertAction(title: NSLocalizedString("🥰 Yes", tableName: "UIBase", comment: "ReviewCheckAlertYes"), style: .default, handler: { _ in
                    SKStoreReviewController.requestReview(in: scene)
                    ReviewController.saveReview?(nil, true, step, note)
                    UserDefaults.standard.set(true, forKey: "RequestReview")
                    complete()
                }))
                rootVC.present(topAlert, animated: true)
            }
        }
    }
}

