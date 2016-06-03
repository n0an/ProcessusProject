//
//  ANCalendarViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 01/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import FSCalendar
import CoreData

class ANCalendarViewController: UIViewController {
    
    
    // MARK: - OUTLETS

    @IBOutlet weak var showButton: UIBarButtonItem!
    @IBOutlet weak var actToolBarButton: UIToolbar!
    
    
    // MARK: - ATTRIBUTES
    
    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var allDueDates: [NSDate] = []
    var allProjects: [Project] = []
    
    var projectsForSegue: [Project] = []
    
    var selectedDate: NSDate!
    
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getAllProjectsAndDueDates()
        
        if selectedDate == nil {
            showButton.enabled = false
            actToolBarButton.hidden = true
        }


    }
    
    
    // MARK: - HELPER METHODS
    
    func getAllProjectsAndDueDates() {
        
        let fetchRequest = NSFetchRequest(entityName: "Project")
        
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        let context = ANDataManager.sharedManager.context
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]
        
        do {
            let allProj = try context.executeFetchRequest(fetchRequest) as! [Project]
            allProjects = allProj
            
            for project in allProj {
                let dueDate = project.dueDate!
                allDueDates.append(dueDate)
            }
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
    }
    
    
    
    
    func isEventForDate(date: NSDate) -> Bool {
        
        let components = calend.components([.Month, .Day], fromDate: date)
        
        for dueDate in allDueDates {
            
            let dueDateComponents = calend.components([.Month, .Day], fromDate: dueDate)
            
            if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                return true
            }
            
        }
        
        return false
    }
    
    
    func getSelectedProjectsForDate(date: NSDate) -> [Project] {
        
        var selectedProjects: [Project] = []
        
        let components = calend.components([.Month, .Day], fromDate: date)
        
        for project in allProjects {
            
            let dueDateComponents = calend.components([.Month, .Day], fromDate: project.dueDate!)
            
            if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                selectedProjects.append(project)
            }
            
        }
        
        return selectedProjects

    }
    
    
    
    // MARK: - ACTIONS

    @IBAction func showButtonPressed(sender: UIBarButtonItem) {
        
        let selectedProjects = getSelectedProjectsForDate(selectedDate)
        
        projectsForSegue = selectedProjects
        performSegueWithIdentifier("showDate", sender: nil)

    }
    
    
    @IBAction func actionToolBarButtonPressed(sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDate" {
            
            let destinationVC = segue.destinationViewController as! ANProjectsForDateViewController
            
            destinationVC.displayedDate = selectedDate
            
            destinationVC.myProjects = projectsForSegue
            
            destinationVC.delegate = self
        }

    }
    
    
}



// MARK: - FSCalendarDataSource

extension ANCalendarViewController: FSCalendarDataSource {
    
    func calendar(calendar: FSCalendar, hasEventForDate date: NSDate) -> Bool {
        
        return isEventForDate(date)
    }
    
    
    func calendarCurrentMonthDidChange(calendar: FSCalendar) {
        print("calendarCurrentMonthDidChange")
    }
    
    
}

// MARK: - FSCalendarDelegate

extension ANCalendarViewController: FSCalendarDelegate {
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        print("date selected = \(date)")
        
        let components = calend.components([.Month, .Day], fromDate: date)
        
        print("components.day = \(components.day)")
        print("components.month = \(components.month)")

        
        selectedDate = date
        
        showButton.enabled = true
        actToolBarButton.hidden = false
        
    }
    
}


extension ANCalendarViewController: ANProjectsForDateViewControllerDelegate {
    func iterateDateWithDirection(direction: ANDateIterationDirection) -> (date: NSDate, projects: [Project]) {
        
        let iteratedDate: NSDate
        
        if direction == .Next {
            
            iteratedDate = NSDate(timeInterval: 24*3600, sinceDate: selectedDate)
        
        } else {
            iteratedDate = NSDate(timeInterval: -24*3600, sinceDate: selectedDate)
        }
        
        selectedDate = iteratedDate
        
        let selectedProjects = getSelectedProjectsForDate(iteratedDate)

        return (iteratedDate, selectedProjects)
        
    }
    
    
    func refreshDate() -> [Project] {
        
        let selectedProjects = getSelectedProjectsForDate(selectedDate)

        return selectedProjects
        
    }

}







