//
//  CustomTextField.swift
//
//  Created by Xiangyu Wang on 1/30/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//

import SwiftUI
import UIKit

public struct CustomTextField: UIViewRepresentable {
    
    public class Coordinator: NSObject, UITextFieldDelegate {

        @Binding public var text: String
        @Binding public var integerOnly: Bool
        public var didBecomeFirstResponder = false

        public init(text: Binding<String>, onlyInteger: Binding<Bool>) {
            _text = text
            _integerOnly = onlyInteger
        }

        public func textFieldDidChangeSelection(_ textField: UITextField) {
            if textField.markedTextRange == nil || self.text == "" {
                text = textField.text ?? ""
            }
        }
        
        public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if self.integerOnly {
                let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
                let compSepByCharInSet = string.components(separatedBy: aSet)
                let numberFiltered = compSepByCharInSet.joined(separator: "")
                return string == numberFiltered
            } else {
                return true
            }
        }
        
        public func textFieldDidBeginEditing(_ textField: UITextField) {
            self.didBecomeFirstResponder = true
        }

        
    }
    
    @Binding public var text: String
    @Binding public var acceptOnlyInteger: Bool
    public var dynamicResponder: Bool
    @Binding public var isSecureTextEntry: Bool
    @Binding public var isFirstResponder: Bool
    public var textField: CustomUITextField = CustomUITextField(frame: .zero)
    
    public init(text: Binding<String>, acceptOnlyInteger: Binding<Bool>, dynamicResponder: Bool = false, isSecureTextEntry: Binding<Bool>, isFirstResponder: Binding<Bool>, textField: CustomUITextField = CustomUITextField(frame: .zero)) {
        self._text = text
        self._acceptOnlyInteger = acceptOnlyInteger
        self.dynamicResponder = dynamicResponder
        self._isSecureTextEntry = isSecureTextEntry
        self._isFirstResponder = isFirstResponder
        self.textField = textField
    }
    
    public func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> CustomUITextField {
        self.textField.delegate = context.coordinator
        self.textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    public func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text, onlyInteger: self.$acceptOnlyInteger)
    }

    public func updateUIView(_ uiView: CustomUITextField, context: UIViewRepresentableContext<CustomTextField>) {
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
        uiView.isSecureTextEntry = self.isSecureTextEntry
    }
    
}


public extension CustomTextField {
    
    func setFont(font: UIFont) -> CustomTextField {
        let view = self
        view.textField.font = font
        return view
    }
    
    func numberPadOnly() -> CustomTextField {
        let view = self
        view.textField.keyboardType = .numberPad
        return view
    }
    
    func placeholder(_ placeholder: String) -> CustomTextField {
        let view = self
        view.textField.placeholder = placeholder
        return view
    }
    
    func textColor(_ setColor: UIColor) -> CustomTextField {
        let view = self
        view.textField.textColor = setColor
        return view
    }
    
    func adjustsFontSizeToFitWidth() -> CustomTextField {
        let view = self
        view.textField.adjustsFontSizeToFitWidth = true
        return view
    }
    
    func minimumFontSize(_ setSize: CGFloat) -> CustomTextField {
        let view = self
        view.textField.minimumFontSize = setSize
        return view
    }
    
    func tintColor(_ setColor: UIColor) -> CustomTextField {
        let view = self
        view.textField.tintColor = setColor
        return view
    }
    
    func isEnable(_ set: Bool) -> CustomTextField {
        let view = self
        view.textField.isEnabled = set
        return view
    }
    
    func integerOnly() -> CustomTextField {
        let view = self
        view.acceptOnlyInteger = true
        return view
    }
    
    func customTextView(_ setTextField: (CustomUITextField) -> Void) -> CustomTextField {
        let view = self
        setTextField(view.textField)
        return view
    }
    
    func isUserInterationEnable(_ set: Bool) -> CustomTextField {
        self.textField.isUserInteractionEnabled = set
        return self
    }
    
}
