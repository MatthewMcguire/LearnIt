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
        let uiObj = findFirstResponder(in: view) //as? SmartLanguageUITextField!
        if let inpMode = uiObj?.textInputMode
        {
            if inpMode.primaryLanguage?.prefix(2) == "el"
            {
                showGreekToolbar(status: true, onThis:uiObj! as! UITextField)
            }
            else
            {
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
    enum greekDiacrits : String  {
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
        let uiObj = findFirstResponder(in: view) as! UITextField
        if let justBefore = uiObj.selectedTextRange, let f2Text = uiObj.text  {
            if f2Text.characters.count > 0  {
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
    
    func showGreekToolbar(status:Bool, onThis: UITextField) -> Void
    {
//        let toolbarTextField = onThis as! SmartLanguageUITextField
        guard onThis.isFirstResponder == true else {
            onThis.inputAccessoryView = nil
            return
        }
        if status == false  {
            onThis.inputAccessoryView = nil
            onThis.reloadInputViews()
            return
        }
        if let windowWidth = view.window  {
            // Make a nice wee toolbar out of these buttons
            let barSize : CGRect = CGRect(x: 0.0, y: 0.0, width: CGFloat((windowWidth.frame.size.width)*0.5), height: 34.0)
            let greekInputTool = getToolbar(size: barSize)
            let greekDiacriticsBox = UIView(frame: barSize)
            greekDiacriticsBox.addSubview(greekInputTool)
            greekInputTool.autoresizingMask = .flexibleWidth
            onThis.inputAccessoryView = greekDiacriticsBox
            greekInputTool.frame.origin.y += 6
        }
        onThis.reloadInputViews()

    }
    
    func getToolbar(size: CGRect) -> UIToolbar
    {
        let greekInputTool = UIToolbar(frame: size)
        greekInputTool.tintColor = UIColor.darkText
        greekInputTool.isTranslucent = true
        greekInputTool.barTintColor = UIColor.groupTableViewBackground
        let diacritFontAttribs =  [NSFontAttributeName:UIFont(name: "Avenir-Black", size: CGFloat(24.0))]
        var barButtonArray = Array<UIBarButtonItem>()
        let diacritArray = [greekDiacrits.acute,greekDiacrits.acuteSmooth, greekDiacrits.acuteRough,
                            greekDiacrits.grave, greekDiacrits.graveSmooth, greekDiacrits.graveRough,
                            greekDiacrits.circumf,greekDiacrits.circumfSmooth,greekDiacrits.circumfRough,
                            greekDiacrits.Smooth, greekDiacrits.Rough]
        for diacrit in diacritArray
        {
            let button = UIBarButtonItem(title: diacrit.rawValue, style: .plain, target: self, action:#selector(barButtonAddText(sender:)))
            button.setTitleTextAttributes((diacritFontAttribs as Any as! [String : Any]), for: .normal)
            barButtonArray.append(button)
            barButtonArray.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        barButtonArray.removeLast() // we have appended one too many flexible spaces!

        greekInputTool.items = barButtonArray
        return greekInputTool
    }
    
    
    func getReplacementSymbol(letter: String, diacrit : greekDiacrits) -> String
    {
        var graphemeCluster = letter
        var mod : greekDiacrits = diacrit

        if [greekDiacrits.acuteRough, greekDiacrits.acuteSmooth].contains(diacrit)  {
            mod = greekDiacrits.acute
        }
        if [greekDiacrits.graveRough, greekDiacrits.graveSmooth].contains(diacrit)  {
            mod = greekDiacrits.grave
        }
        if [greekDiacrits.circumfRough, greekDiacrits.circumfSmooth].contains(diacrit)  {
            mod = greekDiacrits.circumf
        }
        if [greekDiacrits.acuteRough, greekDiacrits.graveRough,greekDiacrits.circumfRough].contains(diacrit)  {
            graphemeCluster = toRough(graphemeCluster)
        }
        if [greekDiacrits.acuteSmooth, greekDiacrits.graveSmooth,greekDiacrits.circumfSmooth].contains(diacrit)  {
            graphemeCluster = toSmooth(graphemeCluster)
        }
        return addMark(letter: graphemeCluster, mark: mod )
    }
    
    func  toRough (_ c : String) -> String
    {
        var returnValue = ""
        let rough : Dictionary = ["α" : "\u{1F00}",
         "ε" : "\u{1F10}",
         "ι" : "\u{1F30}",
         "ο" : "\u{1F40}",
         "ω" : "\u{1F60}",
         "η" : "\u{1F20}",
         "υ" : "\u{1F50}",
         "Α" : "\u{1F08}",
         "Ε" : "\u{1F18}",
         "Ι" : "\u{1F38}",
         "Ο" : "\u{1F48}",
         "Ω" : "\u{1F68}",
         "Η" : "\u{1F28}"/*,
             "Υ" : "\u{1F58}"*/
        ]
        if rough.keys.contains(c) == true
        {
            returnValue = rough[c]!
        }
        return returnValue
    }
    
    func  toSmooth (_ c : String) -> String
    {
        var returnValue = ""
        let smooth : Dictionary = ["α" : "\u{1F01}",
        "ε" : "\u{1F11}",
        "ι" : "\u{1F31}",
        "ο" : "\u{1F41}",
        "ω" : "\u{1F61}",
        "η" : "\u{1F21}",
        "υ" : "\u{1F51}",
        "Α" : "\u{1F09}",
        "Ε" : "\u{1F19}",
        "Ι" : "\u{1F39}",
        "Ο" : "\u{1F49}",
        "Ω" : "\u{1F69}",
        "Η" : "\u{1F29}",
        "Υ" : "\u{1F59}"
        ]
        if smooth.keys.contains(c) == true
        {
            returnValue = smooth[c]!
        }
        return returnValue
    }

    
    // for adding (rough, smooth, accent, grave) to the character
    func addMark(letter: String, mark : greekDiacrits) -> String
    {
        var returnChar = letter
        if mark == greekDiacrits.acute
            { returnChar += "\u{0301}"}
        if mark == greekDiacrits.grave
            { returnChar += "\u{0300}"}
        if mark == greekDiacrits.Rough
            { returnChar += "\u{0314}"}
        if mark == greekDiacrits.Smooth
            { returnChar += "\u{0313}"}
        if mark == greekDiacrits.circumf
            { returnChar += "\u{0342}"}
        return returnChar
    }
    
}

