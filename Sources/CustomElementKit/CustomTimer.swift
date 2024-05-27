//
//  File.swift
//
//
//  Created by Xiangyu Wang on 11/2/23.
//

import Foundation

public class CustomTimer {
    let timeInterval: TimeInterval
    let repeatTime: TimeInterval?
    
    public init(delay timeInterval: TimeInterval, repeat repeatTime: TimeInterval? = nil) {
        self.timeInterval = timeInterval
        self.repeatTime = repeatTime
    }
    
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        if let getRepeatTime = self.repeatTime {
            t.schedule(deadline: .now() + self.timeInterval, repeating: getRepeatTime)
        } else {
            t.schedule(deadline: .now() + self.timeInterval)
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
    
    public func setEventHandler(handler action: @escaping () -> Void) {
        self.eventHandler = action
    }
    
    public func resume() {
        if self.state == .resumed {
            return
        }
        self.state = .resumed
        self.timer.resume()
    }
    
    public func cancel() {
        self.suspend()
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
    }
}
