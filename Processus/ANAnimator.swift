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
    
    
    func animateSelectRowView(_ animatedView: UIView) {
        
        // First move animatedView to the right for 600pt and scale to 0.0
        let firstScaleAnimation = CGAffineTransform(scaleX: 0.0, y: 0.0)
        let firsttranslationAntimation = CGAffineTransform(translationX: 600.0, y: 0.0)
        
        animatedView.transform = firstScaleAnimation.concatenating(firsttranslationAntimation)
        
        // Second - back to initial size and origin
        
        let scaleAnimation = CGAffineTransform(scaleX: 0.0, y: 0.0)
        let translationAntimation = CGAffineTransform(translationX: 600.0, y: 0.0)
        
        animatedView.transform = scaleAnimation.concatenating(translationAntimation)
        
        UIView.animate(withDuration: 0.7,
                                   delay: 0.1,
                                   usingSpringWithDamping: 0.7,
                                   initialSpringVelocity: 0.5,
                                   options: UIViewAnimationOptions(),
                                   animations: {
                                    let scaleAnimation = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    
                                    let translationAnimation = CGAffineTransform(translationX: 0, y: 0)
                                    
                                    animatedView.transform = scaleAnimation.concatenating(translationAnimation)
                                    
                                    
            },
                                   completion: nil)

    }
    
    
    
    
}




