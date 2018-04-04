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
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userPicker: UIPickerView!
    
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
            self.deleteButton.isHidden = true
        }
        let db = Firestore.firestore()

        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
//                self.userPicker.dataSource
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//
//                }
            }
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
        self.displayTaskUsers()
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

    func deleteTask() {
        let db = Firestore.firestore()

        db.collection("tasks").document(documentID!).delete()
    }
    
    @IBAction func addUserToTask() {
        var userList = documentData["users"] as! [String: Bool]
        
        // userList[user.uid] = true
        documentData["users"] = userList
    }
    
    func displayTaskUsers() {
        var userList = documentData["users"] as! [String: Bool]

    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "fromCancel":
            print ("Cancel changes...")
        case "fromSave":
            print ("Saving task...")
            self.saveTask()
        case "fromDelete":
            print ("Deleting task...")
            self.deleteTask()
        default:
            print ("Unknown segue identifier ", identifier)
        }
    }
}
