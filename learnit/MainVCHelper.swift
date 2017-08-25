//
//  MainVCHelper.swift
//  learnit
//
//  Created by Matthew McGuire on 8/25/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

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

func assessResponse(_ AnswerField : SmartLanguageUITextField, _ currentCard : CardObject, _ currentAnswerValue: inout Float) -> Float
{
    let givenAnswer = AnswerField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    if givenAnswer?.characters.count == 0
    {
        // a negative number indicates an incorrect answer
        return -1000.0
    }
    var closestBestAnswer : String = "                 "
    // calculate distance from a correct answer
    var shortestDistance = 1000 // to begin, obviously way higher than any plausible input
    let possibleAnswers = currentCard.cardInfo.faceTwoAsSet
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
        return Float(shortestDistance)
    }
    else
    {
        // a negative number indicates an incorrect answer
        return (Float(shortestDistance) * -1.0)
    }
}

