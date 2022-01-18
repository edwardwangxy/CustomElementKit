//
//  File.swift
//  
//
//  Created by Xiangyu Wang on 1/18/22.
//

import Foundation
import SwiftUI
import SafariServices

public struct CustomWebKit: UIViewControllerRepresentable {
    let controller: SFSafariViewController
    
    public init(url: URL) {
        self.controller = SFSafariViewController(url: url)
    }
    
    public func makeUIViewController(context: Context) -> SFSafariViewController {
        return self.controller
    }
    
    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}
