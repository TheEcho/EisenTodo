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

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

class TaskViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var taskTitle: UITextView!
    @IBOutlet weak var taskDescription: UITextView!
    @IBOutlet weak var taskDueDate: UIDatePicker!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var userPicker: UIPickerView!
    @IBOutlet weak var userDisplay: UIStackView!
    
    var documentID: String?
    var documentData: [String: Any] = [:]
    var users: [[String: Any]] = []

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
        
        self.userPicker.dataSource = self
        self.userPicker.delegate = self

        let db = Firestore.firestore()

        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.users.append(document.data())
                }
                self.userPicker.reloadAllComponents()
                self.displayTaskUsers()
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
        var usersList = documentData["users"] as! [String: Bool]
        
        usersList[self.users[self.userPicker.selectedRow(inComponent: 0)]["uid"] as! String] = true
        documentData["users"] = usersList
        self.displayTaskUsers()
    }
    
    func displayTaskUsers() {
        let usersList = documentData["users"] as! [String: Bool]
        
        self.userDisplay.removeAllArrangedSubviews()
        
        for user in usersList {
            DispatchQueue.global().async {
                let userdata = self.users.first(where: { (item) -> Bool in
                    item["uid"] as! String == user.key
                })!
                let photoUrl = userdata["photoUrl"] as? String
                
                if photoUrl != nil && !photoUrl!.isEmpty {
                    let data = try? Data(contentsOf: URL(string: photoUrl!)!)
                    DispatchQueue.main.async {
                        let userPic = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
                        
                        userPic.image = UIImage(data: data!)
                        self.userDisplay.addArrangedSubview(userPic)
                    }
                }
            }
        }
    }
    
    func reset() {
        self.documentID = nil
        self.documentData = [:]
        self.users = []
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
    
    // MARK: UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // Column count: use one column.
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        // Row count: rows equals array length.
        return users.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        // Return a string from the array for this row.
        return users[row]["displayName"] as! String
    }
}
