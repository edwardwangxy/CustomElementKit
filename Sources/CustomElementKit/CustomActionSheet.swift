//
//  CustomActionSheet.swift
//  
//
//  Created by Xiangyu Wang on 1/2/22.
//

import Foundation

import SwiftUI
import Combine

public extension View {
    func customActionSheet<Content: View>(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil, actionButtons: [CustomActionSheet<Content>.ActionButton], presentComplete: (() -> Void)? = nil, dismissComplete: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        return self
            .background(
                CustomActionSheet(title: title, message: message, actionButtons: actionButtons, presentComplete: presentComplete, dismissComplete: dismissComplete, isPresented: isPresented)
            )
    }
}

public struct CustomActionSheet<Content: View>: UIViewControllerRepresentable {
    let alertController: UIAlertController
    var presentComplete: (() -> Void)?
    var dismissComplete: (() -> Void)?
    @Binding var isPresented: Bool
    
    init(title: String?, message: String?, actionButtons: [ActionButton], presentComplete: (() -> Void)?, dismissComplete: (() -> Void)?, isPresented: Binding<Bool>) {
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for eachBtn in actionButtons {
            self.alertController.addAction(eachBtn.button)
        }
        self.presentComplete = presentComplete
        self.dismissComplete = dismissComplete
        self._isPresented = isPresented
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> UIViewController {
        
        return UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if self.isPresented {
            uiViewController.present(self.alertController, animated: true, completion: self.presentComplete)
            self.alertController.presentationController?.delegate = context.coordinator
        } else {
            uiViewController.presentedViewController?.dismiss(animated: true, completion: {
                self.isPresented = false
                self.dismissComplete?()
            })
        }
    }
    
    public struct ActionButton {
        let button: UIAlertAction
        
        init(title: String, image: UIImage? = nil, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)?) {
            let btn = UIAlertAction(title: title, style: style, handler: handler)
            if let getImage = image {
                btn.setValue(getImage, forKey: "image")
            }
            self.button = btn
        }
        
        static func `default`(title: String, image: UIImage? = nil, handler: ((UIAlertAction) -> Void)? = nil) -> ActionButton {
            return ActionButton(title: title, image: image, style: .default, handler: handler)
        }
        
        static func destructive(title: String, image: UIImage? = nil, handler: ((UIAlertAction) -> Void)? = nil) -> ActionButton {
            return ActionButton(title: title, image: image, style: .destructive, handler: handler)
        }
        
        static func cancel(title: String, image: UIImage? = nil, handler: ((UIAlertAction) -> Void)? = nil) -> ActionButton {
            return ActionButton(title: title, image: image, style: .cancel, handler: handler)
        }
    }
    
    public class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        let parent: CustomActionSheet
        init(parent: CustomActionSheet) {
            self.parent = parent
        }
        
        public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            self.parent.isPresented = false
        }
        
    }
    
}

