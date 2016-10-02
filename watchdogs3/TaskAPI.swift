//
//  TaskAPI.swift
//  watchdogs3
//
//  Created by shunsuke on 2016/09/13.
//
//

import Foundation

struct Task: CustomStringConvertible {
    
    var status: String
    var title: String
    var date: String
    
    var description: String {
        return ("title: \(title), date: \(date)")
    }
}

class TaskAPI {
    let BASE_URL = "http://localhost:3000/tasks"
    
    let DUMMY_DATA: String = "[{\"id\":1,\"user_id\":1,\"name\":\"サンプルタスク\",\"description\":\"サンプルテスト\",\"state\":\"created\",\"created_at\":\"2016-09-10T21:58:45.691+09:00\",\"updated_at\":\"2016-09-10T21:58:45.691+09:00\"},{\"id\":2,\"user_id\":1,\"name\":\"サンプルタスク\",\"description\":\"サンプルテスト\",\"state\":\"created\",\"created_at\":\"2016-09-10T22:06:36.517+09:00\",\"updated_at\":\"2016-09-10T22:06:36.517+09:00\"},{\"id\":3,\"user_id\":1,\"name\":\"サンプルタスク\",\"description\":\"サンプルテスト\",\"state\":\"created\",\"created_at\":\"2016-09-11T20:57:55.418+09:00\",\"updated_at\":\"2016-09-11T20:57:55.418+09:00\"},{\"id\":4,\"user_id\":1,\"name\":\"curl\",\"description\":\"curl2\",\"state\":\"created\",\"created_at\":\"2016-09-22T22:08:38.622+09:00\",\"updated_at\":\"2016-09-22T22:08:38.622+09:00\"}]"

    let url: URL?
    let config: URLSessionConfiguration
    let session: URLSession
    
    init() {
        url = URL(string: BASE_URL)
        config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
    }
    
    func fetchTaskList(_ query: String = "", success: @escaping (NSArray) -> Void) {
        let req = URLRequest(url: url!)
        
        let task = session.dataTask(with: req, completionHandler: {
            (data, resp, err) in
            if err != nil {
                print("ERROR: \(err?.localizedDescription)")
//                let a = self.dummy()
//                print("a: \(a)")
                return
            }
            
            if let httpResponse = resp as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let response = self.taskIndexFromJson(data: data!) {
                        success(response)
                    }
                default:
                    print("status: \(httpResponse.statusCode)")
                }
            }
            
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        })
        task.resume()
    }
    
    func taskIndexFromJson(data: Data) -> NSArray? {
        let json: Array<NSDictionary>
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as! Array<NSDictionary>
        } catch {
            print("error")
            return nil
        }
        
        let tasks = json.map { (d:NSDictionary) -> Task in
            return Task(status: d["state"] as! String,
                        title: d["name"] as! String,
                        date: d["created_at"] as! String)
        }
        
        return NSArray(array: tasks)
    }
    
    func addTask(title: String, success: @escaping (NSArray) -> Void) {
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "name" : title,
            "description" : "",
            "user_id" : "1"
        ]
        
        do {
            try request.httpBody = JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print("httpBody \(params)")
            return
        }
        
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, resp, err) in
            
            if err != nil {
                print("ERROR: \(err?.localizedDescription)")
                return
            }
            
            if let httpResponse = resp as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    if let response = self.taskIndexFromJson(data: data!) {
                        success(response)
                    }
                default:
                    print("status: \(httpResponse.statusCode)")
                }
            }
            
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        })
        dataTask.resume()
    }

    /*
    func dummy() -> NSArray? {
        let data = DUMMY_DATA.data(using: String.Encoding.utf8)
        let json: Array<NSDictionary>
        do {
            json = try JSONSerialization.jsonObject(with: data!, options: []) as! Array<NSDictionary>
            print("dummy: \(json)")
        } catch {
            print("erroe")
            return nil
        }
        
        let tasks = json.map { (d:NSDictionary) -> Task in
            print("d: \(d)")
            return Task(status: d["state"] as! String,
                 title: d["name"] as! String)
        }

        return NSArray(array: tasks)
    }
    */
}
