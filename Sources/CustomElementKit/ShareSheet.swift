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
    public var callback: Callback? = {(shareType, complete, _, _) in
        if complete {
            print("share complete with \(shareType?.rawValue ?? "unknown")")
        }
    }
    
    public init(shareTitle: String, shareDescription: String, shareLink: String, shareImage: UIImage? = nil, applicationActivities: [UIActivity]? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil, callback: @escaping Callback = {(shareType, complete, _, _) in
        if complete {
            print("share complete with \(shareType?.rawValue ?? "unknown")")
        }
    }) {
        self.shareTitle = shareTitle
        self.shareDescription = shareDescription
        self.shareLink = shareLink
        self.applicationActivities = applicationActivities
        self.excludedActivityTypes = excludedActivityTypes
        self.callback = callback
    }
    
    public func makeUIViewController(context: Context) -> UIActivityViewController {
        let shareLinkURL = URL(string: self.shareLink)
        let activityItemList: [Any] = [shareLinkURL as Any]  //[self.shareTitle + "\n" + self.shareDescription, shareLinkURL as Any]
        // If you want to put an image
//        if let theImage = shareImage {
//            activityItemList.append(theImage)
//        }
        
        
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

