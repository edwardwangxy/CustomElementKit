//
//  OrientationInfo.swift
//  SPN
//
//  Created by Xiangyu Wang on 5/14/20.
//  Copyright © 2020 mysecondphonenumber. All rights reserved.
//

import SwiftUI
import Foundation

public enum Orientation {
    case portrait
    case landscape
}

public final class OrientationInfo: ObservableObject {
    
      
    @Published public var orientation: Orientation
    public static var shared = OrientationInfo()
    private var _observer: NSObjectProtocol?
      
    public init() {
        // fairly arbitrary starting value for 'flat' orientations
        #if os(visionOS)
        self.orientation = .landscape
        #else
        if UIDevice.current.orientation.isLandscape {
            self.orientation = .landscape
        }
        else {
            self.orientation = .portrait
        }
        // unowned self because we unregister before self becomes invalid
        self._observer = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [unowned self] note in
            guard let device = note.object as? UIDevice else {
                return
            }
            if device.orientation.isPortrait {
                self.orientation = .portrait
            }
            else if device.orientation.isLandscape {
                self.orientation = .landscape
            }
        }
        #endif
        
        
    }
      
    deinit {
        if let observer = _observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
