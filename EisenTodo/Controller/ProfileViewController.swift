//
//  ProfileViewController.swift
//  EisenTodo
//
//  Created by Alex on 03/04/2018.
//  Copyright © 2018 ByeByeCycleToDie. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
