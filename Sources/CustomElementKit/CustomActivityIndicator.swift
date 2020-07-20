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
    
    public init(isAnimating: Binding<Bool>, style: UIActivityIndicatorView.Style) {
        self._isAnimating = isAnimating
        self.style = style
    }

    public func makeUIView(context: UIViewRepresentableContext<CustomActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<CustomActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

