//
//  ANAddPersonViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 25/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData



//let localNumberMaxLength = 7
//let areaCodeMaxLength = 3
//let countryCodeMaxLength = 3

class ANAddPersonViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
        
        avatarImageView.userInteractionEnabled = true
        
        avatarImageView.addGestureRecognizer(tapGesture)
        
        tableView.allowsSelection = false
    }
    
    
    
    // MARK: - Actions
    
    func avatarImageViewTapped(sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func cancel() {
//        performSegueWithIdentifier("unwindBackToHomeScreen", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func savePerson() {
        
        // checking if all fields are filled
        var error = ""
        
        if textFields[0].text == "" {
            error = "First Name"
        } else if textFields[1].text == "" {
            error = "Last Name"
        } else if textFields[2].text == "" {
            error = "Email"
        }

        if error != "" {
            
            let alertController = UIAlertController(title: "Ого!", message: "Сохранение не удалось, так как поле " + error + " не заполнено", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        
        let context = ANDataManager.sharedManager.context
        
        let person = NSEntityDescription.insertNewObjectForEntityForName("Person", inManagedObjectContext: context) as! Person
        
        person.firstName    = textFields[0].text!
        person.lastName     = textFields[1].text!
        person.email        = textFields[2].text!
        person.image        = UIImagePNGRepresentation(avatarImageView.image!)
        
        ANDataManager.sharedManager.saveContext()
        
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        avatarImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        avatarImageView.clipsToBounds = true
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
//        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }


    
}





// MARK: - UITextFieldDelegate

extension ANAddPersonViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === textFields.last{
            
            textField.resignFirstResponder()
            
        } else {
            let index = textFields.indexOf(textField)
            let textField = textFields[index! + 1]
            textField.becomeFirstResponder()
            
        }
        
        return false
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        doneBarButton.enabled = (textFields[0].text?.characters.count > 0)
        
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

















