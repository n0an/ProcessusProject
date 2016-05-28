//
//  ANAddPersonViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 25/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class ANAddPersonViewController: UITableViewController {

    // MARK: - OUTLETS

    @IBOutlet weak var doneBarButton: UIBarButtonItem!

    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case PersonInfo = 0
        case Separator
        case PersonProject
    }
    
    enum ANFieldType: Int {
        case FirstName = 0, LastName, Email, PhoneNumber
    }
    
//    var personProjects: [Project] = []
    
    var personInfoTextFields: [UITextField] = []
    
    let personInfoLabelsPlaceholders: [(label: String, placeholder: String)] = [("Имя:", "Введите имя"), ("Фамилия:", "Введите фамилию"), ("Email:", "Введите Email"), ("Телефон:", "Введите номер телефона")]
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.allowsSelection = false
    }
    
    // MARK: - Helper Methods
    
    func configureStandartTextField(textField: UITextField) {
        textField.returnKeyType = .Next
        textField.autocapitalizationType = .Words
        textField.keyboardType = .Default
        personInfoTextFields.append(textField)
        
    }
    
    func configurePersonInfoCell(cell: ANPersonInfoCell, forIndexPath indexPath: NSIndexPath) {
        
        let labelPlaceholder = personInfoLabelsPlaceholders[indexPath.row]
        
        cell.keyLabel.text = labelPlaceholder.label
        cell.valueTextField.placeholder = labelPlaceholder.placeholder
        
        switch indexPath.row {
        case ANFieldType.FirstName.rawValue:
            
            configureStandartTextField(cell.valueTextField)
            cell.valueTextField.becomeFirstResponder()
            
        case ANFieldType.LastName.rawValue:
            
            configureStandartTextField(cell.valueTextField)
            
        case ANFieldType.Email.rawValue:
            
            cell.valueTextField.tag = 108
            cell.valueTextField.returnKeyType = .Done
            cell.valueTextField.autocapitalizationType = .None
            cell.valueTextField.keyboardType = .EmailAddress
            personInfoTextFields.append(cell.valueTextField)
            
            
        case ANFieldType.PhoneNumber.rawValue:
            // TODO: phone Field
            break
            
        default:
            break
        }
        
        cell.valueTextField.delegate = self
        
    }
    
//    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
//        
//        let project = personProjects[indexPath.row]
//        
//        cell.customerNameLabel.text = project.customer
//        cell.projectNameLabel.text = project.name
//        
//        if let completedRatio = project.completedRatio?.intValue {
//            cell.completedRatioLabel.text = "\(completedRatio)"
//        }
//        
//        
//        var stateColor = UIColor()
//        
//        switch project.state!.integerValue {
//        case ANProjectState.NonActive.rawValue:
//            stateColor = UIColor.redColor()
//        case ANProjectState.Frozen.rawValue:
//            stateColor = UIColor.yellowColor()
//        case ANProjectState.Active.rawValue:
//            stateColor = UIColor.greenColor()
//        default:
//            break
//        }
//        
//        cell.projectStateView.backgroundColor = stateColor
//        
//    }
    
    func handleEmailTextField(textField: UITextField, inRange range: NSRange, withReplacementString replacementString: String) -> Bool {
        
        var illegalCharactersSet = NSCharacterSet.init(charactersInString: "?><,\\/|`~\'\"[]{}±#$%^&*()=+")
        
        let currentString = textField.text! as NSString
        
        let newString = currentString.stringByReplacingCharactersInRange(range, withString: replacementString)
        
        if currentString.length == 0 && replacementString == "@" {
            return false
        }
        
        if currentString .containsString("@") {
            illegalCharactersSet = NSCharacterSet.init(charactersInString: "?><,\\/|`~\'\"[]{}±#$%^&*()=+@")
        }
        let components = replacementString.componentsSeparatedByCharactersInSet(illegalCharactersSet)
        if components.count > 1 {
            return false
        }
        
        return newString.characters.count <= 40
    }
    
    // MARK: - Actions
    
    
    
    @IBAction func cancel() {
//        performSegueWithIdentifier("unwindBackToHomeScreen", sender: self)
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func savePerson() {
        
        // checking if all fields are filled
        var error = ""
        
        if personInfoTextFields[0].text == "" {
            error = "First Name"
        } else if personInfoTextFields[1].text == "" {
            error = "Last Name"
        } else if personInfoTextFields[2].text == "" {
            error = "Email"
        }

        if error != "" {
            
            let alertController = UIAlertController(title: "Ого!", message: "Сохранение не удалось, так как поле " + error + " не заполнено", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        
        ANDataManager.sharedManager.addPerson(withFirstName: personInfoTextFields[0].text!, lastName: personInfoTextFields[1].text!, email: personInfoTextFields[2].text!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonInfo.rawValue:
            return 3
//        case ANSectionType.Separator.rawValue:
//            return 1
//        case ANSectionType.PersonProject.rawValue:
//            return personProjects.count
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdPersonInfo = "personInfoCell"
//        let cellIdSeparator = "separatorCell"
//        let cellIdPersonProject = "personProjectsCell"
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonInfo, forIndexPath: indexPath) as! ANPersonInfoCell
            configurePersonInfoCell(cell, forIndexPath: indexPath)
            return cell
            
//        case ANSectionType.Separator.rawValue:
//            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdSeparator, forIndexPath: indexPath)
//            return cell
            
//        case ANSectionType.PersonProject.rawValue:
//            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
//            
//            return cell
        default:
            
            let cell = UITableViewCell()
            return cell
            
        }
        
        
    }
    
    
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
//        if indexPath.section == ANSectionType.Separator.rawValue {
//            return 2
//        }
        
        return UITableViewAutomaticDimension
        
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            return 44
//        case ANSectionType.Separator.rawValue:
//            return 2
//        case ANSectionType.PersonProject.rawValue:
//            return 80
        default:
            break
            
        }
        return UITableViewAutomaticDimension
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
        if textField === personInfoTextFields.last{
            
            textField.resignFirstResponder()
            
        } else {
            let index = personInfoTextFields.indexOf(textField)
            let textField = personInfoTextFields[index! + 1]
            textField.becomeFirstResponder()
            
        }
        
        return false
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        doneBarButton.enabled = (personInfoTextFields[0].text?.characters.count > 0)

        if textField.tag == 108 {
            return handleEmailTextField(textField, inRange: range, withReplacementString: string)
        }
        
        return true
    }
    
    
}





