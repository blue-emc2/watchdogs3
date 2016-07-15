//
//  AppDelegate.swift
//  watchdogs2
//
//  Created by shunsuke on 2016/06/26.
//  Copyright © 2016年 panpanpan. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        print("applicationDidFinishLaunching")
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }

    func applicationWillTerminate(aNotification: NSNotification) {
    }

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}

