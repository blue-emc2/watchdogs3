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
        PomodoroTimer.sharedInstance.addNotificationCenterObserver(observer: self,
                                                                   selector: #selector(countDown(_:)),
                                                                   name: PomodoroTimer.COUNT_DOWN,
                                                                    userInfo: nil)
        PomodoroTimer.sharedInstance.addNotificationCenterObserver(observer: self,
                                                                   selector: #selector(updatePrefTimes(_:)),
                                                                   name: PomodoroTimer.UPDATE_TIME_SETTING,
                                                                    userInfo: nil)
        userData = NSUserDefaults.standardUserDefaults()
    }

    func countDown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            var time = userInfo["time"] as! Double
            
            if (time <= 0.0) {
                statusItem.title = String(format: format, 0, 0)
                notificationForTimeUp(PomodoroTimer.sharedInstance.status)
                startTimer("")
                return
            }
            time += 0.1 // 59秒対策
            // 0.9秒で呼ばれる時があるので、23.000の時に0.01で調整する
            statusItem.title = String(format: format, Int(time / 60.0), Int(time % 60.0 - 0.01))
        }
    }
    
    func updatePrefTimes(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let work = userInfo["work"] as! Int
            statusItem.title = String(format: format, work ?? 25, 0)
        }
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
        
    @IBAction func startTimer(sender: AnyObject) {
        PomodoroTimer.sharedInstance.start()
    }

    @IBAction func suspendTimer(sender: NSMenuItem) {
        PomodoroTimer.sharedInstance.suspend()
    }
    
    @IBAction func resetTimer(sender: NSMenuItem) {
        PomodoroTimer.sharedInstance.reset()
        statusItem.title = String(format: format, workTime, 0)
    }
    
    @IBAction func quit(sender: AnyObject) {
        PomodoroTimer.sharedInstance.reset()
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func showPreference(sender: AnyObject) {
        PomodoroTimer.sharedInstance.reset()
        preferencesWindow.showWindow(nil)
    }
    
    func notificationForTimeUp(status: PomodoroTimer.Status) {
        print("notificationForTimeUp : \(status)")
        let notification = NSUserNotification()

        notification.deliveryDate = NSDate()

        if (status == PomodoroTimer.Status.Working) {
            notification.title = "休憩しましょう"
        } else {
            notification.title = "働きましょう"
        }

        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
}
