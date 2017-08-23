//
//  CoreDataManagement.swift
//  learnit
//
//  Created by Matthew McGuire on 8/23/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManagement: NSObject {

    var context : NSManagedObjectContext
    
    init(manObjContext: NSManagedObjectContext) {
        self.context = manObjContext
    }

    fileprivate func getFaceObj(aFace: String, query : NSFetchRequest<FaceManagedObject>, aSetOfFaces: inout Set<FaceManagedObject>) throws {
        var trimmedFace = aFace.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        trimmedFace = trimmedFace.replacingOccurrences(of: "##", with: ",")
        query.predicate = NSPredicate(format: "faceText like[cd] %@", trimmedFace)
        
        let faceQueryResult = try context.fetch(query)
        if faceQueryResult.count == 0 {
            aSetOfFaces.insert(makeNewFaceObj(trimmedFace))
        }
        else {
            aSetOfFaces.insert(reuseFaceObj(faceQueryResult))
        }
    }
    
    fileprivate func makeNewFaceObj(_ trimmedFace: String) -> FaceManagedObject {
        let newFaceObject = NSEntityDescription.insertNewObject(forEntityName: "Face", into: context) as! FaceManagedObject
        newFaceObject.faceText = trimmedFace
        newFaceObject.enabled = true
        newFaceObject.timesUsed = 1
        return newFaceObject
}
    
    fileprivate func reuseFaceObj(_ faceQueryResult: [FaceManagedObject]) -> FaceManagedObject {
        let toUpdate : FaceManagedObject = faceQueryResult.first!
        var scratchValue = toUpdate.timesUsed
        scratchValue += 1
        toUpdate.timesUsed = scratchValue
        return toUpdate
    }
    
    fileprivate func getCommonCards(faceObjects: Set<FaceManagedObject>, newCard: CardStackManagedObject) -> Set<CardStackManagedObject> {
        var commonCards = Set<CardStackManagedObject>()
        for fo in faceObjects {
            if let assocCardsArray = fo.toCardsSideOne?.allObjects {
                let assocCardsSet = Set<CardStackManagedObject>(assocCardsArray as! [CardStackManagedObject])
                if assocCardsSet.count > 0 {
                    if commonCards.isEmpty {
                        commonCards = commonCards.union(assocCardsSet)
                    }
                    else {
                        commonCards = commonCards.intersection(assocCardsSet)
                    }
                }
            }
            if let assocCardsArray = fo.toCardsSideTwo?.allObjects {
                let assocCardsSet = Set<CardStackManagedObject>(assocCardsArray as! [CardStackManagedObject])
                if assocCardsSet.count > 0 {
                    if commonCards.isEmpty {
                        commonCards = commonCards.union(assocCardsSet)
                    }
                    else {
                        commonCards = commonCards.intersection(assocCardsSet)
                    }
                }
            }
        }
        
        // now we have a set of cardstack Objects with identical face one and face two objects
        // first, throw out the newly-added object if its in the set.
        commonCards.remove(newCard)
        if commonCards.count > 1
        {
            fatalError("We have a problem. There are two existing cards with the same face one and face two")
        }
        return commonCards
    }
    
    fileprivate func getTagObj(_ tagQueryResult: [TagManagedObject], _ trimmedTag: String, _ aSetOfTags: inout Set<TagManagedObject>) {
        if tagQueryResult.count == 0 {
            let newTagObject = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context) as! TagManagedObject
            newTagObject.tagText = trimmedTag
            newTagObject.enabled = true
            newTagObject.timesUsed = 1
            aSetOfTags.insert(newTagObject)
        }
        else {
            let toUpdate : TagManagedObject = tagQueryResult.first!
            if !aSetOfTags.contains(toUpdate) {
                var scratchValue = toUpdate.timesUsed
                scratchValue += 1
                toUpdate.timesUsed = scratchValue
                aSetOfTags.insert(toUpdate)
            }
            
            print ("Tag: \(String(describing: toUpdate.tagText)) is used \(toUpdate.timesUsed) times")
        }
    }
    
    fileprivate func useExistingCard(_ cardsInCommon: Set<CardStackManagedObject>, _ aSet: inout Set<String>, _ card: CardObject) {
        if let oldCard = cardsInCommon.first {
            // create the set of given tags for the newly-added card
            aSet.removeAll()
            aSet = Set(card.cardInfo.tags.components(separatedBy: ","))
            
            // prepare to look for existing tag objects
            let quaestioQuartus = NSFetchRequest<TagManagedObject>(entityName: "Tag")
            
            do {
                // begin with the set of existing tag objects for the old card
                var aSetOfTags = Set<TagManagedObject>(oldCard.cardToTags as! Set)
                
                // for each tag in the set of strings, look for any TagMO and insert it into the set
                // or, if it doesn't already exist, make a new one and insert it into the set as well
                for aTag in aSet {
                    var trimmedTag = aTag.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                    trimmedTag = trimmedTag.replacingOccurrences(of: "##", with: ",")
                    quaestioQuartus.predicate = NSPredicate(format: "tagText like[cd] %@", trimmedTag)
                    
                    let tagQueryResult = try context.fetch(quaestioQuartus)
                    getTagObj(tagQueryResult, trimmedTag, &aSetOfTags)
                }
                oldCard.cardToTags = aSetOfTags as NSSet
                
            }
            catch {
                fatalError("Couldn't fetch Tag objects from Core Data")
            }
        }
    }
    
    func newCard(card : CardObject)
    {
        let newCard = NSEntityDescription.insertNewObject(forEntityName: "CardStack", into: context) as! CardStackManagedObject
        
        // Break up elements of Face One and add as distinct MOs
        // - Divide the full string into a set of strings
        var aSet : Set<String> = Set(card.cardInfo.faceOne.components(separatedBy: ","))
        
        // create a set of FacesMO objects
        // prepare to look for existing FaceMO objects
        let quaestioQuartusDecius = NSFetchRequest<FaceManagedObject>(entityName: "Face")
        
        // for each tag in the set of strings, look for a corresponding TagMO and link it, or make a new one if not
        do {
            var aSetOfFaces = Set<FaceManagedObject>()
            for aFace in aSet {
                try getFaceObj(aFace: aFace, query: quaestioQuartusDecius, aSetOfFaces: &aSetOfFaces)
            }
            // add the set of FaceMO Managed Objects to the card
            newCard.faceOne = aSetOfFaces as NSSet
            
            // Do the same thing for Face Two
            aSet.removeAll()
            aSet = Set(card.cardInfo.faceTwo.components(separatedBy: ","))
            aSetOfFaces.removeAll()
            for aFace in aSet {
                try getFaceObj(aFace: aFace, query: quaestioQuartusDecius, aSetOfFaces: &aSetOfFaces)
            }
            // add the set of FaceMO Managed Objects to the card
            newCard.faceTwo = aSetOfFaces as NSSet
            
        }
        catch {
            fatalError("Couldn't fetch Faces objects from Core Data")
        }
        
        // Before going further, check if there is already another card with the same face one and face two connections
        // If so, this card is a duplicate and shouldn't be added. Instead, the existing card's tags should be a union
        // of those tags it already has and the ones in the 'new card to be added'
        
        // Goal: find any cardstack item with the same face one and face two objects
        // It seems the simplest way to do this is to get the set of cardsstack objects that are linked
        // to each face object of the 'newly added'. Then if the intersection of these sets has a Card *other* than
        // the newly added one, it is a duplicate. In this case, update the tags of the found Card as needed and move on.
        
        // create a set of face objects to test
        var faceObjects = Set<FaceManagedObject>(newCard.faceOne! as! Set)
        faceObjects = faceObjects.union(newCard.faceTwo! as! Set)
        
        // create a set to hold the intersection of all associated Cardstack objects
        // then fill it by looking at the toCardsSideOne and toCardsSideTo sets associated
        // with these
        let cardsInCommon = getCommonCards(faceObjects : faceObjects, newCard : newCard)
        
        // if there is a card remaining in the set, use it instead of creating a new one
        if cardsInCommon.count > 0 {
            context.delete(newCard)
            useExistingCard(cardsInCommon, &aSet, card)
            negozioGrande!.saveContext()
            negozioGrande!.refreshFetchedTagsController()
            negozioGrande!.refreshFetchedResultsController()
            return
        }
        
        
        // connect existing or add new tags to the card object
        // create the set of given tags
        aSet.removeAll()
        aSet = Set(card.cardInfo.tags.components(separatedBy: ","))
        
        // prepare to look for existing tag objects
        let quaestioQuartus = NSFetchRequest<TagManagedObject>(entityName: "Tag")
        
        do {
            var aSetOfTags = Set<TagManagedObject>()
            // for each tag in the set of strings, look for a corresponding TagMO and link it, or make a new one if not
            for aTag in aSet {
                var trimmedTag = aTag.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                trimmedTag = trimmedTag.replacingOccurrences(of: "##", with: ",")
                quaestioQuartus.predicate = NSPredicate(format: "tagText like[cd] %@", trimmedTag)
                
                let tagQueryResult = try context.fetch(quaestioQuartus)
                if tagQueryResult.count == 0 {
                    let newTagObject = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: context) as! TagManagedObject
                    newTagObject.tagText = trimmedTag
                    newTagObject.enabled = true
                    newTagObject.timesUsed = 1
                    aSetOfTags.insert(newTagObject)
                }
                else {
                    let toUpdate : TagManagedObject = tagQueryResult.first!
                    var scratchValue = toUpdate.timesUsed
                    scratchValue += 1
                    toUpdate.timesUsed = scratchValue
                    aSetOfTags.insert(toUpdate)
                    print ("Tag: \(String(describing: toUpdate.tagText)) is used \(toUpdate.timesUsed) times")
                }
            }
            newCard.cardToTags = aSetOfTags as NSSet
            
        }
        catch {
            fatalError("Couldn't fetch Tag objects from Core Data")
        }
        
        // add the set of tags to the new card
        newCard.uniqueID = card.uniqueID
        newCard.isActive = card.cardInfo.isActive
        newCard.isKnown = card.cardInfo.isKnown
        newCard.timeCreated = card.timeCreated
        newCard.timeUpdated = card.timeUpdated
        newCard.studyToday = card.cardInfo.studyToday
        
        // create a set of empty stats for the card
        let newStatsObject = NSEntityDescription.insertNewObject(forEntityName: "CardStats", into: context) as! CardStatsManagedObject
        newStatsObject.numberTimesIncorrect = 0
        newStatsObject.numberTimesForgotten = 0
        newStatsObject.numberTimesCorrect = 0
        newStatsObject.difficultyRating = 1.3
        newStatsObject.idealInterval = 0.1 // a card, once learned, should be repeated the next day
        newCard.cardToStats = newStatsObject
    }
}