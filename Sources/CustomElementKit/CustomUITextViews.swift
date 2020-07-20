//
//  CustomUITextViews.swift
//  
//
//  Created by Xiangyu Wang on 7/19/20.
//

import UIKit

public class CustomUITextField: UITextField {
    var actionType = TextFieldCanPerformAction()
    
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
    var actionType = TextFieldCanPerformAction()
    
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



struct TextFieldCanPerformAction {
    var paste = #selector(UIResponderStandardEditActions.paste(_:))
    var cut = #selector(UIResponderStandardEditActions.cut(_:))
    var copy = #selector(UIResponderStandardEditActions.copy(_:))
    var select = #selector(UIResponderStandardEditActions.select(_:))
    var selectAll = #selector(UIResponderStandardEditActions.selectAll(_:))

    func onlyAllowAbove(action: Selector) -> Bool {
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



