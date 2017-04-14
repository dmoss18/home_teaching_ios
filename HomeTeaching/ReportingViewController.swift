//
//  ViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/18/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit
import PromiseKit
import NVActivityIndicatorView

class ReportingViewController: UIViewController {
    
    let reportStatuses : [String] = ["Contacted", "Tried to contact", "No contact"]
    
    @IBOutlet var householdName : UILabel!
    @IBOutlet var segmentedControl : UISegmentedControl!
    @IBOutlet var textView : UITextView!
    
    let httpService = HttpService.sharedInstance
    let userStore = UserStore.sharedInstance
    
    var assignment : Assignment?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.layer.borderColor = UIColor.black.cgColor
        self.textView.layer.borderWidth = 1
        assignmentChanged()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @IBAction func submit() {
        // TODO
        let status = reportStatuses[segmentedControl.selectedSegmentIndex]
        let message = textView.text
        if (message ?? "").isEmpty {
            presentAlert("Please enter some info about how this family is doing")
            return
        }
        
        let report = Report(status: status, message: message, assignment: assignment!)
        firstly {
            self.httpService.createReport(report)
        }.then { [weak self] _ -> Void in
            guard let wSelf = self else { return }
            wSelf.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func assignmentChanged() {
        guard let household = assignment?.household else { return }
        self.householdName.text = household.name
    }
    
    func presentAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

