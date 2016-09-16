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
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    fileprivate var myDateContext = 0
    fileprivate var workTimeContext = 1
    fileprivate var restTimeContext = 2
    
    var preferencesWindow: PreferencesWindow!
    let tasksPopover: NSPopover! = NSPopover()
    
    var userData: UserDefaults!
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
        userData = UserDefaults.standard
    }

    func countDown(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let time = userInfo["time"] as! Double
            
            if (time <= 0.9) {
                statusItem.title = String(format: format, 0, 0)
                notificationForTimeUp(PomodoroTimer.sharedInstance.status)
                startTimer("" as AnyObject)
                return
            }

            statusItem.title = String(format: format, Int(time / 60.0), Int(time.truncatingRemainder(dividingBy: 60.0)))
        }
    }
    
    func updatePrefTimes(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            let work = userInfo["work"] as! Int
            statusItem.title = String(format: format, work ?? 25, 0)
        }
        
//        statusItem.attributedTitle
    }
    
    override func awakeFromNib() {
        workTime = userData.integer(forKey: PomodoroTimer.KEY_WORK_TIME)
        breakTime = userData.integer(forKey: PomodoroTimer.KEY_REST_TIME)
//        print("awakeFromNib \(workTime), \(breakTime)")
        
        statusItem.title = String(format: format, workTime, 0)
        statusItem.menu = statusMenu
        
        preferencesWindow = PreferencesWindow()
        
        tasksPopover.contentViewController = TasksViewController(nibName: "TasksViewController", bundle: nil)
    }
    
    @IBAction func startTimer(_ sender: AnyObject) {
        PomodoroTimer.sharedInstance.start()
    }

    @IBAction func suspendTimer(_ sender: NSMenuItem) {
        PomodoroTimer.sharedInstance.suspend()
    }
    
    @IBAction func resetTimer(_ sender: NSMenuItem) {
        PomodoroTimer.sharedInstance.reset()
        workTime = userData.integer(forKey: PomodoroTimer.KEY_WORK_TIME)
        statusItem.title = String(format: format, workTime, 0)
    }
    
    @IBAction func quit(_ sender: AnyObject) {
        PomodoroTimer.sharedInstance.reset()
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func showPreference(_ sender: AnyObject) {
        PomodoroTimer.sharedInstance.reset()
        preferencesWindow.showWindow(nil)
    }
    
    @IBAction func showTasks(_ sender: AnyObject) {
    }
    
    func notificationForTimeUp(_ status: PomodoroTimer.Status) {
        print("notificationForTimeUp : \(status)")
        let notification = NSUserNotification()

        notification.deliveryDate = Date()

        if (status == PomodoroTimer.Status.working) {
            notification.title = "休憩しましょう"
        } else {
            notification.title = "働きましょう"
        }

        NSUserNotificationCenter.default.deliver(notification)
    }
}
