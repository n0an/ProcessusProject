//
//  ANLoginViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 04/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class ANLoginViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANLoginViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    // MARK: - HELPER METHODS
    
    
    
    // MARK: - ACTIONS

    func didTapView() {
        self.view.endEditing(true)
    }

    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        PFUser.logInWithUsernameInBackground(loginTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) in
            
            guard error == nil else {
                print("Can't login")
                print("error: \(error?.localizedDescription)")
                return
            }
            
            let installation: PFInstallation = PFInstallation.currentInstallation()
            installation["user"] = PFUser.currentUser()
            
            installation.saveInBackground()
            
            self.performSegueWithIdentifier("toUsersSegue1", sender: self)
            
            
        }
        
        
        
        
    }
    
    @IBAction func createAccButtonPressed(sender: AnyObject) {
    }
    

    
}
