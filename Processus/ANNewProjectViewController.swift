//
//  ANNewProjectViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 14/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import CoreData

class ANNewProjectViewController: UIViewController {

    // MARK: - OUTLETS

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    
    // MARK: - ATTRIBUTES
    
    enum ANSectionType: Int {
        case ProjectTextInfo = 0, ProjectNonTextInfo
    }
    
    enum ANRowType: Int {
        case ProjectProgress = 0, ProjectState, ProjectDescription
    }
    
    enum ANFieldType: Int {
        case CustomerName = 0, ProjectName, DueDate
    }
    
    var newProject: Project!
    
    var projectInfoTextFields: [UITextField] = []
    var projectInfoDescriptionTextView: UITextView!
    
    var projectProgressCell: ANProjectInfoProgressCell!
    
    var projectStateCell: ANProjectInfoStateCell!
    
    var dateFormatter: NSDateFormatter!

    let projectInfoLabelsPlaceholders: [(label: String, placeholder: String)] = [("Заказчик:", "наименование заказчика"), ("Название проекта:", "название проекта"), ("Срок выполнения:", "срок выполненеия проекта")]
    
    let projectNonTextInfoLabels = ["Степень готовности:", "Состояние:", "Описание:"]
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        tableView.allowsSelection = false
        
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd.MM.YYYY"
        

        
    }
    
    // MARK: - ACTIONS
    
    @IBAction func saveProject() {
        
        let context = ANDataManager.sharedManager.context
        
        guard let newProject = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: context) as? Project else {return}

//        newProject = NSEntityDescription.insertNewObjectForEntityForName("Project", inManagedObjectContext: context) as! Project
        
        newProject.customer = projectInfoTextFields[0].text
        newProject.name = projectInfoTextFields[1].text
        newProject.dueDate = dateFormatter.dateFromString(projectInfoTextFields[2].text!)
        
        newProject.completedRatio = projectProgressCell.valueProgressSlider.value
        newProject.state = projectStateCell.valueStateSegmentedControl.selectedSegmentIndex
        
        newProject.descript = projectInfoDescriptionTextView.text!
        
        ANDataManager.sharedManager.saveContext()
        
        performSegueWithIdentifier("unwindBackToHomeScreen", sender: self)
        
        
    }
    
    
    @IBAction func actionProgressSliderValueChanged(sender: UISlider) {
        
        print("actionProgressSliderValueChanged")
        
        updateProgressLabel(projectProgressCell)
        
    }
    
    
    @IBAction func actionStateSegmControlValueChanged(sender: UISegmentedControl) {
        print("actionStateSegmControlValueChanged")
        
        updateStateView(projectStateCell)

    }
    
    // MARK: - HELPER METHODS
    
    func updateProgressLabel(cell: ANProjectInfoProgressCell) {
        
        let value = cell.valueProgressSlider.value
        let intVal = Int(value)
        
        cell.valuePercentLabel.text = "\(intVal) %"

    }
    
    func updateStateView(cell: ANProjectInfoStateCell) {
        let projectState = cell.valueStateSegmentedControl.selectedSegmentIndex
        
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
        
        cell.projectStateView.backgroundColor = stateColor
    }
    
    
    func configureStandartTextField(textField: UITextField) {
        textField.returnKeyType = .Next
        textField.autocapitalizationType = .Sentences
        textField.keyboardType = .Default
        
    }
    
    func configureProjectInfoTextCell(cell: ANProjectInfoTextCell, forIndexPath indexPath: NSIndexPath) {
        
        let labelPlaceholder = projectInfoLabelsPlaceholders[indexPath.row]
        
        cell.keyLabel.text = labelPlaceholder.label
        cell.valueTextField.placeholder = labelPlaceholder.placeholder
        
        switch indexPath.row {
        case ANFieldType.CustomerName.rawValue:
//            cell.valueTextField.text = newProject.customer
            configureStandartTextField(cell.valueTextField)
            
        case ANFieldType.ProjectName.rawValue:
            configureStandartTextField(cell.valueTextField)
            
        case ANFieldType.DueDate.rawValue:
            configureStandartTextField(cell.valueTextField)
            cell.valueTextField.returnKeyType = .Done
            
        default:
            break
        }
        projectInfoTextFields.append(cell.valueTextField)
        cell.valueTextField.delegate = self
        
    }
    
    func configureProjectInfoProgressCell(cell: ANProjectInfoProgressCell, forIndexPath indexPath: NSIndexPath) {
        
        cell.keyLabel.text = projectNonTextInfoLabels[indexPath.row]
        
        updateProgressLabel(cell)
        
    }
    
    func configureProjectInfoStateCell(cell: ANProjectInfoStateCell, forIndexPath indexPath: NSIndexPath) {
        
        cell.keyLabel.text = projectNonTextInfoLabels[indexPath.row]
        
        updateStateView(cell)
        
    }
    
    func configureProjectInfoDescriptionCell(cell: ANProjectDescriptionCell, forIndexPath indexPath: NSIndexPath) {
        cell.keyLabel.text = projectNonTextInfoLabels[indexPath.row]
        
        projectInfoDescriptionTextView = cell.valueTextView
    }
    


    
}

// MARK: - UITableViewDataSource

extension ANNewProjectViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case ANSectionType.ProjectTextInfo.rawValue:
            return projectInfoLabelsPlaceholders.count
            
        case ANSectionType.ProjectNonTextInfo.rawValue:
            return projectNonTextInfoLabels.count
            
        default:
            break
        }
        
        return 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdProjectInfoText = "ANProjectInfoTextCell"
        let cellIdProjectProgress = "ANProjectInfoProgressCell"
        let cellIdProjectState = "ANProjectInfoStateCell"
        let cellIdProjectDescription = "ANProjectDescriptionCell"
        
        switch indexPath.section {
            
        case ANSectionType.ProjectTextInfo.rawValue:
            
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdProjectInfoText, forIndexPath: indexPath) as! ANProjectInfoTextCell
            configureProjectInfoTextCell(cell, forIndexPath: indexPath)
            return cell

        case ANSectionType.ProjectNonTextInfo.rawValue:
            
            switch indexPath.row {
            case ANRowType.ProjectProgress.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdProjectProgress, forIndexPath: indexPath) as! ANProjectInfoProgressCell
                configureProjectInfoProgressCell(cell, forIndexPath: indexPath)
                
                projectProgressCell = cell
                
                return cell
                
            case ANRowType.ProjectState.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdProjectState, forIndexPath: indexPath) as! ANProjectInfoStateCell
                configureProjectInfoStateCell(cell, forIndexPath: indexPath)
                
                projectStateCell = cell
                
                return cell
                
            case ANRowType.ProjectDescription.rawValue:
                
                let cell = tableView.dequeueReusableCellWithIdentifier(cellIdProjectDescription, forIndexPath: indexPath) as! ANProjectDescriptionCell
                configureProjectInfoDescriptionCell(cell, forIndexPath: indexPath)
                return cell
                
            default:
                break
            }
            
            
            
        default:
            break
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    
    
}



extension ANNewProjectViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case ANSectionType.ProjectTextInfo.rawValue:
            return 70
        case ANSectionType.ProjectNonTextInfo.rawValue:
            
            if indexPath.row == ANRowType.ProjectDescription.rawValue {
                return 120
            } else {
                return 80
            }
          
        default:
            break
            
        }
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case ANSectionType.ProjectTextInfo.rawValue:
            return 70
        case ANSectionType.ProjectNonTextInfo.rawValue:
            
            if indexPath.row == ANRowType.ProjectDescription.rawValue {
                return 120
            } else {
                return 80
            }
            
        default:
            break
            
        }
        return UITableViewAutomaticDimension

        
    }
    
    
}



// MARK: - UITextFieldDelegate

extension ANNewProjectViewController: UITextFieldDelegate {
    
}

















