//
//  SwiftUIView.swift
//  
//
//  Created by Xiangyu Wang on 12/3/21.
//

import SwiftUI

public struct CustomOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue: CGFloat = .zero
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

public struct CustomScrollView<Content: View>: View {
    
    let axes: Axis.Set
    let showsIndicators: Bool
    let content: Content
    let offsetChange: (CGFloat) -> Void
    let spaceName: String = UUID().uuidString
    
    public init(_ axes: Axis.Set = .vertical, showsIndicators: Bool = false, offsetChange: @escaping (CGFloat) -> Void = {_ in}, content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content()
        self.offsetChange = offsetChange
    }
    
    public var body: some View {
        ScrollView(self.axes, showsIndicators: self.showsIndicators) {
            GeometryReader { proxy in
                Color.clear
                    .preference(
                        key: CustomOffsetPreferenceKey.self,
                        value: self.axes == .vertical ? proxy.frame(in: .named(self.spaceName)).minY : proxy.frame(in: .named(self.spaceName)).minX
                    )
            }
            .frame(height: 0)
            self.content
        }
        .coordinateSpace(name: self.spaceName)
        .onPreferenceChange(CustomOffsetPreferenceKey.self, perform: self.offsetChange)
    }
}


