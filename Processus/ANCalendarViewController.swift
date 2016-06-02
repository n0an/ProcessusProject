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
    
    // MARK: - ATTRIBUTES
    
    var fakeDate: NSDate!
    var allDueDates: [NSDate] = []
    var allProjects: [Project] = []
    var selectedDate: NSDate?
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        fakeDate = NSDate(timeIntervalSinceNow: 3600*24)
        
        getAllProjectsDueDates()
        
        
    }
    
    
    // MARK: - HELPER METHODS
    
    func getAllProjectsDueDates() {
        
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
        
        let calend = NSCalendar.currentCalendar()
        let components = calend.components([.Month, .Day], fromDate: date)
        
        
        
        for dueDate in allDueDates {
            
            let dueDateComponents = calend.components([.Month, .Day], fromDate: dueDate)
            
            if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                return true
            }
            
        }
        
        return false
    }
    
    
    
    // MARK: - ACTIONS

    @IBAction func showButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("showDate", sender: nil)
        
    }
    
    
    
    @IBAction func actionToolBarButtonPressed(sender: UIBarButtonItem) {
        
        performSegueWithIdentifier("showDate", sender: nil)

    }
    
    
    // MARK: - NAVIGATION
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDate" {
            
            var selectedProjects: [Project] = []
            
            let destinationVC = segue.destinationViewController as! ANProjectsViewController
            
            let calend = NSCalendar.currentCalendar()
            let components = calend.components([.Month, .Day], fromDate: selectedDate!)
            
            
            for project in allProjects {
                
                let dueDateComponents = calend.components([.Month, .Day], fromDate: project.dueDate!)
                
                if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                    selectedProjects.append(project)
                }
                
            }
            

            destinationVC.projectsSelectedByDate = selectedProjects
            
            
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
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day], fromDate: date)
        
        print("components.day = \(components.day)")
        print("components.month = \(components.month)")

        
        selectedDate = date
        
        
        
    }
    
}






