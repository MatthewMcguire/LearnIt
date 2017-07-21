//
//  CardDetailViewController.swift
//  learnit
//
//  Created by Matthew McGuire on 7/10/17.
//  Copyright © 2017 Matthew McGuire. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    var selectedIndexPath : IndexPath?
    var currentCard : CardObject?
    var hasChangesToSave : Bool = false

    @IBOutlet weak var faceOneField: UITextField!
    @IBOutlet weak var faceTwoField: UITextField!
    @IBOutlet weak var tagsField: UITextField!
    @IBOutlet weak var isActiveSwitch: UISwitch!
    @IBOutlet weak var isKnownSwitch: UISwitch!
    @IBOutlet weak var studyTodaySwitch: UISwitch!
    @IBOutlet weak var difficultyField: UILabel!
    @IBOutlet weak var idealIntervalField: UILabel!
    @IBOutlet weak var correctTimesField: UILabel!
    @IBOutlet weak var incorrectTimesFields: UILabel!
    @IBOutlet weak var forgottenTimesField: UILabel!
    @IBOutlet weak var lastCorrectField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Update"
        populateFields()
        
    }

    func  populateFields()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier:"en_US")
        
        if let cc = currentCard
        {
            faceOneField.text = cc.faceOne
            faceTwoField.text = cc.faceTwo
            tagsField.text = cc.tags
            isActiveSwitch.isOn = cc.isActive!
            isKnownSwitch.isOn = cc.isKnown!
            studyTodaySwitch.isOn = cc.studyToday!
            if let ccdif = cc.diffRating
            {
                difficultyField.text = String(format:"%.2f", ccdif)
                
            }
            else
            {
                difficultyField.text = "---"
            }
            if let ccII = cc.idealInterval
            {
                idealIntervalField.text = String(format:"%.2f", ccII)
                
            }
            else
            {
                idealIntervalField.text = "---"
            }
            if let ccnumCor = cc.numCorr
            {
                correctTimesField.text = "\(ccnumCor)"
                
            }
            else
            {
                correctTimesField.text = "---"
            }
            if let ccIncor = cc.numIncorr
            {
                incorrectTimesFields.text = "\(ccIncor)"
                
            }
            else
            {
                incorrectTimesFields.text = "---"
            }
            if let ccnumForg = cc.numForgot
            {
                forgottenTimesField.text = "\(ccnumForg)"
                
            }
            else
            {
                forgottenTimesField.text = "---"
            }
            if let ccLastCorrect = cc.lastAnswerCorrect
            {
                lastCorrectField.text = dateFormatter.string(from: ccLastCorrect as Date)
            }
            else
            {
                lastCorrectField.text = "---"
            }
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        if hasChangesToSave == true
        {
            if let cc = currentCard
            {
                    negozioGrande!.updateItem(indexPath: selectedIndexPath!, withValues: cc)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
