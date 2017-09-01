//
//  CoreDataGlobalAction.swift
//  learnit
//
//  Created by Matthew McGuire on 8/23/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit
import CoreData

func clearAllObjectsFromStore(context: NSManagedObjectContext)
{
    let quaestio = [NSFetchRequest<CardStackManagedObject>(entityName: "CardStack"),
                    NSFetchRequest<FaceManagedObject>(entityName: "Face"),
                    NSFetchRequest<TagManagedObject>(entityName: "Tag"),
                    NSFetchRequest<CardStatsManagedObject>(entityName: "CardStats")]
    for q in quaestio
    {
        do {
            
            let queryResult = try context.fetch(q as! NSFetchRequest<NSFetchRequestResult>)
            for qr in queryResult  {
                context.delete(qr as! NSManagedObject)
            }
        }
        catch  {
            fatalError("Couldn't fetch CardStack info from Core Data")
        }
    }
    
    negozioGrande!.saveContext()
    negozioGrande!.refreshFetchedResultsController()
    negozioGrande!.refreshFetchedTagsController()
}

func updateAllCardsAsUnknown(context: NSManagedObjectContext)
{
    let quaestioNonus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    do  {
        let queryResult = try context.fetch(quaestioNonus)
        for toUpdate in queryResult   {
            toUpdate.isKnown = false
        }
        negozioGrande!.saveContext()
    }
    catch  {
        fatalError("Couldn't fetch from Core Data")
    }
}

func howManyActiveCards (context: NSManagedObjectContext) -> Int
{
    var numCards : Int = 0
    let quaestioUnDecimus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    quaestioUnDecimus.predicate = NSPredicate(format: "(isActive == YES)")
    quaestioUnDecimus.resultType = NSFetchRequestResultType.countResultType
    do {
        numCards = try context.count(for: quaestioUnDecimus)
    }
    catch
    {
        fatalError("Couldn't fetch CardStack count result from Core Data")
    }
    return numCards
}

func howManyActiveKnownCards(context: NSManagedObjectContext) -> Int
{
    var numCards : Int = 0
    let quaestioSecundus = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    quaestioSecundus.predicate = NSPredicate(format: "(isActive == YES) AND (isKnown == YES)")
    quaestioSecundus.resultType = NSFetchRequestResultType.countResultType
    do {
        numCards = try context.count(for: quaestioSecundus)
    }
    catch
    {
        fatalError("Couldn't fetch CardStack count result from Core Data")
    }
    return numCards
}

func initUserInfo(context: NSManagedObjectContext) -> LearnerManagedObject
{
    let quaestioTertius = NSFetchRequest<NSFetchRequestResult>(entityName: "Learner")
    do {
        let queryResult = try context.fetch(quaestioTertius) as! [LearnerManagedObject]
        if queryResult.count == 0  {
            // create a new Learner Object
            let aNewLearner = NSEntityDescription.insertNewObject(forEntityName: "Learner", into: context) as! LearnerManagedObject
            aNewLearner.name = "Matthew"
            aNewLearner.totalPoints = 0.0
            aNewLearner.daysActive = 0
            aNewLearner.studyTodayLastUpdated = NSDate.distantPast as NSDate
            aNewLearner.correctAnswerShownPause = 3.5
            aNewLearner.maxCardsInHand = 20
            aNewLearner.maximumAnswerValue = 10.0
            return aNewLearner
        }
        else  {
            return queryResult.first!
        }
    }
    catch  {
        fatalError("Couldn't fetch learner info from Core Data")
    }
}


func updateUserInfo(context: NSManagedObjectContext)
{
    if let currentIdentity = negozioGrande!.currentLearner  {
        let quaestioNull = NSFetchRequest<LearnerManagedObject>(entityName: "Learner")
        quaestioNull.predicate = NSPredicate(format: "name == %@", currentIdentity.name!)
        do  {
            let queryResult = try context.fetch(quaestioNull)
            if queryResult.count != 0  {
                let learner = queryResult.first!
                learner.correctAnswerShownPause = currentIdentity.correctAnswerShownPause
                learner.maxCardsInHand = currentIdentity.maxCardsInHand
                learner.maximumAnswerValue = currentIdentity.maximumAnswerValue
                negozioGrande!.saveContext()
            }
        }
        catch  {
            fatalError("Couldn't find the learner object in Core Data.")
        }
        
    }
}

func refreshLearningQueue() -> Array<String> {
    
    /*
     The Learning Queue is an array of Unique ID strings that correspond to the cards that
     should be shown to the learner on the current day. It is comprised of all cards marked as
     due for study today, and also of all cards not currently known.
     */
    var currentlearningQueue = Array<String>()
    guard let context = negozioGrande?.manObjContext
        else  {  return currentlearningQueue }
    let quaestio = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    quaestio.propertiesToFetch = ["uniqueID"]
    quaestio.predicate = NSPredicate(format: "(isKnown == NO) AND (isActive == YES)")
    quaestio.sortDescriptors = [NSSortDescriptor(key: "uniqueID", ascending: true)]
    let gatheringArrayOne = getResultFromQuaestio(quaestio, context)
    quaestio.predicate = NSPredicate(format: "(studyToday == YES) AND (isActive == YES)")
    let gatheringArrayTwo = getResultFromQuaestio(quaestio, context)
    
    var gatheringArrayAll = Array(gatheringArrayOne)
    gatheringArrayAll.append(contentsOf: gatheringArrayTwo)
    
    for result in gatheringArrayAll
    {
        currentlearningQueue.append(result.uniqueID!)
    }
    
    return currentlearningQueue
    }

fileprivate func getResultFromQuaestio(_ quaestio: NSFetchRequest<CardStackManagedObject>, _ context: NSManagedObjectContext) -> Array<CardStackManagedObject>
{
    do
    {
        let qResult = try context.fetch(quaestio)
        return qResult
    }
    catch
    {
        fatalError("Couldn't fetch learning queue info from Core Data")
    }
}
