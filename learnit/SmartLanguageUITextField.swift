//
//  SmartLanguageUITextField.swift
//  learnit
//
//  Created by Matthew McGuire on 7/22/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class SmartLanguageUITextField: UITextField {


    var preferredLang : String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.preferredLang = "en"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.preferredLang = "en"
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
                        if loq == true {print("UITextInputMode.textInputMode = \(tim)")}
                        return tim
                    }
                }
                return super.textInputMode
            }
        }
        return super.textInputMode
  
    }

    
}
