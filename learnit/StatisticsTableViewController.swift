//
//  StatisticsTableViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 7/19/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UITableViewController {

    var selectedIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Tag and Card Statistics"
        self.addTheBackButton()

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
        
        performSegue(withIdentifier: "StatsToMainSegue", sender: self)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let negG = negozioGrande
        {
            return negG.numberOfTagSections()
        }
        else
        {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let negG = negozioGrande
        {
            return negG.numberOfTagRows(section: section)
        }
        else
        {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagItemCell", for: indexPath)
     
        cell.textLabel?.text = negozioGrande!.getTagTextForCell(indexPath: indexPath)
        cell.detailTextLabel?.text = "\(negozioGrande!.getTagCountForCell(indexPath: indexPath))"
        let isEnabled = negozioGrande!.getEnabledStateForTag(indexPath: indexPath)
        if isEnabled == true
        {
           cell.accessoryType = .checkmark
        }
        else
        {
            cell.accessoryType = .none
        }
        
     
        return cell
     }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndexPath = indexPath
        if let cell = tableView.cellForRow(at: selectedIndexPath!)
        {
            if cell.accessoryType == .checkmark
            {
                negozioGrande!.tagEnabled(set: false, indexPath: indexPath)
                cell.accessoryType = .none
            }
            else
            {
                negozioGrande!.tagEnabled(set: true, indexPath: indexPath)
                cell.accessoryType = .checkmark
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}