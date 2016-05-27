//
//  ANPersonDetailsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 13/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

enum ANProjectState: Int {
    case NonActive = 0, Frozen, Active
}

protocol ANPersonDetailsVCDelegate: class {
    func personEditingDidEndForPerson(person: Person)
}

class ANPersonDetailsViewController: UITableViewController {
    
    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case PersonInfo = 0
        case Separator
        case Addbutton
        case PersonProject
    }
    
    enum ANFieldType: Int {
        case FirstName = 0, LastName, Email, PhoneNumber
    }
    
    var personFirstName: String!
    var personLastName: String!
    var personEmail: String!
    var personPhoneNumber: String!

    
    var person: Person!
    
    var personProjects: [Project] = []
    
    var personInfoTextFields: [UITextField] = []
    
    weak var delegate: ANPersonDetailsVCDelegate?
    
    let personInfoLabelsPlaceholders: [(label: String, placeholder: String)] = [("Имя:", "Введите имя"), ("Фамилия:", "Введите фамилию"), ("Email:", "Введите Email"), ("Телефон:", "Введите номер телефона")]
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(person.firstName!) \(person.email!)"
        
        // Saving initial credentials
        personFirstName     = person.firstName
        personLastName      = person.lastName
        personEmail         = person.email
        personPhoneNumber   = person.phoneNumber
        
        
        personProjects = person.projects?.allObjects as! [Project]

        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        navigationItem.rightBarButtonItem = editButtonItem()
        
        
    }
    
    deinit {
        print("deinit")
    }
    
    
    
    // MARK: - ACTIONS
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        print("addButtonPressed")
        
        transitToProjectSelection()
    }
    
    
    // MARK: - HELPER METHODS
    
    
    func transitToProjectSelection() {
        let fetchRequest = NSFetchRequest(entityName: "Project")
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        let context = ANDataManager.sharedManager.context
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANProjectSelectionViewController") as! ANProjectSelectionViewController
        
        vc.person = person
        vc.selectedProjects = personProjects
        vc.delegate = self
        
        do {
            let allProjects = try context.executeFetchRequest(fetchRequest) as! [Project]
            
            vc.allProjects = allProjects
            
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
    func resetTextFields() {
        
        personInfoTextFields[0].text = personFirstName
        personInfoTextFields[1].text = personLastName
        personInfoTextFields[2].text = personEmail
//        personInfoTextFields[3].text = personPhoneNumber

        
    }
    
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
        if editing {
            personInfoTextFields.first?.becomeFirstResponder()
            
        } else {
            
            personInfoTextFields.forEach{
                $0.resignFirstResponder()
            }
            
            
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
                
                resetTextFields()
                
                return
            }
            
            ANDataManager.sharedManager.saveContext()
            
        }
        
    }
    
    
    
    func actionInfoChanged(sender: UITextField) {
        
        switch sender.tag {
        case ANFieldType.FirstName.rawValue:
            person.firstName = sender.text
        case ANFieldType.LastName.rawValue:
            person.lastName = sender.text
        case ANFieldType.Email.rawValue:
            person.email = sender.text
        case ANFieldType.PhoneNumber.rawValue:
            person.phoneNumber = sender.text
        default:
            break
        }
        
    }
    
    
    func configureStandartTextField(textField: UITextField) {
        textField.returnKeyType = .Next
        textField.autocapitalizationType = .Words
        textField.keyboardType = .Default
        
        textField.addTarget(self, action: #selector(ANPersonDetailsViewController.actionInfoChanged(_:)), forControlEvents: .EditingChanged)
        
        if !(personInfoTextFields.contains(textField)) {
            personInfoTextFields.append(textField)
        }
        
    }
    
    
    func configurePersonInfoCell(cell: ANPersonInfoCell, forIndexPath indexPath: NSIndexPath) {
        
        let labelPlaceholder = personInfoLabelsPlaceholders[indexPath.row]
        
        cell.keyLabel.text = labelPlaceholder.label
        cell.valueTextField.placeholder = labelPlaceholder.placeholder

        switch indexPath.row {
        case ANFieldType.FirstName.rawValue:
            cell.valueTextField.text = person.firstName
            configureStandartTextField(cell.valueTextField)
            cell.valueTextField.tag = ANFieldType.FirstName.rawValue
            
        case ANFieldType.LastName.rawValue:
            cell.valueTextField.text = person.lastName
            configureStandartTextField(cell.valueTextField)
            cell.valueTextField.tag = ANFieldType.LastName.rawValue
            
        case ANFieldType.Email.rawValue:
            cell.valueTextField.text = person.email
            cell.valueTextField.returnKeyType = .Done
            cell.valueTextField.autocapitalizationType = .None
            cell.valueTextField.keyboardType = .EmailAddress
            personInfoTextFields.append(cell.valueTextField)
            cell.valueTextField.tag = ANFieldType.Email.rawValue
            
            
        case ANFieldType.PhoneNumber.rawValue:
            // TODO: phone Field
            cell.valueTextField.text = person.phoneNumber
            cell.valueTextField.tag = ANFieldType.PhoneNumber.rawValue
            
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
        return 4
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonInfo.rawValue:
            return 3
        case ANSectionType.Separator.rawValue:
            return 1
        case ANSectionType.Addbutton.rawValue:
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
        let cellIdAddbutton = "ANPersonAddProjectCell"
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonInfo, forIndexPath: indexPath) as! ANPersonInfoCell
            configurePersonInfoCell(cell, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Separator.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdSeparator, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Addbutton.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdAddbutton, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.PersonProject.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
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
        case ANSectionType.Addbutton.rawValue:
            return 44
        case ANSectionType.PersonProject.rawValue:
            return 80
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        

        if indexPath.section == ANSectionType.PersonProject.rawValue {
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANEditProjectTableViewController") as! ANEditProjectTableViewController
            
            vc.delegate = self
            
            vc.itemToEdit = personProjects[indexPath.row] as Project
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == ANSectionType.Addbutton.rawValue {
            transitToProjectSelection()
        }
        
        
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
            
            person.remove(projectObject: project)
            
            personProjects = person.projects?.allObjects as! [Project]
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
        }
        
    }
    

    
    
}

// MARK: - UITextFieldDelegate

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



// MARK: - ANProjectSelectionViewControllerDelegate

extension ANPersonDetailsViewController: ANProjectSelectionViewControllerDelegate {
    
    func projectSelectionDidFinish(selectedProjects: [Project]) {
        print("projectSelectionDidFinish")
        
        personProjects = selectedProjects
        
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
        
    }
    
}


// MARK: - ANEditProjectTableViewControllerDelegate

extension ANPersonDetailsViewController: ANEditProjectTableViewControllerDelegate {
    
    func projectEditingDidEndForProject(project: Project) {
        
        tableView.reloadData()
    }

    
    
}








