//
//  File.swift
//  
//
//  Created by Xiangyu Wang on 1/18/22.
//

import Foundation
import SwiftUI
import WebKit

public struct CustomWKWebView: UIViewRepresentable {
    let controller: CustomWKWebViewController
    
    public init(controller: CustomWKWebViewController) {
        self.controller = controller
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        return self.controller.webView
    }
}


open class CustomWKWebViewController: NSObject, WKUIDelegate, ObservableObject {
    public let config = WKWebViewConfiguration()
    public let webView: WKWebView
    
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    public override init() {
        self.webView = WKWebView(frame: .zero, configuration: self.config)
        super.init()
        self.webView.uiDelegate = self
    }
    
    public func updateURL(url: URL) {
        let request = URLRequest(url: url)
        self.webView.load(request)
    }
    
    public func back() {
        self.webView.goBack()
    }
    
    public func forward() {
        self.webView.goForward()
    }
    
}
