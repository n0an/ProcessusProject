//
//  ANCalendarViewController.swift
//  Processus
//
//  Created by Anton Novoselov on 01/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit
import FSCalendar

class ANCalendarViewController: UIViewController {
    
    var fakeDate: NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()

        fakeDate = NSDate(timeIntervalSinceNow: 3600*24)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let curDate = NSDate()
        let curComponents = calendar.components([.Month, .Day], fromDate: fakeDate)
        
        let components = calendar.components([.Month, .Day], fromDate: date)
        
        if components.day == curComponents.day && components.month == curComponents.month {
            return true
        }
        
        return false
        
        
        
    }
    
    
    func calendarCurrentMonthDidChange(calendar: FSCalendar) {
        print("calendarCurrentMonthDidChange")
    }
    
}