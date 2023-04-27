//
//  ShareSheet.swift
//  PrivacyKeyboard
//
//  Created by Xiangyu Wang on 1/20/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//

import SwiftUI
import UIKit

public struct ShareSheet: UIViewControllerRepresentable {
    public typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    public var shareTitle: String
    public var shareDescription: String
    public var shareLink: String
    public var shareImage: UIImage?
    public var applicationActivities: [UIActivity]? = nil
    public var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    public var setActivityItemList: [Any] = [Any]()
    public var callback: Callback? = {(shareType, complete, _, _) in
        if complete {
            print("share complete with \(shareType?.rawValue ?? "unknown")")
        }
    }
    
    public init(shareTitle: String, shareDescription: String, shareLink: String, shareImage: UIImage? = nil, applicationActivities: [UIActivity]? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil, activityItemList: [Any] = [Any](), callback: @escaping Callback = {(shareType, complete, _, _) in
        if complete {
            print("share complete with \(shareType?.rawValue ?? "unknown")")
        }
    }) {
        self.shareTitle = shareTitle
        self.shareDescription = shareDescription
        self.shareLink = shareLink
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.setActivityItemList = activityItemList
        let shareLinkURL = URL(string: self.shareLink)
        if self.setActivityItemList.count == 0, let getShareLink = shareLinkURL {
            self.setActivityItemList.append(getShareLink as Any)
        }
        self.setActivityItemList.append(self.shareTitle + "\n" + self.shareDescription)
        if let theImage = self.shareImage {
            self.setActivityItemList.append(theImage)
        }
        self.callback = callback
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        var activityItemList: [Any] = [self.shareTitle + "\n" + self.shareDescription] + self.setActivityItemList
        // If you want to put an image
        if let theImage = shareImage {
            activityItemList.append(theImage as Any)
        }
        
        let controller : UIActivityViewController = UIActivityViewController(
            activityItems: activityItemList, applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}

