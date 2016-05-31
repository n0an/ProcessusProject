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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}


