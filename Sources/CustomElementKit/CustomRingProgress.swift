//
//  SwiftUIView.swift
//  
//
//  Created by Xiangyu Wang on 11/29/21.
//

import SwiftUI

struct CustomRingProgress: View {
    let lineWidth: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    @Binding var completePercent: Double
    
    init(percent: Binding<Double>, lineWidth: CGFloat, backgroundColor: Color, foregroundColor: Color) {
        self._completePercent = percent
        self.lineWidth = lineWidth
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(self.backgroundColor, lineWidth: self.lineWidth)
            Circle()
                .trim(from: 0, to: self.completePercent)
                .stroke(self.foregroundColor, lineWidth: self.lineWidth)
                .rotationEffect(Angle(degrees: -90))
        }
    }
}

struct CustomRingProgress_Previews: PreviewProvider {
    static var previews: some View {
        CustomRingProgress(percent: .constant(0.5), lineWidth: 4, backgroundColor: .gray, foregroundColor: .blue)
            .frame(width: 50, height: 50, alignment: .center)
    }
}
