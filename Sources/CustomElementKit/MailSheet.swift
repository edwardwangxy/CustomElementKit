//
//  MailSheet.swift
//  PrivacyKeyboard
//
//  Created by Xiangyu Wang on 1/20/20.
//  Copyright © 2020 Xiangyu Wang. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

public struct MailSheet: UIViewControllerRepresentable {
    public var recipient: String
    public var subject: String
    public var messageBody: String
    public var isHtml: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Environment(\.presentationMode) var presentation
    
    public init(recipient: String, subject: String, messageBody: String, isHtml: Bool, result: Binding<Result<MFMailComposeResult, Error>?>) {
        self.recipient = recipient
        self.subject = subject
        self.messageBody = messageBody
        self.isHtml = isHtml
        self._result = result
    }

    public class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding public var presentation: PresentationMode
        @Binding public var result: Result<MFMailComposeResult, Error>?

        public init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>) {
            _presentation = presentation
            _result = result
        }

        public func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard error == nil else {
                self.result = .failure(error!)
                return
            }
            self.result = .success(result)
        }
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result)
    }

    public func makeUIViewController(context: UIViewControllerRepresentableContext<MailSheet>) -> MFMailComposeViewController {
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = context.coordinator
        mail.setToRecipients([recipient])
        mail.setSubject(subject)
        mail.setMessageBody(messageBody, isHTML: isHtml)
        return mail
    }

    public func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailSheet>) {

    }
}
