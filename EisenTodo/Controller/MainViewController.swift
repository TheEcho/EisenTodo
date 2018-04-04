//
//  MainViewController.swift
//  EisenTodo
//
//  Created by Alex on 02/04/2018.
//  Copyright © 2018 ByeByeCycleToDie. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var authStateHandle: AuthStateDidChangeListenerHandle?
    var userId: String?
    var tasks: [[String: Any]] = []

    @IBOutlet weak var CollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authStateHandle = Auth.auth().addStateDidChangeListener { (auth, user) in

        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Data Handling (note: firebase uid is unique)
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
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
                            self.tasks.append(document.data())
                        }
                        print("Done with \(querySnapshot!.documents.count) document(s).")
                        self.CollectionView.reloadData()
                    }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! CollectionCellController
        if (self.tasks.count > 0) {
            let myFormatter = DateFormatter()

            myFormatter.dateStyle = .medium
            let date = myFormatter.string(from: self.tasks[indexPath.item]["dueDate"] as! Date)

            cell.name.text = self.tasks[indexPath.item]["title"] as! String
            cell.date.text = date
            if (self.tasks[indexPath.item]["importance"] as! Int == 1 && self.tasks[indexPath.item]["status"] as! Int == 1) {
                cell.backgroundColor = hexStringToUIColor(hex: "#D55F3F")
            } else if (self.tasks[indexPath.item]["importance"] as! Int == 0 && self.tasks[indexPath.item]["status"] as! Int == 1) {
                cell.backgroundColor = hexStringToUIColor(hex: "#91CE5B")
            } else if (self.tasks[indexPath.item]["importance"] as! Int == 1 && self.tasks[indexPath.item]["status"] as! Int == 0) {
                cell.backgroundColor = hexStringToUIColor(hex: "#51A6B7")
            } else if (self.tasks[indexPath.item]["importance"] as! Int == 0 && self.tasks[indexPath.item]["status"] as! Int == 0) {
                cell.backgroundColor = hexStringToUIColor(hex: "#B7D496")
            }
        }
        return cell
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
