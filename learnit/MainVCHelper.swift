//
//  MainVCHelper.swift
//  learnit
//
//  Created by Matthew McGuire on 8/25/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

struct userState {
    var maxCardsInHand: Int = 5
    var correctAnswerShownPause: Float = 5.0
    var maxAnswerValue: Float = 10.0
    var hintAnswer: String = ""
    var currentPlaceInQueue: Int = 0
}

struct buttonParams {
    let borderWidth : CGFloat = 2.5
    let cornerRadius : CGFloat = 9.0
    let fieldBorderWidth : CGFloat = 1.5
}

struct bOfVenusColors {
    let green = UIColor.init(red: (168.0/255), green: (192.0/255), blue: (168.0/255), alpha: 1.0)
    let red = UIColor.init(red: (212.0/255), green: (126.0/255), blue: (115.0/255), alpha: 1.0)
    let blue = UIColor.init(red: (120.0/255), green: (144.0/255), blue: (144.0/255), alpha: 1.0)
    let dark = UIColor.init(red: (48.0/255), green: (24.0/255), blue: (24.0/255), alpha: 1.0)
    let beige = UIColor.init(red: (240.0/255), green: (240.0/255), blue: (216.0/255), alpha: 1.0)
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
func animateResponse(_ colr: UIColor,_  messageLabel: UILabel,_ feedbackView: UIView, _ correctAnswerShownPause: Float)
{
    feedbackView.alpha = 1.0
    messageLabel.backgroundColor = UIColor.white
    feedbackView.backgroundColor = UIColor.white
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options:UIViewAnimationOptions.curveEaseInOut, animations: {
        messageLabel.backgroundColor = colr
        feedbackView.backgroundColor = colr
    }, completion: nil)
    UIView.animate(withDuration: TimeInterval(correctAnswerShownPause), delay: 0.5, options:UIViewAnimationOptions.curveEaseInOut, animations: {
        feedbackView.alpha = 0.0
    }, completion: nil)
}

func animateShowCard(_  t: String,_ f: SmartLanguageUITextField)
{
    UIView.animate(withDuration: 1.5, delay: 0.5, options:UIViewAnimationOptions.curveEaseInOut, animations: {
        f.text = t
    }, completion: nil)
}

func assessResponse(_ AnswerField : SmartLanguageUITextField, _ currentCard : CardObject, _ currentAnswerValue: inout Float) -> Float
{
    let givenAnswer = AnswerField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    if givenAnswer?.characters.count == 0
    {
        // a negative number indicates an incorrect answer
        return -1000.0
    }
    var closestBestAnswer = "                 "
    // calculate distance from a correct answer
    var shortestDistance = 1000 // to begin, obviously way higher than any plausible input
    for aCorrectAnswer in currentCard.cardInfo.faceTwoAsSet
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
        return Float(shortestDistance)
    }
    // a negative number indicates an incorrect answer
    return (Float(shortestDistance) * -1.0)
}

func buttonAppearance(_ buttnsType1: Array<UIButton>, _ buttnsType2: Array<UIButton>)
{
    let bov = bOfVenusColors()
    let bp = buttonParams()
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
func labelTextColor(_ label: Array<UILabel>, _ colr: UIColor )
{
    for l in label
    {
        l.textColor = colr
    }
}

func  setLabelText(_ labels: [UILabel],_ text: String)
{
    for l in labels  {
        l.text = text
    }
}


func updateForPointsIndicator(_ c: Float) -> String
{
    let ptsString = String(format: "for %.1f points", c)
    return ptsString
}

func setEnableButtons(_ uiObj: Array<UIButton>,_ enable: Bool)
{
    for s in uiObj
    {
        s.isEnabled = enable
    }
}

func updateTotalPoints() -> String
{
    let totalPoints = getUserTotalPoints()
    let ptsString = String(format: "%.1f pts.", totalPoints)
    return ptsString
}

func updateCounter() -> String
{
    // obtain the total number of active cards and the number to
    // review or learn today, and show in the 'cards known' label
    
    let numCards = howManyActiveCards(context: negozioGrande!.manObjContext)
    let numKnownCards = howManyActiveKnownCards(context: negozioGrande!.manObjContext)
    let counterLabelText = "known: \(numKnownCards)/\(numCards)"
    return counterLabelText
}


func updatePlaceInQueue(_ oggiQueue: Array<String>,_ state: userState) -> userState
{
    var stateNow = state
    let todaysQueue = oggiQueue
    if todaysQueue.count > 0
    {
        stateNow.currentPlaceInQueue += 1
        if stateNow.currentPlaceInQueue > (todaysQueue.count - 1) || (stateNow.currentPlaceInQueue >= stateNow.maxCardsInHand)
        {
            stateNow.currentPlaceInQueue = 0
        }
    }
    return stateNow
}

func refreshLearnerPreferences(_ currentAnswerValue: inout Float) -> userState
{
    var stateNow = userState()
    if let currentL = negozioGrande?.currentLearner  {
        stateNow.maxCardsInHand = Int(currentL.maxCardsInHand)
        stateNow.correctAnswerShownPause = currentL.correctAnswerShownPause
        currentAnswerValue = currentL.maximumAnswerValue
        stateNow.maxAnswerValue = currentL.maximumAnswerValue
    }
    return stateNow
}

