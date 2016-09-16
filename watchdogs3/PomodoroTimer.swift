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
        case stopped
        case working
        case resting
    }

    var status = Status.stopped
    var endTime : Date! = nil             // 終了時間を表す変数
    var userData: UserDefaults!
    var observerObject: NSObject!
    
    weak var timer: Timer?

    static let COUNT_DOWN = "COUNT_DOWN"
    static let UPDATE_TIME_SETTING = "UPDATE_TIME_SETTING"
    
    static let KEY_WORK_TIME = "workTime"
    static let KEY_REST_TIME = "restTime"
    
    class var sharedInstance: PomodoroTimer {
        struct Singleton {
            static let instance: PomodoroTimer = PomodoroTimer()
        }
        return Singleton.instance
    }
    
    override init() {
        userData = UserDefaults.standard
        status = Status.stopped
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observerObject)
    }

    func start() -> Timer {
        switch status {
        case Status.working:
            rest()
        case Status.resting, Status.stopped:
            work()
        }

        print("start status: \(status)")
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ticktock), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: RunLoopMode.commonModes)

        return timer!
    }
    
    func ticktock() {
        let now = Date()
        if (now == endTime) {
            timer?.invalidate()
            return
        }

        // 0.9秒で呼ばれる時があるので、23.000の時に0.1で調整する
        let time_left: Double = endTime.timeIntervalSince(now) - 0.1
        print("ticktock \(time_left)" )
        NotificationCenter.default.post(name: Notification.Name(rawValue: PomodoroTimer.COUNT_DOWN), object: observerObject, userInfo: ["time" : time_left])
    }

    func work() {
        if (status == .working) {
            return
        }

        suspend()
        currentSettingTime(PomodoroTimer.KEY_WORK_TIME)
        status = Status.working
    }

    func rest() {
        if (status == .resting) {
            return
        }

        suspend()
        currentSettingTime(PomodoroTimer.KEY_REST_TIME)
        status = Status.resting
    }
    
    func reset() {
        suspend()
        status = Status.stopped
//        print("status: \(status)")
    }
    
    func suspend() {
        timer?.invalidate()
    }

    func currentSettingTime(_ key: String) {
        if let _ = userData {
            userData = UserDefaults.standard
        }

        let start = userData.integer(forKey: key)
        let interval = Double(start) * 61.0
//        let interval = 5.0    デバック
        endTime = Date(timeInterval: interval, since: Date())
        print("currentSettingTime \(endTime), \(start), \(interval), \(userData)")
    }

    func addNotificationCenterObserver(observer target: NSObject, selector aSelector: Selector, name: String, userInfo anObject: AnyObject?) {
        observerObject = target
        NotificationCenter.default.addObserver(observerObject, selector: aSelector, name: NSNotification.Name(rawValue: name), object: anObject)
    }
}
