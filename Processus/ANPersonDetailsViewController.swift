//
//  ANPersonDetailsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 13/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

class ANPersonDetailsViewController: UITableViewController {
    
    enum ANSectionType: Int {
        case PersonInfo = 0
        case Separator
        case PersonProject
    }
    
    enum ANFieldType: Int {
        case FirstName = 0, LastName, Email, PhoneNumber
    }
    
    enum ANProjectState: Int {
        case NonActive = 0, Frozen, Active
    }
    
    var person: Person!
    
    var personProjects: [Project] = []
    
    var personInfoTextFields: [UITextField] = []
    
    let personInfoLabelsPlaceholders: [(label: String, placeholder: String)] = [("Имя:", "Введите имя"), ("Фамилия:", "Введите фамилию"), ("Email:", "Введите Email"), ("Телефон:", "Введите номер телефона")]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("incoming person = \(person.firstName) \(person.lastName)")
        
        title = "\(person.firstName!) \(person.email!)"
        
        if person.projects?.count > 0 {
            personProjects = person.projects?.allObjects as! [Project]
            
            
        }
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        
        navigationItem.rightBarButtonItem = editButtonItem()
        
        tableView.allowsSelection = false
        
        
        
    }
    
    // MARK: - Helper Methods
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
        if editing {
            personInfoTextFields.first?.becomeFirstResponder()
        } else {
            
            personInfoTextFields.forEach{
                $0.resignFirstResponder()
            }
        }
        
        
        
    }
    
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
            cell.valueTextField.text = person.firstName
            configureStandartTextField(cell.valueTextField)
            
        case ANFieldType.LastName.rawValue:
            cell.valueTextField.text = person.lastName
            configureStandartTextField(cell.valueTextField)
            
        case ANFieldType.Email.rawValue:
            cell.valueTextField.text = person.email
            cell.valueTextField.returnKeyType = .Done
            cell.valueTextField.autocapitalizationType = .None
            cell.valueTextField.keyboardType = .EmailAddress
            personInfoTextFields.append(cell.valueTextField)
            
            
        case ANFieldType.PhoneNumber.rawValue:
            // TODO: phone Field
            cell.valueTextField.text = person.phoneNumber
            
        default:
            break
        }
        
        cell.valueTextField.delegate = self
        
    }
    
    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
        
        let project = personProjects[indexPath.row]
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        
        if let completedRatio = project.completedRatio?.intValue {
            cell.completedRatioLabel.text = "\(completedRatio)"
        }
        
        
        var stateColor = UIColor()
        
        switch project.state!.integerValue {
        case ANProjectState.NonActive.rawValue:
            stateColor = UIColor.redColor()
        case ANProjectState.Frozen.rawValue:
            stateColor = UIColor.yellowColor()
        case ANProjectState.Active.rawValue:
            stateColor = UIColor.greenColor()
        default:
            break
        }
        
        cell.projectStateView.backgroundColor = stateColor
        
    }

    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonInfo.rawValue:
            return 3
        case ANSectionType.Separator.rawValue:
            return 1
        case ANSectionType.PersonProject.rawValue:
            return personProjects.count
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdPersonInfo = "personInfoCell"
        let cellIdSeparator = "separatorCell"
        let cellIdPersonProject = "personProjectsCell"
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonInfo, forIndexPath: indexPath) as! ANPersonInfoCell
            configurePersonInfoCell(cell, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Separator.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdSeparator, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.PersonProject.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
            
            return cell
        default:
            
            let cell = UITableViewCell()
            return cell
            
        }
        
        
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == ANSectionType.Separator.rawValue {
            return 2
        }
        
        return UITableViewAutomaticDimension

    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            return 44
        case ANSectionType.Separator.rawValue:
            return 2
        case ANSectionType.PersonProject.rawValue:
            return 80
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section != ANSectionType.PersonProject.rawValue  {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let project = personProjects[indexPath.row]
            
            let tmpWorkers = project.workers as! NSMutableSet
            
            tmpWorkers.removeObject(person)
            
            project.workers = tmpWorkers
            
            if person.projects?.count > 0 {
                personProjects = person.projects?.allObjects as! [Project]
                
                
            }
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
        }
        
    }


}


extension ANPersonDetailsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editing
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
    
    
}










