//
//  File.swift
//  
//
//  Created by JIAZI XUAN on 8/31/21.
//

import Foundation
import SwiftUI

public struct CustomAttributedText: UIViewRepresentable {
    fileprivate var configuration = { (view: UILabel) in }

    public init(config: @escaping (UILabel) -> Void = {_ in}) {
        self.configuration = config
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow,
                                        for: .vertical)
        return label
    }
    
    public func updateUIView(_ uiView: UILabel, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}

public struct CustomAttributedTextView: UIViewRepresentable {
    fileprivate var configuration = { (view: UITextView) in }
    private var isEditable: Bool
    private var isSelectable: Bool
    
    public init(isEditable: Bool = false, isSelectable: Bool = false, config: @escaping (UITextView) -> Void = {_ in}) {
        self.configuration = config
        self.isEditable = isEditable
        self.isSelectable = isSelectable
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let label = UITextView()
        label.backgroundColor = .clear
        label.isEditable = self.isEditable
        label.isSelectable = self.isSelectable
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow,
                                        for: .vertical)
        return label
    }
    
    public func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        configuration(uiView)
    }
}

