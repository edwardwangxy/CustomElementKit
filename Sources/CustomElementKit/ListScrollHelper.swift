//
//  ListScrollingHelper.swift
//  SPN
//
//  Created by Xiangyu Wang on 5/8/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit
import Combine

public enum ListScrollingHelperCatchType {
    case table
    case scroll
}

public struct ListScrollingHelper: UIViewRepresentable {
    var catchType: ListScrollingHelperCatchType
    var forcePage: Bool = false
    @Binding public var proxy: ListScrollingProxy // reference type
    @Binding public var reCatch: Bool
    private var setView = UIView()
    public func forceUpdate() {
        if catchType == .table {
            proxy.catchScrollTable(for: self.setView)
        } else {
            proxy.catchScrollView(for: self.setView, forcePage: self.forcePage) // here UIView is in view hierarchy
        }
    }
    
    public init(catchType: ListScrollingHelperCatchType, forcePage: Bool = false, proxy: Binding<ListScrollingProxy>, reCatch: Binding<Bool>) {
        self.catchType = catchType
        self.forcePage = forcePage
        self._proxy = proxy
        self._reCatch = reCatch
    }
    
    public func makeUIView(context: Context) -> UIView {
        return self.setView // managed by SwiftUI, no overloads
    }

    public func updateUIView(_ uiView: UIView, context: Context) {
        print("List Scroll Helper Update")
        if catchType == .table {
            proxy.catchScrollTable(for: uiView)
        } else {
            proxy.catchScrollView(for: uiView, forcePage: self.forcePage) // here UIView is in view hierarchy
        }
    }
}

public class ListScrollingNotification: ObservableObject {
    @Published public var firstTimeScrollBottom: Bool = false
    public static var shared = ListScrollingNotification()
}

public class ListScrollingProxy: ObservableObject {
    public enum Action {
        case end
        case top
        case point(point: CGPoint)     // << bonus !!
    }
    private var scrollToButtom = false
    @Published public var tableView: UITableView?
    @Published public var scrollView: UIScrollView?
    private var notification = ListScrollingNotification.shared
    private var catchScrollView: AnyCancellable? = nil
    private var watchKeyboard: AnyCancellable? = nil
    private var keepScrollingOnKeyboard: AnyCancellable? = nil
    public init(scrollToButtom: Bool = false) {
        self.scrollToButtom = scrollToButtom
        self.watchKeyboard = NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification).sink(receiveValue: { (_) in
            
            DispatchQueue.main.async {
                self.scrollViewToEnd()
                self.scrollTableToEnd()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.scrollViewToEnd()
                self.scrollTableToEnd()
            }
        })
        
        self.keepScrollingOnKeyboard = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).sink(receiveValue: { (_) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.scrollViewToEnd()
                self.scrollTableToEnd()
            }
        })
        
    }
    
    public func catchScrollView(for view: UIView, forcePage: Bool = true) {
        if nil == scrollView {
            if let getScroll = view.enclosingScrollView() {
                if forcePage {
                    getScroll.isPagingEnabled = true
                    getScroll.clipsToBounds = false
                }
                print("get Scroll view")
                if self.scrollView == nil {
                    if self.scrollToButtom {
                        let bottomOffset = CGPoint(x: 0, y: max(0, getScroll.contentSize.height - getScroll.bounds.size.height))
                        getScroll.setContentOffset(bottomOffset, animated: false)
                        self.notification.firstTimeScrollBottom = true
                    }
                    self.scrollView = getScroll
                    
                }
            }
        }
    }
    
    public func catchScrollTable(for view: UIView) {
        if nil == tableView {
            if let getTable = view.enclosingTableView() {
                print("get Table view")
                if self.tableView == nil {
                    if self.scrollToButtom {
                        let lastIndex = IndexPath(row: getTable.numberOfRows(inSection: 0) - 1, section: 0)
                        getTable.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                        self.notification.firstTimeScrollBottom = true
                    }
                    self.tableView = getTable
                }
            }
        }
    }
    
    public func scrollToEnd(animate: Bool = true) {
        self.scrollViewToEnd(animate: animate)
        self.scrollTableToEnd(animate: animate)
    }
    
    public func scrollViewToEnd(animate: Bool = true) {
        if let getScroll = self.scrollView {
            let bottomOffset = CGPoint(x: 0, y: max(0, getScroll.contentSize.height - getScroll.bounds.size.height))
            getScroll.setContentOffset(bottomOffset, animated: animate)
        }
    }
    
    public func scrollTableToEnd(animate: Bool = true) {
        if let getTable = self.tableView {
            let lastIndex = IndexPath(row: getTable.numberOfRows(inSection: 0) - 1, section: 0)
            getTable.scrollToRow(at: lastIndex, at: .bottom, animated: animate)
        }
    }

    
}

public extension UIView {
    func enclosingScrollView() -> UIScrollView? {
        var next: UIView? = self
        repeat {
            next = next?.superview
            if let scrollview = next as? UIScrollView {
                return scrollview
            }
        } while next != nil
        return nil
    }
    
    func enclosingTableView() -> UITableView? {
        var next: UIView? = self
        repeat {
            next = next?.superview
            if let scrollview = next as? UITableView {
                return scrollview
            }
        } while next != nil
        return nil
    }
}
