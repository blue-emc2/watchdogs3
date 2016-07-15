//
//  StatusMenuController.swift
//  watchdogs2
//
//  Created by shunsuke on 2016/06/26.
//  Copyright © 2016年 panpanpan. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, NSUserNotificationCenterDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    
    var timer: NSTimer!
    let format = "%02d:%02d"
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    private var myDateContext = 0
    private var workTimeContext = 1
    private var restTimeContext = 2
    
    var preferencesWindow: PreferencesWindow!
    
    var userData: NSUserDefaults!
    var workTime: Int!
    var breakTime: Int!
    
    override init() {
        super.init()
        
        PomodoroTimer.sharedInstance.addObserver(self, forKeyPath: "myDate", options: .New, context: &myDateContext)
        // TODO: 本当はこんな事しなくてもdelegateあたりを使えば良いっぽい
        PomodoroTimer.sharedInstance.addObserver(self, forKeyPath: "workTime", options: .New, context: &workTimeContext)
        PomodoroTimer.sharedInstance.addObserver(self, forKeyPath: "restTime", options: .New, context: &restTimeContext)
        
        userData = NSUserDefaults.standardUserDefaults()
    }

    override func awakeFromNib() {
        workTime = userData.integerForKey("workTime")
        breakTime = userData.integerForKey("breakTime")
        print("awakeFromNib \(workTime), \(breakTime)")
        
//        print(workTime.dynamicType)
//        print(userData.dictionaryRepresentation())
//        print(String(format: format, String(workTime), 0))
        
        statusItem.title = String(format: format, workTime, 0)
        statusItem.menu = statusMenu
        
        preferencesWindow = PreferencesWindow()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("observeValueForKeyPath   \(keyPath)")
        
        if context == &myDateContext {
            let t = PomodoroTimer.sharedInstance.myDate
            
            if (t <= 0.0) {
                statusItem.title = String(format: format, 0, 0)
                timer.invalidate()
                notificationForTimeUp(PomodoroTimer.sharedInstance.status)
                startTimer("")
                return
            }
            
            // 0.9秒で呼ばれる時があるので、23.000の時に0.01で調整する
            statusItem.title = String(format: format, Int(t / 60.0), Int(t % 60.0 - 0.01))
        } else if context == &workTimeContext || context == &restTimeContext {
            if let _ = timer {
                timer.invalidate()
            }
            
            let t = PomodoroTimer.sharedInstance.workTime
            statusItem.title = String(format: format, Int(t) ?? 25, 0)
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    @IBAction func startTimer(sender: AnyObject) {
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(countdown(_:)), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer!, forMode: NSRunLoopCommonModes)
        
        PomodoroTimer.sharedInstance.start()
    }

    @IBAction func suspendTimer(sender: NSMenuItem) {
        if let _ = timer {
            timer.invalidate()
        }
    }
    
    @IBAction func resetTimer(sender: NSMenuItem) {
        if let _ = timer {
            timer.invalidate()
        }
        
        PomodoroTimer.sharedInstance.reset()
        statusItem.title = String(format: format, workTime, 0)
    }
    
    @IBAction func quit(sender: AnyObject) {
        PomodoroTimer.sharedInstance.reset()
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func showPreference(sender: AnyObject) {
        if let _ = timer {
            timer.invalidate()
        }

        preferencesWindow.showWindow(nil)
    }
    
    func countdown(timer: NSTimer) {
        PomodoroTimer.sharedInstance.updateDate(NSDate())
    }
    
    func notificationForTimeUp(status: PomodoroTimer.Status) {
        let notification = NSUserNotification()

        notification.deliveryDate = NSDate()

        if (status == PomodoroTimer.Status.Working) {
            notification.title = "働きましょう"
        } else {
            notification.title = "休憩しましょう"
        }

        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
        print("notificationForTimeUp: \(NSUserNotificationCenter.defaultUserNotificationCenter().deliveredNotifications)")
    }
    
    deinit {
        PomodoroTimer.sharedInstance.removeObserver(self, forKeyPath: "myDate", context: &myDateContext)
        PomodoroTimer.sharedInstance.removeObserver(self, forKeyPath: "workTime", context: &workTimeContext)
        PomodoroTimer.sharedInstance.removeObserver(self, forKeyPath: "restTime", context: &restTimeContext)
    }

}
