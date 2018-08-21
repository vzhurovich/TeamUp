//
//  WatchProtocol.swift
//  TeamUp
//
//  Created by Vladimir on 8/3/18.
//  Copyright © 2018 LULUZ Talent. All rights reserved.
//

import Foundation

public protocol WatchProtocol: class {
    var startTime : TimeInterval { get set }
    var timeFromStart: TimeInterval? { get set }
    var periodTimeInterval: TimeInterval? { get set }
    var triggerTimeIntervals: [UInt16] { get }
    var doActionOnTime: ((UInt16)->())? { get }
}

extension WatchProtocol {
    
    public func resetTimer() {
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    public func pauseTimer() {
        timeFromStart = NSDate.timeIntervalSinceReferenceDate - startTime
    }
    
    public func resumeTimer() {
        guard let timeFromStart = timeFromStart else { return }
        startTime = NSDate.timeIntervalSinceReferenceDate - timeFromStart
        self.timeFromStart = nil
    }
    
    func currentElapsedTime() -> TimeInterval {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        var elapsedTime: TimeInterval = currentTime - startTime
        if let periodTimeInterval = periodTimeInterval {
            elapsedTime = periodTimeInterval - currentTime + startTime
        }
        
        let nbSeconds:UInt16 = UInt16(elapsedTime)
        if triggerTimeIntervals.contains(nbSeconds) {
            doActionOnTime?(nbSeconds)
        }
        return elapsedTime
    }
    
    func timeText() -> String {        
        return timeIntervalToString(time: currentElapsedTime())
    }
    
    public func timeIntervalToString(time: TimeInterval) -> String {
        var elapsedTime = time
        //calculate the minutes in elapsed time.
        let minutes = UInt16(elapsedTime / 60.0)
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt16(elapsedTime)
        elapsedTime -= TimeInterval(seconds)
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        
        return strMinutes + ":" + strSeconds
    }
}

