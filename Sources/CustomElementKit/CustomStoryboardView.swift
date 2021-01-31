//
//  CustomStoryboardView.swift
//  FunnyChat
//
//  Created by JIAZI XUAN on 1/31/21.
//

import Foundation
import SwiftUI

public struct CustomStoryboardView: UIViewControllerRepresentable {

    let storyboard: UIStoryboard
    
    public init(name: String, bundle: Bundle?) {
        self.storyboard = UIStoryboard(name: name, bundle: bundle)
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        if let vc = self.storyboard.instantiateInitialViewController() {
            return vc
        } else {
            return UIViewController()
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
       
    }
}
