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
    
    
    func addNewObj(card : CardObject)
    {
        let helper = CoreDataManagement(manObjContext: manObjContext)
        helper.newCard(card: card)
        
        saveContext()
        refreshFetchedTagsController()
        refreshFetchedResultsController()
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
