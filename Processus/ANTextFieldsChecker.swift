//
//  ANTextFieldsChecker.swift
//  Processus
//
//  Created by Anton Novoselov on 29/05/16.
//  Copyright © 2016 Anton Novoselov. All rights reserved.
//


import UIKit

class ANTextFieldsChecker {
    
    static let sharedChecker = ANTextFieldsChecker()
    
    private let localNumberMaxLength = 7
    private let areaCodeMaxLength = 3
    private let countryCodeMaxLength = 3
    
    func handleEmailTextField(textField: UITextField, inRange range: NSRange, withReplacementString replacementString: String) -> Bool {
        
        var illegalCharactersSet = NSCharacterSet.init(charactersInString: "?><,\\/|`~\'\"[]{}±#$%^&*()=+")
        
        let currentString = textField.text! as NSString
        
        let newString = currentString.stringByReplacingCharactersInRange(range, withString: replacementString)
        
        if currentString.length == 0 && replacementString == "@" {
            return false
        }
        
        if currentString .containsString("@") {
            illegalCharactersSet = NSCharacterSet.init(charactersInString: "?><,\\/|`~\'\"[]{}±#$%^&*()=+@")
        }
        let components = replacementString.componentsSeparatedByCharactersInSet(illegalCharactersSet)
        if components.count > 1 {
            return false
        }
        
        return newString.characters.count <= 40
    }
    
    
    func handlePhoneNumberForTextField(textField: UITextField, inRange range: NSRange, withReplacementString replacementString: String) -> Bool {
        
//        print("replacementString = \(replacementString)")
        let validationSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let components = replacementString.componentsSeparatedByCharactersInSet(validationSet)
        
        // **  CHECKING - IF USER ENTERS NOT NUMBER, FORBID ENTERING
        if components.count > 1 {
            return false
        }
        
        // **  GETTING NEWSTRING, USER TRYING TO ENTER
        let currentString = textField.text! as NSString
        var newString = currentString.stringByReplacingCharactersInRange(range, withString: replacementString) as NSString
        
//        print("new string = \(newString)")
        
        
        // **  PURIFYING NEWSTRING FROM SYMBOLS ( ) - + THAT WE ADDED BY OURSELVES BELOW IN METHOD
        let validComponents = newString.componentsSeparatedByCharactersInSet(validationSet)
        
        newString = validComponents.joinWithSeparator("")
        
//        print("new string fixed = \(newString)")
        
        if newString.length > localNumberMaxLength + areaCodeMaxLength + countryCodeMaxLength {
            return false
        }
        
        // **  MAKING SCHEME FOR ENTERING PHONE NUMBER
        
        let resultString: NSMutableString = ""
        
        
        /* FOR LOCAL NUMBER
         XXX-XXXX
         */
        
        let localNumberLength = min(newString.length, localNumberMaxLength)
        
        if localNumberLength > 0 {
            
            let number = newString.substringFromIndex(newString.length - localNumberLength)
            
            resultString.appendString(number)
            
            if resultString.length > 3 {
                resultString.insertString("-", atIndex: 3)
            }
        }
        
        
        /* FOR INTERCITY NUMBER
         (XXX) XXX-XXXX
         */
        
        if newString.length > localNumberMaxLength {
            
            let areaCodeLength = min(newString.length - localNumberMaxLength, areaCodeMaxLength)
            
            let areaRange = NSMakeRange(newString.length - localNumberMaxLength - areaCodeLength, areaCodeLength)
            
            var area = newString.substringWithRange(areaRange)
            
            area = "(\(area)) "
            
            resultString.insertString(area, atIndex: 0)
        }
        
        /* INTERNATIONAL NUMBER
         +XX (XXX) XXX-XXXX
         */
        
        if newString.length > localNumberMaxLength + areaCodeMaxLength {
            
            let countryCodeLength = min(newString.length - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength)
            
            let countryCodeRange = NSMakeRange(0, countryCodeLength)
            
            var countryCode = newString.substringWithRange(countryCodeRange)
            
            countryCode = "+\(countryCode) "
            
            resultString.insertString(countryCode, atIndex: 0)
            
        }
        
        textField.text = resultString as String
        
        
        
        
        return false
    }

    
    
}
