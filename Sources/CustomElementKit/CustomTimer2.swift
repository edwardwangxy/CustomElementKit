//
//  File.swift
//  
//
//  Created by Xiangyu Wang on 6/20/24.
//

import Foundation

public class CustomTimer2 {
    let timeInterval: TimeInterval
    let repeatTime: TimeInterval?
    private var task: Task<(), Never>?
    public var eventHandler: (() async -> Void)?
    private var state: State = .suspended
    let priority: TaskPriority
    
    private enum State {
        case suspended
        case resumed
    }
    
    public init(delay timeInterval: TimeInterval, repeat repeatTime: TimeInterval? = nil, priority: TaskPriority = .background) {
        self.priority = priority
        self.timeInterval = timeInterval
        self.repeatTime = repeatTime
    }
    
    public func setEventHandler(handler action: @escaping () async -> Void) {
        self.eventHandler = action
    }
    
    public func resume() {
        if self.state == .resumed {
            return
        }
        self.state = .resumed
        self.activeTask()
    }
    
    public func cancel() {
        self.suspend()
    }
    
    public func suspend() {
        if self.state == .suspended {
            return
        }
        self.state = .suspended
        self.task?.cancel()
    }
    
    private func activeTask() {
        if let getTask = self.task, !getTask.isCancelled {
            return
        }
        self.task?.cancel()
        self.task = Task.detached(priority: self.priority, operation: {
            try? await Task.sleep(seconds: self.timeInterval)
            if let getRepeatTime = self.repeatTime {
                repeat {
                    await self.eventHandler?()
                    try? await Task.sleep(seconds: getRepeatTime)
                } while(!Task.isCancelled)
            }
        })
    }
    
    deinit {
        self.setEventHandler {}
        self.cancel()
    }
}


public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
