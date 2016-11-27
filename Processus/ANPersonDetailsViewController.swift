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
    case nonActive = 0, frozen, active
}

protocol ANPersonDetailsVCDelegate: class {
    func personEditingDidEndForPerson(_ person: Person)
}

class ANPersonDetailsViewController: UITableViewController {
    
    
    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case personInfo = 0
        case separator
        case addbutton
        case personProject
    }
    
    enum ANFieldType: Int {
        case firstName = 0, lastName, email, phoneNumber
    }
    
    var personFirstName: String!
    var personLastName: String!
    var personEmail: String!
    var personPhoneNumber: String!
    
    
    var newPersonFirstName: String!
    var newPersonLastName: String!
    var newPersonEmail: String!
    var newPersonPhoneNumber: String!
    

    
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

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        
        tableView.allowsSelectionDuringEditing = true
        
   
    }
    
    deinit {
        
        delegate?.personEditingDidEndForPerson(person)
    }
    
    
    
    // MARK: - HELPER METHODS
    
    
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        let context = ANDataManager.sharedManager.context
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ANProjectSelectionViewController") as! ANProjectSelectionViewController
        
        vc.person = person
        vc.selectedProjects = personProjects
        vc.delegate = self
        
        do {
            let allProjects = try context.fetch(fetchRequest) as! [Project]
            
            vc.allProjects = allProjects
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    
    func resetTextFields() {
        
        let indexP = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexP) as! ANPersonInfoCell
        
        cell.textFields[0].text = personFirstName
        cell.textFields[1].text = personLastName
        cell.textFields[2].text = personEmail
        cell.textFields[3].text = personPhoneNumber

    }
    
    
    // MARK: - Saving Context
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: true)
        
        let indexP = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexP) as! ANPersonInfoCell
        
        if editing {
            
            selectCellShowed = true
            sectionsCount = 4
            
            tableView.beginUpdates()
            
            tableView.insertSections(IndexSet(integer: 2), with: .fade)
            
            tableView.endUpdates()

            
            cell.textFields.first?.becomeFirstResponder()
            cell.avatarImageView.isUserInteractionEnabled = true
            
            
            let selectCellIndexP = IndexPath(row: 0, section: 2)
            
            let selectCell = tableView.cellForRow(at: selectCellIndexP) as! ANPersonAddProjectCell

            
            ANAnimator.sharedAnimator.animateSelectRowView(selectCell.addProjectsView)
            
            
        } else {
            
            selectCellShowed = false
            sectionsCount = 3
            
            tableView.beginUpdates()
            
            tableView.deleteSections(IndexSet(integer: 2), with: .fade)
            
            tableView.endUpdates()
            

            cell.avatarImageView.isUserInteractionEnabled = false
            
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
                
                let alertController = UIAlertController(title: NSLocalizedString("SAVE_ALERT_TITLE", comment: ""), message: NSLocalizedString("SAVE_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("SAVE_ALERT_MESSAGE2", comment: ""), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                resetTextFields()
                
                return
            }
            
            person.firstName    = newPersonFirstName
            person.lastName     = newPersonLastName
            person.email        = newPersonEmail
            person.phoneNumber  = newPersonPhoneNumber
            
            person.image = UIImageJPEGRepresentation(cell.avatarImageView.image!, 1.0)

            
            ANDataManager.sharedManager.saveContext()
            
            updateInitialCredentials()
            
        }
        
    }
    
    
    
    func configurePersonInfoCell(_ cell: ANPersonInfoCell, forIndexPath indexPath: IndexPath) {

        cell.firstNameTextField.text = person.firstName
        cell.lastNameTextField.text = person.lastName
        cell.emailTextField.text = person.email
        cell.phoneNumberTextField.text = person.phoneNumber
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData as Data)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ANAddPersonViewController.avatarImageViewTapped(_:)))
        
        
        cell.avatarImageView.addGestureRecognizer(tapGesture)

        
    }
    
    func configurePersonProjectCell(_ cell: ANPersonProjectCell, forIndexPath indexPath: IndexPath) {
        
        let project = personProjects[indexPath.row]
        
        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.string(from: project.dueDate!)
        
        if let participantsCount = project.workers?.allObjects.count {
            cell.participantsCountLabel.text = "\(participantsCount)"
        }
        
        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)

    }
    
    
    // MARK: - ACTIONS
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        transitToProjectSelection()
    }
    
    @IBAction func actionEditingDidEnd(_ sender: UITextField) {
        
        switch sender.tag {
                    
        case ANFieldType.phoneNumber.rawValue:
            newPersonPhoneNumber = sender.text
            
        default:
            break
        }

        
    }
    
    @IBAction func actionInfoChanged(_ sender: UITextField) {
        
        switch sender.tag {
        case ANFieldType.firstName.rawValue:
            newPersonFirstName = sender.text

        case ANFieldType.lastName.rawValue:
            newPersonLastName = sender.text

        case ANFieldType.email.rawValue:
            newPersonEmail = sender.text

        case ANFieldType.phoneNumber.rawValue:
            newPersonPhoneNumber = sender.text

        default:
            break
        }
        
    }
    
    func avatarImageViewTapped(_ sender: UITapGestureRecognizer) {
        
        
        let navController = storyboard?.instantiateViewController(withIdentifier: "ANPhotoAddingNavController") as! UINavigationController
        
        let destVC = navController.viewControllers[0] as! ANPhotoAddingViewController
        
        destVC.delegate = self
        
        present(navController, animated: true, completion: nil)

    }

    
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.personInfo.rawValue:
            return 1
        case ANSectionType.separator.rawValue:
            return 1
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            return 1
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            return personProjects.count
        case ANSectionType.personProject.rawValue:
            return personProjects.count
        default:
            break
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdPersonInfo = "personInfoCell"
        let cellIdSeparator = "separatorCell"
        let cellIdPersonProject = "personProjectsCell"
        let cellIdAddbutton = "ANPersonAddProjectCell"
        
        switch indexPath.section {
        case ANSectionType.personInfo.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPersonInfo, for: indexPath) as! ANPersonInfoCell
            configurePersonInfoCell(cell, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.separator.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdSeparator, for: indexPath)
            return cell
            
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdAddbutton, for: indexPath) as! ANPersonAddProjectCell
            
            
            return cell
            
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPersonProject, for: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.personProject.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPersonProject, for: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
            return cell
            
        default:
            let cell = UITableViewCell()
            return cell
            
        }
        
        
    }
    
    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        switch indexPath.section {
        case ANSectionType.personInfo.rawValue:
            return 256
        case ANSectionType.separator.rawValue:
            return 20
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            return 80
        case ANSectionType.personProject.rawValue:
            return 80
        default:
            break
            
        }
        
        return UITableViewAutomaticDimension

    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.personInfo.rawValue:
            return 160
        case ANSectionType.separator.rawValue:
            return 20
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            return 80
        case ANSectionType.personProject.rawValue:
            return 80
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexP = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexP) as! ANPersonInfoCell
        
        cell.textFields.forEach{
            $0.resignFirstResponder()
        }
        
        if indexPath.section == ANSectionType.personProject.rawValue || (indexPath.section == ANSectionType.addbutton.rawValue && !selectCellShowed) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ANEditProjectTableViewController") as! ANEditProjectTableViewController
            
            vc.delegate = self
            
            vc.itemToEdit = personProjects[indexPath.row] as Project
            
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == ANSectionType.addbutton.rawValue && selectCellShowed {
//            transitToProjectSelection()
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != ANSectionType.personProject.rawValue  {
            return false
        } else {
            return true
        }

        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let project = personProjects[indexPath.row]
            
            person.removeFromProjects(project)
            
//            person.remove(projectObject: project) // Swift 2 Old
            
            personProjects = person.projects?.allObjects as! [Project]
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
            
        }
        
    }
    

}

// MARK: - UITextFieldDelegate

extension ANPersonDetailsViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return isEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let indexP = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexP) as! ANPersonInfoCell
        
        if textField === cell.textFields.last{
            
            textField.resignFirstResponder()
            
        } else {
            let index = cell.textFields.index(of: textField)
            let textField = cell.textFields[index! + 1]
            textField.becomeFirstResponder()
            
        }
        
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        switch textField.tag {
        case ANFieldType.email.rawValue:
            let checkResult = ANTextFieldsChecker.sharedChecker.handleEmailTextField(textField, inRange: range, withReplacementString: string)
            
            return checkResult
            
        case ANFieldType.phoneNumber.rawValue:
            
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
    
    func projectSelectionDidFinish(_ selectedProjects: [Project]) {
        
        personProjects = selectedProjects
        
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
    }
}


// MARK: - ANEditProjectTableViewControllerDelegate

extension ANPersonDetailsViewController: ANEditProjectTableViewControllerDelegate {
    
    func projectEditingDidEndForProject(_ project: Project) {
        
        tableView.reloadData()
    }

    
    
}


// MARK: - ANPhotoAddingVCDelegate

extension ANPersonDetailsViewController: ANPhotoAddingVCDelegate {
    func photoSelectionDidEnd(_ photo: UIImage) {
        
        let indexP = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: indexP) as! ANPersonInfoCell
        
        cell.avatarImageView.image = photo
        
        
    }
}






