//
//  CustomSearchBar.swift
//  SPN
//
//  Created by Xiangyu Wang on 4/10/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//

import SwiftUI
import UIKit

public struct CustomSearchBar: UIViewRepresentable {

    @Binding public var text: String
    @Binding public var endSearch: Bool
    @State public var showCancel: Bool = false
    @State public var numpadOnly: Bool = false
    @State public var placeholder: String? = nil
    @State public var tintColor: UIColor? = nil
    @State public var textDidChangeCallback: (String) -> Void = {_ in}
    
    public init(text: Binding<String>, endSearch: Binding<Bool>, showCancel: Bool = false, numpadOnly: Bool = false, placeholder: String? = nil, tintColor: UIColor? = nil, textDidChangeCallback: @escaping (String) -> Void = {_ in}) {
        self._text = text
        self._endSearch = endSearch
        self.showCancel = showCancel
        self.numpadOnly = numpadOnly
        self.placeholder = placeholder
        self.tintColor = tintColor
        self.textDidChangeCallback = textDidChangeCallback
    }
    
    public class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var needShowCancel: Bool
        @Binding var text: String
        @Binding var endSearch: Bool
        var textDidChangeSetter: (String) -> Void
        public init(text: Binding<String>, needShowCancel: Binding<Bool>, setEndSearch: Binding<Bool>, textDidChanged: @escaping (String) -> Void) {
            _text = text
            _needShowCancel = needShowCancel
            _endSearch = setEndSearch
            textDidChangeSetter = textDidChanged
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
            self.textDidChangeSetter(searchText)
        }
        
        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            self.textDidChangeSetter(self.text)
            searchBar.resignFirstResponder()
        }
        
        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }

    public func makeCoordinator() -> CustomSearchBar.Coordinator {
        return Coordinator(text: $text, needShowCancel: self.$showCancel, setEndSearch: self.$endSearch, textDidChanged: self.textDidChangeCallback)
    }

    public func makeUIView(context: UIViewRepresentableContext<CustomSearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .prominent
        searchBar.backgroundImage = UIImage()
        searchBar.placeholder = "Search"
        return searchBar
    }

    public func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<CustomSearchBar>) {
        uiView.text = text
        if self.endSearch {
            uiView.setShowsCancelButton(false, animated: true)
            uiView.resignFirstResponder()
        }
        if self.numpadOnly {
            uiView.keyboardType = .numberPad
        }
        if let getTintColor = self.tintColor {
            uiView.tintColor = getTintColor
        }
        uiView.placeholder = self.placeholder
    }
}

public extension CustomSearchBar {
    func numberPadOnly() -> CustomSearchBar {
        let view = self
        view.numpadOnly = true
        return view
    }
    
    func setTintColor(_ color: UIColor) -> CustomSearchBar {
        let view = self
        view.tintColor = color
        return view
    }
}
