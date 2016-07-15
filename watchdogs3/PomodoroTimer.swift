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

    dynamic var myDate = 0.0    // 名前はかえる
    dynamic var workTime: String!
    dynamic var restTime: String!

    // dynamic var status : Status.Stoped
    
    var endTime : NSDate! = nil             // 終了時間を表す変数
    var userData: NSUserDefaults!
    
    class var sharedInstance: PomodoroTimer {
        struct Singleton {
            static let instance: PomodoroTimer = PomodoroTimer()
        }
        return Singleton.instance
    }
    
    override init() {
        userData = NSUserDefaults.standardUserDefaults()
    }
    
    func updateDate(now: NSDate) {
        if (now.isEqualToDate(endTime)) {
            myDate = 0.0
            return
        }
        
        myDate = endTime.timeIntervalSinceDate(now)
    }

    func start() {
//    func start(workTime work:Int, breakTime rest:Int, startTime start:Int) {
//        print("start work \(work)")
//        print("start rest \(rest)")

        switch status {
        case Status.Working:
            rest()
        case Status.Resting, Status.Stopped:
            work()
        }

        print("status: \(status)")
    }
    
    func work() {
        currentSettingTime("workTime")
        status = Status.Working
    }
    func rest() {
        currentSettingTime("restTime")
        status = Status.Resting
    }
    
    func reset() {
        status = Status.Stopped
        print("status: \(status)")
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
}
