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
    
    func projectDetailsVCDidCancel(_ controller: ANNewProjectTableViewController)
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishAddingItem item: Project)
    func projectDetailsVC(_ controller: ANNewProjectTableViewController, didFinishEditingItem item: Project)
    
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
        case participants = 0
        case progress
        case status
    }
    
    
    weak var delegate: ANNewProjectTableViewControllerDelegate?
    
    var itemToEdit: Project?

    var dueDate = Date()
    var datePickerVisible = false
    
    var projectParticipants: [Person] = []
    var initialParticipants: NSSet?

    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let item = itemToEdit {
            title = NSLocalizedString("NEWPROJECTVC_TITLE", comment: "")

            customerTitleTextField.text = item.customer
            
            projectTitleTextField.text  = item.name
            
            dueDate = item.dueDate! as Date
            
            shouldRemindSwitch.isOn = (item.shouldRemind?.boolValue)!
            
            progressSlider.value = (item.completedRatio?.floatValue)!
            stateControl.selectedSegmentIndex = (item.state?.intValue)!
            
            // shouldRemindSwitch.on = item.shouldRemind
            
            doneBarButton.isEnabled = true
            
            projectParticipants = item.workers?.allObjects as! [Person]
            initialParticipants = item.workers?.copy() as? NSSet
            
            participantsCount.text = "\(projectParticipants.count)"
        }

        updateStateView()
        updateProgressLabel()
        updateDueDateLabel()
    
        
        ANConfigurator.sharedConfigurator.customizeSlider(progressSlider)


    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        customerTitleTextField.becomeFirstResponder()
    }

    
    // MARK: - HELPER METHODS

    
    func showDatePicker() {
        datePickerVisible = true
        
        let indexPathDatePicker = IndexPath(row: ANGeneralRowType.datePicker.rawValue, section: ANSectionType.generalInfo.rawValue)
        
        tableView.insertRows(at: [indexPathDatePicker], with: .fade)
        
        dueDateLabel.textColor = dueDateLabel.tintColor
        
        datePicker.setDate(dueDate, animated: false)
    }
    
    
    func hideDatePicker() {
        if datePickerVisible {
            datePickerVisible = false
            
            let indexPathDatePicker = IndexPath(row: ANGeneralRowType.datePicker.rawValue, section: ANSectionType.generalInfo.rawValue)
            
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
    
    
    
    func transitToParticipantSelection() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
        let firstNameDescriptor = NSSortDescriptor(key: "firstName", ascending: true)
        let lastNameDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        
        fetchRequest.sortDescriptors = [firstNameDescriptor, lastNameDescriptor]

        let context = ANDataManager.sharedManager.context
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ANPeopleSelectionViewController") as! ANPeopleSelectionViewController
        
        vc.project = itemToEdit!
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
    
    func isItDatePickerCellForSection(_ section: Int, andRow row: Int) -> Bool {
        if section == ANSectionType.generalInfo.rawValue && row == ANGeneralRowType.dueDate.rawValue {
            return true
        } else {
            return false
        }
        
    }
    
    func isItParticipantsCellForSection(_ section: Int, andRow row: Int) -> Bool {
        if itemToEdit != nil && section == ANSectionType.additionalInfo.rawValue && row == ANAdditionalRowType.participants.rawValue {
            return true
        } else {
            return false
        }
        
    }
    
    func checkForSave() -> Bool {
        var error = ""
        if customerTitleTextField.text == "" {
            error = NSLocalizedString("ERROR_CUSTOMER_NAME_FIELD", comment: "")
        } else if projectTitleTextField.text == "" {
            error = NSLocalizedString("ERROR_PROJECT_TITLE_FIELD", comment: "")
        }
        
        if error != "" {
            
            let alertController = UIAlertController(title: NSLocalizedString("SAVE_ALERT_TITLE", comment: ""), message: NSLocalizedString("SAVE_ALERT_MESSAGE1", comment: "") + error + NSLocalizedString("SAVE_ALERT_MESSAGE2", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            return false
        }
        
        return true
    }
    
    

    
    // MARK: - ACTIONS
    
    @IBAction func unwindBackToHomeScreen(_ segue: UIStoryboardSegue) {
        
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
            editingProject.shouldRemind     = shouldRemindSwitch.isOn as NSNumber?
            
            editingProject.completedRatio   = progressSlider.value as NSNumber?
            editingProject.state            = stateControl.selectedSegmentIndex as NSNumber?
            
            editingProject.scheduleNotification()
            
            ANDataManager.sharedManager.saveContext()
            
            delegate?.projectDetailsVC(self, didFinishEditingItem: editingProject)
            
        } else {
            let context = ANDataManager.sharedManager.context
            
            guard let newProject = NSEntityDescription.insertNewObject(forEntityName: "Project", into: context) as? Project else {return}
            
            newProject.customer         = customerTitleTextField.text
            newProject.name             = projectTitleTextField.text
            newProject.dueDate          = dueDate
            newProject.shouldRemind     = shouldRemindSwitch.isOn as NSNumber?
            
            newProject.completedRatio   = progressSlider.value as NSNumber?
            newProject.state            = stateControl.selectedSegmentIndex as NSNumber?
            
            newProject.finished         = false
            
            let newId = ANDataManager.sharedManager.nextProjectItemID()
            
            newProject.projectId        = newId as NSNumber?
            
            newProject.scheduleNotification()

            
            //        newProject.descript = projectInfoDescriptionTextView.text!
            
            ANDataManager.sharedManager.saveContext()
            
            delegate?.projectDetailsVC(self, didFinishAddingItem: newProject)
            
        }
    }
    
    @IBAction func actionShouldRemindToggled(_ switchControl: UISwitch) {
        
        if shouldRemindSwitch.isOn {
            let notificationsSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationsSettings)
        }
        
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
            
        } else if isItParticipantsCellForSection(indexPath.section, andRow: indexPath.row) {
            
            if datePickerVisible {
                hideDatePicker()
            }
            
            transitToParticipantSelection()
        }
    }
    
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
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
    
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        if indexPath.section == ANSectionType.generalInfo.rawValue && indexPath.row == ANGeneralRowType.datePicker.rawValue {
            let indexP = IndexPath(row: 0, section: indexPath.section)
            return super.tableView(tableView, indentationLevelForRowAt: indexP)
        }
        
        return super.tableView(tableView, indentationLevelForRowAt: indexPath)
    }


    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === projectTitleTextField{
            textField.resignFirstResponder()
        } else {
            projectTitleTextField.becomeFirstResponder()
        }
        
        return false
    }

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text! as NSString
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    }

}


// MARK: - ANPeopleSelectionViewControllerDelegate
extension ANNewProjectTableViewController: ANPeopleSelectionViewControllerDelegate {
    
    func participantsSelectionDidFinish(_ selectedParticipants: [Person]) {
        
        updateParticipantsCount()
        
        tableView.reloadData()
        
        
    }

    
}













