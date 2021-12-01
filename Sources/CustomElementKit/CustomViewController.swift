//
//  File.swift
//  
//
//  Created by Xiangyu Wang on 12/1/21.
//

import SwiftUI

public struct EmptyVCView: UIViewControllerRepresentable {
    private var vc: UIViewController
    
    public init(vc: UIViewController) {
        self.vc = vc
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        return self.vc
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

