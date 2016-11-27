//
//  ANAddPersonViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 25/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class ANAddPersonViewController: UITableViewController {

    // MARK: - OUTLETS

    @IBOutlet weak var doneBarButton: UIBarButtonItem!

    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    @IBOutlet var textFields: [UITextField]!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ANAddPersonViewController.avatarImageViewTapped(_:)))
        
        avatarImageView.isUserInteractionEnabled = true
        
        avatarImageView.addGestureRecognizer(tapGesture)
        
        tableView.allowsSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        firstNameTextField.becomeFirstResponder()
    }
    
    
    
    // MARK: - Actions
    
    func avatarImageViewTapped(_ sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            
            let navController = storyboard?.instantiateViewController(withIdentifier: "ANPhotoAddingNavController") as! UINavigationController
            
            let destVC = navController.viewControllers[0] as! ANPhotoAddingViewController
            
            destVC.delegate = self
            
            present(navController, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func cancel() {

        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func savePerson() {
        
        // checking if all fields are filled
        var error = ""
        
        if textFields[0].text == "" {
            error = NSLocalizedString("ERROR_FIRSTNAME_FIELD", comment: "")
        } else if textFields[1].text == "" {
            error = NSLocalizedString("ERROR_LASTNAME_FIELD", comment: "")
        } else if textFields[2].text == "" {
            error = NSLocalizedString("ERROR_EMAIL", comment: "")
        }

        if error != "" {
            
            let alertController = UIAlertController(title: NSLocalizedString("SAVE_ALERT_TITLE", comment: ""), message: NSLocalizedString("SAVE_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("SAVE_ALERT_MESSAGE2", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        
        let context = ANDataManager.sharedManager.context
        
        let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: context) as! Person
        
        person.firstName    = textFields[0].text!
        person.lastName     = textFields[1].text!
        person.email        = textFields[2].text!
        person.phoneNumber  = textFields[3].text!
        
        person.image        = UIImageJPEGRepresentation(avatarImageView.image!, 1.0)

        
        ANDataManager.sharedManager.saveContext()
        
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        textFields.forEach{
            $0.resignFirstResponder()
        }
        
        
        return indexPath
    }
    
    

    
}





// MARK: - UITextFieldDelegate

extension ANAddPersonViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === textFields.last{
            
            textField.resignFirstResponder()
            
        } else {
            let index = textFields.index(of: textField)
            let textField = textFields[index! + 1]
            textField.becomeFirstResponder()
            
        }
        
        return false
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        doneBarButton.isEnabled = (textFields[0].text?.characters.count > 0)
        
        switch textField.tag {
        case 108:
            
            let checkResult = ANTextFieldsChecker.sharedChecker.handleEmailTextField(textField, inRange: range, withReplacementString: string)
            
            return checkResult
            
        case 109:
            
            return ANTextFieldsChecker.sharedChecker.handlePhoneNumberForTextField(textField, inRange: range, withReplacementString: string)
            
        default:
            break
        }
        
        return true
    }
    
    
}




// MARK: - ANPhotoAddingVCDelegate

extension ANAddPersonViewController: ANPhotoAddingVCDelegate {
    func photoSelectionDidEnd(_ photo: UIImage) {
        
        avatarImageView.image = photo
        
        
    }
}













