//
//  ANProjectDetailsViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 27/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

protocol ANProjectDetailsVCDelegate: class {
    func projectEditingDidEndForProject(_ project: Project)
}

class ANProjectDetailsViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearParticipantsButton: UIBarButtonItem!

    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case personProject = 0
        case separator
        case addbutton
        case person
    }
    
    var isEditingMode = false

    var project: Project!
    
    var projectParticipants: [Person] = []
    
    weak var delegate: ANProjectDetailsVCDelegate?
    
    
    var sectionsCount = 3
    var selectCellShowed = false
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshVCTitle()
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    deinit {
        ANDataManager.sharedManager.saveContext()
        
        delegate?.projectEditingDidEndForProject(project)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshClearParticipantsButton()
        
        tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: view.bounds.maxY)
        
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func refreshClearParticipantsButton() {
        let participants = project.workers?.allObjects
        
        if participants!.isEmpty {
            clearParticipantsButton.isEnabled = false
        } else {
            clearParticipantsButton.isEnabled = true
        }
    }
    
    func refreshVCTitle() {
        title = "\(project.name!)"

    }
    
    
    func configurePersonProjectCell(_ cell: ANPersonProjectCell, forIndexPath indexPath: IndexPath) {
        

        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.string(from: project.dueDate!)
        
        if let completedRatio = project.completedRatio?.int32Value {
            cell.completedRatioLabel.text = "\(completedRatio) %"
        }

        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)

        
    }
    
    func configurePersonCell(_ cell: ANPersonCell, atIndexPath indexPath: IndexPath) {
        
        let person = projectParticipants[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData as Data)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        cell.fullNameLabel.text = "\(firstName) \(lastName)"
        
    }
    
    func transitToParticipantsSelection() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]
        
        let context = ANDataManager.sharedManager.context
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ANPeopleSelectionViewController") as! ANPeopleSelectionViewController
        
        vc.project = project
        vc.selectedPeople = projectParticipants
        vc.delegate = self
        
        do {
            let allPeople = try context.fetch(fetchRequest) as! [Person]
            
            vc.allPeople = allPeople
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - ACTIONS
    
    
    @IBAction func actionButtonPressed(_ sender: UIBarButtonItem) {
        
        
        if self.project.finished?.boolValue == false {
            let finishActionMenu = UIAlertController(title: nil, message:NSLocalizedString("ACTION_DETAILS_FINISH_TITLE", comment: ""), preferredStyle: .actionSheet)
            
            let finishSuccessAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_SUCCESS_ACTION", comment: ""), style: .default) { (action: UIAlertAction) in
                
                let projectToFinish = self.project
                
                projectToFinish?.state = ANProjectState.nonActive.rawValue
                projectToFinish?.finished = true
                projectToFinish?.finishedStatus = ProjectFinishedStatus.Success.rawValue
                
                ANDataManager.sharedManager.saveContext()
            }
            
            
            let finishFailureAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_FAILURE_ACTION", comment: ""), style: .default, handler: { (action: UIAlertAction) in
                
                let projectToFinish = self.project
                
                projectToFinish?.state = ANProjectState.nonActive.rawValue
                projectToFinish?.finished = true
                projectToFinish?.finishedStatus = ProjectFinishedStatus.Failure.rawValue
                
                ANDataManager.sharedManager.saveContext()
            })
            
            
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_CANCEL_ACTION", comment: ""), style: .cancel, handler: nil)
            
            finishActionMenu.addAction(finishSuccessAction)
            finishActionMenu.addAction(finishFailureAction)
            
            finishActionMenu.addAction(cancelAction)
            
            
            self.present(finishActionMenu, animated: true, completion: nil)
        }
        
        
        
        if self.project.finished?.boolValue == true {

            let finishActionMenu = UIAlertController(title: nil, message: NSLocalizedString("ACTION_DETAILS_START_TITLE", comment: ""), preferredStyle: .actionSheet)
            
            let finishSuccessAction = UIAlertAction(title: NSLocalizedString("ACTION_DETAILS_START_ACTION", comment: ""), style: .default) { (action: UIAlertAction) in
                
                let projectToStart = self.project
                
                projectToStart?.state = ANProjectState.nonActive.rawValue
                projectToStart?.finished = false
                projectToStart?.finishedStatus = nil
                
                ANDataManager.sharedManager.saveContext()
            }
            
            
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_CANCEL_ACTION", comment: ""), style: .cancel, handler: nil)
            
            finishActionMenu.addAction(finishSuccessAction)
            
            finishActionMenu.addAction(cancelAction)
            
            
            self.present(finishActionMenu, animated: true, completion: nil)
            
            
            
        }
        
        
    }
    
    
    @IBAction func clearParticipants(_ sender: UIBarButtonItem) {
        
        SweetAlert().showAlert(NSLocalizedString("DELETE_ALERT", comment: ""), subTitle: NSLocalizedString("CLEAR_PARTICIPANTS_ALERT_MESSAGE", comment: ""), style: AlertStyle.warning, buttonTitle:NSLocalizedString("DELETE_ALERT_BUTTON", comment: ""), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  NSLocalizedString("CLEAR_PARTICIPANTS_ALERT_OTHER_BUTTON", comment: ""), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
                
            }
            else {
                
                let projectToClear = self.project
                
                let participants = projectToClear.workers?.allObjects as! [Person]
                
                for person in participants {
                    projectToClear.remove(workerObject: person)
                }
                
                let managedObjectContext = ANDataManager.sharedManager.context

                
                if managedObjectContext.hasChanges {
                    do {
                        try managedObjectContext.save()
                    } catch {
                        let nserror = error as NSError
                        NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                        abort()
                    }
                }
                
                SweetAlert().showAlert(NSLocalizedString("DELETE_ACTION_RESULT", comment: ""), subTitle: NSLocalizedString("CLEAR_PARTICIPANTS_ALERT_RESULT_TITLE", comment: ""), style: AlertStyle.success)
                
                self.projectParticipants = self.project.workers?.allObjects as! [Person]
                
                self.refreshClearParticipantsButton()

                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
    @IBAction func deleteButtonPressed(_ sender: UIBarButtonItem) {
        
        SweetAlert().showAlert(NSLocalizedString("DELETE_ALERT", comment: ""), subTitle: NSLocalizedString("DELETE_PROJECT_ALERT_MESSAGE", comment: ""), style: AlertStyle.warning, buttonTitle:NSLocalizedString("DELETE_ALERT_BUTTON", comment: ""), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  NSLocalizedString("DELETE_PROJECT_ALERT_OTHER_BUTTON", comment: ""), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
                
            }
            else {
                
                let projectToRemove = self.project
                
                
                let managedObjectContext = ANDataManager.sharedManager.context
                
                managedObjectContext.delete(projectToRemove)
                
                if managedObjectContext.hasChanges {
                    do {
                        try managedObjectContext.save()
                    } catch {
                        let nserror = error as NSError
                        NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                        abort()
                    }
                }
                
                SweetAlert().showAlert(NSLocalizedString("DELETE_ACTION_RESULT", comment: ""), subTitle: NSLocalizedString("DELETE_PROJECT_ACTION_RESULT_TITLE", comment: ""), style: AlertStyle.success)
                
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        
        transitToParticipantsSelection()
    }
    
    func editPressed(_ sender: UIBarButtonItem) {
        
        tableView.setEditing(!isEditingMode, animated: true)
        isEditingMode = !isEditingMode
        
        var buttonItem: UIBarButtonSystemItem
        
        if isEditingMode {
            buttonItem = .done
            
            selectCellShowed = true
            sectionsCount = 4
            
            tableView.beginUpdates()
            
            tableView.insertSections(IndexSet(integer: 2), with: .fade)
            
            tableView.endUpdates()
            
            
            let selectCellIndexP = IndexPath(row: 0, section: 2)
            
            let selectCell = tableView.cellForRow(at: selectCellIndexP) as! ANProjectAddPersonCell
            
            ANAnimator.sharedAnimator.animateSelectRowView(selectCell.addPersonView)



            
        } else {
            buttonItem = .edit
            
            selectCellShowed = false
            sectionsCount = 3
            
            tableView.beginUpdates()
            
            tableView.deleteSections(IndexSet(integer: 2), with: .fade)
            
            tableView.endUpdates()
            
            ANDataManager.sharedManager.saveContext()
        }
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonItem, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditItem" {
            
            let navigationController = segue.destination as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.itemToEdit = project
            
            controller.delegate = self

        }
    }
    
    
}



// MARK: - UITableViewDataSource

extension ANProjectDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.personProject.rawValue:
            return 1
        case ANSectionType.separator.rawValue:
            return 1
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            return 1
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            return projectParticipants.count
        case ANSectionType.person.rawValue:
            return projectParticipants.count
        default:
            break
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdPersonProject = "personProjectsCell"
        let cellIdSeparator = "separatorCell"
        let cellIdAddbutton = "AddCell"
        let cellIdPerson = "ANPersonCell"
        
        switch indexPath.section {
        case ANSectionType.personProject.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPersonProject, for: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
            
            if project.finished?.boolValue == true {
                cell.selectionStyle = .none
            } else {
                cell.selectionStyle = .default
            }
            
            return cell
            
        case ANSectionType.separator.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdSeparator, for: indexPath)
            return cell
            
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdAddbutton, for: indexPath) as! ANProjectAddPersonCell
            
            return cell
            
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPerson, for: indexPath)  as! ANPersonCell
            configurePersonCell(cell, atIndexPath: indexPath)
            return cell
            
        case ANSectionType.person.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdPerson, for: indexPath)  as! ANPersonCell
            configurePersonCell(cell, atIndexPath: indexPath)
            return cell
            
        default:
            
            let cell = UITableViewCell()
            return cell
            
        }
        
    }
    
}



// MARK: - UITableViewDelegate

extension ANProjectDetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        switch indexPath.section {
        case ANSectionType.personProject.rawValue:
            return 80
        case ANSectionType.separator.rawValue:
            return 20
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            return 70
        case ANSectionType.person.rawValue:
            return 70
        default:
            break
            
        }
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.personProject.rawValue:
            return 80
        case ANSectionType.separator.rawValue:
            return 20
        case ANSectionType.addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.addbutton.rawValue where selectCellShowed == false:
            return 70
        case ANSectionType.person.rawValue:
            return 70
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == ANSectionType.personProject.rawValue && project.finished?.boolValue == false {
            
            
            performSegue(withIdentifier: "EditItem", sender: self)
            
        } else if indexPath.section == ANSectionType.addbutton.rawValue && selectCellShowed {
            
            
            
        } else if indexPath.section == ANSectionType.person.rawValue || (indexPath.section == ANSectionType.addbutton.rawValue && !selectCellShowed) {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ANPersonDetailsViewController") as! ANPersonDetailsViewController
            
            vc.person = projectParticipants[indexPath.row] as Person
            
            vc.delegate = self
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section != ANSectionType.person.rawValue  {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let person = projectParticipants[indexPath.row]
            
            project.remove(workerObject: person)
            
            projectParticipants = project.workers?.allObjects as! [Person]
            
            tableView.beginUpdates()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            tableView.endUpdates()
            
        }
    }
}



// MARK: - ANPeopleSelectionViewControllerDelegate

extension ANProjectDetailsViewController: ANPeopleSelectionViewControllerDelegate {
    
    func participantsSelectionDidFinish(_ selectedParticipants: [Person]) {
        
        projectParticipants = selectedParticipants
        
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
        
    }
    
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANProjectDetailsViewController: ANNewProjectTableViewControllerDelegate {
    
    func projectDetailsVCDidCancel(_ controller: ANNewProjectTableViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {
        
    }
    
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {
        controller.dismiss(animated: true, completion: nil)
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        tableView.reloadData()
        
        
        delegate?.projectEditingDidEndForProject(project)

    }

}


// MARK: - ANPersonDetailsVCDelegate

extension ANProjectDetailsViewController: ANPersonDetailsVCDelegate {
    
    func personEditingDidEndForPerson(_ person: Person) {
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        refreshVCTitle()
        
        tableView.reloadData()
        
        ANDataManager.sharedManager.saveContext()
        
    }

}











