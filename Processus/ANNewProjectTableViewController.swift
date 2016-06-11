//
//  ANNewProjectTableViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 24/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

protocol ANNewProjectTableViewControllerDelegate: class {
    
    func projectDetailsVCDidCancel(controller: ANNewProjectTableViewController)
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishAddingItem item: Project)
    func projectDetailsVC(controller: ANNewProjectTableViewController, didFinishEditingItem item: Project)
    
}


class ANNewProjectTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var customerTitleTextField: UITextField!
    @IBOutlet weak var projectTitleTextField: UITextField!
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var progressPercentLabel: UILabel!

    @IBOutlet weak var stateControl: UISegmentedControl!
    @IBOutlet weak var projectStateView: UIView!
    @IBOutlet weak var participantsCount: UILabel!


    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case GeneralInfo = 0
        case AdditionalInfo
    }
    
    enum ANGeneralRowType: Int {
        case CustomerName = 0
        case Title
        case DueDate
        case Remind
        case DatePicker
    }
    
    enum ANAdditionalRowType: Int {
        case Participants = 0
        case Progress
        case Status
    }
    
    
    weak var delegate: ANNewProjectTableViewControllerDelegate?
    
    var itemToEdit: Project?

    var dueDate = NSDate()
    var datePickerVisible = false
    
    var projectParticipants: [Person] = []
    var initialParticipants: NSSet?

    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = "Edit Project"

            customerTitleTextField.text = item.customer
            
            projectTitleTextField.text  = item.name
            
            dueDate = item.dueDate!
            
            shouldRemindSwitch.on = (item.shouldRemind?.boolValue)!
            
            progressSlider.value = (item.completedRatio?.floatValue)!
            stateControl.selectedSegmentIndex = (item.state?.integerValue)!
            
            // shouldRemindSwitch.on = item.shouldRemind
            
            doneBarButton.enabled = true
            
            projectParticipants = item.workers?.allObjects as! [Person]
            initialParticipants = item.workers?.copy() as? NSSet
            
            participantsCount.text = "\(projectParticipants.count)"
        }

        updateStateView()
        updateProgressLabel()
        updateDueDateLabel()
    
        
        ANConfigurator.sharedConfigurator.customizeSlider(progressSlider)


    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        customerTitleTextField.becomeFirstResponder()
    }

    
    // MARK: - HELPER METHODS

    
    func showDatePicker() {
        datePickerVisible = true
        
        let indexPathDatePicker = NSIndexPath(forRow: ANGeneralRowType.DatePicker.rawValue, inSection: ANSectionType.GeneralInfo.rawValue)
        
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        
        dueDateLabel.textColor = dueDateLabel.tintColor
        
        datePicker.setDate(dueDate, animated: false)
    }
    
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            
            let indexPathDatePicker = NSIndexPath(forRow: ANGeneralRowType.DatePicker.rawValue, inSection: ANSectionType.GeneralInfo.rawValue)
            
            dueDateLabel.textColor = UIColor.blackColor()
            
            tableView.deleteRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        }
    }
    
    
    func updateDueDateLabel() {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        dueDateLabel.text = formatter.stringFromDate(dueDate)
    }
    
    
    func updateParticipantsCount() {
        
        if let item = itemToEdit {
            projectParticipants = item.workers?.allObjects as! [Person]
            
            participantsCount.text = "\(projectParticipants.count)"
        }
    }
    
    
    func updateProgressLabel() {
        
        let value = progressSlider.value
        let intVal = Int(value)
        
        progressPercentLabel.text = "\(intVal) %"
        
    }
    
    func updateStateView() {
        let projectState = stateControl.selectedSegmentIndex
        
        var stateColor = UIColor()
        
        switch projectState {
        case ANProjectState.NonActive.rawValue:
            stateColor = UIColor.redColor()
        case ANProjectState.Frozen.rawValue:
            stateColor = UIColor.yellowColor()
        case ANProjectState.Active.rawValue:
            stateColor = UIColor.greenColor()
        default:
            break
        }
        
        projectStateView.backgroundColor = stateColor
    }
    
    
    
    func transitToParticipantSelection() {
        let fetchRequest = NSFetchRequest(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]

        let context = ANDataManager.sharedManager.context
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("ANPeopleSelectionViewController") as! ANPeopleSelectionViewController
        
        vc.project = itemToEdit!
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
    
    func isItDatePickerCellForSection(section: Int, andRow row: Int) -> Bool {
        if section == ANSectionType.GeneralInfo.rawValue && row == ANGeneralRowType.DueDate.rawValue {
            return true
        } else {
            return false
        }
        
    }
    
    func isItParticipantsCellForSection(section: Int, andRow row: Int) -> Bool {
        if itemToEdit != nil && section == ANSectionType.AdditionalInfo.rawValue && row == ANAdditionalRowType.Participants.rawValue {
            return true
        } else {
            return false
        }
        
    }
    
    func checkForSave() -> Bool {
        var error = ""
        if customerTitleTextField.text == "" {
            error = "Customer Name"
        } else if projectTitleTextField.text == "" {
            error = "Project Title"
        }
        
        if error != "" {
            
            let alertController = UIAlertController(title: "Ого!", message: "Сохранение не удалось, так как поле " + error + " не заполнено", preferredStyle: .Alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    

    
    // MARK: - ACTIONS
    
    @IBAction func unwindBackToHomeScreen(segue: UIStoryboardSegue) {
        
        if let item = itemToEdit {
            item.workers = initialParticipants
        }

        delegate!.projectDetailsVCDidCancel(self)
    }
    
    @IBAction func cancelPressed() {
        
        if let item = itemToEdit {
            item.workers = initialParticipants
        }
        
        delegate?.projectDetailsVCDidCancel(self)
        
    }
    
    @IBAction func saveProject() {
        
        guard checkForSave() else {return}
        
        if let editingProject = itemToEdit {
            
            editingProject.customer         = customerTitleTextField.text
            editingProject.name             = projectTitleTextField.text
            editingProject.dueDate          = dueDate
            editingProject.shouldRemind     = shouldRemindSwitch.on
            
            editingProject.completedRatio   = progressSlider.value
            editingProject.state            = stateControl.selectedSegmentIndex
            
            editingProject.scheduleNotification()
            
            ANDataManager.sharedManager.saveContext()
            
            delegate?.projectDetailsVC(self, didFinishEditingItem: editingProject)
            
        } else {
            let context = ANDataManager.sharedManager.context
            
            guard let newProject = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: context) as? Project else {return}
            
            newProject.customer         = customerTitleTextField.text
            newProject.name             = projectTitleTextField.text
            newProject.dueDate          = dueDate
            newProject.shouldRemind     = shouldRemindSwitch.on
            
            newProject.completedRatio   = progressSlider.value
            newProject.state            = stateControl.selectedSegmentIndex
            
            newProject.finished         = false
            
            let newId = ANDataManager.sharedManager.nextProjectItemID()
            
            newProject.projectId        = newId
            
            newProject.scheduleNotification()

            
            //        newProject.descript = projectInfoDescriptionTextView.text!
            
            ANDataManager.sharedManager.saveContext()
            
            delegate?.projectDetailsVC(self, didFinishAddingItem: newProject)
            
        }
    }
    
    @IBAction func actionShouldRemindToggled(switchControl: UISwitch) {
        
        if shouldRemindSwitch.on {
            let notificationsSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationsSettings)
        }
        
    }
    
    @IBAction func actionProgressSliderValueChanged(sender: UISlider) {
        updateProgressLabel()
    }
    
    
    @IBAction func actionStateSegmControlValueChanged(sender: UISegmentedControl) {
        updateStateView()
    }
    
    
    @IBAction func dateChanged(datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDueDateLabel()
    }

    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == ANSectionType.GeneralInfo.rawValue && indexPath.row == ANGeneralRowType.DatePicker.rawValue {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == ANSectionType.GeneralInfo.rawValue && datePickerVisible {
            return 5
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.section == ANSectionType.GeneralInfo.rawValue && indexPath.row == ANGeneralRowType.DatePicker.rawValue {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
        
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if isItDatePickerCellForSection(indexPath.section, andRow: indexPath.row) {
            
            if !datePickerVisible {
                showDatePicker()
            } else {
                hideDatePicker()
            }
            
        } else if isItParticipantsCellForSection(indexPath.section, andRow: indexPath.row) {
            
            if datePickerVisible {
                hideDatePicker()
            }
            
            transitToParticipantSelection()
        }
    }
    
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        
        customerTitleTextField.resignFirstResponder()
        projectTitleTextField.resignFirstResponder()
        
        if isItDatePickerCellForSection(indexPath.section, andRow: indexPath.row) {
            return indexPath
        
        } else if isItParticipantsCellForSection(indexPath.section, andRow: indexPath.row) {
            
            return indexPath
            
        } else {
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == ANSectionType.GeneralInfo.rawValue && indexPath.row == ANGeneralRowType.DatePicker.rawValue {
            let indexP = NSIndexPath(forRow: 0, inSection: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexP)
        }
        
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }


    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === projectTitleTextField{
            textField.resignFirstResponder()
        } else {
            projectTitleTextField.becomeFirstResponder()
        }
        
        return false
    }

    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        doneBarButton.enabled = (newText.length > 0)
        return true
    }

}


// MARK: - ANPeopleSelectionViewControllerDelegate
extension ANNewProjectTableViewController: ANPeopleSelectionViewControllerDelegate {
    
    func participantsSelectionDidFinish(selectedParticipants: [Person]) {
        
        updateParticipantsCount()
        
        tableView.reloadData()
        
        
    }

    
}













