//
//  LanguageHelperFunctions.swift
//  learnit
//
//  Created by Matthew McGuire on 8/23/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

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
    
    let (t, s) = (aStr.characters, bStr.characters)
    
    let empty = Array<Int>(repeating:0, count: s.count)
    var last = [Int](0...s.count)
    
    for (i, tLett) in t.enumerated() {
        var cur = [i + 1] + empty
        for (j, sLett) in s.enumerated() {
            cur[j + 1] = tLett == sLett ? last[j] : min(last[j], last[j + 1], cur[j])+1
        }
        last = cur
    }
    return last.last!
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

func mediumDateFormat() -> DateFormatter
{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale(identifier:"en_US")
    return dateFormatter
}
/*
private extension String {
    
    subscript(index: Int) -> Character {
        return self[startIndex.advancedBy(index)]
    }
    
    subscript(range: Range<Int>) -> String {
        let start = startIndex.advancedBy(range.startIndex)
        let end = startIndex.advancedBy(range.endIndex)
        return self[start..<end]
    }
}

extension String {
    
    func levenshtein(cmpString: String) -> Int {
        let (length, cmpLength) = (characters.count, cmpString.characters.count)
        var matrix = Array(
            count: cmpLength + 1,
            repeatedValue: Array(
                count: length + 1,
                repeatedValue: 0
            )
        )
        
        for m in 1..<cmpLength {
            matrix[m][0] = matrix[m - 1][0] + 1
        }
        
        for n in 1..<length {
            matrix[0][n] = matrix[0][n - 1] + 1
        }
        
        for m in 1..<(cmpLength + 1) {
            for n in 1..<(length + 1) {
                let penalty = self[n - 1] == cmpString[m - 1] ? 0 : 1
                let (horizontal, vertical, diagonal) = (matrix[m - 1][n] + 1, matrix[m][n - 1] + 1, matrix[m - 1][n - 1])
                matrix[m][n] = min(horizontal, vertical, diagonal + penalty)
            }
        }
        
        return matrix[cmpLength][length]
    }
}
 */
