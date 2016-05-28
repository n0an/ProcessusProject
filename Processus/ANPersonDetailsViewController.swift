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

class ANPersonDetailsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
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
    
    
    var newPersonFirstName: String!
    var newPersonLastName: String!
    var newPersonEmail: String!
    var newPersonPhoneNumber: String!
    

    var dateFormatter: NSDateFormatter!
    
    var person: Person!
    
    var personProjects: [Project] = []
    
    weak var delegate: ANPersonDetailsVCDelegate?
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(person.firstName!) \(person.email!)"
        
        // Saving initial credentials
        personFirstName     = person.firstName
        personLastName      = person.lastName
        personEmail         = person.email
        personPhoneNumber   = person.phoneNumber
        
        newPersonFirstName     = person.firstName
        newPersonLastName      = person.lastName
        newPersonEmail         = person.email
        newPersonPhoneNumber   = person.phoneNumber
        
        personProjects = person.projects?.allObjects as! [Project]

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        navigationItem.rightBarButtonItem = editButtonItem()
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        
    }
    
    deinit {
        print("deinit")
        delegate?.personEditingDidEndForPerson(person)
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
        
        let indexP = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexP) as! ANPersonInfoCell
        
        cell.textFields[0].text = personFirstName
        cell.textFields[1].text = personLastName
        cell.textFields[2].text = personEmail
//        cell.textFields[3].text = personPhoneNumber

    }
    
    
    // MARK: - Saving Context
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
        let indexP = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexP) as! ANPersonInfoCell
        
        if editing {
            cell.textFields.first?.becomeFirstResponder()
            cell.avatarImageView.userInteractionEnabled = true
            
        } else {
            
            cell.avatarImageView.userInteractionEnabled = false
            
            cell.textFields.forEach{
                $0.resignFirstResponder()
            }
            
            var error = ""
            if cell.textFields[0].text == "" {
                error = "First Name"
            } else if cell.textFields[1].text == "" {
                error = "Last Name"
            } else if cell.textFields[2].text == "" {
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
            
            person.firstName = newPersonFirstName
            person.lastName = newPersonLastName
            person.email = newPersonEmail
            person.phoneNumber = newPersonPhoneNumber
            
            person.image = UIImagePNGRepresentation(cell.avatarImageView.image!)
            
            ANDataManager.sharedManager.saveContext()
            
        }
        
    }
    
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
    
    
    
    func configurePersonInfoCell(cell: ANPersonInfoCell, forIndexPath indexPath: NSIndexPath) {

        cell.firstNameTextField.text = person.firstName
        cell.lastNameTextField.text = person.lastName
        cell.emailTextField.text = person.email
        cell.phoneNumberTextField.text = person.phoneNumber
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ANAddPersonViewController.avatarImageViewTapped(_:)))
        
        
        cell.avatarImageView.addGestureRecognizer(tapGesture)

        
    }
    
    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
        
        let project = personProjects[indexPath.row]
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        cell.projectDueDateLabel.text = dateFormatter.stringFromDate(project.dueDate!)

        
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
    
    
    // MARK: - ACTIONS
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        print("addButtonPressed")
        
        transitToProjectSelection()
    }
    
    
    @IBAction func actionInfoChanged(sender: UITextField) {
        
        switch sender.tag {
        case ANFieldType.FirstName.rawValue:
            newPersonFirstName = sender.text

        case ANFieldType.LastName.rawValue:
            newPersonLastName = sender.text

        case ANFieldType.Email.rawValue:
            newPersonEmail = sender.text

        case ANFieldType.PhoneNumber.rawValue:
            newPersonPhoneNumber = sender.text

        default:
            break
        }
        
    }
    
    func avatarImageViewTapped(sender: UITapGestureRecognizer) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .PhotoLibrary
            
            imagePicker.delegate = self
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
    }

    


    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonInfo.rawValue:
            return 1
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
        } else if indexPath.section == ANSectionType.PersonInfo.rawValue {
            return 160
        }
        
        return UITableViewAutomaticDimension

    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            return 160
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let indexP = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexP) as! ANPersonInfoCell
        
        cell.avatarImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        cell.avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        cell.avatarImageView.clipsToBounds = true
        
        
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        //        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }
    

}

// MARK: - UITextFieldDelegate

extension ANPersonDetailsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return editing
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        let indexP = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexP) as! ANPersonInfoCell
        
        if textField === cell.textFields.last{
            
            textField.resignFirstResponder()
            
        } else {
            let index = cell.textFields.indexOf(textField)
            let textField = cell.textFields[index! + 1]
            textField.becomeFirstResponder()
            
        }
        
        return false
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == ANFieldType.Email.rawValue {
            return handleEmailTextField(textField, inRange: range, withReplacementString: string)
        }
        
        return true
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








