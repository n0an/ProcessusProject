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
    func projectEditingDidEndForProject(project: Project)
}

class ANProjectDetailsViewController: UIViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearParticipantsButton: UIBarButtonItem!

    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case PersonProject = 0
        case Separator
        case Addbutton
        case Person
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
        tableView.allowsSelectionDuringEditing = true
        
    }
    
    deinit {
        ANDataManager.sharedManager.saveContext()
        
        delegate?.projectEditingDidEndForProject(project)
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshClearParticipantsButton()
        
        tabBarController?.tabBar.frame.origin = CGPoint(x: 0, y: CGRectGetMaxY(view.bounds))
        
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func refreshClearParticipantsButton() {
        let participants = project.workers?.allObjects
        
        if participants!.isEmpty {
            clearParticipantsButton.enabled = false
        } else {
            clearParticipantsButton.enabled = true
        }
    }
    
    func refreshVCTitle() {
        title = "\(project.name!)"

    }
    
    
    func configurePersonProjectCell(cell: ANPersonProjectCell, forIndexPath indexPath: NSIndexPath) {
        

        cell.projectDueDateLabel.text = ANConfigurator.sharedConfigurator.dateFormatter.stringFromDate(project.dueDate!)
        
        if let completedRatio = project.completedRatio?.intValue {
            cell.completedRatioLabel.text = "\(completedRatio) %"
        }

        ANConfigurator.sharedConfigurator.configureProjectCell(cell, forProject: project, viewWidth: view.bounds.width)

        
    }
    
    func configurePersonCell(cell: ANPersonCell, atIndexPath indexPath: NSIndexPath) {
        
        let person = projectParticipants[indexPath.row]
        
        guard let firstName = person.firstName else {return}
        guard let lastName = person.lastName else {return}
        
        if let imageData = person.image {
            cell.avatarImageView.image = UIImage(data: imageData)
        }
        
        if let projectsCount = person.projects?.allObjects.count {
            cell.projectsCountLabel.text = "\(projectsCount)"
        }
        
        cell.fullNameLabel.text = "\(firstName) \(lastName)"
        
    }
    
    func transitToParticipantsSelection() {
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]
        
        let context = ANDataManager.sharedManager.context
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANPeopleSelectionViewController") as! ANPeopleSelectionViewController
        
        vc.project = project
        vc.selectedPeople = projectParticipants
        vc.delegate = self
        
        do {
            let allPeople = try context.executeFetchRequest(fetchRequest) as! [Person]
            
            vc.allPeople = allPeople
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - ACTIONS
    
    
    @IBAction func actionButtonPressed(sender: UIBarButtonItem) {
        
        
        if self.project.finished?.boolValue == false {
            let finishActionMenu = UIAlertController(title: nil, message:NSLocalizedString("ACTION_DETAILS_FINISH_TITLE", comment: ""), preferredStyle: .ActionSheet)
            
            let finishSuccessAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_SUCCESS_ACTION", comment: ""), style: .Default) { (action: UIAlertAction) in
                
                let projectToFinish = self.project
                
                projectToFinish.state = ANProjectState.NonActive.rawValue
                projectToFinish.finished = true
                projectToFinish.finishedStatus = ProjectFinishedStatus.Success.rawValue
                
                ANDataManager.sharedManager.saveContext()
            }
            
            
            let finishFailureAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_FAILURE_ACTION", comment: ""), style: .Default, handler: { (action: UIAlertAction) in
                
                let projectToFinish = self.project
                
                projectToFinish.state = ANProjectState.NonActive.rawValue
                projectToFinish.finished = true
                projectToFinish.finishedStatus = ProjectFinishedStatus.Failure.rawValue
                
                ANDataManager.sharedManager.saveContext()
            })
            
            
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_CANCEL_ACTION", comment: ""), style: .Cancel, handler: nil)
            
            finishActionMenu.addAction(finishSuccessAction)
            finishActionMenu.addAction(finishFailureAction)
            
            finishActionMenu.addAction(cancelAction)
            
            
            self.presentViewController(finishActionMenu, animated: true, completion: nil)
        }
        
        
        
        if self.project.finished?.boolValue == true {

            let finishActionMenu = UIAlertController(title: nil, message: NSLocalizedString("ACTION_DETAILS_START_TITLE", comment: ""), preferredStyle: .ActionSheet)
            
            let finishSuccessAction = UIAlertAction(title: NSLocalizedString("ACTION_DETAILS_START_ACTION", comment: ""), style: .Default) { (action: UIAlertAction) in
                
                let projectToStart = self.project
                
                projectToStart.state = ANProjectState.NonActive.rawValue
                projectToStart.finished = false
                projectToStart.finishedStatus = nil
                
                ANDataManager.sharedManager.saveContext()
            }
            
            
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ACTION_FINISH_CANCEL_ACTION", comment: ""), style: .Cancel, handler: nil)
            
            finishActionMenu.addAction(finishSuccessAction)
            
            finishActionMenu.addAction(cancelAction)
            
            
            self.presentViewController(finishActionMenu, animated: true, completion: nil)
            
            
            
        }
        
        
    }
    
    
    @IBAction func clearParticipants(sender: UIBarButtonItem) {
        
        SweetAlert().showAlert(NSLocalizedString("DELETE_ALERT", comment: ""), subTitle: NSLocalizedString("CLEAR_PARTICIPANTS_ALERT_MESSAGE", comment: ""), style: AlertStyle.Warning, buttonTitle:NSLocalizedString("DELETE_ALERT_BUTTON", comment: ""), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  NSLocalizedString("CLEAR_PARTICIPANTS_ALERT_OTHER_BUTTON", comment: ""), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
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
                
                SweetAlert().showAlert(NSLocalizedString("DELETE_ACTION_RESULT", comment: ""), subTitle: NSLocalizedString("CLEAR_PARTICIPANTS_ALERT_RESULT_TITLE", comment: ""), style: AlertStyle.Success)
                
                self.projectParticipants = self.project.workers?.allObjects as! [Person]
                
                self.refreshClearParticipantsButton()

                self.tableView.reloadData()
            }
        }
        
    }
    
    
    
    @IBAction func deleteButtonPressed(sender: UIBarButtonItem) {
        
        SweetAlert().showAlert(NSLocalizedString("DELETE_ALERT", comment: ""), subTitle: NSLocalizedString("DELETE_PROJECT_ALERT_MESSAGE", comment: ""), style: AlertStyle.Warning, buttonTitle:NSLocalizedString("DELETE_ALERT_BUTTON", comment: ""), buttonColor:UIColor.colorFromRGB(0xD0D0D0) , otherButtonTitle:  NSLocalizedString("DELETE_PROJECT_ALERT_OTHER_BUTTON", comment: ""), otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
                
            }
            else {
                
                let projectToRemove = self.project
                
                
                let managedObjectContext = ANDataManager.sharedManager.context
                
                managedObjectContext.deleteObject(projectToRemove)
                
                if managedObjectContext.hasChanges {
                    do {
                        try managedObjectContext.save()
                    } catch {
                        let nserror = error as NSError
                        NSLog("deleting error occured: \(nserror), \(nserror.localizedDescription)")
                        abort()
                    }
                }
                
                SweetAlert().showAlert(NSLocalizedString("DELETE_ACTION_RESULT", comment: ""), subTitle: NSLocalizedString("DELETE_PROJECT_ACTION_RESULT_TITLE", comment: ""), style: AlertStyle.Success)
                
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        
        
        transitToParticipantsSelection()
    }
    
    func editPressed(sender: UIBarButtonItem) {
        
        tableView.setEditing(!isEditingMode, animated: true)
        isEditingMode = !isEditingMode
        
        var buttonItem: UIBarButtonSystemItem
        
        if isEditingMode {
            buttonItem = .Done
            
            selectCellShowed = true
            sectionsCount = 4
            
            tableView.beginUpdates()
            
            tableView.insertSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
            
            let selectCellIndexP = NSIndexPath(forRow: 0, inSection: 2)
            
            let selectCell = tableView.cellForRowAtIndexPath(selectCellIndexP) as! ANProjectAddPersonCell
            
            ANAnimator.sharedAnimator.animateSelectRowView(selectCell.addPersonView)



            
        } else {
            buttonItem = .Edit
            
            selectCellShowed = false
            sectionsCount = 3
            
            tableView.beginUpdates()
            
            tableView.deleteSections(NSIndexSet(index: 2), withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
            ANDataManager.sharedManager.saveContext()
        }
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonItem, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "EditItem" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ANNewProjectTableViewController
            
            controller.itemToEdit = project
            
            controller.delegate = self

        }
    }
    
    
}



// MARK: - UITableViewDataSource

extension ANProjectDetailsViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionsCount
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.PersonProject.rawValue:
            return 1
        case ANSectionType.Separator.rawValue:
            return 1
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 1
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return projectParticipants.count
        case ANSectionType.Person.rawValue:
            return projectParticipants.count
        default:
            break
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdPersonProject = "personProjectsCell"
        let cellIdSeparator = "separatorCell"
        let cellIdAddbutton = "AddCell"
        let cellIdPerson = "ANPersonCell"
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPersonProject, forIndexPath: indexPath) as! ANPersonProjectCell
            configurePersonProjectCell(cell, forIndexPath: indexPath)
            
            if project.finished?.boolValue == true {
                cell.selectionStyle = .None
            } else {
                cell.selectionStyle = .Default
            }
            
            return cell
            
        case ANSectionType.Separator.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdSeparator, forIndexPath: indexPath)
            return cell
            
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdAddbutton, forIndexPath: indexPath) as! ANProjectAddPersonCell
            
            return cell
            
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPerson, forIndexPath: indexPath)  as! ANPersonCell
            configurePersonCell(cell, atIndexPath: indexPath)
            return cell
            
        case ANSectionType.Person.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdPerson, forIndexPath: indexPath)  as! ANPersonCell
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            return 80
        case ANSectionType.Separator.rawValue:
            return 20
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return 70
        case ANSectionType.Person.rawValue:
            return 70
        default:
            break
            
        }
        
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.PersonProject.rawValue:
            return 80
        case ANSectionType.Separator.rawValue:
            return 20
        case ANSectionType.Addbutton.rawValue where selectCellShowed == true:
            return 44
        case ANSectionType.Addbutton.rawValue where selectCellShowed == false:
            return 70
        case ANSectionType.Person.rawValue:
            return 70
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == ANSectionType.PersonProject.rawValue && project.finished?.boolValue == false {
            
            
            performSegueWithIdentifier("EditItem", sender: self)
            
        } else if indexPath.section == ANSectionType.Addbutton.rawValue && selectCellShowed {
            
            
            
        } else if indexPath.section == ANSectionType.Person.rawValue || (indexPath.section == ANSectionType.Addbutton.rawValue && !selectCellShowed) {
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANPersonDetailsViewController") as! ANPersonDetailsViewController
            
            vc.person = projectParticipants[indexPath.row] as Person
            
            vc.delegate = self
            
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section != ANSectionType.Person.rawValue  {
            return false
        } else {
            return true
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let person = projectParticipants[indexPath.row]
            
            project.remove(workerObject: person)
            
            projectParticipants = project.workers?.allObjects as! [Person]
            
            tableView.beginUpdates()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
            tableView.endUpdates()
            
        }
    }
}



// MARK: - ANPeopleSelectionViewControllerDelegate

extension ANProjectDetailsViewController: ANPeopleSelectionViewControllerDelegate {
    
    func participantsSelectionDidFinish(selectedParticipants: [Person]) {
        
        projectParticipants = selectedParticipants
        
        ANDataManager.sharedManager.saveContext()
        
        tableView.reloadData()
        
    }
    
}



// MARK: - ANNewProjectTableViewControllerDelegate

extension ANProjectDetailsViewController: ANNewProjectTableViewControllerDelegate {
    
    func projectDetailsVCDidCancel(controller: ANNewProjectTableViewController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishAddingItem item: Project) {
        
    }
    
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishEditingItem item: Project) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        tableView.reloadData()
        
        
        delegate?.projectEditingDidEndForProject(project)

    }

}


// MARK: - ANPersonDetailsVCDelegate

extension ANProjectDetailsViewController: ANPersonDetailsVCDelegate {
    
    func personEditingDidEndForPerson(person: Person) {
        
        projectParticipants = project.workers?.allObjects as! [Person]
        
        refreshVCTitle()
        
        tableView.reloadData()
        
        ANDataManager.sharedManager.saveContext()
        
    }

}











