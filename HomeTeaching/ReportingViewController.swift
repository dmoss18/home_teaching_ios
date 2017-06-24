//
//  ViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 3/18/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit
import PromiseKit

class ReportingViewController: UIViewController {
    
    let reportStatuses : [String] = ["Contacted", "Tried to contact", "No contact"]
    
    @IBOutlet var scrollView : UIScrollView!
    @IBOutlet var householdName : UILabel!
    @IBOutlet var segmentedControl : UISegmentedControl!
    @IBOutlet var textView : UITextView!
    @IBOutlet var monthPicker : UISegmentedControl!
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReportingViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ReportingViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        
        resetScrollViewInsets()
    }

    @IBAction func submit() {
        // TODO
        let status = reportStatuses[segmentedControl.selectedSegmentIndex]
        let message = textView.text
        if (message ?? "").isEmpty && status != "No contact" {
            presentAlert("Please enter some info about how this family is doing")
            return
        }
        
        var period = Date()
        if monthPicker.selectedSegmentIndex == 1 {
            period = Calendar.current.date(byAdding: .month, value: -1, to: period)!
        }
        
        let report = Report(status: status, message: message, assignment: assignment!, period: period)
        firstly {
            self.httpService.createReport(report)
        }.then { [weak self] _ -> Void in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Report successfully submitted. Thank you.", handler: { _ in
                wSelf.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func assignmentChanged() {
        guard let household = assignment?.household else { return }
        self.householdName.text = household.name
    }
    
    func presentAlert(_ message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func keyboardDidShow(_ notification: Notification) {
        let info = (notification as NSNotification).userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        let insets = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        self.scrollView.scrollRectToVisible(self.textView.frame, animated: true)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        resetScrollViewInsets()
    }
    
    func resetScrollViewInsets() {
        let insets = UIEdgeInsets.zero
        self.scrollView.contentInset = insets
        self.scrollView.scrollIndicatorInsets = insets
    }
}

