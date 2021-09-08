//
//  CustomUITextViews.swift
//  
//
//  Created by Xiangyu Wang on 7/19/20.
//

import UIKit

open class CustomUITextField: UITextField {
    public var actionType = TextFieldCanPerformAction()
    private var deleteAction: (String?) -> Void = {_ in}
    private var actions: [Selector] = []
    
    convenience public init(canPerformActions: [Selector]) {
        self.init()
        self.actions = canPerformActions
    }
    
    override public init(frame: CGRect = .zero) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
    }
    
    public func setDeleteAction(action: @escaping (String?) -> Void) {
        self.deleteAction = action
    }
    
    public override func deleteBackward() {
        self.deleteAction(self.text)
        super.deleteBackward()
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if self.actions.count == 0 {
            return true
        } else {
            if self.actions.contains(action) {
                return true
            } else {
                return false
            }
        }
    }
}

open class CustomUITextView: UITextView {
    public var actionType = TextFieldCanPerformAction()
    private var actions: [Selector] = []
    
    convenience public init(canPerformActions: [Selector]) {
        self.init()
        self.actions = canPerformActions
    }
    
    override public init(frame: CGRect = .zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    open override func encode(with coder: NSCoder) {
        super.encode(with: coder)
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if self.actions.count == 0 {
            return true
        } else {
            if self.actions.contains(action) {
                return true
            } else {
                return false
            }
        }
    }
}



public struct TextFieldCanPerformAction {
    public static var paste = #selector(UIResponderStandardEditActions.paste(_:))
    public static var cut = #selector(UIResponderStandardEditActions.cut(_:))
    public static var copy = #selector(UIResponderStandardEditActions.copy(_:))
    public static var select = #selector(UIResponderStandardEditActions.select(_:))
    public static var selectAll = #selector(UIResponderStandardEditActions.selectAll(_:))

    public static func onlyAllowAbove(action: Selector) -> Bool {
        switch action {
        case self.paste:
            return true
        case self.cut:
            return true
        case self.copy:
            return true
        case self.select:
            return true
        case self.selectAll:
            return true
        default:
            return false
        }
    }
}



