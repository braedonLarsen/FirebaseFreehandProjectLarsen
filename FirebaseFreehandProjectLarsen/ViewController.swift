//
//  ViewController.swift
//  FirebaseFreehandProjectLarsen
//
//  Created by BRAEDON LARSEN on 1/13/23.
//

import UIKit
import FirebaseCore
import FirebaseDatabase



class Task
{
    var task: String
    var time: Int
    var ref = Database.database().reference()
    var key : String = ""
    
    init(task: String, time: Int) {
        self.task = task
        self.time = time
    }
    init(dict: [String: Any])
    {
        if let n = dict["task"] as? String{
            task = n
        }
        else {
            task = "null"
        }
        if let a = dict["time"] as? Int{
            time = a
        }
        else {
            time = 00
        }
    }
    func equals(tsk: Task) -> Bool
    {
        var out = false
        if tsk.task == self.task && tsk.time == self.time
        {
            out = true
        }
        return out
    }

    func saveToFirebase()
    {
        var dict = ["task" : task, "time": time] as [String : Any]
        key = ref.child("Tasks").childByAutoId().key ?? "0"
        ref.child("Tasks").child(key).setValue(dict)
        
    }
    func deleteToFirebase()
    {
        ref.child("Tasks").child(key).removeValue()
    }
    
}



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //vars
    var contents = [Task]()
    var lastAddedTask = Task(task: "", time: 0)
    @IBOutlet weak var tableViewOutlet: UITableView!
    @IBOutlet weak var taskOutlet: UITextField!
    @IBOutlet weak var timeOutlet: UITextField!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewOutlet.dequeueReusableCell(withIdentifier: "myCell")!
        cell.textLabel?.text = contents[indexPath.row].task
        cell.detailTextLabel?.text = String(contents[indexPath.row].time)
        return cell
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
        contents[indexPath.row].deleteToFirebase()
            contents.remove(at: indexPath.row)
            tableViewOutlet.reloadData()
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        var tempTask = taskOutlet.text!
        var tempTime = (Int(timeOutlet.text!))!
        var tempObj = Task(task: tempTask, time: tempTime)
      
        lastAddedTask = tempObj
        tempObj.saveToFirebase()
        //contents.append(tempObj)
        
        tableViewOutlet.reloadData()
        
        
    }
    
    
    
    override func viewDidLoad() {
        tableViewOutlet.delegate = self
        tableViewOutlet.dataSource = self
        
        var ref = Database.database().reference()
        
        ref.child("Tasks").observe(.childAdded){ snapshot in
            var dict = snapshot.value as! [String: Any]
            var temp = Task(dict: dict)
            temp.key = snapshot.key
            if !(temp.equals(tsk: self.lastAddedTask))
            {
                self.contents.append(temp)
            }
            self.tableViewOutlet.reloadData()
        }
        ref.child("Tasks").observe(.childRemoved){ snapshot in
            var dict = snapshot.value as! [String: Any]
            
            for i in 0..<self.contents.count {
                if self.contents[i].key == snapshot.key
                {
                    self.contents.remove(at: i)
                    self.tableViewOutlet.reloadData()
                    break
                }
            }
            
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

