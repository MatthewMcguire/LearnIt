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
        if let currentPoints = negozioGrande?.getUserTotalPoints()  {
            negozioGrande!.updateUserTotalPoints(addThese: (-1 * currentPoints))
        }
        resetPointsButton.isEnabled = false
    }
    @IBAction func maxCardsEntered(_ sender: Any) {
        storeValsHideKeyboard()
    }
    @IBAction func maximumAnswerValueEntered(_ sender: Any) {
        storeValsHideKeyboard()
    }

    @IBAction func answerPauseEntered(_ sender: Any) {
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
    }
    
    func storeValsHideKeyboard()
    {
        if Float (answerPauseField.text!)! > 0.0
        {
            negozioGrande!.currentLearner?.correctAnswerShownPause = Float(answerPauseField.text!)!
        }
        if Int(maxCardsInHandField.text!)! > 0
        {
            negozioGrande!.currentLearner?.maxCardsInHand = Int32(maxCardsInHandField.text!)!
        }
        if Int(maxCardsInHandField.text!)! > 0
        {
            negozioGrande!.currentLearner?.maxCardsInHand = Int32(maxCardsInHandField.text!)!
        }
        
        updateUserInfo(context: negozioGrande!.manObjContext)
        self.view.endEditing(true)
        resignFirstResponder()
    }
}
