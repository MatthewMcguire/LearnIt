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
        initUserInfo()
    }
    
    
    func refreshFetchedResultsController()
    {
        if loq == true {print("Refreshing the fetched results controller (i.e. list of all active cards)")}
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
        if loq == true {print("Obtaining a fetched results controller of Tag items")}
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
    
    func initUserInfo()
    {
        if loq == true {print("Looking in Core Data for a learner object...")}
        let quaestioTertius = NSFetchRequest<NSFetchRequestResult>(entityName: "Learner")
        do {
            let queryResult = try manObjContext?.fetch(quaestioTertius) as! [LearnerManagedObject]
            if queryResult.count == 0
            {
                // create a new Learner Object
                let aNewLearner = NSEntityDescription.insertNewObject(forEntityName: "Learner", into: manObjContext!) as! LearnerManagedObject
                aNewLearner.name = "Matthew"
                aNewLearner.totalPoints = 0.0
                aNewLearner.daysActive = 0
                aNewLearner.studyTodayLastUpdated = NSDate.distantPast as NSDate
                aNewLearner.correctAnswerShownPause = 3.5
                aNewLearner.maxCardsInHand = 20
                aNewLearner.maximumAnswerValue = 10.0
                currentLearner = aNewLearner
                saveContext()
                if loq == true {print("\tNo learner found, so creating a new one with default settings.")}
            }
            else
            {
                currentLearner = queryResult.first
                if loq == true {print("\tFound and loaded a learner.")}
            }
        }
        catch
        {
            fatalError("Couldn't fetch learner info from Core Data")
        }

    }
    func updateUserInfo()
    {
        if let currentIdentity = currentLearner
        {
            let quaestioNull = NSFetchRequest<LearnerManagedObject>(entityName: "Learner")
            quaestioNull.predicate = NSPredicate(format: "name == %@", currentIdentity.name!)
            do
            {
                let queryResult = try manObjContext?.fetch(quaestioNull)
                if queryResult?.count != 0
                {
                    let learner = queryResult?.first!
                    learner?.correctAnswerShownPause = currentIdentity.correctAnswerShownPause
                    learner?.maxCardsInHand = currentIdentity.maxCardsInHand
                    learner?.maximumAnswerValue = currentIdentity.maximumAnswerValue
                    saveContext()
                    if loq == true {print("Updating learner settings.")}
                }
                else
                {
                    if loq == true {print("No learner found, sorry!")}
                }
            }
            catch
            {
                fatalError("Couldn't find the learner object in Core Data.")
            }
            
        }
    }
    
    
    func updateStudyToday() -> Bool
    {
        // 1) Search for cards that should be added to today's queue
        // 2) Add them to the queue
        // 3) Return true if any such cards were found and added.
        if loq == true {print("Updating the list of which cards should be studied today...")}
        var cardsAddedToQueue = false
        if currentLearner != nil
        {
            // if a learner has never had his 'study today' flag checked... 
            // (i.e. this function has never been executed)
            if currentLearner!.studyTodayLastUpdated == nil
            {
                // set the flag to today's date
                currentLearner!.studyTodayLastUpdated = NSDate()
                currentLearner!.daysActive = currentLearner!.daysActive + 1
                cardsAddedToQueue = updateStudyTodayFlagOnCards()
                if loq == true {print("\tThis update is occuring for the first time for this learner.")}
            }
            else
            {
                // If the studyTodayLastUpdated value was at least a day ago,
                // update the queue with updateStudyTodayFlagOnCards()
                let howLongSince = -1.0 * (currentLearner?.studyTodayLastUpdated!.timeIntervalSinceNow)!
                let sixteenHoursInSeconds = 16 * 60 * 60
                if loq == true {print("\tIt's been \(Int(howLongSince)) seconds since the Study Today queue was updated.")}
                if Int(howLongSince) > sixteenHoursInSeconds
                {
                    currentLearner!.studyTodayLastUpdated = NSDate()
                    currentLearner!.daysActive = currentLearner!.daysActive + 1
                    cardsAddedToQueue = updateStudyTodayFlagOnCards()
                    if loq == true {print("\tSince it's been more than sixteen hours, the queue was updated.")}
                }
            }
        }
        saveContext()
        return cardsAddedToQueue
    }
    
    func updateStudyTodayFlagOnCards() -> Bool
    {
        var cardsAddedToQueue = false
        
        let quaestioDuoDecimus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioDuoDecimus.predicate = NSPredicate(format: "(isKnown == YES) AND (isActive == YES) AND (studyToday == NO)")
        if loq == true {print("\tLooking through active, known cards not currently marked as 'study today'.")}
        do {
//              if a card is currently Active, Known, and marked as StudyToday = NO,...
//              and if the date it was last answered correctly plus its ideal interval falls today or earlier,
//              then mark the card as StudyToday = YES
            let queryResult = try manObjContext?.fetch(quaestioDuoDecimus)
            let secondsInOneDay : TimeInterval = (60.0 * 60.0 * 24.0)
            for card:CardStackManagedObject in queryResult!
            {
                let statsForCard : CardStatsManagedObject = card.cardToStats!
                var shouldStudyNext : NSDate?
                if let lastCorrect = statsForCard.lastAnsweredCorrect
                {
                     shouldStudyNext = lastCorrect.addingTimeInterval(secondsInOneDay * TimeInterval( statsForCard.idealInterval))
                }
                else
                {
                    shouldStudyNext = NSDate()
                }
               
                if loq == true {print("\tCard \(String(describing: card.uniqueID)) should be studied: \(String(describing: shouldStudyNext))")}
                // shouldStudyNext is the NSDate value for the ideal study-it-again for the card.
                // if that value is sometime 'today' or it is previous to 'right now' the card is marked as studyToday = true
                if (NSCalendar.current.isDateInToday(shouldStudyNext! as Date) == true) || (shouldStudyNext!.compare(Date()) != ComparisonResult.orderedDescending)
                {
                    card.studyToday = true
                    cardsAddedToQueue = true
                    if loq == true {print("\t\t...and it has been marked as one needing to be studied today.")}
                }
            }
            saveContext()
        }
        catch
        {
            fatalError("Error fetching objects from the persistent store")
        }
        return cardsAddedToQueue
    }
    
    func getUserTotalPoints() -> Float
    {
        return currentLearner!.totalPoints
    }
    
    func updateUserTotalPoints(addThese: Float)
    {
        if loq == true {print("Adding \(addThese) points to the learner's total.")}
        let points = currentLearner!.totalPoints
        currentLearner!.totalPoints = points + addThese
        saveContext()
    }
    
    func howManyActiveCards () -> Int
    {
        var numCards : Int = 0
        let quaestioUnDecimus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioUnDecimus.predicate = NSPredicate(format: "(isActive == YES)")
        quaestioUnDecimus.resultType = NSFetchRequestResultType.countResultType
        do {
            numCards = try manObjContext.count(for: quaestioUnDecimus)
            if loq == true {print("There are \(numCards) active cards.")}
        }
        catch
        {
            fatalError("Couldn't fetch CardStack count result from Core Data")
        }
        return numCards
    }
 
    func howManyActiveKnownCards() -> Int
    {
        var numCards : Int = 0
        let quaestioSecundus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioSecundus.predicate = NSPredicate(format: "(isActive == YES) AND (isKnown == YES)")
        quaestioSecundus.resultType = NSFetchRequestResultType.countResultType
        do {
            numCards = try manObjContext.count(for: quaestioSecundus)
            if loq == true {print("There are \(numCards) active, known cards.")}
        }
        catch
        {
            fatalError("Couldn't fetch CardStack count result from Core Data")
        }
        return numCards
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
        let quaestioTertiusDecius = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        quaestioTertiusDecius.predicate = NSPredicate(format: "uniqueID == %@", uniqueID)
        
        do {
            
            let queryResult = try manObjContext.fetch(quaestioTertiusDecius)
            
            if queryResult.count > 0
            {
                let resultCard : CardStackManagedObject = (queryResult.first)!

                if let cardStats = resultCard.cardToStats
                {
                    if resultCard.isKnown == true
                    {
                        if cardStats.numberTimesForgotten >= 1
                        {
                            cardStats.numberTimesForgotten += 1
                        }
                        else
                        {
                            cardStats.numberTimesForgotten = 1
                        }
                    }
                    if cardStats.numberTimesIncorrect >= 1
                    {
                        cardStats.numberTimesIncorrect += 1
                    }
                    else
                    {
                        cardStats.numberTimesIncorrect = 1
                    }
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
 
    func updateAllCardsAsUnknown()
    {
        let quaestioNonus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        do
        {
            let queryResult = try manObjContext.fetch(quaestioNonus)
            for toUpdate in queryResult
            {
                toUpdate.isKnown = false
            }
            saveContext()
        }
        catch
        {
            fatalError("Couldn't fetch CardStack count result from Core Data")
        }
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
        if state == false
        {
            // logic: any card with this tag should be made inactive, since the tag is disabled
            let cardsForTagManagedObject = tag.tagToCards as! Set<CardStackManagedObject>
            for card in cardsForTagManagedObject
            {
                card.isActive = false
            }
        }
        else
        {
            // logic: for each card, set to active if all its tags are now active
            let cardsForTagManagedObject = tag.tagToCards as! Set<CardStackManagedObject>
            for card in cardsForTagManagedObject
            {
                let itsTags = card.cardToTags
                var activateIt = true
                for aTag in itsTags!
                {
                    if (aTag as! TagManagedObject).enabled == false
                    {
                        activateIt = false
                    }
                }
                if activateIt == true
                {
                    card.isActive = true
                }
                
            }
        }
        saveContext()
    }
    
    
    func refreshLearningQueue() -> Array<String> {
        
        /*
         The Learning Queue is an array of Unique ID strings that correspond to the cards that
         should be shown to the learner on the current day. It is comprised of all cards marked as
         due for study today, and also of all cards not currently known.
         */

        var currentlearningQueue = Array<String>()
        let quaestioSextus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
//        quaestioSextus.resultType = NSFetchRequestResultType.dictionaryResultType
        quaestioSextus.propertiesToFetch = ["uniqueID"]
        quaestioSextus.predicate = NSPredicate(format: "(isKnown == NO) AND (isActive == YES)")
        let sortKey1 =  NSSortDescriptor(key: "uniqueID", ascending: true)
        quaestioSextus.sortDescriptors = [sortKey1]
        do {

            let gatheringArrayOne = try manObjContext.fetch(quaestioSextus)
            quaestioSextus.predicate = NSPredicate(format: "(studyToday == YES) AND (isActive == YES)")
            let gatheringArrayTwo = try manObjContext.fetch(quaestioSextus)
            
            var gatheringArrayAll = Array(gatheringArrayOne)
            gatheringArrayAll.append(contentsOf: gatheringArrayTwo)
            
            
            if gatheringArrayAll.count == 0
            {
                return currentlearningQueue
            }
            
            for result in gatheringArrayAll
            {
                let aQueueItem : String? = result.uniqueID
                currentlearningQueue.append(aQueueItem!)
            }
        }
        catch
        {
            fatalError("Couldn't fetch learning queue info from Core Data")
        }
        return currentlearningQueue
        
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
 
    func cardObjFromCardMO(cardMO : CardStackManagedObject) -> CardObject
    {
        let returnedCard = CardObject()
        returnedCard.uniqueID = cardMO.uniqueID!
        returnedCard.isActive = cardMO.isActive
        returnedCard.isKnown = cardMO.isKnown
        returnedCard.studyToday = cardMO.studyToday
        returnedCard.timeCreated = cardMO.timeCreated!
        returnedCard.timeUpdated = cardMO.timeUpdated!
        returnedCard.faceOne = getStringFromMOSet(setGlob: cardMO.faceOne as! Set<NSManagedObject>)
        returnedCard.faceTwo = getStringFromMOSet(setGlob: cardMO.faceTwo as! Set<NSManagedObject>)
        returnedCard.tags = getStringFromMOSet(setGlob: cardMO.cardToTags as! Set<NSManagedObject>)
        returnedCard.faceOneAsSet = getSetFromMOSet(setGlob: cardMO.faceOne as! Set<NSManagedObject>)
        returnedCard.faceTwoAsSet = getSetFromMOSet(setGlob: cardMO.faceTwo as! Set<NSManagedObject>)
        returnedCard.diffRating = cardMO.cardToStats?.difficultyRating
        returnedCard.idealInterval = cardMO.cardToStats?.idealInterval
        returnedCard.numForgot = Int((cardMO.cardToStats?.numberTimesForgotten)!)
        returnedCard.numIncorr = Int((cardMO.cardToStats?.numberTimesIncorrect)!)
        returnedCard.numCorr = Int((cardMO.cardToStats?.numberTimesCorrect)!)
        returnedCard.lastAnswerCorrect = cardMO.cardToStats?.lastAnsweredCorrect
        
        return returnedCard
    }
    
    
    func clearAllObjectsFromStore()
    {
        print("Deleting all the cards. Hope you know what you're doing!")
        let quaestioDecimus_alpha = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
        do {
            
            let queryResult = try manObjContext.fetch(quaestioDecimus_alpha)
            for qr in queryResult
            {
                manObjContext.delete(qr)
            }
        }
        catch
        {
            fatalError("Couldn't fetch CardStack info from Core Data")
        }
        
        let quaestioDecimus_beta = NSFetchRequest<FaceManagedObject>(entityName: "Face")
        do {
            
            let queryResult = try manObjContext.fetch(quaestioDecimus_beta)
            for qr in queryResult
            {
                manObjContext.delete(qr)
            }
        }
        catch
        {
            fatalError("Couldn't fetch Face info from Core Data")
        }
        
        let quaestioDecimus_gamma = NSFetchRequest<TagManagedObject>(entityName: "Tag")
        do {
            
            let queryResult = try manObjContext.fetch(quaestioDecimus_gamma)
            for qr in queryResult
            {
                manObjContext.delete(qr)
            }
        }
        catch
        {
            fatalError("Couldn't fetch Tag info from Core Data")
        }
        
        let quaestioDecimus_delta = NSFetchRequest<CardStatsManagedObject>(entityName: "CardStats")
        do {
            
            let queryResult = try manObjContext.fetch(quaestioDecimus_delta)
            for qr in queryResult
            {
                manObjContext.delete(qr)
            }
        }
        catch
        {
            fatalError("Couldn't CardStats info from Core Data")
        }
        saveContext()
        refreshFetchedTagsController()
}
 
    // MARK: TODO - this function doesn't reuse existing face or tag items (or maintain their use stats) -
    func updateItem(indexPath : IndexPath, withValues : CardObject)
    {
        let oneCard : CardStackManagedObject = fetchedItems.sections![indexPath.section].objects![indexPath.row] as! CardStackManagedObject
        oneCard.timeUpdated = NSDate()
        
         // UPDATE FACE ONE
        var stringSet = Set(withValues.faceOne.components(separatedBy: ","))
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
        stringSet = Set(withValues.faceTwo.components(separatedBy: ","))
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
        stringSet = Set(withValues.tags.components(separatedBy: ","))
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
 
    // MARK: - Helper Functions -
    
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
