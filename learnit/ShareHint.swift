//
//  ShareHint.swift
//  learnit
//
//  Created by Matthew McGuire on 8/22/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

enum circumstance : Int
{
    case StageZero = 0
    case StageOne = 1
    case StageTwo = 2
    case StageThree = 3
    case StageFour = 4
}


func shareHint(hintAnswer: String, hintLevel: inout Int, answerValue: inout Float) -> String
{
    // gradually offer more detailed hints as the button is pressed
    // the function will return an empty string if there is no further hint
    // level available
    
    let hintLength:Int = hintAnswer.characters.count
    var hintText = ""
    let maxHintLength = [2,4,7,14,14]
    
    // If for some reason the hint length is not in the expected range, return nothing
    guard ((hintLevel >= 0) && (hintLevel <= 4))
        else { return hintText }
    
    // if the length of the answer is not long enough (according to maxHintLength array)
    // don't go to the next hint level
    if hintLength < maxHintLength[hintLevel]
        { return hintText }

    hintText = underscoreForLetters(hintAnswer: hintAnswer)
    
    // go to the next hint level and reduce the value of a correct answer
    hintLevel += 1
    answerValue *= 0.75
    return hintText
}

func underscoreForLetters(hintAnswer: String) -> String
{
    var returnAnswer = hintAnswer.replacingOccurrences(of: "\\w", with: "_", options: .regularExpression)
    returnAnswer = returnAnswer.replacingOccurrences(of: "\\W", with: "  ", options: .regularExpression)
    return returnAnswer
}
    /*

    
    
    switch circumstance {
    case "Stage One":
        hintLevel = 1
        for i in 0..<hintLength
        {
            // show a space where there's a space in the answer, and an _ where there's a letter in the answer
            let stri : String.Index = hintAnswer.index(hintAnswer.startIndex, offsetBy: i)
            if hintAnswer[stri] == " "
            {
                hintText += "  "
            }
            else
            {
                hintText += "_"
            }
        }
        answerValue = answerValue * 0.75
    case "Stage Two":
        hintLevel = 2
        // show the first letter of the answer
        hintText += String(hintAnswer[hintAnswer.startIndex])
        // show a space where there's a space in the answer, and an _ where there's a letter in the answer
        for i in 1..<(hintLength - 1)
        {
            let stri : String.Index = hintAnswer.index(hintAnswer.startIndex, offsetBy: i)
            if hintAnswer[stri] == " "
            {
                hintText += "  "
            }
            else
            {
                hintText += "_"
            }
        }
        // show the last letter of the answer
        hintText += String(hintAnswer[hintAnswer.index(hintAnswer.endIndex, offsetBy: -1)])
        answerValue = answerValue * 0.75
    case "Stage Three":
        hintLevel = 3
        // show the first letter of the answer
        hintText += String(hintAnswer[hintAnswer.startIndex])
        // show a space where there's a space in the answer, and an _ where there's a letter in the answer
        for i in 1..<(hintLength - 1)
        {
            let stri : String.Index = hintAnswer.index(hintAnswer.startIndex, offsetBy: i)
            // But reveal the actual letter for every third letter
            if (i % 3) == 0
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += String(hintAnswer[stri])
                }
            }
            else
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += "_"
                }
            }
        }
        // show the last letter of the answer
        hintText += String(hintAnswer[hintAnswer.index(hintAnswer.endIndex, offsetBy: -1)])
        answerValue = answerValue * 0.75
    case "Stage Four":
        hintLevel = 4
        // show the first letter of the answer
        hintText += String(hintAnswer[hintAnswer.startIndex])
        // show a space where there's a space in the answer, and an _ where there's a letter in the answer
        for i in 1..<(hintLength - 1)
        {
            let stri : String.Index = hintAnswer.index(hintAnswer.startIndex, offsetBy: i)
            // But reveal the actual letter for every third or fourth letter
            if ((i % 3) == 0) || ((i % 4) == 0)
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += String(hintAnswer[stri])
                }
            }
            else
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += "_"
                }
            }
        }
        // show the last letter of the answer
        hintText += String(hintAnswer[hintAnswer.index(hintAnswer.endIndex, offsetBy: -1)])
        answerValue = answerValue * 0.75
    case "Stage Five":
        hintLevel = 5
        // show the first letter of the answer
        hintText += String(hintAnswer[hintAnswer.startIndex])
        // show a space where there's a space in the answer, and an _ where there's a letter in the answer
        for i in 1..<(hintLength - 1)
        {
            let stri : String.Index = hintAnswer.index(hintAnswer.startIndex, offsetBy: i)
            // But reveal the actual letter for every other letter
            if ((i % 3) == 0) || ((i % 2) == 0)
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += String(hintAnswer[stri])
                }
            }
            else
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += "_"
                }
            }
        }
        // show the last letter of the answer
        hintText += String(hintAnswer[hintAnswer.index(hintAnswer.endIndex, offsetBy: -1)])
        answerValue = answerValue * 0.75
    case "Stage Six":
        hintLevel = 6
        // show the first letter of the answer
        hintText += String(hintAnswer[hintAnswer.startIndex])
        // show a space where there's a space in the answer, and an _ where there's a letter in the answer
        for i in 1..<(hintLength - 1)
        {
            let stri : String.Index = hintAnswer.index(hintAnswer.startIndex, offsetBy: i)
            // But reveal the actual letter for every other letter
            if ((i % 3) == 0) || ((i % 2) == 0) || ((i % 5) == 0)  || ((i % 7) == 0)  || ((i % 17) == 0)
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += String(hintAnswer[stri])
                }
            }
            else
            {
                if hintAnswer[stri] == " "
                {
                    hintText += "  "
                }
                else
                {
                    hintText += "_"
                }
            }
        }
        // show the last letter of the answer
        hintText += String(hintAnswer[hintAnswer.index(hintAnswer.endIndex, offsetBy: -1)])
        answerValue = answerValue * 0.75
    default:
        if loq == true {print("maximum hintage is shown!")}
    }
        if loq == true {print("Hint level is now: \(hintLevel).")}
    */


