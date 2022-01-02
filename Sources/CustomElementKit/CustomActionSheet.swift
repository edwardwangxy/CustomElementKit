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
    func customActionSheet(isPresented: Binding<Bool>, title: String? = nil, message: String? = nil, actionButtons: [CustomActionSheet.ActionButton], presentComplete: (() -> Void)? = nil, dismissComplete: (() -> Void)? = nil) -> some View {
        return self
            .background(
                CustomActionSheet(title: title, message: message, actionButtons: actionButtons, presentComplete: presentComplete, dismissComplete: dismissComplete, isPresented: isPresented)
            )
    }
}

public struct CustomActionSheet: UIViewControllerRepresentable {
    let alertController: UIAlertController
    var presentComplete: (() -> Void)?
    var dismissComplete: (() -> Void)?
    @Binding var isPresented: Bool
    
    init(title: String?, message: String?, actionButtons: [ActionButton], presentComplete: (() -> Void)?, dismissComplete: (() -> Void)?, isPresented: Binding<Bool>) {
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for eachBtn in actionButtons {
            self.alertController.addAction(eachBtn.generateButton {
                isPresented.wrappedValue = false
            })
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
            uiViewController.present(self.alertController, animated: true, completion: {
                let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.dismissAlertController))
                self.alertController.view.superview?.subviews[0].addGestureRecognizer(tapGesture)
                self.presentComplete?()
            })
        } else {
            uiViewController.presentedViewController?.dismiss(animated: true, completion: {
                self.isPresented = false
                self.dismissComplete?()
            })
        }
    }
    
    public struct ActionButton {
        let title: String
        let image: UIImage?
        let style: UIAlertAction.Style
        let handler: (() -> Void)?
        
        init(title: String, image: UIImage? = nil, style: UIAlertAction.Style, handler: (() -> Void)?) {
            self.title = title
            self.image = image
            self.style = style
            self.handler = handler
        }
        
        func generateButton(preAction: @escaping () -> Void) -> UIAlertAction {
            let btn = UIAlertAction(title: self.title, style: self.style) { _ in
                preAction()
                self.handler?()
            }
            btn.setValue(self.image, forKey: "image")
            return btn
        }
        
        public static func `default`(title: String, image: UIImage? = nil, handler: (() -> Void)? = nil) -> ActionButton {
            return ActionButton(title: title, image: image, style: .default, handler: handler)
        }
        
        public static func destructive(title: String, image: UIImage? = nil, handler: (() -> Void)? = nil) -> ActionButton {
            return ActionButton(title: title, image: image, style: .destructive, handler: handler)
        }
        
        public static func cancel(title: String, image: UIImage? = nil, handler: (() -> Void)? = nil) -> ActionButton {
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
        
        @objc func dismissAlertController(){
            self.parent.isPresented = false
        }
        
    }
    
}

