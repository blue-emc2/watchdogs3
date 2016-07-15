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
    var workTime: String!
    var restTime: String!
    
    private var myContext = 1
    
    override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activateIgnoringOtherApps(true)
        
        userData = NSUserDefaults.standardUserDefaults()
        workTime = userData.stringForKey("workTime") ?? "25"
        workTimeButton.selectItemWithTitle(workTime)
        
        restTime = userData.stringForKey("restTime") ?? "5"
        breakTimeButton.selectItemWithTitle(restTime)
        
        print("\(workTime),    \(restTime),    \(workTimeButton.itemTitles), \(breakTimeButton.itemTitles)")
    }

    override var windowNibName : String! {
        return "PreferencesWindow"
    }
    
    @IBAction func updateWorkTime(sender: NSPopUpButton) {
        print("updateWorkTime begin")
        
        PomodoroTimer.sharedInstance.workTime = sender.titleOfSelectedItem
        workTime = sender.titleOfSelectedItem

        print("updateWorkTime end")
    }
    
    @IBAction func updateBreakTime(sender: NSPopUpButton) {
        print("updateBreakTime begin")
        
        PomodoroTimer.sharedInstance.restTime = sender.titleOfSelectedItem
        restTime = sender.titleOfSelectedItem
            
        print("updateBreakTime end")
    }
    
    func windowWillClose(notification: NSNotification) {
        if let _ = userData {
            userData = NSUserDefaults.standardUserDefaults()
        }
        
        userData.setInteger(Int(workTime)!, forKey: "workTime")
        userData.setInteger(Int(restTime)!, forKey: "breakTime")
        userData.synchronize()

        delegate?.preferencesDidUpdate()
    }
}
