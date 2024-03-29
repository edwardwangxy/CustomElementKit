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

    public class Coordinator: NSObject, UITextViewDelegate, NSLayoutManagerDelegate {
        private let parent: CustomTextView
        @Binding public var text: String
        public var didBecomeFirstResponder = false

        public init(parent: CustomTextView, text: Binding<String>) {
            _text = text
            self.parent = parent
        }
        
        public func layoutManager(_ layoutManager: NSLayoutManager, paragraphSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
            return self.parent.lineSpacing
        }

        public func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                if textView.markedTextRange == nil || self.text == "" {
                    self.text = textView.text
                }
            }
            self.parent.textEditing?(textView)
        }
        
        public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            return self.parent.onClickUrl(URL)
        }
        
        public func textViewDidBeginEditing(_ textView: UITextView) {
            self.didBecomeFirstResponder = true
        }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return self.parent.setTextViewShouldChangeChar(textView, range, text)
        }

    }
    
    @Binding public var text: String
    @Binding public var acceptOnlyInteger: Bool
    public var dynamicResponder: Bool
    @Binding public var isFirstResponder: Bool
    public var textField: CustomUITextView
    public var setTextViewShouldChangeChar: (UITextView, NSRange, String) -> Bool
    public var lineSpacing: CGFloat
    private var textEditing: ((UITextView) -> Void)?
    private var onClickUrl: (URL) -> Bool
    
    public init(text: Binding<String>, acceptOnlyInteger: Binding<Bool>, dynamicResponder: Bool = false, isFirstResponder: Binding<Bool>, lineSpacing: CGFloat = 2, textView: CustomUITextView = CustomUITextView(frame: .zero), urlClicked: @escaping (URL) -> Bool = {_ in return true}, setShouldChangeChar: @escaping (UITextView, NSRange, String) -> Bool = {_, _, _ in return true}, textEditing: ((UITextView) -> Void)?) {
        self._text = text
        self._acceptOnlyInteger = acceptOnlyInteger
        self._isFirstResponder = isFirstResponder
        self.dynamicResponder = dynamicResponder
        self.textField = textView
        self.setTextViewShouldChangeChar = setShouldChangeChar
        self.lineSpacing = lineSpacing
        self.textEditing = textEditing
        self.onClickUrl = urlClicked
    }
    
    public init(text: Binding<String>, acceptOnlyInteger: Binding<Bool>, dynamicResponder: Bool = false, isFirstResponder: Binding<Bool>, lineSpacing: CGFloat = 2, textView: CustomUITextView = CustomUITextView(frame: .zero), urlClicked: @escaping (URL) -> Bool = {_ in return true}, setShouldChangeChar: @escaping (UITextView, NSRange, String) -> Bool = {_, _, _ in return true}) {
        self._text = text
        self._acceptOnlyInteger = acceptOnlyInteger
        self._isFirstResponder = isFirstResponder
        self.dynamicResponder = dynamicResponder
        self.textField = textView
        self.setTextViewShouldChangeChar = setShouldChangeChar
        self.lineSpacing = lineSpacing
        self.textEditing = nil
        self.onClickUrl = urlClicked
    }
    
    public func makeUIView(context: UIViewRepresentableContext<CustomTextView>) -> CustomUITextView {
        self.textField.delegate = context.coordinator
        self.textField.layoutManager.delegate = context.coordinator
//        self.textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textField
    }

    public func makeCoordinator() -> CustomTextView.Coordinator {
        return Coordinator(parent: self, text: self.$text)
    }

    public func updateUIView(_ uiView: CustomUITextView, context: UIViewRepresentableContext<CustomTextView>) {
        if uiView.text != self.text {
            uiView.text = text
        }
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
