//
//  CoreDataHelper.swift
//  learnit
//
//  Created by Matthew McGuire on 8/23/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit
import CoreData

func cardObjFromCardMO(cardMO : CardStackManagedObject) -> CardObject
{
    let returnedCard = CardObject()
    returnedCard.uniqueID = cardMO.uniqueID!
    returnedCard.cardInfo.isActive = cardMO.isActive
    returnedCard.cardInfo.isKnown = cardMO.isKnown
    returnedCard.cardInfo.studyToday = cardMO.studyToday
    returnedCard.timeCreated = cardMO.timeCreated!
    returnedCard.timeUpdated = cardMO.timeUpdated!
    returnedCard.cardInfo.faceOne = getStringFromMOSet(setGlob: cardMO.faceOne as! Set<NSManagedObject>)
    returnedCard.cardInfo.faceTwo = getStringFromMOSet(setGlob: cardMO.faceTwo as! Set<NSManagedObject>)
    returnedCard.cardInfo.tags = getStringFromMOSet(setGlob: cardMO.cardToTags as! Set<NSManagedObject>)
    returnedCard.cardInfo.faceOneAsSet = getSetFromMOSet(setGlob: cardMO.faceOne as! Set<NSManagedObject>)
    returnedCard.cardInfo.faceTwoAsSet = getSetFromMOSet(setGlob: cardMO.faceTwo as! Set<NSManagedObject>)
    returnedCard.cardInfo.diffRating = cardMO.cardToStats?.difficultyRating
    returnedCard.cardInfo.idealInterval = cardMO.cardToStats?.idealInterval
    returnedCard.cardInfo.numForgot = Int((cardMO.cardToStats?.numberTimesForgotten)!)
    returnedCard.cardInfo.numIncorr = Int((cardMO.cardToStats?.numberTimesIncorrect)!)
    returnedCard.cardInfo.numCorr = Int((cardMO.cardToStats?.numberTimesCorrect)!)
    returnedCard.cardInfo.lastAnswerCorrect = cardMO.cardToStats?.lastAnsweredCorrect
    
    return returnedCard
}

func getSetFromMOSet(setGlob: Set<NSManagedObject>) -> Set<String> {
    var returnSet = Set<String>()
    for mo in setGlob
    {
        if let fmo = mo as? FaceManagedObject
        {
            returnSet.insert(fmo.faceText!)
        }
        if let fmo = mo as? TagManagedObject
        {
            returnSet.insert(fmo.tagText!)
        }
    }
    return returnSet
}

func getStringFromMOSet(setGlob: Set<NSManagedObject>) -> String {
    var returnString : String = ""
    for mo in setGlob
    {
        if returnString.characters.count > 0
        {
            returnString += ", "
        }
        if let fmo = mo as? FaceManagedObject
        {
            returnString += fmo.faceText!
        }
        if let fmo = mo as? TagManagedObject
        {
            returnString += fmo.tagText!
        }
    }
    return returnString
}

