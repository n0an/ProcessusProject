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
        
        if let user = PFUser.current() {
            if user.isAuthenticated {
                self.performSegue(withIdentifier: "toUsersSegue1", sender: nil)
            }
        }
        
        // ** REGISTERING FOR PUSH NOTIFICATIONS
        let userNotificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
        let settings = UIUserNotificationSettings(types: userNotificationTypes, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(ANLoginViewController.didTapView))
        tapGestureRecognizer.numberOfTapsRequired = 1
        
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ANLoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ANLoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UIScreen.main.bounds.height < ANiOSScreenHeights.iPhone5.rawValue {
            scrollVIew.isScrollEnabled = true
        } else {
            scrollVIew.isScrollEnabled = false
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setScrollViewContentSize()
    }
    
    // MARK: - NOTIFICATIONS
    
    func keyboardWillShow(_ notification: Notification) {
        
        if UIScreen.main.bounds.height < ANiOSScreenHeights.iPhone6.rawValue {
            
            scrollVIew.isScrollEnabled = true
            updateBottomConstraint(notification, showing: true)
            
            setScrollViewContentSize()

        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if UIScreen.main.bounds.height < ANiOSScreenHeights.iPhone6.rawValue {
            scrollVIew.isScrollEnabled = false
            updateBottomConstraint(notification, showing: false)

            setScrollViewContentSize()

        }
        
    }

    
    // MARK: - HELPER METHODS
    
    func setScrollViewContentSize() {
        
        var contentRect = CGRect.zero
        
        for view in contentView.subviews {
            contentRect = contentRect.union(view.frame)
        }
        
        scrollVIew.contentSize = CGSize(width: view.frame.width, height: contentRect.height)
        
    }
    
    func updateBottomConstraint(_ notification: Notification, showing: Bool) {
        
        
        if let
            userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            
            let newFrame = view.convert(frame, from: (UIApplication.shared.delegate?.window)!)
            
            let diff = showing ? 49 : 0
            
            bottomConstraint.constant = view.frame.height - newFrame.origin.y - CGFloat(diff)
            
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
                
                if showing {
                    let scrollViewOffset: CGPoint = CGPoint(x: 0, y: self.scrollVIew.contentSize.height - self.scrollVIew.bounds.height)
                    
                    self.scrollVIew.setContentOffset(scrollViewOffset, animated: true)
                }
                
                
            })
            
            
        }
        
    }
    
    // MARK: - ACTIONS

    func didTapView() {
        self.view.endEditing(true)
    }

    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        
        loginTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // Show alert with error, if any field is empty when SignUp pressed
        var error = ""
        
        if loginTextField.text == "" {
            error = NSLocalizedString("CHAT_ERROR_LOGIN_FIELD", comment: "")
            
        } else if passwordTextField.text == "" {
            error = NSLocalizedString("CHAT_ERROR_PASSWORD_FIELD", comment: "")
            
        }
        
        if error != "" {
            
            let alertController = UIAlertController(title: NSLocalizedString("CHAT_ALERT_TITLE", comment: ""), message: NSLocalizedString("CHAT_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("CHAT_ALERT_MESSAGE2", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            
            return
        }
        
        PFUser.logInWithUsername(inBackground: loginTextField.text!, password: passwordTextField.text!) { (user: PFUser?, error: NSError?) in
            
            guard error == nil else {
                print("Can't login")
                print("error: \(error?.localizedDescription)")
                
                SweetAlert().showAlert(NSLocalizedString("CHAT_ALERT_TITLE", comment: ""), subTitle: error!.localizedDescription, style: AlertStyle.error)
                
                return
            }
            
            let installation: PFInstallation = PFInstallation.current()
            installation["user"] = PFUser.current()
            
            installation.saveInBackground()
            
            self.performSegue(withIdentifier: "toUsersSegue1", sender: self)
            
            
        }
        
        
    }
    
    @IBAction func createAccButtonPressed(_ sender: AnyObject) {
    }
    

    
    
}


// MARK: - UITextFieldDelegate

extension ANLoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordTextField {
            textField.resignFirstResponder()
        } else {
            
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    
}




















