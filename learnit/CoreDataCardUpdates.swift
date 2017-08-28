//
//  CoreDataCardUpdates.swift
//  learnit
//
//  Created by Matthew McGuire on 8/28/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit
import CoreData

func updateStudyToday()
{
    // 1) Search for cards that should be added to today's queue
    // 2) Add them to the queue
    // 3) Return true if any such cards were found and added.
    guard let currentLearner = negozioGrande?.currentLearner
            else { fatalError("No current learner") }
        // if a learner has never had his 'study today' flag checked...
        // (i.e. this function has never been executed)
        if currentLearner.studyTodayLastUpdated == nil
        {
            // set the flag to today's date
            currentLearner.studyTodayLastUpdated = NSDate()
            currentLearner.daysActive += 1
            updateStudyTodayFlagOnCards()
        }
        else
        {
            // If the studyTodayLastUpdated value was at least a day ago,
            // update the queue with updateStudyTodayFlagOnCards()
            let howLongSince = -1.0 * currentLearner.studyTodayLastUpdated!.timeIntervalSinceNow
            let sixteenHoursInSeconds = 16 * 60 * 60
            
            if Int(howLongSince) > sixteenHoursInSeconds
            {
                currentLearner.studyTodayLastUpdated = NSDate()
                currentLearner.daysActive += 1
                updateStudyTodayFlagOnCards()
            }
        }
    negozioGrande?.saveContext()
}

fileprivate func adjustStudyToday(_ queryResult: [CardStackManagedObject]) {
   let secondsInOneDay : TimeInterval = (60.0 * 60.0 * 24.0)
    for card:CardStackManagedObject in queryResult
    {
        let statsForCard : CardStatsManagedObject = card.cardToStats!
        var shouldStudyNext : NSDate = NSDate()
        if let lastCorrect = statsForCard.lastAnsweredCorrect
        {
            shouldStudyNext = lastCorrect.addingTimeInterval(secondsInOneDay * TimeInterval( statsForCard.idealInterval))
        }
        
        // shouldStudyNext is the NSDate value for the ideal study-it-again for the card.
        // if that value is sometime 'today' or it is previous to 'right now' the card is marked as studyToday = true
        if (NSCalendar.current.isDateInToday(shouldStudyNext as Date) == true) || (shouldStudyNext.compare(Date()) != ComparisonResult.orderedDescending)
        {
            card.studyToday = true
        }
    }
}

fileprivate func updateStudyTodayFlagOnCards()
{
    
    let quaestio = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    quaestio.predicate = NSPredicate(format: "(isKnown == YES) AND (isActive == YES) AND (studyToday == NO)")
    var queryResult: [CardStackManagedObject]
    guard let context = negozioGrande?.manObjContext
        else { fatalError("No managed object context!" ) }
    do {
        // if a card is currently Active, Known, and marked as StudyToday = NO,...
        // and if the date it was last answered correctly plus its ideal interval falls today or earlier,
        // then mark the card as StudyToday = YES
        queryResult = try context.fetch(quaestio)
    }
    catch  {
        fatalError("Error fetching objects from the persistent store")
    }
    adjustStudyToday(queryResult)
    negozioGrande?.saveContext()
}
