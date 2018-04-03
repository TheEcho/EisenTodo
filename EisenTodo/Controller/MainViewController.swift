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

    @IBOutlet weak var usernameLabel: UILabel!
    var authStateHandle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authStateHandle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let name = user?.displayName {
                self.usernameLabel.text = "Hello \(name)"
            }
        }
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(authStateHandle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
