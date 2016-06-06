//
//  ANConfigurator.swift
//  Processus
//
//  Created by Anton Novoselov on 31/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//


import UIKit


class ANConfigurator {
    
    static let sharedConfigurator = ANConfigurator()
    
    // MARK: - PRIVATE METHODS
    
    private func dueDateSoonForProject(project: Project) -> Bool {
        
        let currentDate = NSDate()
        
        let timeLeft = project.dueDate!.timeIntervalSinceDate(currentDate)
        
        
        // If there're less than 5 days befor deadline - activate warning sign
        if timeLeft < 5 * 24 * 3600 && timeLeft > 0 {
            return true
        }
        
        return false
        
    }
    
    
    private func coloredImage(image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage! {
        
        let rect = CGRect(origin: CGPointZero, size: image.size)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        image.drawInRect(rect)
        
        
        CGContextSetRGBFillColor(context, red, green, blue, alpha)
        CGContextSetBlendMode(context, CGBlendMode.SourceAtop)
        
        CGContextFillRect(context, rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
        
        
    }

    
    
    

    lazy var dateFormatter: NSDateFormatter = {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd.MM.YYYY"
        
        return dateFormatter
    }()
    

    lazy var calendar: NSCalendar = {
        let calendar = NSCalendar.currentCalendar()

        return calendar
    }()
    
    
    
    
    // MARK: - PUBLIC METHODS

    func customizeSlider(slider: UISlider) {
        // Custom Slider
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")
        slider.setThumbImage(thumbImageNormal, forState: .Normal)
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbImageHighlighted, forState: .Highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        if let trackLeftImage = UIImage(named: "SliderTrackLeft1") {
            let trackLeftResizable = trackLeftImage.resizableImageWithCapInsets(insets)
            slider.setMinimumTrackImage(trackLeftResizable, forState: .Normal)
        }
        if let trackRightImage = UIImage(named: "SliderTrackRight1") {
            let trackRightResizable = trackRightImage.resizableImageWithCapInsets(insets)
            slider.setMaximumTrackImage(trackRightResizable, forState: .Normal)
        }

    }
    
    
    func configureProjectCell(cell: ANPersonProjectCell, forProject project: Project, viewWidth: CGFloat) {
        
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        
        
        var stateColor = UIColor()
        
        switch project.state!.integerValue {
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
        
        if dueDateSoonForProject(project) {
            
            cell.dueDateSoonImageView.hidden = false
            cell.projectDueDateLabel.textColor = UIColor(red: 170.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        } else {
            
            cell.dueDateSoonImageView.hidden = true
            cell.projectDueDateLabel.textColor = UIColor.blackColor()
        }
        
        if project.shouldRemind!.boolValue {
            cell.alarmImageView.hidden = false
            
            if dueDateSoonForProject(project) {
                
                let alarmImage = UIImage(named: "AlarmSign")!
            
                let coloredImage = self.coloredImage(alarmImage, red: 170.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                cell.alarmImageView.image = coloredImage
                
            }
            
        } else {
            cell.alarmImageView.hidden = true
        }

        
        
        // Progress View
        
        
        
        let progressRectWidth = (CGFloat)(project.completedRatio!.floatValue/100) * viewWidth

        let progressRect = CGRect(x: 0, y: 0, width: progressRectWidth, height: 80)

        
        let progressView = UIView(frame: progressRect)
        progressView.backgroundColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 0.27)
        
        
        if let viewToRemove = cell.contentView.viewWithTag(111) {
            viewToRemove.removeFromSuperview()
        }
        
        cell.contentView.insertSubview(progressView, atIndex: 0)
        progressView.tag = 111
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


