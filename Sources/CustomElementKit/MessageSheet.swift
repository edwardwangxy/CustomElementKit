//
//  File.swift
//  CustomElementKit
//
//  Created by Xiangyu Wang on 9/11/24.
//

import Foundation
import UIKit
import MessageUI
import SwiftUI

public struct MessageSheet: UIViewControllerRepresentable {
    public var recipient: String
    public var subject: String
    public var messageBody: String
    
    @Binding var result: MessageComposeResult?
    @Environment(\.presentationMode) var presentation
    
    public init(recipient: String, subject: String, messageBody: String, result: Binding<MessageComposeResult?>) {
        self.recipient = recipient
        self.subject = subject
        self.messageBody = messageBody
        self._result = result
    }

    public class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {

        @Binding public var presentation: PresentationMode
        @Binding public var result: MessageComposeResult?

        public init(presentation: Binding<PresentationMode>,
             result: Binding<MessageComposeResult?>) {
            _presentation = presentation
            _result = result
        }
        
        public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            self.result = result
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<MessageSheet>) -> MFMessageComposeViewController {
        let message = MFMessageComposeViewController()
        message.messageComposeDelegate = context.coordinator
        message.recipients = [recipient]
        message.body = messageBody
        message.subject = subject
        return message
    }

    public func updateUIViewController(_ uiViewController: MFMessageComposeViewController,
                                       context: UIViewControllerRepresentableContext<MessageSheet>) {

    }
}
