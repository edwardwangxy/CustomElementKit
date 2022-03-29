//
//  File.swift
//  
//
//  Created by Xiangyu Wang on 3/29/22.
//

import Foundation
import SwiftUI
import UIKit

public struct ListHideSeperator: ViewModifier {
    let bgColor: Color
    
    public init(bgColor: Color = Color(red: 1, green: 1, blue: 1)) {
        self.bgColor = bgColor
    }
    
    public func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .listRowInsets(.init(top: -1, leading: -1, bottom: -1, trailing: -1))
                .listRowSeparator(.hidden)
        } else {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .listRowInsets(.init(top: -1, leading: -1, bottom: -1, trailing: -1))
                .background(self.bgColor)
        }
    }
}

public extension View {
    func listItemRemoveStyle(bgColor: Color = Color(red: 1, green: 1, blue: 1)) -> some View {
        return self.modifier(ListHideSeperator(bgColor: bgColor))
    }
}
