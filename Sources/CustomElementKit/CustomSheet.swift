//
//  CustomSheet.swift
//
//
//  Created by Edward Wang on 8/18/21.
//

import SwiftUI
import Combine

public extension View {
    func customSheet<Content: View>(isPresented: Binding<Bool>, animated: Bool = true, canDragDismiss: Bool = true, style: UIModalPresentationStyle = .automatic, transition: UIModalTransitionStyle = .coverVertical, attemptDismiss: (() -> Void)? = nil, presentComplete: (() -> Void)? = nil, dismissComplete: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        return self
            .background(
                CustomSheet(content: content, animated: animated, canDragDismiss: canDragDismiss, style: style, transition: transition, attemptDismiss: attemptDismiss, presentComplete: presentComplete, dismissComplete: dismissComplete, isPresented: isPresented)
            )
    }
}

struct CustomSheet<Content: View>: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    let sheet: UINavigationController
    var animated: Bool
    var canDragDismiss: Bool
    var attemptDismiss: (() -> Void)?
    var presentComplete: (() -> Void)?
    var dismissComplete: (() -> Void)?
    @Binding var isPresented: Bool
    
    init(content: @escaping () -> Content, animated: Bool, canDragDismiss: Bool, style: UIModalPresentationStyle, transition: UIModalTransitionStyle, attemptDismiss: (() -> Void)?, presentComplete: (() -> Void)?, dismissComplete: (() -> Void)?, isPresented: Binding<Bool>) {
        let hc = UIHostingController(rootView: content())
        hc.view.backgroundColor = .clear
        self.sheet = UINavigationController(rootViewController: hc)
        self.sheet.modalPresentationStyle = style
        self.sheet.modalTransitionStyle = transition
        self.sheet.view.backgroundColor = .clear
        self.animated = animated
        self.canDragDismiss = canDragDismiss
        self.presentComplete = presentComplete
        self.dismissComplete = dismissComplete
        self.attemptDismiss = attemptDismiss
        self._isPresented = isPresented
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        return UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if self.isPresented {
            self.sheet.presentationController?.delegate = context.coordinator
            uiViewController.present(self.sheet, animated: self.animated, completion: self.presentComplete)
        } else {
            uiViewController.presentedViewController?.dismiss(animated: self.animated, completion: dismissComplete)
        }
    }
    
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        let parent: CustomSheet
        init(parent: CustomSheet) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            self.parent.isPresented = false
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            return self.parent.canDragDismiss
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            self.parent.attemptDismiss?()
        }
    }
    
}

