//
//  ViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 6/26/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

var negozioGrande : CoreDataDomus?
var oggiQueue : Array<String>?

class ViewController: UIViewController {
    @IBOutlet weak var faceOneLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var cardsKnownLabel: UILabel!
    @IBOutlet weak var AnswerField: SmartLanguageUITextField!

    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var forPointsLabel: UILabel!
    @IBOutlet weak var showHintButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var configureButton: UIButton!
    @IBOutlet weak var statisticsButton: UIButton!
    @IBOutlet weak var feedbackHeight: NSLayoutConstraint!
    @IBOutlet weak var messageHeight: NSLayoutConstraint!
    
    var maxCardsInHand : Int = 5
    var correctAnswerShownPause : Float = 5.0
    var currentCard : CardObject?
    var currentPlaceInQueue: Int = 0
    var hintLevel : Int = 0
    var hintAnswer: String?
    var maxAnswerValue : Float = 10.0
    var currentAnswerValue : Float = 10.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.storageSetup()
        self.refreshLearnerPreferences()
        negozioGrande?.updateStudyToday()
        self.uiSetup()
        self.pointsLabel.text = updateTotalPoints()
        prepareKeyboardNotifications()
        
//        if oggiQueue  == nil
//        {
//            self.refreshCardShown()
//        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.endEditing(true)
        self.refreshLearnerPreferences()
        cardsKnownLabel.text = updateCounter()
        
        forPointsLabel.text = updateForPointsIndicator(currentAnswerValue)
        faceOneLabel.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnswerField.preferredLang = nil
        refreshCardShown()
    }

    @IBAction func hintButtonPress(_ sender: Any) {
        if let hintA = hintAnswer
        {
            let nextHint = shareHint(hintAnswer: hintA, hintLevel: &hintLevel, answerValue: &currentAnswerValue)
            if nextHint.characters.count > 1
            {
              hintLabel.text = nextHint
            }
            let attHintText = NSAttributedString(string: hintLabel.text!, attributes: [NSKernAttributeName : 2.0])
            hintLabel.attributedText = attHintText
            forPointsLabel.text = updateForPointsIndicator(currentAnswerValue)
        }
    }

    @IBAction func skipButtonPress(_ sender: Any) {
        updatePlaceInQueue()
        refreshCardShown()
    }


    @IBAction func beginTypingAnswer(_ sender: Any) {
        self.messageLabel.text = " "
        
    }
    @IBAction func enteredAnswer(_ sender: Any) {
        view.endEditing(true)
        var result = assessResponse(AnswerField, currentCard!, &currentAnswerValue)
        if result < 0.0
        {
            if result < -10.00 { result = -10.00}
            processIncorrectAnswer(uniqueID: currentCard!.uniqueID, distance: (result * -1.0))
        }
        else
        {
            processCorrectAnswer(uniqueID: currentCard!.uniqueID, distance: result)
        }
        forPointsLabel.text = updateForPointsIndicator(currentAnswerValue)
    }
    
    
    @IBAction func dismissKeyb(_ sender: Any) {
        view.endEditing(true)
    }
    
    func storageSetup()
    {
        negozioGrande = CoreDataDomus()
        if negozioGrande == nil  {
            fatalError("Error creating Core Data Object")
        }
        else  {
            negozioGrande!.refreshFetchedResultsController()
            negozioGrande!.refreshFetchedTagsController()
        }

    }
    
    func refreshLearnerPreferences()
    {
        if let currentL = negozioGrande!.currentLearner  {
            maxCardsInHand = Int(currentL.maxCardsInHand)
            correctAnswerShownPause = currentL.correctAnswerShownPause
            currentAnswerValue = currentL.maximumAnswerValue
            maxAnswerValue = currentL.maximumAnswerValue
        }
    }

        
    func refreshCardShown()
    {
        oggiQueue = refreshLearningQueue()
        let queueSize = oggiQueue?.count
        if queueSize! > 0 && currentPlaceInQueue < 1
        {
            currentPlaceInQueue = 0
            currentCard = negozioGrande!.getCardWithID(uniqueID: oggiQueue![currentPlaceInQueue])
        }
        if currentPlaceInQueue >= queueSize!
        {
            currentPlaceInQueue = queueSize! - 1
        }
        hintLabel.text = " "
        UIView.animate(withDuration: 1.5, delay: 0.5, options:UIViewAnimationOptions.curveEaseInOut, animations: {
            self.AnswerField.text = ""
            }, completion: nil)
        hintLevel = 0
        pointsLabel.text = updateTotalPoints()
        showACard()
        hintAnswer = currentCard?.cardInfo.faceTwoAsSet.first
    }
 
    
    func showACard()
    {
        guard let queueSize = oggiQueue?.count
            else { fatalError("Cannot obtain learning queue size.") }
        if queueSize > 0
        {
            setEnableButtons([skipButton, showHintButton], true)
            AnswerField.isEnabled = true
            currentCard = negozioGrande!.getCardWithID(uniqueID: oggiQueue![currentPlaceInQueue])
            faceOneLabel.text = currentCard?.cardInfo.faceOne
            tagLabel.text = currentCard?.cardInfo.tags
            currentAnswerValue = maxAnswerValue
        }
        else
        {
            setEnableButtons([skipButton, showHintButton], false)
            AnswerField.isEnabled = false
            faceOneLabel.text = "-- All caught up --"
            tagLabel.text = " "
            messageLabel.text = " "
        }
    }
 
    
    func updatePlaceInQueue()
    {
        guard let todaysQueue = oggiQueue
            else { fatalError("no learning queue available") }
        if todaysQueue.count > 0
        {
            currentPlaceInQueue += 1
            if currentPlaceInQueue > (todaysQueue.count - 1) || (currentPlaceInQueue >= maxCardsInHand)
            {
                currentPlaceInQueue = 0
            }
        }
    }
    
    func processIncorrectAnswer(uniqueID:String, distance dist: Float)
    {
        feedbackView.alpha = 1.0
        // notify the learner
        messageLabel.text = "No:  \(currentCard?.cardInfo.faceTwo ?? " ")"
        // update statistics for the card
        negozioGrande!.updateCardAnsweredINCorrect(uniqueID: currentCard!.uniqueID, distance: dist)
        // move to next card & show it
        updatePlaceInQueue()
        refreshCardShown()
        animateResponse(UIColor.red,  messageLabel, feedbackView, correctAnswerShownPause)
    }
    
    func processCorrectAnswer(uniqueID:String, distance dist:Float)
    {
        feedbackView.alpha = 1.0
        negozioGrande!.updateUserTotalPoints(addThese: currentAnswerValue)
        pointsLabel.text = updateTotalPoints()
        
        // notify the learner
        messageLabel.text = "(" + String(format:"%.1f", currentAnswerValue) + " pts): \(currentCard?.cardInfo.faceTwo ?? " ")"
        
        // update statistics for the card
        negozioGrande!.updateCardAnsweredCorrect(uniqueID: currentCard!.uniqueID, distance: dist)
        
        // remove the card from the stack of today's cards
        if let removeElementHere = oggiQueue!.index(of: (currentCard?.uniqueID)!)
        {
            oggiQueue!.remove(at: removeElementHere)
        }
        
        // move to next card & show it
        if currentPlaceInQueue >= oggiQueue!.count
        {
            currentPlaceInQueue = 0
        }

        refreshCardShown()
        cardsKnownLabel.text = updateCounter()
        animateResponse(UIColor.green,  messageLabel, feedbackView, correctAnswerShownPause)
    }
    

    

    @IBAction func unwindToMain(sender : UIStoryboardSegue)
    {
       // if loq == true {print("Unwinding to the main view...")}
    }

    func uiSetup()
    {
        buttonAppearance([showHintButton, skipButton],[addButton, browseButton, configureButton, statisticsButton])
        view!.backgroundColor = bOfVenusColors().beige
        faceOneLabel.backgroundColor = bOfVenusColors().blue
        messageLabel.backgroundColor = bOfVenusColors().beige
        AnswerField.backgroundColor = bOfVenusColors().blue
        hintLabel.backgroundColor = bOfVenusColors().beige
        forPointsLabel.textColor = bOfVenusColors().red
        tagLabel.textColor = bOfVenusColors().red
        pointsLabel.textColor = bOfVenusColors().red
        cardsKnownLabel.textColor = bOfVenusColors().red
        

    }

}




