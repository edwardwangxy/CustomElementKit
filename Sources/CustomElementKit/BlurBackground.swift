//
//  BlurBackground.swift
//  
//
//  Created by Xiangyu Wang on 9/2/20.
//

import SwiftUI

public struct BlurBackground: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
