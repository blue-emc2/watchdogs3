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
    
    var userData: UserDefaults!
    var workTime: Int!
    var restTime: Int!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        userData = UserDefaults.standard
        workTime = userData.integer(forKey: PomodoroTimer.KEY_WORK_TIME) ?? 25
        if (workTime == 0) {
            workTime = 25
        }
        
        workTimeButton.selectItem(withTitle: "\(workTime)")
        
        restTime = userData.integer(forKey: PomodoroTimer.KEY_REST_TIME) ?? 5
        if (restTime == 0) {
            restTime = 5
        }
        
        breakTimeButton.selectItem(withTitle: "\(restTime)")
        
        print("\(workTime),    \(restTime),    \(workTimeButton.itemTitles), \(breakTimeButton.itemTitles)")
    }

    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    @IBAction func updateWorkTime(_ sender: NSPopUpButton) {
//        print("updateWorkTime begin")
        workTime = Int(sender.titleOfSelectedItem!)
//        print("updateWorkTime \(workTime) end")
    }
    
    @IBAction func updateBreakTime(_ sender: NSPopUpButton) {
//        print("updateBreakTime begin")
        restTime = Int(sender.titleOfSelectedItem!)
//        print("updateBreakTime \(restTime) end")
    }
    
    func windowWillClose(_ notification: Notification) {
        if let _ = userData {
            userData = UserDefaults.standard
        }
        
        userData.set(workTime!, forKey: PomodoroTimer.KEY_WORK_TIME)
        userData.set(restTime!, forKey: PomodoroTimer.KEY_REST_TIME)
        userData.synchronize()

        delegate?.preferencesDidUpdate()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: PomodoroTimer.UPDATE_TIME_SETTING),
                                                                  object: self,
                                                                  userInfo: ["work" : workTime,
                                                                    "rest" : restTime])
    }
}
