//
//  CustomExtension.swift
//  SPN
//
//  Created by Xiangyu Wang on 4/14/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

public extension String {
    func height(constraintedWidth width: CGFloat, font: UIFont, maxNumberOfLines: Int = 2) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = maxNumberOfLines
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.height
    }
    
    func width(font: UIFont) -> CGFloat {
        let label =  UILabel(frame: CGRect(x: 0, y: 0, width: .greatestFiniteMagnitude, height: font.pointSize))
        label.numberOfLines = 2
        label.text = self
        label.font = font
        label.sizeToFit()
        
        return label.frame.width
    }
    
}


public extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}


public extension String {
    /// This method makes it easier extract a substring by character index where a character is viewed as a human-readable character (grapheme cluster).
    internal func substring(start: Int, offsetBy: Int) -> String? {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return nil
        }

        guard let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) else {
            return nil
        }

        return String(self[substringStartIndex ..< substringEndIndex])
    }
}


public extension UIImage {
    func copy(newSize: CGSize, retina: Bool = true) -> UIImage? {
        // In next line, pass 0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
        // Pass 1 to force exact pixel size.
        UIGraphicsBeginImageContextWithOptions(
            /* size: */ newSize,
            /* opaque: */ false,
            /* scale: */ retina ? 0 : 1
        )
        defer { UIGraphicsEndImageContext() }

        self.draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
