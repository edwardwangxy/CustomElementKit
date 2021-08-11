//
//  CustomUITextViews.swift
//  
//
//  Created by Xiangyu Wang on 7/19/20.
//

import UIKit

public class CustomUITextField: UITextField {
    public var actionType = TextFieldCanPerformAction()
    private var deleteAction: (String?) -> Void = {_ in}
    
    public func setDeleteAction(action: @escaping (String?) -> Void) {
        self.deleteAction = action
    }
    
    public override func deleteBackward() {
        self.deleteAction(self.text)
        super.deleteBackward()
    }
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if UIPasteboard.general.string != nil {
            if action == actionType.paste {
                return true
            }
        }
        if (self.text?.count ?? 0) > 0 {
            if action == actionType.selectAll || action == actionType.select {
                return true
            }
        }
        
        return false
    }
}

public class CustomUITextView: UITextView {
    public var actionType = TextFieldCanPerformAction()
    
    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if UIPasteboard.general.string != nil {
            if action == actionType.paste {
                return true
            }
        }
        if (self.text?.count ?? 0) > 0 {
            if action == actionType.selectAll || action == actionType.select {
                return true
            }
        }
        return false
    }
}



public struct TextFieldCanPerformAction {
    public var paste = #selector(UIResponderStandardEditActions.paste(_:))
    public var cut = #selector(UIResponderStandardEditActions.cut(_:))
    public var copy = #selector(UIResponderStandardEditActions.copy(_:))
    public var select = #selector(UIResponderStandardEditActions.select(_:))
    public var selectAll = #selector(UIResponderStandardEditActions.selectAll(_:))

    public func onlyAllowAbove(action: Selector) -> Bool {
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



