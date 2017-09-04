//
//  ConfigurationViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 7/7/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        if let cl = negozioGrande!.currentLearner
        {
            answerPauseField.text = String(cl.correctAnswerShownPause)
            maxCardsInHandField.text = String(cl.maxCardsInHand)
            maxAnswerValueField.text = String(cl.maximumAnswerValue)
        }
        resetPointsButton.isEnabled = true
        deleteCardsButton.isEnabled = true
        resetCardsButton.isEnabled = true
        addDoneKeyToDecimalKeyboard()
    }
    
    @IBAction func importHomericGreekPress(_ sender: Any) {
        let getXML = ParseXML()
        getXML.addCardsViaXML(fileName: "sampleGreek")
    }
    
    @IBAction func importWelshPress(_ sender: Any) {
        let getXML = ParseXML()
        getXML.addCardsViaXML(fileName: "sampleWelsh")
    }
    
    @IBAction func resetPointsPress(_ sender: Any) {
        updateUserTotalPoints(addThese: (-1 * getUserTotalPoints()))
        resetPointsButton.isEnabled = false
    }
    @IBAction func maxCardsEntered(_ sender: Any) {
        validateMaxCardsHeld()
        storeValsHideKeyboard()
    }
    @IBAction func maximumAnswerValueEntered(_ sender: Any) {
        validateMaxAnswerValueField()
        storeValsHideKeyboard()
    }
    
    @IBAction func answerPauseEntered(_ sender: Any) {
        validateAnswerPauseField()
        storeValsHideKeyboard()
    }
    
    @IBAction func resetCardsPress(_ sender: Any) {
        updateAllCardsAsUnknown(context: negozioGrande!.manObjContext)
        resetCardsButton.isEnabled = false
    }
    
    @IBAction func deleteAllCardsPress(_ sender: Any) {
        clearAllObjectsFromStore(context: negozioGrande!.manObjContext)
        deleteCardsButton.isEnabled = false
    }
    
    @IBOutlet weak var answerPauseField: UITextField!
    @IBOutlet weak var maxCardsInHandField: UITextField!
    @IBOutlet weak var maxAnswerValueField: UITextField!
    
    @IBOutlet weak var resetPointsButton: UIButton!
    @IBOutlet weak var resetCardsButton: UIButton!
    @IBOutlet weak var deleteCardsButton: UIButton!
    
    
    // MARK: - Keyboard customization -
    
    func addDoneKeyToDecimalKeyboard()
    {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(ConfigurationViewController.storeValsHideKeyboard))
        let buttonSpace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target:nil , action: nil)
        let keyboardItems = [buttonSpace,doneButton,buttonSpace]
        let toolbar = UIToolbar()
        toolbar.frame.size.height = 40
        toolbar.isTranslucent = false
        
        toolbar.items = keyboardItems
        maxCardsInHandField.inputAccessoryView = toolbar
        answerPauseField.inputAccessoryView = toolbar
        maxAnswerValueField.inputAccessoryView = toolbar
    }
    
    func storeValsHideKeyboard()
    {
        validateMaxCardsHeld()
        validateAnswerPauseField()
        validateMaxAnswerValueField()
        negozioGrande!.currentLearner?.correctAnswerShownPause = Float(answerPauseField.text!)!
        negozioGrande!.currentLearner?.maxCardsInHand = Int32(maxCardsInHandField.text!)!
        negozioGrande!.currentLearner?.maximumAnswerValue = Float(maxAnswerValueField.text!)!
        updateUserInfo(context: negozioGrande!.manObjContext)
        self.view.endEditing(true)
        resignFirstResponder()
    }
    
    func validateMaxCardsHeld() {
        // guard against the field text not being available for some reason
        guard let fieldText = maxCardsInHandField.text
            else { resetMaxCardsInHandField(); return }
        // guard against the field text not being gracefully convertible to an Integer
        guard let val = Int32(fieldText)
            else { resetMaxCardsInHandField() ; return }
        // guard against an unreasonable value (i.e. zero or less)
        if val <= 0 { resetMaxCardsInHandField()}
    }
    
    func resetMaxCardsInHandField()  {
        // obtain the field value stored in the current learner object if possible
        if let clVal = negozioGrande!.currentLearner?.maxCardsInHand {
            maxCardsInHandField.text = String(clVal)
        }
        // otherwise use 10
        else { maxCardsInHandField.text = "10"}
    }
    
    func validateAnswerPauseField() {
        // guard against the field text not being available for some reason
        guard let fieldText = answerPauseField.text
            else { resetAnswerPauseField(); return }
        // guard against the field text not being gracefully convertible to an Integer
        guard let val = Float(fieldText)
            else { resetAnswerPauseField() ; return }
        // guard against an unreasonable value (i.e. zero or less)
        if val <= 0.0 { resetAnswerPauseField()}
    }
    
    fileprivate func extractedFunc() {
        // obtain the field value stored in the current learner object if possible
        if let clVal = negozioGrande!.currentLearner?.correctAnswerShownPause {
            answerPauseField.text = String(clVal)
        }
            // otherwise use 5.5
        else { answerPauseField.text = "5.5"}
    }
    
    func resetAnswerPauseField()  {
        extractedFunc()
    }
    
    func validateMaxAnswerValueField() {
        // guard against the field text not being available for some reason
        guard let fieldText = maxAnswerValueField.text
            else { resetMaxAnswerValueField(); return }
        // guard against the field text not being gracefully convertible to an Integer
        guard let val = Float(fieldText)
            else { resetMaxAnswerValueField() ; return }
        // guard against an unreasonable value (i.e. zero or less)
        if val <= 0.0 { resetMaxAnswerValueField()}
    }
    
    func resetMaxAnswerValueField()  {
        // obtain the field value stored in the current learner object if possible
        if let clVal = negozioGrande!.currentLearner?.maximumAnswerValue {
            maxAnswerValueField.text = String(clVal)
        }
            // otherwise use 10.0
        else { maxAnswerValueField.text = "10.0"}
    }
    
    
}
