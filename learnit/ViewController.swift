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
    
    
    var currentCard : CardObject?
    var hintLevel : Int = 0
    var currentAnswerValue : Float = 10.0
    var stateNow = userState()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if negozioGrande == nil
        {
            negozioGrande = CoreDataDomus()
        }
        negozioGrande?.refreshFetchedResultsController()
        negozioGrande?.refreshFetchedTagsController()
        //        refreshLearnerPreferences()
        updateStudyToday()
        uiSetup()
        pointsLabel.text = updateTotalPoints()
        prepareKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.endEditing(true)
        stateNow = refreshLearnerPreferences( &currentAnswerValue)
        cardsKnownLabel.text = updateCounter()
        forPointsLabel.text = updateForPointsIndicator(currentAnswerValue)
        faceOneLabel.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        AnswerField.preferredLang = nil
        refreshCardShown()
    }
    
    @IBAction func hintButtonPress(_ sender: Any) {
        let hintA = stateNow.hintAnswer
        let nextHint = shareHint(hintAnswer: hintA, hintLevel: &hintLevel, answerValue: &currentAnswerValue)
        if nextHint.characters.count > 0
        {
            hintLabel.text = nextHint
        }
        let attHintText = NSAttributedString(string: hintLabel.text!, attributes: [NSKernAttributeName : 2.0])
        hintLabel.attributedText = attHintText
        forPointsLabel.text = updateForPointsIndicator(currentAnswerValue)
    }
    
    @IBAction func skipButtonPress(_ sender: Any) {
        stateNow = updatePlaceInQueue(oggiQueue!, stateNow)
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
    }
    
    @IBAction func dismissKeyb(_ sender: Any) {
        view.endEditing(true)
    }
    
    func refreshCardShown()
    {
        oggiQueue = refreshLearningQueue()
        if let queueSize = oggiQueue?.count, queueSize > 0
        {
            stateNow.currentPlaceInQueue = max(min(stateNow.currentPlaceInQueue,queueSize-1),0)
            showACard()
        }
        else
        {
            setEnableButtons([skipButton, showHintButton], false)
            AnswerField.isEnabled = false
            setLabelText([faceOneLabel,tagLabel,messageLabel], "--")
            
        }
        
        hintLabel.text = " "
        pointsLabel.text = updateTotalPoints()
        forPointsLabel.text = updateForPointsIndicator(currentAnswerValue)
    }
    
    func showACard()
    {
        hintLevel = 0
        animateShowCard("",AnswerField)
        setEnableButtons([skipButton, showHintButton], true)
        AnswerField.isEnabled = true
        currentCard = getCardWithID(uniqueID: oggiQueue![stateNow.currentPlaceInQueue])
        faceOneLabel.text = currentCard?.cardInfo.faceOne
        tagLabel.text = currentCard?.cardInfo.tags
        currentAnswerValue = stateNow.maxAnswerValue
        stateNow.hintAnswer = (currentCard?.cardInfo.faceTwoAsSet.first!)!
    }
    
    func processIncorrectAnswer(uniqueID:String, distance dist: Float)
    {
        feedbackView.alpha = 1.0
        // notify the learner
        messageLabel.text = "No:  \(currentCard?.cardInfo.faceTwo ?? " ")"
        // update statistics for the card
        updateCardAnsweredINCorrect(uniqueID: currentCard!.uniqueID, distance: dist)
        // move to next card & show it
        stateNow = updatePlaceInQueue(oggiQueue!, stateNow)
        refreshCardShown()
        animateResponse(UIColor.red,  messageLabel, feedbackView, stateNow.correctAnswerShownPause)
    }
    
    func processCorrectAnswer(uniqueID:String, distance dist:Float)
    {
        updateUserTotalPoints(addThese: currentAnswerValue)
        pointsLabel.text = updateTotalPoints()
        
        // notify the learner
        messageLabel.text = "(" + String(format:"%.1f", currentAnswerValue) + " pts): \(currentCard?.cardInfo.faceTwo ?? " ")"
        
        // update statistics for the card
        updateCardAnsweredCorrect(uniqueID: currentCard!.uniqueID, distance: dist)
        
        // remove the card from the stack of today's cards
        if let removeElementHere = oggiQueue!.index(of: (currentCard?.uniqueID)!)
        {
            oggiQueue!.remove(at: removeElementHere)
        }
        
        // move to next card & show it
        stateNow.currentPlaceInQueue = min(stateNow.currentPlaceInQueue,(oggiQueue!.count-1))
        
        refreshCardShown()
        cardsKnownLabel.text = updateCounter()
        animateResponse(UIColor.green,  messageLabel, feedbackView, stateNow.correctAnswerShownPause)
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
        labelTextColor([forPointsLabel,tagLabel,pointsLabel,cardsKnownLabel], bOfVenusColors().red )
    }
    
}




