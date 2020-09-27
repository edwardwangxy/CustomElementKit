//
//  Clipped.swift
//  
//
//  Created by Xiangyu Wang on 9/27/20.
//

import Foundation
import SwiftUI
import UIKit

public struct CustomClippedView<Content: View>: UIViewControllerRepresentable {

    var content: () -> Content
    
    public init(@ViewBuilder builder: @escaping () -> Content) {
        self.content = builder
    }
    
    public func makeUIViewController(context: Context) -> UIHostingController<Content> {
        UIHostingController(rootView: self.content())
    }
    
    public func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: Context) {
        uiViewController.rootView = self.content()
    }
}
