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
    let queryResult = getQueryResultsCardstack(NSPredicate(format: "(isKnown == YES) AND (isActive == YES) AND (studyToday == NO)" ))
    adjustStudyToday(queryResult)
    negozioGrande?.saveContext()
}

fileprivate func getQueryResultsCardstack(_ predicate: NSPredicate) -> Array<CardStackManagedObject>
{
    let quaestio = NSFetchRequest<CardStackManagedObject>(entityName: "CardStack")
    quaestio.predicate = predicate
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
    return queryResult
}

func updateCardAnsweredCorrect(uniqueID: String, distance: Float)
{
    let queryResult = getQueryResultsCardstack(NSPredicate(format: "uniqueID == %@", uniqueID))
    guard queryResult.count > 0 else { return }
    let resultCard : CardStackManagedObject = (queryResult.first)!
    resultCard.isKnown = true
    resultCard.studyToday = false
    if let cardStats = resultCard.cardToStats
    {
        cardStats.numberTimesCorrect += 1
        // update difficulty rating
        cardStats.difficultyRating = getNewCardDifficultyRating(cardStats.difficultyRating, (5.0 - distance))
        
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
    
    negozioGrande?.saveContext()
}

func updateCardAnsweredINCorrect(uniqueID: String, distance: Float)
{
    let queryResult = getQueryResultsCardstack(NSPredicate(format: "uniqueID == %@", uniqueID))
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
        cardStats.difficultyRating = getNewCardDifficultyRating(cardStats.difficultyRating, max(5.0 - distance, 0.0))
        resultCard.isKnown = false
        resultCard.studyToday = false
    }
    negozioGrande?.saveContext()
}

fileprivate func getNewCardDifficultyRating(_ diffRat: Float, _ q: Float) -> Float
{
    var newDiffRat = max(diffRat, Float(1.3))
    newDiffRat += (-0.8 + (0.28 * q) - 0.02 * q * q)
    newDiffRat = max(newDiffRat, Float(1.3))
    newDiffRat = min(newDiffRat, Float(2.5))
    return newDiffRat
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
        card.isActive = cardIsActive(card.cardToTags as! Set<TagManagedObject>)
    }
    negozioGrande?.saveContext()
}

fileprivate func cardIsActive(_ tags: Set<TagManagedObject>) -> Bool
{
    var activateIt = true
    for aTag in tags
    {
        if aTag.enabled == false
        {
            activateIt = false
        }
    }
    return activateIt
}
