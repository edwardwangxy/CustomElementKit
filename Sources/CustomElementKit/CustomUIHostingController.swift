//
//  SwiftUIView.swift
//  CustomElementKit
//
//  Created by Xiangyu Wang on 2/14/25.
//

import SwiftUI
import UIKit

public class CustomUIHostingController<Content: View>: UIHostingController<Content> {
    
    public var dismissAction: (() -> Void)? = nil
    
    public init(rootView: Content, dismissAction: @escaping () -> Void) {
        super.init(rootView: rootView)
        self.dismissAction = dismissAction
    }
    
    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismissAction?()
    }
    
}
