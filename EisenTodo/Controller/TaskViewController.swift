//
//  TaskInfoViewController.swift
//  EisenTodo
//
//  Created by Alex on 03/04/2018.
//  Copyright © 2018 ByeByeCycleToDie. All rights reserved.
//

import UIKit
import Firebase

class TaskViewController: UIViewController {

    var documentID: String?
    var documentData: [String: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        if let documentID = documentID {
            print("Open Task View for document \(documentID)")
        } else {
            documentData = [
                "title": "",
                "description": "",
                "users": {
                    // "{uid}": true;
                },
                "importance": 1,
                "status": 0,
                "dueDate": 0 // "2018-04-03 22:00:00 +0000"
            ]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    
    func saveTask() {
        let db = Firestore.firestore()

//        db.collection("tasks").document(documentID).setData(documentData)
        
//        if let documentID = documentID {
//            
//        } else {
//            
//        }
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
