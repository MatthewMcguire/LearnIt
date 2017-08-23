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
