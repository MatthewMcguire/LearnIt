//
//  ConfigurationViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 7/7/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController, XMLParserDelegate {

    var aNewCard : CardObject?
    var currentElement : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Settings"
        if let cl = negozioGrande!.currentLearner
        {
            answerPauseField.text = String(cl.correctAnswerShownPause)
            maxCardsInHandField.text = String(cl.maxCardsInHand)
        }
        resetPointsButton.isEnabled = true
        deleteCardsButton.isEnabled = true
        resetCardsButton.isEnabled = true
        addDoneKeyToDecimalKeyboard()
    }

    @IBAction func importHomericGreekPress(_ sender: Any) {
        if loq == true {print("Importing sample Greek language cards.")}
        addCardsViaXML(fileName: "sampleGreek")
    }
    
    @IBAction func importWelshPress(_ sender: Any) {
        if loq == true {print("Importing sample Welsh language cards.")}
        addCardsViaXML(fileName: "sampleWelshDuolingo")
    }
    
    @IBAction func resetPointsPress(_ sender: Any) {
        if loq == true {print("Setting the total user points to zero.")}
        if let currentPoints = negozioGrande?.getUserTotalPoints()
        {
            negozioGrande!.updateUserTotalPoints(addThese: (-1 * currentPoints))
        }
        resetPointsButton.isEnabled = false
    }
    @IBAction func maxCardsEntered(_ sender: Any) {
        if Int(maxCardsInHandField.text!)! > 0
        {
            negozioGrande!.currentLearner?.maxCardsInHand = Int32(maxCardsInHandField.text!)!
        }
        negozioGrande!.updateUserInfo()
        hideKeyboard()
    }

    @IBAction func answerPauseEntered(_ sender: Any) {
        if Float (answerPauseField.text!)! > 0.0
        {
            negozioGrande!.currentLearner?.correctAnswerShownPause = Float(answerPauseField.text!)!
        }
        negozioGrande!.updateUserInfo()
        hideKeyboard()
    }
    
    @IBAction func resetCardsPress(_ sender: Any) {
        if loq == true {print("Setting the status of all cards to 'unknown'.")}
        negozioGrande!.updateAllCardsAsUnknown()
        resetCardsButton.isEnabled = false
    }

    @IBAction func deleteAllCardsPress(_ sender: Any) {
        if loq == true {print("Removing all cards and their related fields from Core Data.")}
        negozioGrande!.clearAllObjectsFromStore()
        deleteCardsButton.isEnabled = false
    }
  
    @IBOutlet weak var answerPauseField: UITextField!
    @IBOutlet weak var maxCardsInHandField: UITextField!

    @IBOutlet weak var resetPointsButton: UIButton!
    @IBOutlet weak var resetCardsButton: UIButton!
    @IBOutlet weak var deleteCardsButton: UIButton!
    
    /*
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    */
    
    // MARK: - XML Import -
    func addCardsViaXML(fileName : String) -> Void
    {
        if let myResource = Bundle.main.url(forResource: fileName, withExtension: "xml")
        {
            if let simpleParser = XMLParser.init(contentsOf: myResource)
            {
                simpleParser.delegate = self
                simpleParser.parse()
            }
        }
    }
    func parserDidStartDocument(_ parser: XMLParser) {
        print("XML Parsing has begun.")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "card":
            aNewCard = CardObject()
            if aNewCard != nil
            {
                aNewCard!.isKnown = false
                aNewCard!.isActive = true
                aNewCard!.studyToday = false
            }
        case "faceOne":
        if aNewCard != nil
            {
                aNewCard!.faceOne = ""
                currentElement = ""
            }
        case "faceOneText":
            if aNewCard != nil && currentElement != nil
            {
                if currentElement!.characters.count > 0
                {
                    currentElement! += ", "
                }
            }
        case "faceTwo":
            if aNewCard != nil
            {
                aNewCard!.faceTwo = ""
                currentElement = ""
            }
        case "faceTwoText":
            if aNewCard != nil && currentElement != nil
            {
                if currentElement!.characters.count > 0
                {
                    currentElement! += ", "
                }
            }
        case "tags":
            if aNewCard != nil
            {
                aNewCard!.tags = ""
                currentElement = ""
            }
        case "tag":
            if aNewCard != nil && currentElement != nil
            {
                if currentElement!.characters.count > 0
                {
                    currentElement! += ", "
                }
            }
        default:
            print("Unknown XML tag. This is not anticipated or handled.")
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let elimTrashChars = CharacterSet.whitespacesAndNewlines
        var globToAdd = string.trimmingCharacters(in: elimTrashChars)
        globToAdd.replacingOccurrences(of: "\"", with: "")
        globToAdd.replacingOccurrences(of: ",", with: "##")
        if currentElement != nil
        {
            currentElement! += globToAdd
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "card":
            if aNewCard != nil
            {
                if aNewCard!.faceOne!.characters.count > 0 &&
                aNewCard!.faceTwo!.characters.count > 0 &&
                aNewCard!.tags!.characters.count > 0
                {
                    negozioGrande!.addNewObj(card: aNewCard!)
                }
            }
        case "faceOne":
            if aNewCard != nil && currentElement != nil
            {
                aNewCard!.faceOne = currentElement!
            }
        case "faceOneText":
            print("\tClosing the 'faceOneText' tag.")
        case "faceTwo":
            if aNewCard != nil && currentElement != nil
            {
                aNewCard!.faceTwo = currentElement!
            }
        case "faceTwoText":
            print("\tClosing the 'faceTwoText' tag.")
        case "tags":
            if aNewCard != nil && currentElement != nil
            {
                aNewCard!.tags = currentElement!
            }
        case "tag":
            print("\tClosing the 'tag' tag.")
            
        default:
            print("Unknown XML tag. This is not anticipated or handled.")
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        if parser.parserError != nil
        {
            print("XML processing is completed.")
        }
        else
        {
            print("An error occurred during XML processing.")
        }
    }
    
        // MARK: - Keyboard customization -
    
    func addDoneKeyToDecimalKeyboard()
    {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action:#selector(ConfigurationViewController.hideKeyboard))
        let buttonSpace = UIBarButtonItem(barButtonSystemItem:.flexibleSpace, target:nil , action: nil)
        let keyboardItems = [buttonSpace,doneButton,buttonSpace]
        let toolbar = UIToolbar()
        toolbar.frame.size.height = 40
        toolbar.isTranslucent = false
        
        toolbar.items = keyboardItems
        maxCardsInHandField.inputAccessoryView = toolbar
        answerPauseField.inputAccessoryView = toolbar
    }
    
    func hideKeyboard()
    {
        if Float (answerPauseField.text!)! > 0.0
        {
            negozioGrande!.currentLearner?.correctAnswerShownPause = Float(answerPauseField.text!)!
            
        }
        
        if Int(maxCardsInHandField.text!)! > 0
        {
            negozioGrande!.currentLearner?.maxCardsInHand = Int32(maxCardsInHandField.text!)!
        }
        
        negozioGrande!.updateUserInfo()
        self.view.endEditing(true)
        resignFirstResponder()
    }
}
