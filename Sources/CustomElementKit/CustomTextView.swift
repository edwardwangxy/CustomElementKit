//
//  CustomTextView.swift
//
//  Created by Xiangyu Wang on 1/30/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//

import SwiftUI
import UIKit
import Foundation

public struct CustomTextView: UIViewRepresentable {

    public class Coordinator: NSObject, UITextViewDelegate {

        @Binding public var text: String
        public var didBecomeFirstResponder = false

        public init(text: Binding<String>) {
            _text = text
        }

        public func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                if textView.markedTextRange == nil || self.text == "" {
                    self.text = textView.text
                }
                
            }
            
        }

    }
    
    @Binding public var text: String
    @Binding public var acceptOnlyInteger: Bool
    @State public var dynamicResponder: Bool = false
    @Binding public var isFirstResponder: Bool
    public var textField: CustomUITextView = CustomUITextView(frame: .zero)
    
    public init(text: Binding<String>, acceptOnlyInteger: Binding<Bool>, dynamicResponder: Bool = false, isFirstResponder: Binding<Bool>) {
        self._text = text
        self._acceptOnlyInteger = acceptOnlyInteger
        self._isFirstResponder = isFirstResponder
        self.dynamicResponder = dynamicResponder
    }
    
    public func makeUIView(context: UIViewRepresentableContext<CustomTextView>) -> CustomUITextView {
        self.textField.delegate = context.coordinator
//        self.textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    public func makeCoordinator() -> CustomTextView.Coordinator {
        return Coordinator(text: self.$text)
    }

    public func updateUIView(_ uiView: CustomUITextView, context: UIViewRepresentableContext<CustomTextView>) {
        uiView.text = text
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder  {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
        if self.dynamicResponder {
            if !isFirstResponder {
                uiView.resignFirstResponder()
                context.coordinator.didBecomeFirstResponder = false
            }
        }
    }
    
}


public extension CustomTextView {
    
    func setBackground(color: UIColor) -> CustomTextView {
        let view = self
        view.textField.backgroundColor = color
        return view
    }
    
    func setFont(font: UIFont) -> CustomTextView {
        let view = self
        view.textField.font = font
        return view
    }
    
    func textColor(_ setColor: UIColor) -> CustomTextView {
        let view = self
        view.textField.textColor = setColor
        return view
    }
    
    
    func tintColor(_ setColor: UIColor) -> CustomTextView {
        let view = self
        view.textField.tintColor = setColor
        return view
    }
    
    func integerOnly() -> CustomTextView {
        let view = self
        view.acceptOnlyInteger = true
        return view
    }
    
    func customTextView(_ setTextField: (CustomUITextView) -> Void) -> CustomTextView {
        let view = self
        setTextField(view.textField)
        return view
    }
    
    func isUserInterationEnable(_ set: Bool) -> CustomTextView {
        self.textField.isUserInteractionEnabled = set
        return self
    }
    
}
