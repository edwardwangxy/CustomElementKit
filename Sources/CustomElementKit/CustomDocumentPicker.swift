//
//  CustomDocumentPicker.swift
//
//
//  Created by Xiangyu Wang on 02/18/2021.
//

import SwiftUI
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

public struct CustomDocumentPicker: UIViewControllerRepresentable {
    let showFileExtension: Bool
    let allowMultipleSelection: Bool
    let documentType: [String]
    let documentMode: UIDocumentPickerMode
    let complete: () -> Void
    let picker: UIDocumentPickerViewController
    @Binding var files: [URL]
    @Environment(\.presentationMode) var presentation
    
    public init(files: Binding<[URL]>, fileType: [String], showFileExtension: Bool = true, allowMultipleSelection: Bool = false, mode: UIDocumentPickerMode = .import, complete: @escaping () -> Void = {}) {
        self.showFileExtension = showFileExtension
        self.allowMultipleSelection = allowMultipleSelection
        self.documentType = fileType
        self.complete = complete
        self._files = files
        self.documentMode = mode
        self.picker = UIDocumentPickerViewController(documentTypes: self.documentType, in: self.documentMode)
    }

    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        public let parent: CustomDocumentPicker
        
        public init(parent: CustomDocumentPicker) {
            self.parent = parent
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            self.parent.presentation.wrappedValue.dismiss()
            self.parent.complete()
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            self.parent.files = urls
            self.parent.presentation.wrappedValue.dismiss()
            self.parent.complete()
        }
        
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<CustomDocumentPicker>) -> UIDocumentPickerViewController {
        self.picker.delegate = context.coordinator
        self.picker.shouldShowFileExtensions = self.showFileExtension
        self.picker.allowsMultipleSelection = self.allowMultipleSelection
        return self.picker
    }

    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController,
                                context: UIViewControllerRepresentableContext<CustomDocumentPicker>) {
        uiViewController.allowsMultipleSelection = self.allowMultipleSelection
    }
    
    public func customize(action: @escaping (UIDocumentPickerViewController) -> Void) -> CustomDocumentPicker {
        action(self.picker)
        return self
    }
}
