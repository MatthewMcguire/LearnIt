//
//  BrowseTableViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 7/10/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class BrowseTableViewController: UITableViewController {
    
    var selectedIndexPath : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem?.style = UIBarButtonItemStyle(rawValue: Int(UIFontWeightRegular))!
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.blue
        self.addTheBackButton()
        self.title = "Browse"
        
    }

    func addTheBackButton()
    {
        let segmentBarItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.done, target: self, action:#selector(backButtonPressed))
        segmentBarItem.tintColor = UIColor.blue
        segmentBarItem.style = UIBarButtonItemStyle(rawValue: Int(UIFontWeightRegular))!
        self.navigationItem.leftBarButtonItem = segmentBarItem
        
    }

    func backButtonPressed()
    {
        
         performSegue(withIdentifier: "BrowseToMainSegue", sender: self)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let negG = negozioGrande
        {
            return negG.numberOfSectionsInTblVw()
        }
        else
        {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let negG = negozioGrande
        {
            return negG.numberOfRowsInTblVwSection(section: section)
        }
        else
        {
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardItemCell", for: indexPath)

        cell.textLabel?.text = negozioGrande!.getCardNameForCell(indexPath: indexPath)
        cell.detailTextLabel?.text = negozioGrande!.getCardTagsForCell(indexPath: indexPath)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "BrowseToDetailSegue", sender: self)
        
    }
 


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }



    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            negozioGrande!.deleteItem(indexPath: indexPath)
            negozioGrande!.refreshFetchedResultsController()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BrowseToDetailSegue"
        {
            let detailViewContr = segue.destination as! CardDetailViewController
            detailViewContr.selectedIndexPath = self.selectedIndexPath
            detailViewContr.currentCard = negozioGrande!.getCellItemInfo(indexPath: selectedIndexPath!)
        }
    }


}
