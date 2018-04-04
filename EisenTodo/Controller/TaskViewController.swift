//
//  TaskInfoViewController.swift
//  EisenTodo
//
//  Created by Alex on 03/04/2018.
//  Copyright © 2018 ByeByeCycleToDie. All rights reserved.
//

import UIKit
import Firebase

extension Date {
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
}

class TaskViewController: UIViewController {

    @IBOutlet weak var taskTitle: UITextView!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskDueDate: UIDatePicker!

    var documentID: String?
    var documentData: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        if let documentID = documentID {
            print("Open Task View for document \(documentID)")
        } else {
            documentData = [
                "title": "Task Title",
                "description": "Description",
                "users": [:],
                "importance": 1,
                "status": 0,
                "dueDate": Date().tomorrow
            ]
        }
        self.documentToDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    
    func documentToDisplay() {
        self.taskTitle.text = self.documentData["title"] as! String
        self.taskDescription.text = self.documentData["description"] as! String
        self.taskDueDate.date = self.documentData["dueDate"] as! Date
    }

    func displayToDocument() {
        self.documentData["title"] = self.taskTitle.text
        self.documentData["description"] = self.taskDescription.text
        self.documentData["dueDate"] = self.taskDueDate.date
    }
    
    func saveTask() {
        let db = Firestore.firestore()
        let user = Auth.auth().currentUser!
        
        self.displayToDocument()
        
        var userList = documentData["users"] as! [String: Bool]
        
        userList[user.uid] = true
        documentData["users"] = userList
        
        if let documentID = documentID {
            db.collection("tasks").document(documentID).setData(documentData)
        } else {
            db.collection("tasks").document().setData(documentData)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "fromCancel":
            print ("Cancel changes...")
        case "fromSave":
            self.saveTask()
            print ("Saving task...")
        default:
            print ("Unknown segue identifier ", identifier)
        }
    }
}
