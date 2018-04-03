//
//  MainViewController.swift
//  EisenTodo
//
//  Created by Alex on 02/04/2018.
//  Copyright © 2018 ByeByeCycleToDie. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    var authStateHandle: AuthStateDidChangeListenerHandle?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authStateHandle = Auth.auth().addStateDidChangeListener { (auth, user) in

        }
        fetchData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Data Handling (note: firebase uid is unique)
    
    func fetchData() {
        let user = Auth.auth().currentUser

        if let user = user {
            let db = Firestore.firestore()
            
            print("Retrieving user document with firebase uid \(user.uid)...")
            
            db.collection("users").whereField("uid", isEqualTo: user.uid)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else if querySnapshot!.documents.count > 1 {
                        print("Error: multiple documents with same firebase uid")
                    } else if querySnapshot!.documents.count < 1 {
                        print("No document with this firebase uid. Creating one...")
                        self.createUserData(user: user)
                    } else {
                        let document = querySnapshot!.documents.first!
                        self.userId = (document.data()["uid"] as! String)
                        print("\(document.documentID) => \(document.data())")
                        self.fetchUserTasks()
                    }
            }
        }
    }
    
    func createUserData(user: User) {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil

        ref = db.collection("users").addDocument(data: [
            "displayName": user.displayName as Any,
            "photoUrl": user.photoURL?.absoluteString as Any,
            "uid": user.uid
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.fetchData()
            }
        }
    }
    
    func fetchUserTasks() {
        if let uid = self.userId {
            let db = Firestore.firestore()

            print("Retrieving documents for uid \(uid) : ")

            db.collection("tasks").whereField("users.\(uid)", isEqualTo: true)
                .getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            // Display tasks ...
                        }
                        print("Done with \(querySnapshot!.documents.count) document(s).")
                    }
            }
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindToHome(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "fromSignOut":
            print ("Signing out...")
            
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        default:
            print ("Unknown segue identifier ", identifier)
        }
    }
    
}
