//
//  File.swift
//
//
//  Created by JIAZI XUAN on 2/6/21.
//
import SwiftUI

public struct CustomUIPickerHelper: UIViewControllerRepresentable {
    public var callback: (UIPickerView) -> Void
    private let proxyController = ViewController()
    
    public init(setCallback: @escaping (UIPickerView) -> Void) {
        self.callback = setCallback
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<CustomUIPickerHelper>) ->
                              UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<CustomUIPickerHelper>) {
    }

    public typealias UIViewControllerType = UIViewController

    private class ViewController: UIViewController {
        var callback: (UIPickerView) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let getPicker = self.view.enclosingUIPickerView() {
                self.callback(getPicker)
            }
        }
    }
}

public extension UIView {
    func enclosingUIPickerView() -> UIPickerView? {
        var next: UIView? = self
        repeat {
            next = next?.superview
            if let picker = next as? UIPickerView {
                return picker
            }
        } while next != nil
        return nil
    }
}


