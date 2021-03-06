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
        guard let cc = currentCard
            else { return }
        faceOneField.text = cc.cardInfo.faceOne
        faceTwoField.text = cc.cardInfo.faceTwo
        tagsField.text = cc.cardInfo.tags
        isActiveSwitch.isOn = cc.cardInfo.isActive
        isKnownSwitch.isOn = cc.cardInfo.isKnown
        studyTodaySwitch.isOn = cc.cardInfo.studyToday
        showProgressDetails(cc)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if hasChangesToSave == true
        {
            if let cc = currentCard
            {
                updateItem(indexPath: selectedIndexPath!, withValues: cc)
            }
        }
    }
    
    func showProgressDetails(_ cc: CardObject)
    {
        let dateFormatter = mediumDateFormat()
        difficultyField.text = String(format:"%.2f", cc.cardInfo.diffRating!)
        correctTimesField.text = "\(cc.cardInfo.numCorr)"
        incorrectTimesFields.text = "\(cc.cardInfo.numIncorr)"
        forgottenTimesField.text = "\(cc.cardInfo.numForgot)"
        idealIntervalField.text = String(format:"%.2f", cc.cardInfo.idealInterval!)
        
        if let ccLastCorrect = cc.cardInfo.lastAnswerCorrect
        {
            lastCorrectField.text = dateFormatter.string(from: ccLastCorrect as Date)
        }
        else
        {
            lastCorrectField.text = "---"
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
