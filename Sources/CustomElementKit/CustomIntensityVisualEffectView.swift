//
//  CustomIntensityVisualEffectView.swift
//  WeightLossTrainer
//
//  Created by Xiangyu Wang on 8/8/24.
//

import Foundation
import UIKit
import SwiftUI

public class CustomIntensityVisualEffectUIView: UIVisualEffectView {
    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    public init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator.fractionComplete = intensity
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public func updateIntensity(_ intensity: CGFloat) {
        animator.fractionComplete = intensity
    }

    // MARK: Private
    private var animator: UIViewPropertyAnimator!

}

public struct CustomIntensityVisualEffectView: View {
    let effect: UIVisualEffect
    @Binding var intensity: CGFloat
    
    public init(effect: UIVisualEffect, intensity: Binding<CGFloat>) {
        self.effect = effect
        self._intensity = intensity
    }
    
    public var body: some View {
        Color.clear
            .modifier(CustomIntensityBGModifier(effect: self.effect, intensity: self.intensity))
    }
}

struct CustomIntensityBGModifier: AnimatableModifier {
    let effect: UIVisualEffect
    var intensity: CGFloat
    
    var animatableData: CGFloat {
        get {
            return self.intensity
        }
        set {
            self.intensity = newValue
            print(newValue)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .background(CustomIntensityVisualEffectViewWrapper(effect: effect, intensity: intensity))
    }
}

struct CustomIntensityVisualEffectViewWrapper: UIViewRepresentable, Animatable {
    let effect: UIVisualEffect
    var intensity: CGFloat
    
    func makeUIView(context: Context) -> CustomIntensityVisualEffectUIView {
        return CustomIntensityVisualEffectUIView(effect: self.effect, intensity: self.intensity)
    }
    
    func updateUIView(_ uiView: CustomIntensityVisualEffectUIView, context: Context) {
        uiView.updateIntensity(self.intensity)
    }
}

