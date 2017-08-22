//
//  SmartLanguageUITextField.swift
//  learnit
//
//  Created by Matthew McGuire on 7/22/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class SmartLanguageUITextField: UITextField {
    
    /*
         This subclass offers a simple method of programmatically selecting the
         keyboard that is shown for a UITextField when it is a first responder.
         If the preferredLang property of the SmartLanguageUITextField is set to
         a value that is contained within a primary language code of an available
         keyboard, the textInputMode value of the control is overridden with the
         effect of showing the desired keyboard language.
     */
    
    var preferredLang : String?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }


    override var textInputMode: UITextInputMode? {
        if let language = preferredLang
        {
            if loq == true {print("UITextInputMode.preferredLang = \(language)")}
            if language.isEmpty {
                return super.textInputMode
                
            } else {
                for tim in UITextInputMode.activeInputModes {
                    if tim.primaryLanguage!.contains(language) {
                        if loq == true {print("UITextInputMode.textInputMode.primaryLanguage = \(String(describing: tim.primaryLanguage))")}
                        
                        return tim
                    }
                }
                return super.textInputMode
            }
        }
        return super.textInputMode
  
    }
   
}
