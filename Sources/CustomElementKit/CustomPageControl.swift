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
    var indicatorColor: UIColor? = nil
    var currentIndicatorColor: UIColor? = nil
    
    let control = UIPageControl()
    
    public init(numberOfPages: Binding<Int>, currentPage: Binding<Int>, indicatorColor: UIColor? = nil, currentIndicatorColor: UIColor? = nil) {
        self._numberOfPages = numberOfPages
        self._currentPage = currentPage
        self.indicatorColor = indicatorColor
        self.currentIndicatorColor = currentIndicatorColor
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIView(context: Context) -> UIPageControl {
        self.control.numberOfPages = numberOfPages
        self.control.addTarget(
                    context.coordinator,
                    action: #selector(Coordinator.updateCurrentPage(sender:)),
                    for: .valueChanged)
        self.control.pageIndicatorTintColor = self.indicatorColor
        self.control.currentPageIndicatorTintColor = self.currentIndicatorColor
        return self.control
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



