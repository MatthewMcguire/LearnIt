//
//  ShareHint.swift
//  learnit
//
//  Created by Matthew McGuire on 8/22/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//


func shareHint(hintAnswer: String, hintLevel: inout Int, answerValue: inout Float) -> String
{
    // gradually offer more detailed hints as the button is pressed
    // the function will return an empty string if there is no further hint
    // level available
    
    let hintLength:Int = hintAnswer.characters.count
    var hintText = ""
    let minHintLength = [0,3,5,6,9,13]
    
    // If for some reason the hint length is not in the expected range, return nothing
    guard ((hintLevel >= 0) && (hintLevel < 6))
        else { return hintText }
    
    // if the length of the answer is not long enough (according to maxHintLength array)
    // don't go to the next hint level
    if hintLength < minHintLength[hintLevel]
        { return hintText }

    
    // generate the hint to be shared with the learner
    hintText = revealLetters(answer: hintAnswer, level: hintLevel)
    // broaden the spaces for clarity in the hints
    hintText = hintText.replacingOccurrences(of: "\\W", with: "  ", options: .regularExpression)
    
    // go to the next hint level and reduce the value of a correct answer
    hintLevel += 1
    answerValue *= 0.75
    return hintText
}

fileprivate func underscoreForLetters(hintAnswer: String) -> String
{
    var returnAnswer = hintAnswer.replacingOccurrences(of: "\\w", with: "_", options: .regularExpression)
    returnAnswer = returnAnswer.replacingOccurrences(of: "\\W", with: " ", options: .regularExpression)
    return returnAnswer
}


fileprivate func revealLetters(answer : String, level : Int) -> String
{
    var hintShown = underscoreForLetters(hintAnswer: answer)
    if level == 0 { return hintShown }
    
    // reveal the first and last letters of the answer
    hintShown = String(hintShown.dropLast().dropFirst())
    hintShown.insert(answer[answer.startIndex], at: hintShown.startIndex)
    hintShown.insert(answer[answer.index(answer.endIndex, offsetBy: -1)], at: hintShown.endIndex)
    if level == 1 {return hintShown }

    for i in 1..<(answer.characters.count - 1)
    {
        showFactored(answer, i, level, &hintShown)
    }
    return hintShown
}

fileprivate func showFactored(_ answer: String, _ i: Int, _ level: Int, _ hintShown: inout String) {
    let reveal = [2 : [3], 3 : [3,2], 4 : [3,2,5], 5 : [3,2,5,7,17]]
    let stri : String.Index = answer.index(answer.startIndex, offsetBy: i)
    let factors = reveal[level]!
    for f in factors
    {
        if (i % f) == 0
        {
            hintShown.remove(at: stri)
            hintShown.insert(answer[stri], at: stri)
        }
    }
}
