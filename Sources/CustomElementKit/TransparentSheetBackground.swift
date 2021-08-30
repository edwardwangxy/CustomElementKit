//
//  SwiftUIView.swift
//  
//
//  Created by JIAZI XUAN on 8/30/21.
//

import SwiftUI

public struct TransparentSheetBackground: UIViewRepresentable {
    
    public init() {
        
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

