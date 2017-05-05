//
//  ANConfigurator.swift
//  Processus
//
//  Created by Anton Novoselov on 31/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//


import UIKit


enum ProjectFinishedStatus: String {
    case Success = "Success"
    case Failure = "Stopped"
}

class ANConfigurator {
    
    static let sharedConfigurator = ANConfigurator()
    
    // MARK: - PRIVATE METHODS
    
    fileprivate func dueDateSoonForProject(_ project: Project) -> Bool {
        
        let currentDate = Date()
        
        let timeLeft = project.dueDate!.timeIntervalSince(currentDate)
        
        
        // If there're less than 5 days befor deadline - activate warning sign
        if timeLeft < 5 * 24 * 3600 && timeLeft > 0 {
            return true
        }
        
        return false
        
    }
    
    
    fileprivate func coloredImage(_ image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage! {
        
        let rect = CGRect(origin: CGPoint.zero, size: image.size)
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        let context = UIGraphicsGetCurrentContext()
        
        image.draw(in: rect)
        
        
        context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
        context?.setBlendMode(CGBlendMode.sourceAtop)
        
        context?.fill(rect)
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return result
        
        
    }

    
    
    

    lazy var dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "dd.MM.YYYY"
        
        return dateFormatter
    }()
    

    lazy var calendar: Calendar = {
        let calendar = Calendar.current

        return calendar
    }()
    
    
    
    
    // MARK: - PUBLIC METHODS

    func customizeSlider(_ slider: UISlider) {
        // Custom Slider
        let thumbImageNormal = UIImage(named: "SliderThumb-Normal")
        slider.setThumbImage(thumbImageNormal, for: UIControlState())
        
        let thumbImageHighlighted = UIImage(named: "SliderThumb-Highlighted")
        slider.setThumbImage(thumbImageHighlighted, for: .highlighted)
        
        let insets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        
        if let trackLeftImage = UIImage(named: "SliderTrackLeft1") {
            let trackLeftResizable = trackLeftImage.resizableImage(withCapInsets: insets)
            slider.setMinimumTrackImage(trackLeftResizable, for: UIControlState())
        }
        if let trackRightImage = UIImage(named: "SliderTrackRight1") {
            let trackRightResizable = trackRightImage.resizableImage(withCapInsets: insets)
            slider.setMaximumTrackImage(trackRightResizable, for: UIControlState())
        }

    }
    
    
    func configureProjectCell(_ cell: ANPersonProjectCell, forProject project: Project, viewWidth: CGFloat) {
        
        
        cell.customerNameLabel.text = project.customer
        cell.projectNameLabel.text = project.name
        
        
        var stateColor = UIColor()
        
        switch project.state!.intValue {
        case ANProjectState.nonActive.rawValue:
            stateColor = UIColor.red
        case ANProjectState.frozen.rawValue:
            stateColor = UIColor.yellow
        case ANProjectState.active.rawValue:
            stateColor = UIColor.green
        default:
            break
        }
        
        
        
        
        
        cell.projectStateView.backgroundColor = stateColor
        
        if dueDateSoonForProject(project) {
            
            cell.dueDateSoonImageView.isHidden = false
            cell.projectDueDateLabel.textColor = UIColor(red: 170.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
        } else {
            
            cell.dueDateSoonImageView.isHidden = true
            cell.projectDueDateLabel.textColor = UIColor.black
        }
        
        if project.shouldRemind!.boolValue {
            cell.alarmImageView.isHidden = false
            
            if dueDateSoonForProject(project) {
                
                let alarmImage = UIImage(named: "AlarmSign")!
            
                let coloredImage = self.coloredImage(alarmImage, red: 170.0/255.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                cell.alarmImageView.image = coloredImage
                
            }
            
        } else {
            cell.alarmImageView.isHidden = true
        }

        
        
        // Progress View
        
        let progressRectWidth = (CGFloat)(project.completedRatio!.floatValue/100) * viewWidth

        let progressRect = CGRect(x: 0, y: 0, width: progressRectWidth, height: 80)

        let progressView = UIView(frame: progressRect)
        progressView.backgroundColor = UIColor(red: 208/255, green: 208/255, blue: 208/255, alpha: 0.27)
        
        
        if let viewToRemove = cell.contentView.viewWithTag(111) {
            viewToRemove.removeFromSuperview()
        }
        
        cell.contentView.insertSubview(progressView, at: 0)
        progressView.tag = 111
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


