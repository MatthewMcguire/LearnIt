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
    print("Deleting all the cards. Hope you know what you're doing!")
    let quaestioDecimus_alpha = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    do {
        
        let queryResult = try context.fetch(quaestioDecimus_alpha)
        for qr in queryResult  {
            context.delete(qr)
        }
    }
    catch  {
        fatalError("Couldn't fetch CardStack info from Core Data")
    }
    
    let quaestioDecimus_beta = NSFetchRequest<FaceManagedObject>(entityName: "Face")
    do {
        
        let queryResult = try context.fetch(quaestioDecimus_beta)
        for qr in queryResult  {
            context.delete(qr)
        }
    }
    catch  {
        fatalError("Couldn't fetch Face info from Core Data")
    }
    
    let quaestioDecimus_gamma = NSFetchRequest<TagManagedObject>(entityName: "Tag")
    do {
        
        let queryResult = try context.fetch(quaestioDecimus_gamma)
        for qr in queryResult  {
            context.delete(qr)
        }
    }
    catch  {
        fatalError("Couldn't fetch Tag info from Core Data")
    }
    
    let quaestioDecimus_delta = NSFetchRequest<CardStatsManagedObject>(entityName: "CardStats")
    do {
        
        let queryResult = try context.fetch(quaestioDecimus_delta)
        for qr in queryResult {
            context.delete(qr)
        }
    }
    catch {
        fatalError("Couldn't CardStats info from Core Data")
    }
    negozioGrande!.saveContext()
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
        fatalError("Couldn't fetch CardStack count result from Core Data")
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
