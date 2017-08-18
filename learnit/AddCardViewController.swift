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
        if let inputFaceOne = faceOneField.text
        {
           if let inputFaceTwo = faceTwoField.text
           {
            if let inputTags = tagsField.text
            {
                if inputFaceOne.characters.count > 0 &&
                    inputFaceTwo.characters.count > 0 &&
                    inputTags.characters.count > 0
                {
                    // create a new cards object,
                    // initialize to match input,
                    // and send to Core Data
                    let aNewCard : CardObject = CardObject()
                    aNewCard.isActive = true
                    aNewCard.isKnown = false
                    aNewCard.studyToday = false
                    aNewCard.faceOne = inputFaceOne
                    aNewCard.faceTwo = inputFaceTwo
                    aNewCard.tags = inputTags
                    negozioGrande!.addNewObj(card: aNewCard)
                    if loq == true {print("Adding a new card with:")}
                    if loq == true {print("\tFace One: \(inputFaceOne).")}
                    if loq == true {print("\tFace Two: \(inputFaceTwo).")}
                    if loq == true {print("\tTags: \(inputTags).")}
                }
            }
            }
        }
    }

    // MARK: - Navigation -

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddCardSegueToMain"
        {
            saveNewCard()
            
        }
    }
    // MARK: - UI jiggering -
    func uiSetup()
     {
        let borderWidth : CGFloat = 2.5
        let cornerRadius : CGFloat = 9.0
//        let buttonInsideDGray = UIColor.darkGray.cgColor
//        let buttonBorderLGray = UIColor.black.cgColor
//        let fieldBorder = UIColor.init(red: 0.3, green: 0.3, blue: 0.9, alpha: 0.9).cgColor
        let fieldBorderWidth : CGFloat = 1.5
        
//        let ermine_choco2 = UIColor.init(red: (32.0/255), green: (20.0/255), blue: (8.0/255), alpha: 1.0)
//        let ermine_canoe_red = UIColor.init(red: (144.0/255), green: (36.0/255), blue: (11.0/255), alpha: 1.0)
////        let ermine_renn_orange = UIColor.init(red: (238.0/255), green: (152.0/255), blue: (35.0/255), alpha: 1.0)
//        let ermine_breaking_glass = UIColor.init(red: (254.0/255), green: (226.0/255), blue: (181.0/255), alpha: 1.0)
//        let ermine_pistache_green = UIColor.init(red: (208.0/255), green: (226.0/255), blue: (177.0/255), alpha: 1.0)
        let bOfVenus_green = UIColor.init(red: (168.0/255), green: (192.0/255), blue: (168.0/255), alpha: 1.0)
//        let bOfVenus_red = UIColor.init(red: (212.0/255), green: (126.0/255), blue: (115.0/255), alpha: 1.0)
        let bOfVenus_blue = UIColor.init(red: (120.0/255), green: (144.0/255), blue: (144.0/255), alpha: 1.0)
        let bOfVenus_dark = UIColor.init(red: (48.0/255), green: (24.0/255), blue: (24.0/255), alpha: 1.0)
        let bOfVenus_beige = UIColor.init(red: (240.0/255), green: (240.0/255), blue: (216.0/255), alpha: 1.0)
        let buttns : Array<UIButton> = [cancelButton, saveButton]
        for b in buttns
        {
            b.layer.borderWidth = borderWidth
            b.layer.borderColor = bOfVenus_dark.cgColor
            b.layer.cornerRadius = cornerRadius
            b.backgroundColor = bOfVenus_blue
            b.tintColor = UIColor.white
        }
        
        let inputFields : Array<UITextField> = [faceOneField, faceTwoField, tagsField]
        for infi in inputFields
        {
            infi.layer.borderWidth = fieldBorderWidth
            infi.layer.borderColor = bOfVenus_dark.cgColor
            infi.layer.cornerRadius = cornerRadius
            infi.backgroundColor = bOfVenus_green
        }
        view!.backgroundColor = bOfVenus_beige
     }

}

