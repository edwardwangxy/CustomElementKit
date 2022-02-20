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


open class CustomWKWebViewController: NSObject, ObservableObject {
    public let config = WKWebViewConfiguration()
    public let webView: WKWebView
    
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    
    var urlUpdate: (URL) -> Void = {_ in}
    var navigationResponse: (WKNavigationResponse) -> Void = {_ in}
    var offsetUpdate: (CGPoint) -> Void = {_ in}
    
    public override init() {
        self.webView = WKWebView(frame: .zero, configuration: self.config)
        super.init()
        self.webView.navigationDelegate = self
        self.webView.scrollView.delegate = self
        
        self.webView.uiDelegate = self
    }
    
    public func clearCache(complete: @escaping () -> Void = {}) {
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: complete)
    }
    
    public func clearCookie() {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookies in cookies {
                storage.deleteCookie(cookies)
            }
        }
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
    
    public func setURLUpdate(action: @escaping (URL) -> Void) {
        self.urlUpdate = action
    }
    
    public func setResponse(action: @escaping (WKNavigationResponse) -> Void) {
        self.navigationResponse = action
    }
    
    public func setOffsetUpdate(action: @escaping (CGPoint) -> Void) {
        self.offsetUpdate = action
    }
    
    
    
}


extension CustomWKWebViewController: WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.offsetUpdate(scrollView.contentOffset)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let getURL = navigationAction.request.url {
            self.urlUpdate(getURL)
        }
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        self.navigationResponse(navigationResponse)
        decisionHandler(.allow)
    }
}





