//
//  PreferencesWindow.swift
//  watchdogs2
//
//  Created by shunsuke on 2016/06/26.
//  Copyright © 2016年 panpanpan. All rights reserved.
//

import Cocoa

// 最後のclassよくわからない
protocol PreferencesWindowDelegate: class {
    func preferencesDidUpdate()
}

class PreferencesWindow: NSWindowController, NSWindowDelegate {
    weak var delegate: PreferencesWindowDelegate?
    
    @IBOutlet weak var breakTimeButton: NSPopUpButton!
    @IBOutlet weak var workTimeButton: NSPopUpButton!
    
    var userData: NSUserDefaults!
    var workTime: Int!
    var restTime: Int!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        
        userData = NSUserDefaults.standardUserDefaults()
        workTime = userData.integerForKey("workTime") ?? 25
        if (workTime == 0) {
            workTime = 25
        }
        
        workTimeButton.selectItemWithTitle("\(workTime)")
        
        restTime = userData.integerForKey("restTime") ?? 5
        if (restTime == 0) {
            restTime = 5
        }
        
        breakTimeButton.selectItemWithTitle("\(restTime)")
        
        print("\(workTime),    \(restTime),    \(workTimeButton.itemTitles), \(breakTimeButton.itemTitles)")
    }

    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    @IBAction func updateWorkTime(sender: NSPopUpButton) {
        print("updateWorkTime begin")
        
//        PomodoroTimer.sharedInstance.workTime = sender.titleOfSelectedItem
        workTime = Int(sender.titleOfSelectedItem!)

        print("updateWorkTime \(workTime) end")
    }
    
    @IBAction func updateBreakTime(sender: NSPopUpButton) {
        print("updateBreakTime begin")
        
//        PomodoroTimer.sharedInstance.restTime = sender.titleOfSelectedItem
        restTime = Int(sender.titleOfSelectedItem!)
            
        print("updateBreakTime \(restTime) end")
    }
    
    func windowWillClose(notification: NSNotification) {
        if let _ = userData {
            userData = NSUserDefaults.standardUserDefaults()
        }
        
        userData.setInteger(workTime!, forKey: "workTime")
        userData.setInteger(restTime!, forKey: "breakTime")
        userData.synchronize()

        delegate?.preferencesDidUpdate()
        
        NSNotificationCenter.defaultCenter().postNotificationName(PomodoroTimer.UPDATE_TIME_SETTING,
                                                                  object: self,
                                                                  userInfo: ["work" : workTime,
                                                                    "rest" : restTime])
    }
}
