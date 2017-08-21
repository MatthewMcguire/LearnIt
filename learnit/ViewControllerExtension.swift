//
//  ViewControllerExtension.swift
//  learnit
//
//  Created by Matthew McGuire on 8/15/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

extension UIViewController
{

    func addTheBackButton()
    {
        let segmentBarItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action:#selector(self.backButtonPressed))
        segmentBarItem.tintColor = UIColor.blue
        segmentBarItem.style = UIBarButtonItemStyle(rawValue: Int(UIFontWeightRegular))!
        self.navigationItem.leftBarButtonItem = segmentBarItem
    }
    
    @objc func backButtonPressed()
    {
        if self is BrowseTableViewController
        {
            performSegue(withIdentifier: "BrowseToMainSegue", sender: self)
        }
        if self is StatisticsTableViewController
        {
            performSegue(withIdentifier: "StatsToMainSegue", sender: self)
        }
    }
    
    func prepareKeyboardNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(changeInputMode(notification:)), name: Notification.Name.UITextInputCurrentInputModeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeInputMode(notification:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func changeInputMode(notification : NSNotification)
    {
        // Context: A notification has been triggered that a keyboard has been shown or changed
        let uiObj = findFirstResponder(in: view)// as? SmartLanguageUITextField!
        if uiObj != nil
        {
            let inpLang = uiObj!.textInputMode?.primaryLanguage
            if loq == true {print("\tI detect the primary language of this field is set to \(String(describing: inpLang)).")}
            if inpLang!.prefix(2) == "el"
            {

                if loq == true {print("\tThe user is employing the greek keyboard.")}
                showGreekToolbar(status: true, onThis:uiObj! as! UITextField)
//                if let theTextField = uiObj as! SmartLanguageUITextField?
//                {
//                    theTextField.preferredLang = nil
//                }
            }
            else
            {
                if loq == true {print("\tThe user is employing a non-greek keyboard.")}
                showGreekToolbar(status: false, onThis:uiObj! as! UITextField)
            }
        }
    }
    
    func findFirstResponder(in view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            }
            if let firstReponder = findFirstResponder(in: subview) {
                return firstReponder
            }
        }
        return nil
    }
    
    // this enum makes the toolbar code a bit more readable and provides a pattern for doing this with other languages besides Greek
    enum greekDiacrits : String
    {
        case acute = "´"
        case acuteSmooth = "῎"
        case acuteRough = "῞"
        case grave = "`"
        case graveSmooth = "῍"
        case graveRough = "῝"
        case circumf = "῀"
        case circumfSmooth = "῏"
        case circumfRough = "῟"
        case Smooth = "᾽"
        case Rough = "῾"
    }
    
    @IBAction func barButtonAddText(sender: UIBarButtonItem)
    {
        // obtain a reference to the first responder, since it can't be passed as a parameter
        if let uiObj = findFirstResponder(in: view) as! SmartLanguageUITextField?
        {
            if let justBefore = uiObj.selectedTextRange
            {
                if let f2Text = uiObj.text
                {
                    if f2Text.characters.count > 0
                    {
                        let endPoint = justBefore.start
                        let startPoint = uiObj.position(from: endPoint, offset: -1)
                        let startToEndPoint = uiObj.textRange(from: startPoint!, to: endPoint)
                        let letterBeforeCursor = uiObj.text(in: startToEndPoint!)
                        let replaceWithText = getReplacementSymbol(letter: letterBeforeCursor!, diacrit: greekDiacrits(rawValue: sender.title!)!)
                        uiObj.deleteBackward()
                        uiObj.insertText(replaceWithText)
                    }
                }
            }
        }
        else { return }
    }
    
    func showGreekToolbar(status:Bool, onThis: UITextField) -> Void
    {
        let toolbarTextField = onThis as! SmartLanguageUITextField
        guard toolbarTextField.isFirstResponder == true else {
            toolbarTextField.inputAccessoryView = nil
            return
        }
        if status == false
        {
            if loq == true {print("Hiding the Greek diacriticals toolbar:")}
            toolbarTextField.inputAccessoryView = nil
            toolbarTextField.reloadInputViews()
        }
        else
        {
            if loq == true {print("Showing the Greek diacriticals toolbar:")}
            if let windowWidth = view.window
            {
                let barSize : CGRect = CGRect(x: 0.0, y: 0.0, width: CGFloat((windowWidth.frame.size.width)*0.5), height: 34.0)
                let greekInputTool = UIToolbar(frame: barSize)
                if UI_USER_INTERFACE_IDIOM() == .pad
                {
                    greekInputTool.tintColor = UIColor(red: 0.6, green: 0.6, blue: 0.64, alpha: 1.0)
                }
                else
                {
                    greekInputTool.tintColor = UIColor.darkText
                }
                greekInputTool.isTranslucent = true
                greekInputTool.barTintColor = UIColor.groupTableViewBackground
                let diacritSize = CGFloat(24.0)
                let diacritFont = "Avenir-Black"
                let uiFontName = UIFont(name: diacritFont, size: diacritSize)
                let diacritFontAttribs =  [NSFontAttributeName:uiFontName]
                var barButtonArray = Array<UIBarButtonItem>()
                //            let diacritArray = ["´","῎","῞","`","῍","῝","῀","῏","῟","᾽","῾"]
                let diacritArray = [greekDiacrits.acute,greekDiacrits.acuteSmooth, greekDiacrits.acuteRough,
                                    greekDiacrits.grave, greekDiacrits.graveSmooth, greekDiacrits.graveRough,
                                    greekDiacrits.circumf,greekDiacrits.circumfSmooth,greekDiacrits.circumfRough,
                                    greekDiacrits.Smooth, greekDiacrits.Rough]
                for diacrit in diacritArray
                {
                    barButtonArray.append(UIBarButtonItem(title: diacrit.rawValue, style: .plain, target: self, action:#selector(barButtonAddText(sender:))))
                    barButtonArray.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
                }
                barButtonArray.removeLast() // we have appended one too many flexible spaces!
                
                // give each diacritical button with a symbol a more visible font style
                for barButt in barButtonArray
                {
                    if barButt.action != nil
                    {
                        barButt.setTitleTextAttributes((diacritFontAttribs as Any as! [String : Any]), for: .normal)
                    }
                }
                
                // Make a nice wee toolbar out of these buttons
                
                greekInputTool.items = barButtonArray
                let greekDiacriticsBox = UIView(frame: barSize)
                greekDiacriticsBox.addSubview(greekInputTool)
                greekInputTool.autoresizingMask = .flexibleWidth
                toolbarTextField.inputAccessoryView = greekDiacriticsBox
                var r = greekInputTool.frame
                r.origin.y += 6
                greekInputTool.frame = r
            }
            
        }
        if toolbarTextField.isFirstResponder == true
        {
            toolbarTextField.reloadInputViews()
        }
//        else
//        {
//            toolbarTextField.inputAccessoryView = nil
//        }
    }
    
    func getReplacementSymbol(letter: String, diacrit : greekDiacrits) -> String
    {
        var returnValue = letter
        switch letter {
        case "α":
            switch diacrit {
            case .acute:        returnValue = "ά"
            case .acuteRough:   returnValue = "ἅ"
            case .acuteSmooth:  returnValue = "ἄ"
            case .grave:        returnValue = "ὰ"
            case .graveRough:   returnValue = "ἃ"
            case .graveSmooth:  returnValue = "ἂ"
            case .circumf:      returnValue = "ᾶ"
            case .circumfRough: returnValue = "ἇ"
            case .circumfSmooth: returnValue = "ἆ"
            case .Rough:        returnValue = "ἁ"
            case .Smooth:       returnValue = "ἀ"
            }
        case "ε":
            switch diacrit {
            case .acute:        returnValue = "έ"
            case .acuteRough:   returnValue = "ἕ"
            case .acuteSmooth:  returnValue = "ἔ"
            case .grave:        returnValue = "ὲ"
            case .graveRough:   returnValue = "ἓ"
            case .graveSmooth:  returnValue = "ἒ"
            case .circumf:      returnValue = "ε"
            case .circumfRough: returnValue = "ε"
            case .circumfSmooth: returnValue = "ε"
            case .Rough:        returnValue = "ἑ"
            case .Smooth:       returnValue = "ἐ"
            }
        case "ι":
            switch diacrit {
            case .acute:        returnValue = "ί"
            case .acuteRough:   returnValue = "ἵ"
            case .acuteSmooth:  returnValue = "ἴ"
            case .grave:        returnValue = "ὶ"
            case .graveRough:   returnValue = "ἳ"
            case .graveSmooth:  returnValue = "ἲ"
            case .circumf:      returnValue = "ῖ"
            case .circumfRough: returnValue = "ἷ"
            case .circumfSmooth:returnValue = "ἶ"
            case .Rough:        returnValue = "ἱ"
            case .Smooth:       returnValue = "ἰ"
            }
        case "ο":
            switch diacrit {
            case .acute:        returnValue = "ό"
            case .acuteRough:   returnValue = "ὅ"
            case .acuteSmooth:  returnValue = "ὄ"
            case .grave:        returnValue = "ὸ"
            case .graveRough:   returnValue = "ὃ"
            case .graveSmooth:  returnValue = "ὂ"
            case .circumf:      returnValue = "ο"
            case .circumfRough: returnValue = "ο"
            case .circumfSmooth:returnValue = "ο"
            case .Rough:        returnValue = "ὁ"
            case .Smooth:       returnValue = "ὀ"
            }
        case "ω":
            switch diacrit {
            case .acute:        returnValue = "ώ"
            case .acuteRough:   returnValue = "ὥ"
            case .acuteSmooth:  returnValue = "ὤ"
            case .grave:        returnValue = "ὼ"
            case .graveRough:   returnValue = "ὣ"
            case .graveSmooth:  returnValue = "ὢ"
            case .circumf:      returnValue = "ῶ"
            case .circumfRough: returnValue = "ὧ"
            case .circumfSmooth:returnValue = "ὦ"
            case .Rough:        returnValue = "ὡ"
            case .Smooth:       returnValue = "ὠ"
            }
        case "η":
            switch diacrit {
            case .acute:        returnValue = "ή"
            case .acuteRough:   returnValue = "ἥ"
            case .acuteSmooth:  returnValue = "ἤ"
            case .grave:        returnValue = "ὴ"
            case .graveRough:   returnValue = "ἣ"
            case .graveSmooth:  returnValue = "ἢ"
            case .circumf:      returnValue = "ῆ"
            case .circumfRough: returnValue = "ἧ"
            case .circumfSmooth:returnValue = "ἦ"
            case .Rough:        returnValue = "ἡ"
            case .Smooth:       returnValue = "ἠ"
            }
        default:
            returnValue = letter
        }
        return returnValue
    }
    
}

