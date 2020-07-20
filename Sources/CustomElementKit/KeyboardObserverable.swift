//
//  KeyboardObserverable.swift
//  SPN
//
//  Created by Xiangyu Wang on 5/7/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//

import Combine
import SwiftUI
import UIKit

public final class Keyboard: ObservableObject {
    
    public static var shared = Keyboard()
    
    // MARK: - Published Properties
    @Published var state: Keyboard.State = .default
    
    // MARK: - Private Properties
    private var cancellables: Set<AnyCancellable> = []
    private var notificationCenter: NotificationCenter
    
    // MARK: - Initializers
    public init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        
        // Observe keyboard notifications and transform them into state updates
        notificationCenter.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: notificationCenter.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap(Keyboard.State.from(notification:))
            .sink(receiveValue: { (getState) in
                withAnimation(.easeInOut(duration: 0.05)) {
                    self.state = getState
                }
            })
            .store(in: &cancellables)
    }
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
}


// MARK: - Nested State Type
public extension Keyboard {
    
    struct State {
        
        // MARK: - Properties
        public let animationDuration: TimeInterval
        public let height: CGFloat
        
        // MARK: - Initializers
        public init(animationDuration: TimeInterval, height: CGFloat) {
            self.animationDuration = animationDuration
            self.height = height
        }
        
        // MARK: - Static Properties
        fileprivate static let `default` = Keyboard.State(animationDuration: 0.25, height: 0)
        
        // MARK: - Static Methods
        public static func from(notification: Notification) -> Keyboard.State? {
            return from(
                notification: notification,
                safeAreaInsets: UIApplication.shared.windows.first?.safeAreaInsets,
                screen: .main
            )
        }
        
        // NOTE: A testable version of the transform that injects the dependencies.
        public static func from(
            notification: Notification,
            safeAreaInsets: UIEdgeInsets?,
            screen: UIScreen
        ) -> Keyboard.State? {
            guard let userInfo = notification.userInfo else { return nil }
            // NOTE: We could eventually get the aniamtion curve here too.
            // Get the duration of the keyboard animation
            let animationDuration =
                (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
                    ?? 0.25
            
            // Get keyboard height
            var height: CGFloat = 0
            if let keyboardFrameValue: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardFrame = keyboardFrameValue.cgRectValue
//                print("keyboardHeight: \(keyboardFrame.height)")
                // If the rectangle is at the bottom of the screen, set the height to 0.
                if keyboardFrame.origin.y == screen.bounds.height {
                    height = 0
                } else {
                    height = keyboardFrame.height - (safeAreaInsets?.bottom ?? 0)
                }
            }
            
            return Keyboard.State(
                animationDuration: animationDuration,
                height: height
            )
        }
    }
}


public struct KeyboardObserving<Content: View>: View {
    public var offsetY: CGFloat
    @ObservedObject var keyboard = Keyboard.shared
    let content: Content
    
    public init(offsetY: CGFloat = 0, @ViewBuilder builder: () -> Content) {
        self.content = builder()
        self.offsetY = offsetY
    }
    
    public var body: some View {
        VStack {
            content
            Spacer()
                .frame(height: keyboard.state.height - self.offsetY)
        }
    }
}
