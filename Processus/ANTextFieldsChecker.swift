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
    
    fileprivate let localNumberMaxLength = 7
    fileprivate let areaCodeMaxLength = 3
    fileprivate let countryCodeMaxLength = 3
    
    func handleEmailTextField(_ textField: UITextField, inRange range: NSRange, withReplacementString replacementString: String) -> Bool {
        
        var illegalCharactersSet = CharacterSet.init(charactersIn: "?><,\\/|`~\'\"[]{}±#$%^&*()=+")
        
        let currentString = textField.text! as NSString
        
        let newString = currentString.replacingCharacters(in: range, with: replacementString)
        
        if currentString.length == 0 && replacementString == "@" {
            return false
        }
        
        if currentString .contains("@") {
            illegalCharactersSet = CharacterSet.init(charactersIn: "?><,\\/|`~\'\"[]{}±#$%^&*()=+@")
        }
        let components = replacementString.components(separatedBy: illegalCharactersSet)
        if components.count > 1 {
            return false
        }
        
        return newString.characters.count <= 40
    }
    
    
    func handlePhoneNumberForTextField(_ textField: UITextField, inRange range: NSRange, withReplacementString replacementString: String) -> Bool {
        
//        print("replacementString = \(replacementString)")
        let validationSet = CharacterSet.decimalDigits.inverted
        let components = replacementString.components(separatedBy: validationSet)
        
        // **  CHECKING - IF USER ENTERS NOT NUMBER, FORBID ENTERING
        if components.count > 1 {
            return false
        }
        
        // **  GETTING NEWSTRING, USER TRYING TO ENTER
        let currentString = textField.text! as NSString
        var newString = currentString.replacingCharacters(in: range, with: replacementString) as NSString
        
//        print("new string = \(newString)")
        
        
        // **  PURIFYING NEWSTRING FROM SYMBOLS ( ) - + THAT WE ADDED BY OURSELVES BELOW IN METHOD
        let validComponents = newString.components(separatedBy: validationSet)
        
        newString = validComponents.joined(separator: "") as NSString
        
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
            
            let number = newString.substring(from: newString.length - localNumberLength)
            
            resultString.append(number)
            
            if resultString.length > 3 {
                resultString.insert("-", at: 3)
            }
        }
        
        
        /* FOR INTERCITY NUMBER
         (XXX) XXX-XXXX
         */
        
        if newString.length > localNumberMaxLength {
            
            let areaCodeLength = min(newString.length - localNumberMaxLength, areaCodeMaxLength)
            
            let areaRange = NSMakeRange(newString.length - localNumberMaxLength - areaCodeLength, areaCodeLength)
            
            var area = newString.substring(with: areaRange)
            
            area = "(\(area)) "
            
            resultString.insert(area, at: 0)
        }
        
        /* INTERNATIONAL NUMBER
         +XX (XXX) XXX-XXXX
         */
        
        if newString.length > localNumberMaxLength + areaCodeMaxLength {
            
            let countryCodeLength = min(newString.length - localNumberMaxLength - areaCodeMaxLength, countryCodeMaxLength)
            
            let countryCodeRange = NSMakeRange(0, countryCodeLength)
            
            var countryCode = newString.substring(with: countryCodeRange)
            
            countryCode = "+\(countryCode) "
            
            resultString.insert(countryCode, at: 0)
            
        }
        
        textField.text = resultString as String
        
        
        
        
        return false
    }

    
    
}
