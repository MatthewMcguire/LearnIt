//
//  Model.swift
//  learnit
//
//  Created by Matthew McGuire on 6/29/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class CardObject: NSObject {
    
    var uniqueID : String = UUID().uuidString
    var isActive : Bool = true
    var isKnown : Bool = false
    var studyToday : Bool = false
    var timeCreated : NSDate = NSDate()
    var timeUpdated : NSDate = NSDate()
    var faceOne : String = " "
    var faceTwo : String = " "
    var tags : String = " "
    var faceOneAsSet : Set<String>  = Set()
    var faceTwoAsSet : Set<String> = Set()
    var tagsAsSet : Set<String> = Set()
    var diffRating : Float?
    var idealInterval : Float?
    var numCorr : Int?
    var numIncorr : Int?
    var numForgot : Int?
    var lastAnswerCorrect : NSDate?
    
    func hasFacesAndTags() -> Bool
    {
        if faceOne.characters.count > 0 &&
            faceTwo.characters.count > 0 &&
            tags.characters.count > 0
        {
            return true
        }
        else
        {
            return false
        }
    }
    
}

class TagObject: NSObject {
    var tagText : String?
    var enabled : Bool?
    var timesUsed : Int?
    
    override init() {
        tagText = ""
        enabled = true
        timesUsed = 0
    }
    
}
