//
//  File.swift
//  
//
//  Created by Xiangyu Wang on 4/3/24.
//

import Foundation
import UIKit

public typealias CompletionHandler = () -> Void

public protocol CountDown: NSObjectProtocol {
    // 1
    var timeElapsed: TimeInterval {get set}
    var timeLimit: TimeInterval {get set}
    
    // 2
    var isFinished: Bool {get}
    var isRunning: Bool {get}
    
    // 3
    /// Executed on completion
    var completion: CompletionHandler? {get set}
    /// Executed every iteration
    var repeatingTask: CompletionHandler? {get set}
    
    // 4
    func start()
    func stop()
    func reset()
    func restart()
}

public final class CountDownTimer: NSObject, CountDown {
    
    // - 1
    
    // Initializes the timer to stop after given time limit
    public init(endsAfter timeLimit: TimeInterval, repeatingTask: CompletionHandler?, completion: CompletionHandler?) {
        self.timeLimit = timeLimit
        self.repeatingTask = repeatingTask
        self.completion = completion
        self.timeElapsed = 0.0
        self.lastExecutionTime = Date()
    }
    
    // Uses Date object. If you want to countdown to a particular date/time
    public init(endsOn date: Date, repeatingTask: CompletionHandler?, completion: CompletionHandler?) {
        self.timeLimit = date.timeIntervalSinceNow
        self.repeatingTask = repeatingTask
        self.completion = completion
        self.timeElapsed = 0.0
        self.lastExecutionTime = Date()
    }
    
    // - 2
    
    public var timeElapsed: TimeInterval {
        didSet {
            guard timeElapsed > 0 else {return}
            if timeLimit - timeElapsed <= 0 {
                completion?()
                stop()  // stop timer
            }
        }
    }
    
    public var timeLimit: TimeInterval {
        didSet {
            // Reset
            reset()
        }
    }
    public var isFinished: Bool {
        return  timeLimit - timeElapsed <= 0
    }
    
    public var isRunning: Bool {
        return !(displayLink?.isPaused ?? true)
    }
    
    public var completion: CompletionHandler?
    public var repeatingTask: CompletionHandler?
    
    private var lastExecutionTime: Date
    private weak var displayLink: CADisplayLink?
    
    // - 3
    
    public func start() {
        self.lastExecutionTime = Date()
        let displayLink = CADisplayLink(target: self, selector: #selector(refreshStats))
        displayLink.add(to: .current, forMode: RunLoop.Mode.common)
        self.displayLink = displayLink
    }
    
    public func stop() {
        displayLink?.invalidate()
    }
    
    public func reset() {
        displayLink?.invalidate()
        timeElapsed = 0
    }
    
    public func restart() {
        self.reset()
        self.start()
    }
    
    // Called every iteration
    @objc private func refreshStats() {
        guard !isFinished else {return}
        let now = Date()
        let elapsedTime = now.timeIntervalSince1970 - lastExecutionTime.timeIntervalSince1970
        self.timeElapsed += elapsedTime
        lastExecutionTime = now
        repeatingTask?()
    }
    
    // - 4
    deinit {
        displayLink?.invalidate()
        repeatingTask = nil
        completion = nil
    }
}
