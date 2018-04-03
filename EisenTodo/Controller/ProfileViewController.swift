//
//  ProfileViewController.swift
//  EisenTodo
//
//  Created by Alex on 03/04/2018.
//  Copyright © 2018 ByeByeCycleToDie. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    
    @IBOutlet weak var profileUsername: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let user = Auth.auth().currentUser
        
        if let user = user {
            self.profileEmail.text = user.email
            self.profileUsername.text = user.displayName
            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: user.photoURL!)
                DispatchQueue.main.async {
                    self.profilePhoto.image = UIImage(data: data!)
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "fromBack":
            print ("Back to Home...")
        default:
            print ("Unknown segue identifier ", identifier)
        }
    }

}
