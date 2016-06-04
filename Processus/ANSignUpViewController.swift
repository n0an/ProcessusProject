//
//  ANSignUpViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 04/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse

class ANSignUpViewController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var groupTextField: UITextField!

    @IBOutlet weak var scrollVIew: UIScrollView!


    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANSignUpViewController.didTapImageView(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        imageView.addGestureRecognizer(tapGestureRecognizer)

        
    }
    
    // MARK: - HELPER METHODS
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // !!!IMPORTANT!!!
        self.view.endEditing(true)
    }
    
    
    
    
    // MARK: - ACTIONS
    
    func didTapImageView(sender: UITapGestureRecognizer) {
        
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imageVC.allowsEditing = true
        
        presentViewController(imageVC, animated: true, completion: nil)
        
    }

    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        let user = PFUser()
        
        user.username = loginTextField.text
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        user["group"] = groupTextField.text
        
        let imageData = UIImagePNGRepresentation(imageView.image!)
        let imageFile = PFFile(name: "profileImage.png", data: imageData!)
        
        user["image"] = imageFile
        
        // sign up in background mode
        user.signUpInBackgroundWithBlock { (complete: Bool, error: NSError?) in
            if error == nil {
                
                let installation: PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                
                print("SUCCESS SIGN UP!!")
                
                self.performSegueWithIdentifier("toUsersSegue2", sender: self)
                
            } else {
                return
            }
        }

        
        
        
    }

}



extension ANSignUpViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imageView.image = image
        
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
}


extension ANSignUpViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // TODO: resign become
        
        
        return true
    }
    
    
}










