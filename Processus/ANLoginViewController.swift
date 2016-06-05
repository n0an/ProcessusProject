//
//  ANLoginViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 04/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import Parse


enum ANiOSScreenHeights: CGFloat {
    case iPhone4        = 480
    case iPhone5        = 568
    case iPhone6        = 667
    case iPhone6Plus    = 736
}


class ANLoginViewController: UIViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var scrollVIew: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = PFUser.currentUser() {
            if user.authenticated {
                self.performSegueWithIdentifier("toUsersSegue1", sender: nil)
            }
        }
        
        // ** REGISTERING FOR PUSH NOTIFICATIONS
        let userNotificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANLoginViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone5.rawValue {
            scrollVIew.scrollEnabled = true
        } else {
            scrollVIew.scrollEnabled = false
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setScrollViewContentSize()
    }
    
    // MARK: - NOTIFICATIONS
    
    func keyboardWillShow(notification: NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone6.rawValue {
            
            scrollVIew.scrollEnabled = true
            updateBottomConstraint(notification, showing: true)
            
            setScrollViewContentSize()

        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone6.rawValue {
            scrollVIew.scrollEnabled = false
            updateBottomConstraint(notification, showing: false)

            setScrollViewContentSize()

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
        self.view.endEditing(true)
    }

    @IBAction func loginButtonPressed(sender: AnyObject) {
        
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // Show alert with error, if any field is empty when SignUp pressed
        var error = ""
        
        if loginTextField.text == "" {
            error = "Login"
            
        } else if passwordTextField.text == "" {
            error = "Password"
            
        }
        
        if error != "" {
            
            let alertController = UIAlertController(title: "Error", message: "Please fill " + error + " field", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
            return
        }
        
        PFUser.logInWithUsernameInBackground(loginTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) in
            
            guard error == nil else {
                print("Can't login")
                print("error: \(error?.localizedDescription)")
                
                SweetAlert().showAlert("Error!", subTitle: error!.localizedDescription, style: AlertStyle.Error)
                
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


// MARK: - UITextFieldDelegate

extension ANLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == passwordTextField {
            textField.resignFirstResponder()
        } else {
            
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    
}




















