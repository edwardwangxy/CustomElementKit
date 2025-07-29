//
//  File.swift
//  CustomElementKit
//
//  Created by Xiangyu Wang on 7/29/25.
//

import Foundation
import SwiftUI
import UIKit

class CustomDiffableCollectionCell: UICollectionViewCell {
    var container: UIViewController?
    
    static let reuseIdentifier = "CustomDiffableCollectionCell"
    
    func updateContainer(_ container: UIViewController) {
        self.container?.view.removeFromSuperview()
        self.container?.removeFromParent()
        self.container = container
        self.addSubview(container.view)
        container.view.translatesAutoresizingMaskIntoConstraints = false
        container.view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        container.view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        container.view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        container.view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}


class CustomDiffableCollectionReusableView: UICollectionReusableView {
    var container: UIViewController?
    
    static let reuseHeaderIdentifier = "CustomDiffableCollectionReusableViewHeader"
    static let reuseFooterIdentifier = "CustomDiffableCollectionReusableViewFooter"
    
    func updateContainer(_ container: UIViewController) {
        self.container?.view.removeFromSuperview()
        self.container?.removeFromParent()
        self.container = container
        self.addSubview(container.view)
        container.view.translatesAutoresizingMaskIntoConstraints = false
        container.view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        container.view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        container.view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        container.view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
}
