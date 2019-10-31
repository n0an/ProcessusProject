//
//  ANEditProjectTableViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 26/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit

protocol ANEditProjectTableViewControllerDelegate: class {
    
    func projectEditingDidEndForProject(_ project: Project)
    
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
        case generalInfo = 0
        case additionalInfo
    }
    
    enum ANGeneralRowType: Int {
        case customerName = 0
        case title
        case dueDate
        case remind
        case datePicker
    }
    
    enum ANAdditionalRowType: Int {
        case progress
        case status
    }
    
    var isEditingMode = false
    
    weak var delegate: ANEditProjectTableViewControllerDelegate?
    
    var itemToEdit: Project?
    
    var dueDate = Date()
    var datePickerVisible = false
    
    var customerName: String!
    var projectTitle: String!

    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = NSLocalizedString("NEWPROJECTVC_TITLE", comment: "")
            
            customerTitleTextField.text = item.customer
            
            projectTitleTextField.text  = item.name
            
            dueDate = item.dueDate! as Date
            
            progressSlider.value = (item.completedRatio?.floatValue)!
            stateControl.selectedSegmentIndex = (item.state?.intValue)!
            
            shouldRemindSwitch.isOn = (item.shouldRemind?.boolValue)!

            
            // Saving initial credentials
            customerName    = item.customer
            projectTitle    = item.name

        }
        
        updateStateView()
        updateProgressLabel()
        updateDueDateLabel()
        
        ANConfigurator.sharedConfigurator.customizeSlider(progressSlider)

        
        let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        tableView.isUserInteractionEnabled = false
        
        navigationItem.rightBarButtonItem = rightButton
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    deinit {
        
        
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
            editingProject.dueDate          = dueDate as NSDate
            
            editingProject.completedRatio   = progressSlider.value as NSNumber?
            editingProject.state            = stateControl.selectedSegmentIndex as NSNumber?
            
            editingProject.shouldRemind     = shouldRemindSwitch.isOn as NSNumber?
            
            editingProject.scheduleNotification()
            
            ANDataManager.sharedManager.saveContext()
            
        }
    }
    
    
    func showDatePicker() {
        datePickerVisible = true
        
        let indexPathDatePicker = IndexPath(row: 4, section: 0)
        
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        
        dueDateLabel.textColor = dueDateLabel.tintColor
        
        datePicker.setDate(dueDate, animated: false)
    }
    
    
    func hideDatePicker() {
        
        if datePickerVisible {
            datePickerVisible = false
            
            let indexPathDatePicker = IndexPath(row: 4, section: 0)
            
            dueDateLabel.textColor = UIColor.black
            
            tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
        }
    }
    
    
    func updateDueDateLabel() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dueDateLabel.text = formatter.string(from: dueDate)
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
        case ANProjectState.nonActive.rawValue:
            stateColor = UIColor.red
        case ANProjectState.frozen.rawValue:
            stateColor = UIColor.yellow
        case ANProjectState.active.rawValue:
            stateColor = UIColor.green
        default:
            break
        }
        
        projectStateView.backgroundColor = stateColor
    }
    
    func isItDatePickerCellForSection(_ section: Int, andRow row: Int) -> Bool {
        if section == ANSectionType.generalInfo.rawValue && row == ANGeneralRowType.dueDate.rawValue {
            return true
        } else {
            return false
        }
        
    }
    
    
    // MARK: - ACTIONS
    
    @objc func editPressed(_ sender: UIBarButtonItem) {
        
        isEditingMode = !isEditingMode
        
        var buttonItem: UIBarButtonItem.SystemItem
        
        if isEditingMode {
            buttonItem = .done
            tableView.isUserInteractionEnabled = true
            
            customerTitleTextField.becomeFirstResponder()

        } else {
            buttonItem = .edit
            tableView.isUserInteractionEnabled = false
            
            customerTitleTextField.resignFirstResponder()
            projectTitleTextField.resignFirstResponder()
            
            hideDatePicker()
            
            var error = ""
            if customerTitleTextField.text == "" {
                error = NSLocalizedString("ERROR_CUSTOMER_NAME_FIELD", comment: "")
            } else if projectTitleTextField.text == "" {
                error = NSLocalizedString("ERROR_PROJECT_TITLE_FIELD", comment: "")
            }
            
            
            if error != "" {
                
                let alertController = UIAlertController(title: NSLocalizedString("SAVE_ALERT_TITLE", comment: ""), message: NSLocalizedString("SAVE_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("SAVE_ALERT_MESSAGE2", comment: ""), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
                
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                resetTextFields()
                
                return
            }
            
        
            save()
            
        }
        
        
        let rightButton = UIBarButtonItem(barButtonSystemItem: buttonItem, target: self, action: #selector(ANEditProjectTableViewController.editPressed(_:)))
        
        navigationItem.rightBarButtonItem = rightButton
        
    }
    
    
    @IBAction func actionProgressSliderValueChanged(_ sender: UISlider) {
        
        updateProgressLabel()
        
    }
    
    
    @IBAction func actionStateSegmControlValueChanged(_ sender: UISegmentedControl) {
        
        updateStateView()
        
    }
    
    
    @IBAction func dateChanged(_ datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDueDateLabel()
    }
    
    
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == ANSectionType.generalInfo.rawValue && indexPath.row == ANGeneralRowType.datePicker.rawValue {
            return datePickerCell
        } else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == ANSectionType.generalInfo.rawValue && datePickerVisible {
            return 5
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
        
    }
    
    
    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == ANSectionType.generalInfo.rawValue && indexPath.row == ANGeneralRowType.datePicker.rawValue {
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isItDatePickerCellForSection(indexPath.section, andRow: indexPath.row) {
            
            if !datePickerVisible {
                
                showDatePicker()
            } else {
                hideDatePicker()
                
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        customerTitleTextField.resignFirstResponder()
        projectTitleTextField.resignFirstResponder()
        
        if isItDatePickerCellForSection(indexPath.section, andRow: indexPath.row) {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == ANSectionType.generalInfo.rawValue && indexPath.row == ANGeneralRowType.datePicker.rawValue {
            let indexP = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: indexP)
        }
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    
}




// MARK: - UITextFieldDelegate

extension ANEditProjectTableViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === projectTitleTextField{
            textField.resignFirstResponder()
        } else {
            projectTitleTextField.becomeFirstResponder()
        }
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    
}

















