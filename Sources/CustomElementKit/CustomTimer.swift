//
//  File.swift
//
//
//  Created by Xiangyu Wang on 11/2/23.
//

import Foundation

public class CustomTimer {
    let timeInterval: TimeInterval
    let needRepeat: Bool
    public init(timeInterval: TimeInterval, repeat setRepeat: Bool = true) {
        self.timeInterval = timeInterval
        self.needRepeat = setRepeat
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        if self.needRepeat {
            t.schedule(deadline: .now() + self.timeInterval)
        } else {
            t.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        }
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    public var eventHandler: (() -> Void)?
    private enum State {
        case suspended
        case resumed
    }
    private var state: State = .suspended
    public func resume() {
        if self.state == .resumed {
            return
        }
        self.state = .resumed
        self.timer.resume()
    }
    
    public func suspend() {
        if self.state == .suspended {
            return
        }
        self.state = .suspended
        self.timer.suspend()
    }
    deinit {
        self.timer.setEventHandler {}
        self.timer.cancel()
        self.resume()
        self.eventHandler = nil
    }
}
