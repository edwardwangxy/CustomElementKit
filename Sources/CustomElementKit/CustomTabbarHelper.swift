//
//  File.swift
//  
//
//  Created by JIAZI XUAN on 2/6/21.
//
import SwiftUI

public struct CustomTabbarHelper: UIViewControllerRepresentable {
    public var callback: (UITabBar) -> Void
    private let proxyController = ViewController()
    
    public init(setCallback: @escaping (UITabBar) -> Void) {
        self.callback = setCallback
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<CustomTabbarHelper>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomTabbarHelper>) {
    }

    public typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let tabBar = self.tabBarController {
                self.callback(tabBar.tabBar)
            }
        }
    }
}
