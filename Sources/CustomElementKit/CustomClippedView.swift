//
//  Clipped.swift
//  
//
//  Created by Xiangyu Wang on 9/27/20.
//

import Foundation
import SwiftUI
import UIKit

public struct CustomClippedView<Content: View>: UIViewRepresentable {

    var content: Content
    
    public init(@ViewBuilder builder: () -> Content) {
        self.content = builder()
    }

    public func makeUIView(context: UIViewRepresentableContext<CustomClippedView>) -> UIView {
        let view = UIView()
        let child = UIHostingController(rootView: self.content)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = view.bounds
        view.addSubview(child.view)
        view.clipsToBounds = true
        return view
    }

    public func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<CustomClippedView>) {
        
    }
}
