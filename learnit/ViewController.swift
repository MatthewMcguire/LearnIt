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
        self.updateTotalPoints()
        prepareKeyboardNotifications()
        
//        if oggiQueue  == nil
//        {
//            self.refreshCardShown()
//        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.view.endEditing(true)
        self.refreshLearnerPreferences()
        updateCounter()
        
        updateForPointsIndicator()
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
            updateForPointsIndicator()
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
        
        
        updateForPointsIndicator()
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

    
    func updateCounter()
    {
        // obtain the total number of active cards and the number to
        // review or learn today, and show in the 'cards known' label
        
        let numCards = howManyActiveCards(context: negozioGrande!.manObjContext)
        let numKnownCards = howManyActiveKnownCards(context: negozioGrande!.manObjContext)
        let counterLabelText = "known: \(numKnownCards)/\(numCards)"
        cardsKnownLabel.text = counterLabelText
    }
 
    func updateTotalPoints()
    {
        let totalPoints = negozioGrande!.getUserTotalPoints()
        let ptsString = String(format: "%.1f pts.", totalPoints)
        pointsLabel.text = ptsString
    }
    
    
    func refreshCardShown()
    {
        oggiQueue = refreshLearningQueue()
        if let queueSize = oggiQueue?.count
        {
            if queueSize > 0 && currentPlaceInQueue < 1
            {
                currentPlaceInQueue = 0
                currentCard = negozioGrande!.getCardWithID(uniqueID: oggiQueue![currentPlaceInQueue])
            }
            if currentPlaceInQueue >= queueSize
            {
                currentPlaceInQueue = queueSize - 1
            }
        }
        hintLabel.text = " "
        UIView.animate(withDuration: 1.5, delay: 0.5, options:UIViewAnimationOptions.curveEaseInOut, animations: {
            self.AnswerField.text = ""
            }, completion: nil)
        hintLevel = 0
        hintAnswer = currentCard?.cardInfo.faceTwoAsSet.first
        updateTotalPoints()
        showACard()
    }
 
    
    func showACard()
    {
        if let queueSize = oggiQueue?.count
        {
            if queueSize > 0
            {
                skipButton.isEnabled = true
                showHintButton.isEnabled = true
                AnswerField.isEnabled = true
                let uniqueID = oggiQueue?[currentPlaceInQueue]
                currentCard = negozioGrande!.getCardWithID(uniqueID: uniqueID!)
                faceOneLabel.text = currentCard?.cardInfo.faceOne
                tagLabel.text = currentCard?.cardInfo.tags
                currentAnswerValue = maxAnswerValue

            }
            else
            {
                skipButton.isEnabled = false
                showHintButton.isEnabled = false
                AnswerField.isEnabled = false
                faceOneLabel.text = "-- All caught up --"
                tagLabel.text = " "
                messageLabel.text = " "
            }
        }
    }
 
    func updateForPointsIndicator()
    {
        let ptsString = String(format: "for %.1f points", currentAnswerValue)
        forPointsLabel.text = ptsString
    }
    
    func updatePlaceInQueue()
    {
        if let todaysQueue = oggiQueue
        {

            let queueSize = todaysQueue.count
            if queueSize > 0
            {
                currentPlaceInQueue = currentPlaceInQueue + 1
                if currentPlaceInQueue > (queueSize - 1) || (currentPlaceInQueue >= maxCardsInHand)
                {
                    currentPlaceInQueue = 0
                }
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
        updateTotalPoints()
        
        // notify the learner
        let ptsStr = String(format:"%.1f", currentAnswerValue)
        
        messageLabel.text = "(" + ptsStr + " pts): \(currentCard?.cardInfo.faceTwo ?? " ")"
        
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
        updateCounter()
        animateResponse(UIColor.green,  messageLabel, feedbackView, correctAnswerShownPause)
    }
    

    

    @IBAction func unwindToMain(sender : UIStoryboardSegue)
    {
       // if loq == true {print("Unwinding to the main view...")}
    }

    func uiSetup()
    {
     
        let buttnsType1 : Array<UIButton> = [showHintButton, skipButton]
        let buttnsType2 : Array<UIButton> = [addButton, browseButton, configureButton, statisticsButton]
        let bov = bOfVenusColors()
        let bp = buttonParams()
        
        view!.backgroundColor = bov.beige
        
        faceOneLabel.backgroundColor = bov.blue
        messageLabel.backgroundColor = bov.beige
        AnswerField.backgroundColor = bov.blue
        hintLabel.backgroundColor = bov.beige
        forPointsLabel.textColor = bov.red
        tagLabel.textColor = bov.red
        pointsLabel.textColor = bov.red
        cardsKnownLabel.textColor = bov.red
        
        let both : Array<UIButton> = buttnsType1 + buttnsType2
        for b in both
        {
            b.layer.borderWidth = bp.borderWidth
            b.layer.borderColor = bov.dark.cgColor
            b.layer.cornerRadius = bp.cornerRadius
            b.layer.backgroundColor = bov.green.cgColor
            b.tintColor = UIColor.white
        }
        for b in buttnsType2
        {
            b.layer.backgroundColor = bov.blue.cgColor
        }
    }

}




