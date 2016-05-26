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
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = "Edit Project"

            customerTitleTextField.text = item.customer
            
            projectTitleTextField.text  = item.name
            
            dueDate = item.dueDate!
            
            progressSlider.value = (item.completedRatio?.floatValue)!
            stateControl.selectedSegmentIndex = (item.state?.integerValue)!
            
            // shouldRemindSwitch.on = item.shouldRemind
            
            doneBarButton.enabled = true
            
            
            projectParticipants = item.workers?.allObjects as! [Person]
            
//            let partCount = item.workers?.count
            
            participantsCount.text = "\(projectParticipants.count)"

        }

        updateStateView()
        updateProgressLabel()
        updateDueDateLabel()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        customerTitleTextField.becomeFirstResponder()
    }

    
    // MARK: - HELPER METHODS
    
    @IBAction func saveProject() {
        
        if let editingProject = itemToEdit {
            
            editingProject.customer = customerTitleTextField.text
            editingProject.name             = projectTitleTextField.text
            editingProject.dueDate          = dueDate
            
            editingProject.completedRatio   = progressSlider.value
            editingProject.state            = stateControl.selectedSegmentIndex
            
            ANDataManager.sharedManager.saveContext()
            
            delegate?.projectDetailsVC(self, didFinishEditingItem: editingProject)
            
        } else {
            let context = ANDataManager.sharedManager.context
            
            guard let newProject = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: context) as? Project else {return}
            
            newProject.customer         = customerTitleTextField.text
            newProject.name             = projectTitleTextField.text
            newProject.dueDate          = dueDate
            
            newProject.completedRatio   = progressSlider.value
            newProject.state            = stateControl.selectedSegmentIndex
            
            //        newProject.descript = projectInfoDescriptionTextView.text!
            
            ANDataManager.sharedManager.saveContext()
            
            delegate?.projectDetailsVC(self, didFinishAddingItem: newProject)

        }

        performSegueWithIdentifier("unwindBackToHomeScreen", sender: self)
        
        
    }
    
    func showDatePicker() {
        datePickerVisible = true
        
        let indexPathDatePicker = NSIndexPath(forRow: 4, inSection: 0)
        
        tableView.insertRowsAtIndexPaths([indexPathDatePicker], withRowAnimation: .Fade)
        
        dueDateLabel.textColor = dueDateLabel.tintColor
        
        datePicker.setDate(dueDate, animated: false)
    }
    
    
    func hideDatePicker() {
        
        if datePickerVisible {
            datePickerVisible = false
            
            let indexPathDatePicker = NSIndexPath(forRow: 4, inSection: 0)
            
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
//        vc.delegate = self
        
        
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
    
    @IBAction func unwindBackToHomeScreen(segue: UIStoryboardSegue) {
        delegate!.projectDetailsVCDidCancel(self)
    }
    
    @IBAction func actionProgressSliderValueChanged(sender: UISlider) {
        
        print("actionProgressSliderValueChanged")
        
        updateProgressLabel()
        
    }
    
    
    @IBAction func actionStateSegmControlValueChanged(sender: UISegmentedControl) {
        print("actionStateSegmControlValueChanged")
        
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
        
        customerTitleTextField.resignFirstResponder()
        projectTitleTextField.resignFirstResponder()
        
        if indexPath.section == ANSectionType.GeneralInfo.rawValue && indexPath.row == ANGeneralRowType.DueDate.rawValue {
            
            if !datePickerVisible {
                
                showDatePicker()
            } else {
                hideDatePicker()

            }
            
        } else if indexPath.section == ANSectionType.AdditionalInfo.rawValue && indexPath.row == ANAdditionalRowType.Participants.rawValue {
            
            if datePickerVisible {
                hideDatePicker()
            }
            
            print("test")
            
        }
    }

    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == ANSectionType.GeneralInfo.rawValue && indexPath.row == ANGeneralRowType.DueDate.rawValue {
            return indexPath
        
        } else if indexPath.section == ANSectionType.AdditionalInfo.rawValue && indexPath.row == ANAdditionalRowType.Participants.rawValue {
            return indexPath
            
        } else {
            return nil
        }
    }
    
    
    override func tableView(tableView: UITableView, var indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        if indexPath.section == ANSectionType.GeneralInfo.rawValue && indexPath.row == ANGeneralRowType.DatePicker.rawValue {
            indexPath = NSIndexPath(forRow: 0, inSection: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }


    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text!
        let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
        
        doneBarButton.enabled = (newText.length > 0)
        return true
    }

    

}


extension ANNewProjectViewController: ANPeopleSelectionViewControllerDelegate {
    
    func participantsSelectionDidFinish(selectedParticipants: [Person]) {
        
        tableView.reloadData()
        
        
    }

    
}













