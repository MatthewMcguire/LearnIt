//
//  ShareHint.swift
//  learnit
//
//  Created by Matthew McGuire on 8/22/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

func shareHint(hintAnswer: String, hintLevel: inout Int, answerValue: inout Float) -> String
{
    // gradually offer more detailed hints as the button is pressed
    
    let hintLength:Int = hintAnswer.characters.count
    var circumstance : String = ""
    if hintLevel == 0
    {
        circumstance = "Stage One"
    }
    else if (hintLevel == 1) && (hintLength > 3)
    {
        circumstance = "Stage Two"
    }
    else if (hintLevel == 2) && (hintLength > 5)
    {
        circumstance = "Stage Three"
    }
    else if (hintLevel == 3) && (hintLength > 8)
    {
        circumstance = "Stage Four"
    }
    else if (hintLevel == 4) && (hintLength > 15)
    {
        circumstance = "Stage Five"
    }
    else if (hintLevel == 5) && (hintLength > 15)
    {
        circumstance = "Stage Six"
    }
    
    var hintText = ""
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
    
    return hintText
}

