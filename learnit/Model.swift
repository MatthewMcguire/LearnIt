//
//  Model.swift
//  learnit
//
//  Created by Matthew McGuire on 6/29/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class CardObject: NSObject {
    
    var uniqueID : String
    var isActive : Bool?
    var isKnown : Bool?
    var studyToday : Bool?
    var timeCreated : NSDate?
    var timeUpdated : NSDate?
    var faceOne : String?
    var faceTwo : String?
    var tags : String?
    var faceOneAsSet : Set<String>?
    var faceTwoAsSet : Set<String>?
    var tagsAsSet : Set<String>?
    var diffRating : Float?
    var idealInterval : Float?
    var numCorr : Int?
    var numIncorr : Int?
    var numForgot : Int?
    var lastAnswerCorrect : NSDate?
    
    override init() {
        
        let uuid = UUID()
        let uuidStr = uuid.uuidString
        uniqueID = uuidStr
        isActive = true
        isKnown = false
        studyToday = false
        timeCreated = NSDate()
        timeUpdated = NSDate()
        faceOne = " "
        faceTwo = " "
        tags = " "
        faceOneAsSet = Set()
        faceOneAsSet = Set()
        tagsAsSet = Set()
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
