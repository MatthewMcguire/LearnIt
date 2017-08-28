//
//  CoreDataDomus.swift
//  learnit
//
//  Created by Matthew McGuire on 6/27/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit
import CoreData

class CoreDataDomus: NSObject, NSFetchedResultsControllerDelegate {
    
    var manObjContext : NSManagedObjectContext!
    var currentLearner: LearnerManagedObject?
    var fetchedItems : NSFetchedResultsController<CardStackManagedObject>!
    var fetchedTagItems : NSFetchedResultsController<TagManagedObject>!
    
    
    override init()
    {
        super.init()
        self.manObjContext = persistentContainer.viewContext
        currentLearner = initUserInfo(context: manObjContext)
        saveContext()
    }
    
    
    func refreshFetchedResultsController()
    {
        let quaestioUnus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioUnus.predicate = NSPredicate(format: "isActive == YES")
        let sortKey1 = NSSortDescriptor(key: "uniqueID", ascending: true)
        quaestioUnus.sortDescriptors = [sortKey1]
        fetchedItems = NSFetchedResultsController(fetchRequest: quaestioUnus , managedObjectContext: manObjContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedItems.delegate = self
        
        do {
            try fetchedItems.performFetch()

        }
        catch
        {
            fatalError("Error fetching objects from the persistent store")
        }
    }
    
    func refreshFetchedTagsController()
    {
        let quaestioTertiusDecimus = NSFetchRequest<TagManagedObject>(entityName: "Tag")
//        quaestioTertiusDecimus.predicate = NSPredicate(format: "isActive == YES")
        let sortKey1 = NSSortDescriptor(key: "timesUsed", ascending: false)
        let sortKey2 = NSSortDescriptor(key: "tagText", ascending: true)
        quaestioTertiusDecimus.sortDescriptors = [sortKey1, sortKey2]
        fetchedTagItems = NSFetchedResultsController(fetchRequest: quaestioTertiusDecimus , managedObjectContext: manObjContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedTagItems.delegate = self
        
        do {
            try fetchedTagItems.performFetch()
            
        }
        catch
        {
            fatalError("Error fetching objects from the persistent store")
        }
    }

    
    func getUserTotalPoints() -> Float
    {
        return currentLearner!.totalPoints
    }
    
    func updateUserTotalPoints(addThese: Float)
    {
        let points = currentLearner!.totalPoints
        currentLearner!.totalPoints = points + addThese
        saveContext()
    }
   
    func addNewObj(card : CardObject)
    {
        let helper = CoreDataManagement(manObjContext: manObjContext)
        helper.newCard(card: card)

        saveContext()
        refreshFetchedTagsController()
        refreshFetchedResultsController()
    }
 
    func updateCardAnsweredCorrect(uniqueID: String, distance: Float)
    {
        let quaestioOctavus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioOctavus.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        
        do {
            
            let queryResult = try manObjContext.fetch(quaestioOctavus)
            
            if queryResult.count > 0
            {
                let resultCard : CardStackManagedObject = (queryResult.first)!
                resultCard.isKnown = true
                resultCard.studyToday = false
                if let cardStats = resultCard.cardToStats
                {
                    if cardStats.numberTimesCorrect >= 1
                    {
                        cardStats.numberTimesCorrect += 1
                    }
                    else
                    {
                        cardStats.numberTimesCorrect = 1
                    }
                    // update difficulty rating
                    cardStats.difficultyRating = max(cardStats.difficultyRating, Float(1.3))
                    let q = 5.0 - distance
                    cardStats.difficultyRating += (-0.8 + (0.28 * q) - 0.02 * q * q)
                    cardStats.difficultyRating = max(cardStats.difficultyRating, Float(1.3))
                    cardStats.difficultyRating = min(cardStats.difficultyRating, Float(2.5))
                    
                    // update ideal interval
                    switch cardStats.idealInterval
                        {
                    case 1.0:
                        cardStats.idealInterval = 3.0
                    case 0.0...1.0:
                        cardStats.idealInterval = 1.0
                    default:
                        cardStats.idealInterval *= cardStats.difficultyRating
                    }
                    
                    // update Last Answered Correct
                    cardStats.lastAnsweredCorrect = NSDate()
                }
                else
                {
                    fatalError("Couldn't fetch CardStack Stats objects from Core Data.")
                }
                saveContext()
            }
        }
        catch
        {
            fatalError("Couldn't fetch CardStack object from Core Data")
        }

    }
 
    func updateCardAnsweredINCorrect(uniqueID: String, distance: Float)
    {
        let quaestio = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestio.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        var queryResult : Array<CardStackManagedObject>
        do {
            
            queryResult = try manObjContext.fetch(quaestio)
        }
        catch
        {
            fatalError("Couldn't fetch CardStack object from Core Data")
        }
        guard queryResult.count > 0 else { return }
        let resultCard = (queryResult.first)!
        if let cardStats = resultCard.cardToStats
        {
            if resultCard.isKnown == true
            {
                cardStats.numberTimesForgotten += 1
            }
            cardStats.numberTimesIncorrect += 1
            cardStats.idealInterval = 1.0
            
            // update difficulty rating
            cardStats.difficultyRating = max(cardStats.difficultyRating, Float(1.3))
            let q = max(5.0 - distance, 0.0)
            
            cardStats.difficultyRating += (-0.8 + (0.28 * q) - 0.02 * q * q)
            cardStats.difficultyRating = max(cardStats.difficultyRating, Float(1.3))
            cardStats.difficultyRating = min(cardStats.difficultyRating, Float(2.5))
            
            resultCard.isKnown = false
            resultCard.studyToday = false
        }
        saveContext()
    }

    func numberOfSectionsInTblVw() -> Int
    {
        return fetchedItems!.sections!.count
    }
    
    func numberOfTagSections() -> Int
    {
        let returnValue = fetchedTagItems!.sections!.count
        return returnValue
    }
 
    func numberOfRowsInTblVwSection(section : Int) -> Int
    {
        return fetchedItems!.sections![section].numberOfObjects
    }
 
    func numberOfTagRows(section: Int) -> Int
    {
        let returnValue = fetchedTagItems!.sections![section].numberOfObjects
        return returnValue
    }
    
    func getCellItemInfo(indexPath : IndexPath) -> CardObject
    {
        var returnedCard : CardObject = CardObject()
        let oneCardForCellManagedObject = fetchedItems!.sections?[indexPath.section].objects?[indexPath.row]
        returnedCard = cardObjFromCardMO(cardMO: oneCardForCellManagedObject as! CardStackManagedObject)
        return returnedCard
    }
    
    func getCardNameForCell(indexPath : IndexPath) -> String
    {
        var returnString : String
        let oneCardForCellManagedObject = fetchedItems!.sections?[indexPath.section].objects?[indexPath.row] as! CardStackManagedObject
        let onCardForCellMOFaceOne = oneCardForCellManagedObject.faceOne as! Set<FaceManagedObject>
        returnString = getStringFromMOSet(setGlob: onCardForCellMOFaceOne)
        return returnString
    }
    
    func getCardTagsForCell(indexPath : IndexPath) -> String
    {
        var returnString : String
        let oneCardForCellManagedObject = fetchedItems!.sections?[indexPath.section].objects?[indexPath.row] as! CardStackManagedObject
        let onCardForCellMOTags = oneCardForCellManagedObject.cardToTags as! Set<TagManagedObject>
        returnString = getStringFromMOSet(setGlob: onCardForCellMOTags)
        return returnString
    }
    
    func getTagTextForCell(indexPath : IndexPath) -> String
    {
        var returnString : String
        let oneTagForTagManagedObject = fetchedTagItems!.sections?[indexPath.section].objects?[indexPath.row] as! TagManagedObject
        returnString = oneTagForTagManagedObject.tagText!
        return returnString
    }
    
    func getTagCountForCell(indexPath : IndexPath) -> Int32
    {
        var returnValue : Int32
        let oneTagForTagManagedObject = fetchedTagItems!.sections?[indexPath.section].objects?[indexPath.row] as! TagManagedObject
        returnValue = oneTagForTagManagedObject.timesUsed
        return returnValue
    }
    
    func getEnabledStateForTag(indexPath: IndexPath) -> Bool
    {
        var returnValue : Bool
        let oneTagForTagManagedObject = fetchedTagItems!.sections?[indexPath.section].objects?[indexPath.row] as! TagManagedObject
        returnValue = oneTagForTagManagedObject.enabled
        return returnValue
    }
    func tagEnabled(set: Bool, indexPath: IndexPath)
    {
        // first get the tag
        let tagToUpdate = fetchedTagItems!.sections?[indexPath.section].objects?[indexPath.row] as! TagManagedObject
        
        // second, set the tag object enabled flag
        tagToUpdate.enabled = set
        
        // third, set the card active state based on the tag status change above
        setCardActiveStateByTagActiveState(tag: tagToUpdate, state: set)
        refreshFetchedResultsController()
    }
    
    func setCardActiveStateByTagActiveState(tag : TagManagedObject, state : Bool)
    {
        let cardsForTagManagedObject = tag.tagToCards as! Set<CardStackManagedObject>
        for card in cardsForTagManagedObject
        {
            // logic: any card with this tag should be made inactive, since the tag is disabled
            guard state == true
                else
            {
                card.isActive = false
                continue
            }
        
            // logic: for each card, set to active if all its tags are now active
            let itsTags = card.cardToTags
            var activateIt = true
            for aTag in itsTags!
            {
                if (aTag as! TagManagedObject).enabled == false
                {
                    activateIt = false
                }
            }
            card.isActive = activateIt
        }
        saveContext()
    }
    

    func getCardWithID(uniqueID: String) -> CardObject
    {
        var returnedCard : CardObject = CardObject()
        
        let quaestioSeptimus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioSeptimus.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)

        do {
            
            let queryResult = try manObjContext.fetch(quaestioSeptimus)
            
            if queryResult.count > 0
            {
                let resultCard = queryResult.first
                returnedCard = cardObjFromCardMO(cardMO: resultCard!)
            }
        }
        catch
        {
            fatalError("Couldn't fetch CardStack object from Core Data")
        }
        return returnedCard
    }
 
 
    // MARK: TODO - this function doesn't reuse existing face or tag items (or maintain their use stats) -
    func updateItem(indexPath : IndexPath, withValues : CardObject)
    {
        let oneCard : CardStackManagedObject = fetchedItems.sections![indexPath.section].objects![indexPath.row] as! CardStackManagedObject
        oneCard.timeUpdated = NSDate()
        
         // UPDATE FACE ONE
        var stringSet = Set(withValues.cardInfo.faceOne.components(separatedBy: ","))
        var setOfFaces = Set<FaceManagedObject>()
         // for each string, create a FaceMO Managed Obj and add to the set
        for faceOneValue in stringSet
        {
            let newFaceObject = NSEntityDescription.insertNewObject(forEntityName: "Face", into: manObjContext!) as! FaceManagedObject
            newFaceObject.faceText = faceOneValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            setOfFaces.insert(newFaceObject)
        }
        oneCard.faceOne = setOfFaces as NSSet
        
        // UPDATE FACE TWO
        stringSet = Set(withValues.cardInfo.faceTwo.components(separatedBy: ","))
        setOfFaces.removeAll()
        setOfFaces = Set<FaceManagedObject>()
        // for each string, create a FaceMO Managed Obj and add to the set
        for faceTwoValue in stringSet
        {
            let newFaceObject = NSEntityDescription.insertNewObject(forEntityName: "Face", into: manObjContext!) as! FaceManagedObject
            newFaceObject.faceText = faceTwoValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            setOfFaces.insert(newFaceObject)
        }
        oneCard.faceTwo = setOfFaces as NSSet
        
        // UPDATE TAGS
        stringSet = Set(withValues.cardInfo.tags.components(separatedBy: ","))
        setOfFaces.removeAll()
        var setOfTags = Set<TagManagedObject>()
        // for each string, create a FaceMO Managed Obj and add to the set
        for tagValue in stringSet
        {
            let newTagObject = NSEntityDescription.insertNewObject(forEntityName: "Tag", into: manObjContext!) as! TagManagedObject
            newTagObject.tagText = tagValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            setOfTags.insert(newTagObject)
        }
        oneCard.cardToTags = setOfTags as NSSet
        saveContext()
        refreshFetchedResultsController()
    }
 
    func deleteItem(indexPath : IndexPath)
    {
        // this is the item in the fetched results controller that will be deleted from Core Data
        let oneCard = fetchedItems.sections?[indexPath.section].objects?[indexPath.row] as! CardStackManagedObject
        
        
        // before deleting, we should decrement the number of times each of its tags has been used
//        let quaestioQuartusDecimus = NSFetchRequest<TagManagedObject>(entityName: "Tag")
        let aSetOfTags = oneCard.cardToTags
        // for each tag in the set of strings, look for a corresponding TagMO and link it, or make a new one if not
        for aTag in aSetOfTags!
        {
            let at = aTag as! TagManagedObject
            at.timesUsed -= 1
        }
        saveContext()

        
        manObjContext.delete(oneCard as NSManagedObject)
        saveContext()
        refreshFetchedTagsController()
    }
 
 
    // MARK: - Core Data stack
 
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "learnit")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
