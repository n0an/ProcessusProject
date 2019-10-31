//
//  ANSignUpViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 04/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class ANSignUpViewController: UITableViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!

    @IBOutlet weak var scrollVIew: UIScrollView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var groupInfoButton: UIButton!
    
    // MARK: - ATTRIBUTES
    
    enum ANSignUpFieldType: Int {
        case login = 0, password, email, group
    }

   

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupInfoButton.isHidden = true

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANSignUpViewController.didTapImageView(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        let tapViewGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANSignUpViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        
        view.addGestureRecognizer(tapViewGestureRecognizer)
        
        imageView.addGestureRecognizer(tapGestureRecognizer)

        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        groupInfoButton.isHidden = true

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        

    }

    
    
    // MARK: - ACTIONS
    
    func didTapView() {
        groupInfoButton.isHidden = true

        self.view.endEditing(true)
    }
    
    func didTapImageView(_ sender: UITapGestureRecognizer) {
        
        let navController = storyboard?.instantiateViewController(withIdentifier: "ANPhotoAddingNavController") as! UINavigationController
        
        let destVC = navController.viewControllers[0] as! ANPhotoAddingViewController
        
        destVC.delegate = self
            
        present(navController, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func actionGroupIDInfoButtonPressed(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ANGroupInfoViewController")
        
        let navController = UINavigationController(rootViewController: vc!)
        
        self.present(navController, animated: true, completion: nil)
        
        
    }

    @IBAction func signUpButtonPressed(_ sender: AnyObject) {
        
        textFields.forEach {
            $0.resignFirstResponder()
        }
        
        
        // Show alert with error, if any field is empty when SignUp pressed
        var error = ""
        if textFields[0].text == "" {
            error = NSLocalizedString("CHAT_ERROR_LOGIN_FIELD", comment: "")
        } else if textFields[1].text == "" {
            error = NSLocalizedString("CHAT_ERROR_PASSWORD_FIELD", comment: "")
        } else if textFields[2].text == "" {
            error = NSLocalizedString("CHAT_ERROR_EMAIL_FIELD", comment: "")
        } else if textFields[3].text == "" {
            error = NSLocalizedString("CHAT_ERROR_GROUP_FIELD", comment: "")
        }
        
        if error != "" {
            
            let alertController = UIAlertController(title: NSLocalizedString("SIGNUP_ALERT_TITLE", comment: ""), message: NSLocalizedString("CHAT_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("CHAT_ALERT_MESSAGE2", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }

        // If all fields are filled - save to Parse
        let user = PFUser()
        
        user.username = loginTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        user["group"] = groupTextField.text
        

        let imageData  = UIImageJPEGRepresentation(imageView.image!, 1.0)

        let imageFile = PFFile(name: "profileImage.png", data: imageData!)
        
        user["image"] = imageFile
        
        // sign up in background mode
        user.signUpInBackground { (complete: Bool, error: NSError?) in
            if error == nil {
                
                let installation: PFInstallation = PFInstallation.current()
                installation["user"] = PFUser.current()
                installation.saveInBackground()
                
                
                self.performSegue(withIdentifier: "toUsersSegue2", sender: self)
                
            } else {
                
                SweetAlert().showAlert(NSLocalizedString("CHAT_ALERT_TITLE", comment: ""), subTitle: error!.localizedDescription, style: AlertStyle.error)
                
                return
            }
        }

    }
    
    

}



// MARK: - UITextFieldDelegate

extension ANSignUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == textFields.last {
            groupInfoButton.isHidden = false
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == textFields.last {
            textField.resignFirstResponder()
            groupInfoButton.isHidden = true
        } else {
            
            let index = textFields.index(of: textField)
            let nextTextField = textFields[index! + 1]
            nextTextField.becomeFirstResponder()
            
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case ANSignUpFieldType.email.rawValue:
            let checkResult = ANTextFieldsChecker.sharedChecker.handleEmailTextField(textField, inRange: range, withReplacementString: string)
            
            return checkResult
            
        default:
            break
        }
        
        
        return true
    }

    
    
}


// MARK: - ANPhotoAddingVCDelegate

extension ANSignUpViewController: ANPhotoAddingVCDelegate {
    func photoSelectionDidEnd(_ photo: UIImage) {
        
        imageView.image = photo
        
    }
}














