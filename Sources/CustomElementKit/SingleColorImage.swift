//
//  SingleColorImage.swift
//  SPN
//
//  Created by Xiangyu Wang on 4/14/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//
//


import SwiftUI

public struct SingleColorImage: View {
    public var image: Image
    public var backgroundColor: Color
    public var size: CGSize
    public var alignment: Alignment
    
    public init(image: Image, backgroundColor: Color, size: CGSize, alignment: Alignment = .center) {
        self.image = image
        self.backgroundColor = backgroundColor
        self.size = size
        self.alignment = alignment
    }
    
    public var body: some View {
        Rectangle()
            .foregroundColor(self.backgroundColor)
            .frame(width: self.size.width, height: self.size.height)
        .mask(
            self.image
                .renderingMode(.original)
            .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: self.size.width, height: self.size.height, alignment: self.alignment)
        )
    }
}


