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
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollVIew.scrollEnabled = false

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANLoginViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ANLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

        
    }
    
    // MARK: - NOTIFICATIONS
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone6.rawValue {
            
            scrollVIew.scrollEnabled = true
            updateBottomConstraint(notification, showing: true)
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if UIScreen.mainScreen().bounds.height < ANiOSScreenHeights.iPhone6.rawValue {
            scrollVIew.scrollEnabled = false
            updateBottomConstraint(notification, showing: false)

        }
        
    }

    
    // MARK: - HELPER METHODS
    
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
