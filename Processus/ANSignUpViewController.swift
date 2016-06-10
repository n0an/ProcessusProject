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
        case Login = 0, Password, Email, Group
    }

   

    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupInfoButton.hidden = true

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANSignUpViewController.didTapImageView(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        let tapViewGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANSignUpViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        
        view.addGestureRecognizer(tapViewGestureRecognizer)
        
        imageView.addGestureRecognizer(tapGestureRecognizer)

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
//        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        groupInfoButton.hidden = true
        
//        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone5.rawValue {
//            tableView.scrollEnabled = true
//        } else {
//            tableView.scrollEnabled = false
//            
//        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        setScrollViewContentSize()
    }

    
    // MARK: - NOTIFICATIONS
    
    func keyboardWillShow(notification: NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone6Plus.rawValue {
            
            tableView.scrollEnabled = true
//            updateBottomConstraint(notification, showing: true)
            
//            setScrollViewContentSize()

        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone5.rawValue {
            tableView.scrollEnabled = true
            
//            updateBottomConstraint(notification, showing: false)
            
//            setScrollViewContentSize()

        } else {
            tableView.scrollEnabled = false
        }
        
    }

    
    // MARK: - HELPER METHODS
    
    func setScrollViewContentSize() {
        
        var contentRect = CGRectZero
        
        for view in contentView.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        
        scrollVIew.contentSize = CGSizeMake(CGRectGetWidth(view.frame), CGRectGetHeight(contentRect))
        
    }
    
    
    func updateBottomConstraint(notification: NSNotification, showing: Bool) {
        
        if let
            userInfo = notification.userInfo,
            frame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue,
            animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
            
            let newFrame = view.convertRect(frame, fromView: (UIApplication.sharedApplication().delegate?.window)!)
            
            let diff = showing ? 49 : 0
            
            bottomConstraint.constant = CGRectGetHeight(view.frame) - newFrame.origin.y - CGFloat(diff)
            
            UIView.animateWithDuration(animationDuration, animations: {
                self.view.layoutIfNeeded()
                
                if showing {
                    let scrollViewOffset: CGPoint = CGPointMake(0, self.scrollVIew.contentSize.height - self.scrollVIew.bounds.height)
                    
                    self.scrollVIew.setContentOffset(scrollViewOffset, animated: true)
                }
                
                
            })
            
        }
        
    }


    
    
    // MARK: - ACTIONS
    
    func didTapView() {
        groupInfoButton.hidden = true

        self.view.endEditing(true)
    }
    
    func didTapImageView(sender: UITapGestureRecognizer) {
        
        let navController = storyboard?.instantiateViewControllerWithIdentifier("ANPhotoAddingNavController") as! UINavigationController
        
        let destVC = navController.viewControllers[0] as! ANPhotoAddingViewController
        
        destVC.delegate = self
            
        presentViewController(navController, animated: true, completion: nil)
        
        
    }
    
    
    @IBAction func actionGroupIDInfoButtonPressed(sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANGroupInfoViewController")
        
        let navController = UINavigationController(rootViewController: vc!)
        
        self.presentViewController(navController, animated: true, completion: nil)
        
        
    }

    @IBAction func signUpButtonPressed(sender: AnyObject) {
        
        textFields.forEach {
            $0.resignFirstResponder()
        }
        
        
        // Show alert with error, if any field is empty when SignUp pressed
        var error = ""
        if textFields[0].text == "" {
            error = "Login"
        } else if textFields[1].text == "" {
            error = "Password"
        } else if textFields[2].text == "" {
            error = "Email"
        } else if textFields[3].text == "" {
            error = "Group"
        }
        
        if error != "" {
            
            let alertController = UIAlertController(title: "Can't sign up", message: "Please fill " + error + " field", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
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
        user.signUpInBackgroundWithBlock { (complete: Bool, error: NSError?) in
            if error == nil {
                
                let installation: PFInstallation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                
                print("SUCCESS SIGN UP!!")
                
                self.performSegueWithIdentifier("toUsersSegue2", sender: self)
                
            } else {
                
                SweetAlert().showAlert("Error!", subTitle: error!.localizedDescription, style: AlertStyle.Error)
                
                return
            }
        }

    }
    
    

}



// MARK: - UITextFieldDelegate

extension ANSignUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField == textFields.last {
            groupInfoButton.hidden = false
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == textFields.last {
            textField.resignFirstResponder()
            groupInfoButton.hidden = true
        } else {
            
            let index = textFields.indexOf(textField)
            let nextTextField = textFields[index! + 1]
            nextTextField.becomeFirstResponder()
            
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        switch textField.tag {
        case ANSignUpFieldType.Email.rawValue:
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
    func photoSelectionDidEnd(photo: UIImage) {
        
        imageView.image = photo
        
    }
}














