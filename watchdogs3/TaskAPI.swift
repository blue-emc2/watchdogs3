//
//  TaskAPI.swift
//  watchdogs3
//
//  Created by shunsuke on 2016/09/13.
//
//

import Foundation

class TaskAPI {
    let BASE_URL = "http://localhost:3000/tasks"
    
    func fetchTaskList(_ query: String) {
        let url = URL(string: BASE_URL)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let req = URLRequest(url: url!)
        
        let task = session.dataTask(with: req, completionHandler: {
            (data, resp, err) in
            if err != nil {
                print("ERROR: \(err?.localizedDescription)")
                return
            }
            
            if let httpResponse = resp as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200: // all good!
                    let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as! String
                    print(dataString)
                default:
                    print("status: \(httpResponse.statusCode)")
                }
            }
            
            print(resp!.url!)
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        })
        task.resume()
    }
}
