//
//  AddCardViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 7/6/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit


class AddCardViewController: UIViewController {
    
    @IBOutlet weak var faceOneField: UITextField!
    @IBOutlet weak var faceTwoField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpKeyboards()
        uiSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        prepareKeyboardNotifications()
    }
    // MARK: - Keyboard management -
    // the next three functions withdraw the keyboard 
    // from view when the return button is pressed
    @IBAction func faceOneDoneTyping(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func faceTwoDoneTyping(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func tagsDoneTyping(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    func setUpKeyboards()
    {
        // this is not minimally repetitive, but it will do.
        let textEntryGlobs = [faceOneField,faceTwoField,tagsField]
        for glob in textEntryGlobs
        {
            glob!.autocorrectionType = UITextAutocorrectionType.no
            glob!.spellCheckingType = UITextSpellCheckingType.no
            glob!.autocapitalizationType = UITextAutocapitalizationType.none
            glob!.returnKeyType = UIReturnKeyType.go
        }
    }
    

    func saveNewCard()
    {
        // obtain and validate the input fields
        if let inputFaceOne = faceOneField.text,let inputFaceTwo = faceTwoField.text,let inputTags = tagsField.text {
            if inputFaceOne.characters.count > 0,
                inputFaceTwo.characters.count > 0,
                inputTags.characters.count > 0
            {
                // create a new cards object,
                // initialize to match input,
                // and send to Core Data
                let aNewCard : CardObject = CardObject()
                aNewCard.cardInfo.isActive = true
                aNewCard.cardInfo.isKnown = false
                aNewCard.cardInfo.studyToday = false
                aNewCard.cardInfo.faceOne = inputFaceOne
                aNewCard.cardInfo.faceTwo = inputFaceTwo
                aNewCard.cardInfo.tags = inputTags
                negozioGrande!.addNewObj(card: aNewCard)
            }
        }
    }

    // MARK: - Navigation -

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCardSegueToMain" {
            saveNewCard()

        }
    }
    // MARK: - UI jiggering -
    func uiSetup()
     {
        let bov = bOfVenusColors()
        let bp = buttonParams()
        let buttns : Array<UIButton> = [cancelButton, saveButton]
        for b in buttns
        {
            b.layer.borderWidth = bp.borderWidth
            b.layer.borderColor = bov.dark.cgColor
            b.layer.cornerRadius = bp.cornerRadius
            b.backgroundColor = bov.blue
            b.tintColor = UIColor.white
        }
        
        let inputFields : Array<UITextField> = [faceOneField, faceTwoField, tagsField]
        for infi in inputFields
        {
            infi.layer.borderWidth = bp.fieldBorderWidth
            infi.layer.borderColor = bov.dark.cgColor
            infi.layer.cornerRadius = bp.cornerRadius
            infi.backgroundColor = bov.green
        }
        view!.backgroundColor = bov.beige
     }

}

