//
//  SwiftUIView.swift
//  
//
//  Created by JIAZI XUAN on 8/30/21.
//

import SwiftUI

public struct TransparentSheetBackground: UIViewRepresentable {
    let deep: Bool
    public init(deep: Bool = false) {
        self.deep = deep
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if self.deep {
            DispatchQueue.main.async {
                var checkView = view.superview
                for _ in 0..<10 {
                    checkView?.backgroundColor = .clear
                    if let getName = checkView?.theClassName, getName == "UIDropShadowView" {
                        checkView?.layer.shadowColor = UIColor.clear.cgColor
                    }
                    if checkView?.superview == nil {
                        break
                    }
                    checkView = checkView?.superview
                }
                
            }
        } else {
            DispatchQueue.main.async {
                view.superview?.superview?.backgroundColor = .clear
            }
        }
        return view
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension NSObject {
    var theClassName: String {
        return NSStringFromClass(type(of: self))
    }
}
