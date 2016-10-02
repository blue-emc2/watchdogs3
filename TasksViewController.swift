//
//  TasksViewController.swift
//  watchdogs3
//
//  Created by shunsuke on 2016/09/18.
//
//

import Cocoa

class TasksViewController: NSWindowController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var taskTitleView: NSTextField!
    
    var tasks: NSArray?
    let taskAPI = TaskAPI()
    
    override var windowNibName : String! {
        return "TasksViewController"
    }

    override func windowWillLoad() {
        print("windowWillLoad")
        // task#index
        taskAPI.fetchTaskList() {tasklist in
            print("set list")
            self.tasks = tasklist
            self.tableView.reloadData()
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    @IBAction func postTask(_ sender: AnyObject) {
        if taskTitleView.stringValue.isEmpty == true {
            return
        }
        
        // task#create
        taskAPI.addTask(title: taskTitleView.stringValue, success: {tasklist in
            DispatchQueue.main.async(execute: {
                self.tasks = tasklist
                self.tableView.reloadData()
            })
        })
    }
    
}

extension TasksViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        print("numberOfRows \(tasks?.count)")
        return tasks?.count ?? 0
    }
}

extension TasksViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text = ""
        var cellIdentifier = ""
        
        guard let task: Task = tasks?[row] as! Task? else {
            return nil
        }
        
        if tableColumn == tableView.tableColumns[0] {
            // 表示するデータを取得
            cellIdentifier = "CheckCellID"
        } else if tableColumn == tableView.tableColumns[1] {
            // 表示するデータを取得
            text = convertDateFormat(dateStr: task.date)
            cellIdentifier = "DateCellID"
        } else if tableColumn == tableView.tableColumns[2] {
            // 表示するデータを取得
            text = task.title
            cellIdentifier = "TitleCellID"
        }

        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func convertDateFormat(dateStr: String) -> String {
        print("date format \(dateStr)")
        
        if dateStr.isEmpty == true {
            return ""
        }
        
        let inFormatter = DateFormatter()
        inFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date:NSDate = inFormatter.date(from: dateStr)! as NSDate
        
        // NSDateから指定のフォーマットの文字列に変換します
        let outFormatter = DateFormatter()
        outFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        return outFormatter.string(from: date as Date)
    }
}
