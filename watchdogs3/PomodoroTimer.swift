//
//  PomodoroTimer
//  watchdogs2
//
//  Created by shunsuke on 2016/07/04.
//  Copyright © 2016年 panpanpan. All rights reserved.
//
//  残り時間、ステータスを管理する
//

import Cocoa

class PomodoroTimer: NSObject {

    enum Status {
        case Stopped
        case Working
        case Resting
    }

    var status = Status.Stopped
    var endTime : NSDate! = nil             // 終了時間を表す変数
    var userData: NSUserDefaults!
    var observerObject: NSObject!

    weak var timer: NSTimer?

    static let COUNT_DOWN = "COUNT_DOWN"
    static let UPDATE_TIME_SETTING = "UPDATE_TIME_SETTING"
    
    class var sharedInstance: PomodoroTimer {
        struct Singleton {
            static let instance: PomodoroTimer = PomodoroTimer()
        }
        return Singleton.instance
    }
    
    override init() {
        userData = NSUserDefaults.standardUserDefaults()
        status = Status.Stopped
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observerObject)
    }

    func start() -> NSTimer {
        switch status {
        case Status.Working:
            rest()
        case Status.Resting, Status.Stopped:
            work()
        }

        print("start status: \(status)")

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ticktock), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)

        return timer!
    }
    
    func ticktock() {
        let now = NSDate()
        if (now.isEqualToDate(endTime)) {
            timer?.invalidate()
            return
        }

        let time_left: Double = endTime.timeIntervalSinceDate(now)
        print("ticktock \(time_left)" )
        NSNotificationCenter.defaultCenter().postNotificationName(PomodoroTimer.COUNT_DOWN, object: observerObject, userInfo: ["time" : time_left])
    }

    func work() {
        if (status == .Working) {
            return
        }

        suspend()
        currentSettingTime("workTime")
        status = Status.Working
    }

    func rest() {
        if (status == .Resting) {
            return
        }

        suspend()
        currentSettingTime("restTime")
        status = Status.Resting
    }
    
    func reset() {
        suspend()
        status = Status.Stopped
        print("status: \(status)")
    }
    
    func suspend() {
        timer?.invalidate()
    }

    func currentSettingTime(key: String) {
        if let _ = userData {
            userData = NSUserDefaults.standardUserDefaults()
        }

//        let start = userData.integerForKey(key)
//        let interval = Double(start) * 60.0
        let interval = 5.0
        endTime = NSDate(timeInterval: interval, sinceDate: NSDate())
        print("currentSettingTime \(endTime)")
    }

    func addNotificationCenterObserver(observer target: NSObject, selector aSelector: Selector, name: String, userInfo anObject: AnyObject?) {
        observerObject = target
        NSNotificationCenter.defaultCenter().addObserver(observerObject, selector: aSelector, name: name, object: anObject)
    }
}