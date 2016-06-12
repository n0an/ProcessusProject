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
    
    
    var newPersonFirstName: String!
    var newPersonLastName: String!
    var newPersonEmail: String!
    var newPersonPhoneNumber: String!
    

//    var dateFormatter: NSDateFormatter!
    
    var person: Person!
    
    var personProjects: [Project] = []
    
    weak var delegate: ANPersonDetailsVCDelegate?
    
    var sectionsCount = 3
    var selectCellShowed = false
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(person.firstName!)"
        
        updateInitialCredentials()
        
        personProjects = person.projects?.allObjects as! [Project]

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        navigationItem.rightBarButtonItem = editButtonItem()
        
//        dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "dd.MM.YYYY"
        
        tableView.allowsSelectionDuringEditing = true
        
   
    }
    
    deinit {
        print("deinit")
        delegate?.personEditingDidEndForPerson(person)
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func dueDateSoonForProject(project: Project) -> Bool {
        
        let currentDate = NSDate()
        
        let timeLeft = project.dueDate!.timeIntervalSinceDate(currentDate)
        print(timeLeft)
        
        // If there're less than 5 days befor deadline - activate warning sign
        if timeLeft < 5 * 24 * 3600  && timeLeft > 0 {
            return true
        }
        
        return false
        
    }

    
    func updateInitialCredentials() {
        // Saving initial credentials
        personFirstName     = person.firstName
        personLastName      = person.lastName
        personEmail         = person.email
        personPhoneNumber   = person.phoneNumber
        
        newPersonFirstName     = person.firstName
        newPersonLastName      = person.lastName
        newPersonEmail         = person.email
        newPersonPhoneNumber   = person.phoneNumber
    }
    
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
        cell.textFields[3].text = personPhoneNumber

    }
    
    
    // MARK: - Saving Context
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
        let indexP = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexP) as! ANPersonInfoCell
        
        if editing {
            
            selectCellShowed = true
            sectionsCount = 4
            
            tableView.beginUpdates()
            
            tableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            
            tableView.endUpdates()

            
            cell.textFields.first?.becomeFirstResponder()
            cell.avatarImageView.userInteractionEnabled = true
            
            
            let selectCellIndexP = NSIndexPath(forRow: 0, inSection: 2)
            
            let selectCell = tableView.cellForRowAtIndexPath(selectCellIndexP) as! ANPersonAddProjectCell

            
            ANAnimator.sharedAnimator.animateSelectRowView(selectCell.addProjectsView)
            
            
        } else {
            
            selectCellShowed = false
            sectionsCount = 3
            
            tableView.beginUpdates()
            
            tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            
            tableView.endUpdates()
            

            cell.avatarImageView.userInteractionEnabled = false
            
            cell.textFields.forEach{
                $0.resignFirstResponder()
            }
            
            var error = ""
            if cell.textFields[0].text == "" {
                error = NSLocalizedString("ERROR_FIRSTNAME_FIELD", comment: "")
            } else if cell.textFields[1].text == "" {
                error = NSLocalizedString("ERROR_LASTNAME_FIELD", comment: "")
            } else if cell.textFields[2].text == "" {
                error = NSLocalizedString("ERROR_EMAIL", comment: "")
            }
            
            if error != "" {
                
                let alertController = UIAlertController(title: NSLocalizedString("SAVE_ALERT_TITLE", comment: ""), message: NSLocalizedString("SAVE_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("SAVE_ALERT_MESSAGE2", comment: ""), preferredStyle: .Alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
                resetTextFields()
                
                return
            }
            
            person.firstName    = newPersonFirstName
            person.lastName     = newPersonLastName
            person.email        = newPersonEmail
            person.phoneNumber  = newPersonPhoneNumber
            
//            person.image = UIImagePNGRepresentation(cell.avatarImageView.image!)
            
            person.image = UIImageJPEGRepresentation(cell.avatarImageView.image!, 1.0)

            
            ANDataManager.sharedManager.saveContext()
            
            updateInitialCredentials()
            
        }
        
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
        
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(project.dueDate!)
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
//        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project)
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)

    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        print("addButtonPressed")
        
        transitToProjectSelection()
    }
    
    @IBAction func actionEditingDidEnd(sender: UITextField) {
        
        switch sender.tag {
                    
        case ANFieldType.PhoneNumber.rawValue:
            newPersonPhoneNumber = sender.text
            
        default:
            break
        }

        
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
        
        
        let navController = storyboard?.instantiateViewControllerWithIdentifier("ANPhotoAddingNavController") as! UINavigationController
        
        let destVC = navController.viewControllers[0] as! ANPhotoAddingViewController
        
        destVC.delegate = self
        
        presentViewController(navController, animated: true, completion: nil)

    }

    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonInfo.rawValue:
            return 1
        case ANSectionType.Separator.rawValue:
            return 1
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 1
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return personProjects.count
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
            
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdAddbutton, forIndexPath: indexPath) as! ANPersonAddProjectCell
            
            
            return cell
            
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
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
        
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            return 256
        case ANSectionType.Separator.rawValue:
            return 20
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return 80
        case ANSectionType.PersonProject.rawValue:
            return 80
        default:
            break
            
        }
        
        return UITableViewAutomaticDimension

    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonInfo.rawValue:
            return 160
        case ANSectionType.Separator.rawValue:
            return 20
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return 80
        case ANSectionType.PersonProject.rawValue:
            return 80
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == ANSectionType.PersonProject.rawValue || (indexPath.section == ANSectionType.Addbutton.rawValue && !selectCellShowed) {
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANEditProjectTableViewController") as! ANEditProjectTableViewController
            
            vc.delegate = self
            
            vc.itemToEdit = personProjects[indexPath.row] as Project
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == ANSectionType.Addbutton.rawValue && selectCellShowed {
//            transitToProjectSelection()
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

        
        switch textField.tag {
        case ANFieldType.Email.rawValue:
            let checkResult = ANTextFieldsChecker.sharedChecker.handleEmailTextField(textField, inRange: range, withReplacementString: string)
            
            return checkResult
            
        case ANFieldType.PhoneNumber.rawValue:
            
            newPersonPhoneNumber = textField.text
            
            return ANTextFieldsChecker.sharedChecker.handlePhoneNumberForTextField(textField, inRange: range, withReplacementString: string)
            
        default:
            break
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


// MARK: - ANPhotoAddingVCDelegate

extension ANPersonDetailsViewController: ANPhotoAddingVCDelegate {
    func photoSelectionDidEnd(photo: UIImage) {
        
        let indexP = NSIndexPath(forRow: 0, inSection: 0)
        let cell = tableView.cellForRowAtIndexPath(indexP) as! ANPersonInfoCell
        
        cell.avatarImageView.image = photo
        
        
    }
}






