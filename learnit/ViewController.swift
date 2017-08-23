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
    @IBOutlet weak var hintLabel: KerningLabel!
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
        self.updateStudyToday()
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
        self.assessResponse()
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
    
    func updateStudyToday()
    {
        if negozioGrande?.updateStudyToday() == true
        {
            print("Cards were added to the queue for the day")
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
        refreshQueue()
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
 
    func assessResponse()
    {
        let givenAnswer = AnswerField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        if givenAnswer?.characters.count == 0
        {
            processIncorrectAnswer(uniqueID: (currentCard?.uniqueID)!, distance: 10.0)
            return
        }
        var closestBestAnswer : String = "                 "
        // calculate distance from a correct answer
        var shortestDistance = 1000 // to begin, obviously way higher than any plausible input
        if let possibleAnswers = currentCard?.cardInfo.faceTwoAsSet
        {
            for aCorrectAnswer in possibleAnswers
            {
                let d = levenshteinDistanceFrom(source: aCorrectAnswer, target: givenAnswer!)
                if d < shortestDistance
                {
                    shortestDistance = d
                    closestBestAnswer = givenAnswer!
                }
            }
            // decide whether to mark closest answer as 'correct'
            if isMarkedCorrect(storedAnswer: closestBestAnswer, dist: shortestDistance) == true
            {
                currentAnswerValue = currentAnswerValue * powf(Float(0.85),Float(shortestDistance))
                processCorrectAnswer(uniqueID: (currentCard?.uniqueID)!, distance: Float(shortestDistance))
            }
            else
            {
                processIncorrectAnswer(uniqueID: (currentCard?.uniqueID)!, distance: Float(shortestDistance))
            }
        }
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
//                if let fTwo = currentCard?.faceTwo
//                {
//                    if answerContainsGreek(risposta: fTwo) == true
//                    {

//                        AnswerField.preferredLang = "el"
//
//                    }
//                    else
//                    {
//                        AnswerField.preferredLang = "en"
//                    }
//                }

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
 
    func refreshQueue()
    {
        oggiQueue = negozioGrande!.refreshLearningQueue()
    }
 
    func updateForPointsIndicator()
    {
        let ptsString = String(format: "for %.1f points", currentAnswerValue)
        forPointsLabel.text = ptsString
    }
    
    func isMarkedCorrect (storedAnswer:String, dist dis : Int )->Bool
    {
        let len = storedAnswer.characters.count
        var returnVal = false
        switch len {
        case 0...2:
            if dis < 1
            {
                returnVal = true
            }
        case 3...5:
            if dis < 2
            {
                returnVal = true
            }
        default:
            if dis < 3
            {
                returnVal = true
            }
        }
    return returnVal
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
        messageLabel.text = "Wrong:  \(currentCard?.cardInfo.faceTwo ?? " ")"
        if messageLabel.text!.characters.count > 25
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:UIViewAnimationOptions.curveEaseInOut, animations: {
//                self.feedbackHeight.constant = CGFloat(50.0)
//                self.messageHeight.constant = CGFloat(50.0)
            }, completion: nil)
        }
        // update statistics for the card
        negozioGrande!.updateCardAnsweredINCorrect(uniqueID: currentCard!.uniqueID, distance: dist)
        // move to next card & show it
        updatePlaceInQueue()
        refreshCardShown()
        self.feedbackView.backgroundColor = UIColor.white
        self.messageLabel.backgroundColor = UIColor.white
        UIView.animate(withDuration: 0.5, delay: 0.0, options:UIViewAnimationOptions.curveEaseInOut, animations: {
            self.feedbackView.backgroundColor = UIColor.red
            self.messageLabel.backgroundColor = UIColor.red
        }, completion: nil)
        UIView.animate(withDuration: TimeInterval(correctAnswerShownPause), delay: 0.5, options:UIViewAnimationOptions.curveEaseInOut, animations: {
                self.feedbackView.alpha = 0.0
        }, completion: nil)
    }
    
    func processCorrectAnswer(uniqueID:String, distance dist:Float)
    {
        feedbackView.alpha = 1.0
        negozioGrande!.updateUserTotalPoints(addThese: currentAnswerValue)
        updateTotalPoints()
        
        // notify the learner
        let ptsStr = String(format:"%.1f", currentAnswerValue)
        
        messageLabel.text = "Yes (" + ptsStr + " pts): \(currentCard?.cardInfo.faceTwo ?? " ")"
        if messageLabel.text!.characters.count > 25
        {
            UIView.animate(withDuration: 0.5, delay: 0.0, options:UIViewAnimationOptions.curveEaseInOut, animations: {
            }, completion: nil)
        }
        
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
        self.messageLabel.backgroundColor = UIColor.white
        self.feedbackView.backgroundColor = UIColor.white
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options:UIViewAnimationOptions.curveEaseInOut, animations: {
            self.messageLabel.backgroundColor = UIColor.green
            self.feedbackView.backgroundColor = UIColor.green
        }, completion: nil)
        UIView.animate(withDuration: TimeInterval(correctAnswerShownPause), delay: 0.5, options:UIViewAnimationOptions.curveEaseInOut, animations: {
            self.feedbackView.alpha = 0.0
        }, completion: nil)

    }
    
    // this is a helper function for the Levenshtein Distance calculation
    class Array2D {
        var cols:Int, rows:Int
        var matrix: [Int]
        
        init(cols:Int, rows:Int) {
            self.cols = cols
            self.rows = rows
            matrix = Array(repeating:0, count:cols*rows)
        }
        
        subscript(col:Int, row:Int) -> Int {
            get {
                return matrix[cols * row + col]
            }
            set {
                matrix[cols*row+col] = newValue
            }
        }
        
        func colCount() -> Int {
            return self.cols
        }
        
        func rowCount() -> Int {
            return self.rows
        }
    }
    
    //  common metric for calculating the number of edits (insert/delete/replace) to
    //  go from string a to string b
    func levenshteinDistanceFrom(source aStr:String,target bStr:String) -> Int {
        let a = Array(aStr.utf16)
        let b = Array(bStr.utf16)
        
        let dist = Array2D(cols: a.count + 1, rows: b.count + 1)
        
        for i in 1...a.count {
            dist[i, 0] = i
        }
        
        for j in 1...b.count {
            dist[0, j] = j
        }
        func minLD(numbers: Int...) -> Int {
            return numbers.reduce(numbers[0], {$0 < $1 ? $0 : $1})
        }
        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i, j] = dist[i-1, j-1]  // noop
                } else {
                    dist[i, j] = minLD(
                        numbers: dist[i-1, j] + 1,  // deletion
                        dist[i, j-1] + 1,  // insertion
                        dist[i-1, j-1] + 1  // substitution
                    )
                }
            }
        }
        
        return dist[a.count, b.count]
    }
    
 
    func answerContainsGreek(risposta: String) -> Bool
    {
        let matchingToGreek : Range? = risposta.rangeOfCharacter(from: CharacterSet.init(charactersIn: "ςερτυθιοπασδφγηξκλζχψωβνμ"))
        if matchingToGreek != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    

    @IBAction func unwindToMain(sender : UIStoryboardSegue)
    {
       // if loq == true {print("Unwinding to the main view...")}
    }

    func uiSetup()
    {
        let borderWidth : CGFloat = 2.5
        let cornerRadius : CGFloat = 9.0

        
        let bOfVenus_green = UIColor.init(red: (168.0/255), green: (192.0/255), blue: (168.0/255), alpha: 1.0)
        let bOfVenus_red = UIColor.init(red: (212.0/255), green: (126.0/255), blue: (115.0/255), alpha: 1.0)
        let bOfVenus_blue = UIColor.init(red: (120.0/255), green: (144.0/255), blue: (144.0/255), alpha: 1.0)
        let bOfVenus_dark = UIColor.init(red: (48.0/255), green: (24.0/255), blue: (24.0/255), alpha: 1.0)
        let bOfVenus_beige = UIColor.init(red: (240.0/255), green: (240.0/255), blue: (216.0/255), alpha: 1.0)

        
        let buttnsType1 : Array<UIButton> = [showHintButton, skipButton]
        let buttnsType2 : Array<UIButton> = [addButton, browseButton, configureButton, statisticsButton]
        
        view!.backgroundColor = bOfVenus_beige
        
        faceOneLabel.backgroundColor = bOfVenus_blue
        messageLabel.backgroundColor = bOfVenus_beige
        AnswerField.backgroundColor = bOfVenus_blue
        hintLabel.backgroundColor = bOfVenus_beige
        forPointsLabel.textColor = bOfVenus_red
        tagLabel.textColor = bOfVenus_red
        pointsLabel.textColor = bOfVenus_red
        cardsKnownLabel.textColor = bOfVenus_red
        
        for b in buttnsType1
        {
            b.layer.borderWidth = borderWidth
            b.layer.borderColor = bOfVenus_dark.cgColor
            b.layer.cornerRadius = cornerRadius
            b.layer.backgroundColor = bOfVenus_green.cgColor
            b.tintColor = UIColor.white
        }
        for b in buttnsType2
        {
            b.layer.borderWidth = borderWidth
            b.layer.borderColor = bOfVenus_dark.cgColor
            b.layer.cornerRadius = cornerRadius
            b.layer.backgroundColor = bOfVenus_blue.cgColor
            b.tintColor = UIColor.white
        }
    }

}

class KerningLabel: UILabel {
    func addKerning(kerningValue: Double) {
        let attributedString = self.attributedText as! NSMutableAttributedString
        attributedString.addAttribute(NSKernAttributeName, value: kerningValue, range: NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
}
}



