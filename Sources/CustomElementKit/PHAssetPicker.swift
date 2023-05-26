//
//  ImagePicker.swift
//  meetyourx
//
//  Created by Xiangyu Wang on 6/4/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//

import SwiftUI
import MobileCoreServices
import PhotosUI

@available(iOS 14.0, *)
public struct PHAssetPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding public var assets: [PHPickerResult]?
    let limit: Int
    public var dismissAction: () -> Void = {}
    
    public init(assets: Binding<[PHPickerResult]?>, limit: Int = 1, dismissAction: @escaping () -> Void = {}) {
        self._assets = assets
        self.limit = limit
        self.dismissAction = dismissAction
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
        
        public let parent: PHAssetPicker

        public init(_ parent: PHAssetPicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.parent.assets = results
            self.parent.dismissAction()
            self.parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<PHAssetPicker>) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = self.limit
        config.filter = PHPickerFilter.images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: UIViewControllerRepresentableContext<PHAssetPicker>) {

    }
}

