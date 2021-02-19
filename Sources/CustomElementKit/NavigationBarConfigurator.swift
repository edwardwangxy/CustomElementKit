//
//  NavigationBarConfigurator.swift
//  
//
//  Created by JIAZI XUAN on 2/18/21.
//
import SwiftUI


public struct NavigationBarConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void
    public init(configure: @escaping (UINavigationController) -> Void) {
        self.configure = configure
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationBarConfigurator>) -> UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationBarConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }

}
