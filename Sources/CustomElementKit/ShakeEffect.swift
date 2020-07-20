//
//  ShakeEffect.swift
//  meetyourx
//
//  Created by Xiangyu Wang on 7/5/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//

import SwiftUI

public struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    public var animatableData: CGFloat

    public func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
