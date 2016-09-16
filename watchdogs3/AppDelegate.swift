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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        print("applicationDidFinishLaunching")
        NSUserNotificationCenter.default.delegate = self

        print("start")
        let api = TaskAPI()
        api.fetchTaskList("hoge")
        print("end")
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}

