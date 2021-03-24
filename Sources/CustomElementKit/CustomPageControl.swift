//
//  SwiftUIView.swift
//  
//
//  Created by JIAZI XUAN on 3/24/21.
//

import SwiftUI

public struct CustomPageControl: UIViewRepresentable {
    @Binding var numberOfPages: Int
    @Binding var currentPage: Int

    public init(numberOfPages: Binding<Int>, currentPage: Binding<Int>) {
        self._numberOfPages = numberOfPages
        self._currentPage = currentPage
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.addTarget(
                    context.coordinator,
                    action: #selector(Coordinator.updateCurrentPage(sender:)),
                    for: .valueChanged)
        return control
    }

    public func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = self.currentPage
        uiView.numberOfPages = self.numberOfPages
    }
    
    public class Coordinator: NSObject {
        var control: CustomPageControl
        
        init(_ control: CustomPageControl) {
            self.control = control
        }
        
        @objc
        func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
    
}



