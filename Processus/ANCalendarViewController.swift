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
    
    @IBOutlet weak var fsCalendar: FSCalendar!
    
    // MARK: - ATTRIBUTES
    
    let calend = ANConfigurator.sharedConfigurator.calendar
    
    var allDueDates: [Date] = []
    var allProjects: [Project] = []
    
    var projectsForSegue: [Project] = []
    
    var selectedDate: Date!
    
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getAllProjectsAndDueDates()
        
        fsCalendar.reloadData()
        
        if selectedDate == nil {
            showButton.isEnabled = false
        }

    }
    
    
    // MARK: - HELPER METHODS
    
    func getAllProjectsAndDueDates() {
        
        allProjects = []
        allDueDates = []
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Project")
        
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        let context = ANDataManager.sharedManager.context
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]
        
        do {
            let allProj = try context.fetch(fetchRequest) as! [Project]
            allProjects = allProj
            
            for project in allProj {
                let dueDate = project.dueDate!
                allDueDates.append(dueDate as Date)
            }
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }
        
    }
    
    
    func isEventForDate(_ date: Date) -> Bool {
        
        let components = (calend as NSCalendar).components([.month, .day], from: date)
        
        for dueDate in allDueDates {
            
            let dueDateComponents = (calend as NSCalendar).components([.month, .day], from: dueDate)
            
            if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                return true
            }
            
        }
        
        return false
    }
    
    
    func getSelectedProjectsForDate(_ date: Date) -> [Project] {
        
        var selectedProjects: [Project] = []
        
        let components = (calend as NSCalendar).components([.month, .day], from: date)
        
        for project in allProjects {
            
            let dueDateComponents = (calend as NSCalendar).components([.month, .day], from: project.dueDate! as Date)
            
            if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                selectedProjects.append(project)
            }
            
        }
        
        return selectedProjects

    }
    
    
    
    // MARK: - ACTIONS

    @IBAction func showButtonPressed(_ sender: UIBarButtonItem) {
        
        let selectedProjects = getSelectedProjectsForDate(selectedDate)
        
        projectsForSegue = selectedProjects
        performSegue(withIdentifier: "showDate", sender: nil)

    }
    
    
    @IBAction func actionToolBarButtonPressed(_ sender: UIBarButtonItem) {
        
    }
    
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDate" {
            
            let destinationVC = segue.destination as! ANProjectsForDateViewController
            
            destinationVC.displayedDate = selectedDate
            
            destinationVC.myProjects = projectsForSegue
            
            destinationVC.delegate = self
        }

    }
    
    
}



// MARK: - FSCalendarDataSource

extension ANCalendarViewController: FSCalendarDataSource {
    
    func calendar(_ calendar: FSCalendar, hasEventFor date: Date) -> Bool {
        
        return isEventForDate(date)
    }
    
    
    func calendarCurrentMonthDidChange(_ calendar: FSCalendar) {

    }
    
    
}

// MARK: - FSCalendarDelegate

extension ANCalendarViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date) {

        selectedDate = date
        
        showButton.isEnabled = true
        
    }
    
}


extension ANCalendarViewController: ANProjectsForDateViewControllerDelegate {
    func iterateDateWithDirection(_ direction: ANDateIterationDirection) -> (date: Date, projects: [Project]) {
        
        getAllProjectsAndDueDates()
        
        let iteratedDate: Date
        
        if direction == .next {
            
            iteratedDate = Date(timeInterval: 24*3600, since: selectedDate)
        
        } else {
            iteratedDate = Date(timeInterval: -24*3600, since: selectedDate)
        }
        
        selectedDate = iteratedDate
        
        let selectedProjects = getSelectedProjectsForDate(iteratedDate)

        return (iteratedDate, selectedProjects)
        
    }
    
    
    func refreshDate() -> [Project] {
        
        getAllProjectsAndDueDates()
        
        let selectedProjects = getSelectedProjectsForDate(selectedDate)

        return selectedProjects
        
    }

}







