//
//  CustomSheet.swift
//
//
//  Created by Edward Wang on 8/18/21.
//

import SwiftUI
import Combine

public extension View {
    func customSheet<Content: View>(isPresented: Binding<Bool>, withBackground: Bool = true, animated: Bool = true, canDragDismiss: Bool = true, style: UIModalPresentationStyle = .automatic, transition: UIModalTransitionStyle = .coverVertical, attemptDismiss: (() -> Void)? = nil, presentComplete: (() -> Void)? = nil, dismissComplete: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) -> some View {
        return self
            .background(
                CustomSheet(content: content, withBackgroundCover: withBackground, animated: animated, canDragDismiss: canDragDismiss, style: style, transition: transition, attemptDismiss: attemptDismiss, presentComplete: presentComplete, dismissComplete: dismissComplete, isPresented: isPresented)
            )
    }
}

struct CustomSheet<Content: View>: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    let content: () -> Content
    let style: UIModalPresentationStyle
    let transition: UIModalTransitionStyle
    let withBackgroundCover: Bool
    var animated: Bool
    var canDragDismiss: Bool
    var attemptDismiss: (() -> Void)?
    var presentComplete: (() -> Void)?
    var dismissComplete: (() -> Void)?
    @Binding var isPresented: Bool
    
    init(content: @escaping () -> Content, withBackgroundCover: Bool, animated: Bool, canDragDismiss: Bool, style: UIModalPresentationStyle, transition: UIModalTransitionStyle, attemptDismiss: (() -> Void)?, presentComplete: (() -> Void)?, dismissComplete: (() -> Void)?, isPresented: Binding<Bool>) {
        self.withBackgroundCover = withBackgroundCover
        self.content = content
        self.style = style
        self.transition = transition
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
            let hc = UIHostingController(rootView: self.content())
            hc.view.backgroundColor = .clear
            let sheet = UINavigationController(rootViewController: hc)
            sheet.modalPresentationStyle = self.style
            sheet.modalTransitionStyle = self.transition
            sheet.view.backgroundColor = .clear
            if self.withBackgroundCover {
                uiViewController.present(sheet, animated: self.animated, completion: {
                    UIView.animate(withDuration: 0.15) {
                        sheet.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                    }
                    self.presentComplete?()
                })
                context.coordinator.presetedSheet = sheet
            } else {
                uiViewController.present(sheet, animated: self.animated, completion: self.presentComplete)
            }
            sheet.presentationController?.delegate = context.coordinator
            
        } else {
            if let getSheet = context.coordinator.presetedSheet {
                UIView.animate(withDuration: 0.15) {
                    getSheet.view.backgroundColor = .clear
                } completion: { _ in
                    uiViewController.presentedViewController?.dismiss(animated: self.animated, completion: self.dismissComplete)
                }
            } else {
                uiViewController.presentedViewController?.dismiss(animated: self.animated, completion: self.dismissComplete)
            }
        }
    }
    
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        let parent: CustomSheet
        var presetedSheet: UINavigationController?
        
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

