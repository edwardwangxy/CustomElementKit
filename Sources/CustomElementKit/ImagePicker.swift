//
//  ImagePicker.swift
//  meetyourx
//
//  Created by Xiangyu Wang on 6/4/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//
#if !os(visionOS)
import SwiftUI
import MobileCoreServices


public struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding public var image: UIImage?
    public var allowEditing: Bool = true
    public var sourceType: UIImagePickerController.SourceType = .photoLibrary
    public var cameraType: UIImagePickerController.CameraDevice = .front
    public var dismissAction: () -> Void = {}
    
    public init(image: Binding<UIImage?>, allowEditing: Bool = true, sourceType: UIImagePickerController.SourceType = .photoLibrary, cameraType: UIImagePickerController.CameraDevice = .front, dismissAction: @escaping () -> Void = {}) {
        self._image = image
        self.sourceType = sourceType
        self.cameraType = cameraType
        self.dismissAction = dismissAction
        self.allowEditing = allowEditing
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        public let parent: ImagePicker

        public init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if self.parent.allowEditing {
                if let uiImage = info[.editedImage] as? UIImage {
                    parent.image = uiImage
                }
            } else {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
            }
            self.parent.presentationMode.wrappedValue.dismiss()
            self.parent.dismissAction()
        }
    }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = self.allowEditing
        picker.mediaTypes = [kUTTypeImage as String]
        picker.sourceType = self.sourceType
        if self.sourceType == .camera {
            picker.cameraDevice = self.cameraType
        }
    
        picker.delegate = context.coordinator
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
}
#endif
