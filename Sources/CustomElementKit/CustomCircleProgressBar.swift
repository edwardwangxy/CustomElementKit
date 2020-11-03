//
//  CustomCircleProgressBar.swift
//  themeapp
//
//  Created by Xiangyu Wang on 11/2/20.
//

import SwiftUI

public struct CustomCircleProgressBar: View {
    @Binding var progress: Double
    @State var lineWidth: CGFloat = 10
    @State var color: Color = Color.red
    @State var needPercent: Bool = false
    @State var textFont: Font = Font.system(size: 10, weight: .bold, design: .rounded)
    @State var textColor: Color = Color.black
    
    public init(progress: Binding<Double>, lineWidth: CGFloat = 10, color: Color = Color.red, needPercent: Bool = false, textFont: Font = Font.system(size: 10, weight: .bold, design: .rounded), textColor: Color = Color.black) {
        self._progress = progress
        self.lineWidth = lineWidth
        self.color = color
        self.needPercent = needPercent
        self.textFont = textFont
        self.textColor = textColor
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: self.lineWidth)
                .opacity(0.3)
                .foregroundColor(self.color)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: self.lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(self.color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            if self.needPercent {
                Text(String(format: "%.0f %%", min(self.progress, 1.0)*100.0))
                    .font(self.textFont)
                    .foregroundColor(self.textColor)
            }
            
        }
    }
}

