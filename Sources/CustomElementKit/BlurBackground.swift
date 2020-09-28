//
//  BlurBackground.swift
//  
//
//  Created by Xiangyu Wang on 9/2/20.
//

import SwiftUI

public struct BlurBackground: UIViewRepresentable {
    var style: UIBlurEffect.Style
    var blurPercent: CGFloat
    let blurAnimator = UIViewPropertyAnimator()
    let blur = UIVisualEffectView()
    public init(style: UIBlurEffect.Style, blurPercent: CGFloat = 1) {
        self.style = style
        self.blurPercent = blurPercent
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        self.blurAnimator.addAnimations {
            self.blur.effect = UIBlurEffect(style: self.style)
        }
        self.blurAnimator.fractionComplete = self.blurPercent
//        self.blurAnimator.stopAnimation(true)
//        self.blurAnimator.finishAnimation(at: .current)
        return self.blur
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        if self.blurAnimator.state != .inactive {
            self.blurAnimator.stopAnimation(true)
            self.blurAnimator.finishAnimation(at: .current)
        }
    }
}
