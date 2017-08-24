//
//  Model.swift
//  learnit
//
//  Created by Matthew McGuire on 6/29/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

struct cardProperties
{
    var isActive : Bool = true
    var isKnown : Bool = false
    var studyToday : Bool = false
    var faceOne : String = " "
    var faceTwo : String = " "
    var tags : String = " "
    var faceOneAsSet : Set<String>  = Set()
    var faceTwoAsSet : Set<String> = Set()
    var tagsAsSet : Set<String> = Set()
    var diffRating : Float?
    var idealInterval : Float?
    var numCorr : Int = 0
    var numIncorr : Int = 0
    var numForgot : Int = 0
    var lastAnswerCorrect : NSDate? 
}

class CardObject: NSObject {
    
    var uniqueID : String = UUID().uuidString
    var cardInfo = cardProperties()
    var timeCreated : NSDate = NSDate()
    var timeUpdated : NSDate = NSDate()
    
    func hasFacesAndTags() -> Bool
    {
        if cardInfo.faceOne.characters.count > 0 &&
            cardInfo.faceTwo.characters.count > 0 &&
            cardInfo.tags.characters.count > 0
        {
            return true
        }
        else {
            return false
        }
    }
    
    func copyCardProperties(newCard ns : CardStackManagedObject)
    {
        ns.uniqueID = uniqueID
        ns.isActive = cardInfo.isActive
        ns.isKnown = cardInfo.isKnown
        ns.timeCreated = timeCreated
        ns.timeUpdated = timeUpdated
        ns.studyToday = cardInfo.studyToday
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
