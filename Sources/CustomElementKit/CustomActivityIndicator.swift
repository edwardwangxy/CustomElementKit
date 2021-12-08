//
//  CustomActivityIndicator.swift
//  SPN
//
//  Created by Xiangyu Wang on 5/12/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//

import SwiftUI
import UIKit

public struct CustomActivityIndicator: UIViewRepresentable {

    @Binding public var isAnimating: Bool
    public let style: UIActivityIndicatorView.Style
    let color: UIColor?
    
    public init(isAnimating: Binding<Bool> = .constant(true), style: UIActivityIndicatorView.Style, color: UIColor? = nil) {
        self._isAnimating = isAnimating
        self.style = style
        self.color = color
    }

    public func makeUIView(context: UIViewRepresentableContext<CustomActivityIndicator>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: self.style)
        if let getColor = self.color {
            indicator.color = getColor
        }
        return indicator
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<CustomActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

