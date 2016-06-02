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
    var selectedDate: NSDate?
    
    // MARK: - viewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        fakeDate = NSDate(timeIntervalSinceNow: 3600*24)
        
        getAllProjectsDueDates()
        
    }
    

}


extension ANCalendarViewController: FSCalendarDelegate {
    
    func calendar(calendar: FSCalendar, didSelectDate date: NSDate) {
        print("date selected = \(date)")
        
        
        
        
    }
    
}

extension ANCalendarViewController: FSCalendarDataSource {
    
    func calendar(calendar: FSCalendar, hasEventForDate date: NSDate) -> Bool {
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Month, .Day], fromDate: date)

        for dueDate in allDueDates {
            
            let dueDateComponents = calendar.components([.Month, .Day], fromDate: dueDate)
            
            if components.day == dueDateComponents.day && components.month == dueDateComponents.month {
                return true
            }
            
        }
        
        return false
        
    }
    
    
    func calendarCurrentMonthDidChange(calendar: FSCalendar) {
        print("calendarCurrentMonthDidChange")
    }
    
    
    
    func getAllProjectsDueDates() {
        
        let fetchRequest = NSFetchRequest(entityName: "Project")
        
        let dueDateDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let customerDescriptor = NSSortDescriptor(key: "customer", ascending: true)
        
        let context = ANDataManager.sharedManager.context
        
        fetchRequest.sortDescriptors = [dueDateDescriptor, customerDescriptor]

        do {
            let allProjects = try context.executeFetchRequest(fetchRequest) as! [Project]
            
            for project in allProjects {
                let dueDate = project.dueDate!
                allDueDates.append(dueDate)
            }
            
        } catch {
            let error = error as NSError
            print("Fetch non successful. error occured: \(error.localizedDescription)")
        }

    }
    
    
    
    
}





