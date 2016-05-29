//
//  ANEditProjectTableViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 26/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

protocol ANEditProjectTableViewControllerDelegate: class {
    
    func projectEditingDidEndForProject(project: Project)
    
}

class ANEditProjectTableViewController: UITableViewController {
    
    // MARK: - OUTLETS
    
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    @IBOutlet weak var customerTitleTextField: UITextField!
    @IBOutlet weak var projectTitleTextField: UITextField!
    
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var progressPercentLabel: UILabel!
    
    @IBOutlet weak var stateControl: UISegmentedControl!
    @IBOutlet weak var projectStateView: UIView!

    
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
        case Progress
        case Status
    }
    
    var isEditingMode = false
    
    weak var delegate: ANEditProjectTableViewControllerDelegate?
    
    var itemToEdit: Project?
    
    var dueDate = NSDate()
    var datePickerVisible = false
    
    var customerName: String!
    var projectTitle: String!

    
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
            
            shouldRemindSwitch.on = (item.shouldRemind?.boolValue)!

            
            // shouldRemindSwitch.on = item.shouldRemind
            
            // Saving initial credentials
            customerName    = item.customer
            projectTitle    = item.name

        }
        
        updateStateView()
        updateProgressLabel()
        updateDueDateLabel()
        
        
        let rightButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        tableView.userInteractionEnabled = false
        
        navigationItem.rightBarButtonItem = rightButton

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

    }
    
    deinit {
        
        print("ANEditProjectTableViewController deinit")
        
        delegate?.projectEditingDidEndForProject(itemToEdit!)
    }
    
    
    
    // MARK: - HELPER METHODS
    
    func resetTextFields() {
        customerTitleTextField.text = customerName
        projectTitleTextField.text = projectTitle
    }
    
    
    func save() {
        if let editingProject = itemToEdit {
            
            editingProject.customer         = customerTitleTextField.text
            editingProject.name             = projectTitleTextField.text
            editingProject.dueDate          = dueDate
            
            editingProject.completedRatio   = progressSlider.value
            editingProject.state            = stateControl.selectedSegmentIndex
            
            editingProject.shouldRemind     = shouldRemindSwitch.on
            
            ANDataManager.sharedManager.saveContext()
            
        }
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
    
    func isItDatePickerCellForSection(section: Int, andRow row: Int) -> Bool {
        if section == ANSectionType.GeneralInfo.rawValue && row == ANGeneralRowType.DueDate.rawValue {
            return true
        } else {
            return false
        }
        
    }
    
    
    // MARK: - ACTIONS
    
    func editPressed(sender: UIBarButtonItem) {
        
        isEditingMode = !isEditingMode
        
        var buttonItem: UIBarButtonSystemItem
        
        if isEditingMode {
            buttonItem = .Done
            tableView.userInteractionEnabled = true
            
            customerTitleTextField.becomeFirstResponder()

        } else {
            buttonItem = .Edit
            tableView.userInteractionEnabled = false
            
            customerTitleTextField.resignFirstResponder()
            projectTitleTextField.resignFirstResponder()
            
            hideDatePicker()
            
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
                
                resetTextFields()
                
                return
            }
            
            // if no error - save it!
            save()
            
        }
        
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonItem, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
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
    
    
    // MARK: - UITableViewDelegate

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
        
        if isItDatePickerCellForSection(indexPath.section, andRow: indexPath.row) {
            
            if !datePickerVisible {
                
                showDatePicker()
            } else {
                hideDatePicker()
                
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if isItDatePickerCellForSection(indexPath.section, andRow: indexPath.row) {
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
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    
}




// MARK: - UITextFieldDelegate

extension ANEditProjectTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === projectTitleTextField{
            textField.resignFirstResponder()
        } else {
            projectTitleTextField.becomeFirstResponder()
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        hideDatePicker()
    }
    
    
}

















