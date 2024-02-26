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

public extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}

public extension View {
    func asImage() -> UIImage {
        let controller = UIHostingController(rootView: self)

        // locate far out of screen
        controller.view.frame = CGRect(x: 0, y: CGFloat(Int.max), width: 1, height: 1)
        UIApplication.shared.windows.first!.rootViewController?.view.addSubview(controller.view)
        #if os(visionOS)
        let size = controller.sizeThatFits(in: UIApplication.shared.windows.first?.bounds.size ?? CGSize(width: 200, height: 200))
        #else
        let size = controller.sizeThatFits(in: UIScreen.main.bounds.size)
        #endif
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.sizeToFit()

        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
    }
}

public extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
    }
}

public extension Sequence {
    func concurrentMap<T>(_ transform: @escaping (Element) async throws -> T) async throws -> [T] {
        try await withThrowingTaskGroup(of: (Int, T).self, body: { group in
            for (idx, each) in self.enumerated() {
                group.addTask {
                    return (idx, try await transform(each))
                }
            }
            var out = [(Int, T)]()
            
            for try await (idx, item) in group {
                out.append((idx, item))
            }
            
            return out.sorted(by: { $0.0 <= $1.0 }).map({ $0.1 })
        })
    }
    
    func concurrentMap<T>(_ transform: @escaping (Element) async -> T) async -> [T] {
        await withTaskGroup(of: (Int, T).self, body: { group in
            for (idx, each) in self.enumerated() {
                group.addTask {
                    return (idx, await transform(each))
                }
            }
            var out = [(Int, T)]()
            
            for await (idx, item) in group {
                out.append((idx, item))
            }
            
            return out.sorted(by: { $0.0 <= $1.0 }).map({ $0.1 })
        })
    }
}

