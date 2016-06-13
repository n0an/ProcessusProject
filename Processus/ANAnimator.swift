//
//  ANAnimator.swift
//  Processus
//
//  Created by Anton Novoselov on 01/06/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//

import UIKit


class ANAnimator {
    
    static let sharedAnimator = ANAnimator()
    
    
    func animateSelectRowView(animatedView: UIView) {
        
        // First move animatedView to the right for 600pt and scale to 0.0
        let firstScaleAnimation = CGAffineTransformMakeScale(0.0, 0.0)
        let firsttranslationAntimation = CGAffineTransformMakeTranslation(600.0, 0.0)
        
        animatedView.transform = CGAffineTransformConcat(firstScaleAnimation, firsttranslationAntimation)
        
        // Second - back to initial size and origin
        
        let scaleAnimation = CGAffineTransformMakeScale(0.0, 0.0)
        let translationAntimation = CGAffineTransformMakeTranslation(600.0, 0.0)
        
        animatedView.transform = CGAffineTransformConcat(scaleAnimation, translationAntimation)
        
        UIView.animateWithDuration(0.7,
                                   delay: 0.1,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.5,
                                   options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    let scaleAnimation = CGAffineTransformMakeScale(1.0, 1.0)
                                    
                                    let translationAnimation = CGAffineTransformMakeTranslation(0, 0)
                                    
                                    animatedView.transform = CGAffineTransformConcat(scaleAnimation, translationAnimation)
                                    
                                    
            },
                                   completion: nil)

    }
    
    
    
    
}




