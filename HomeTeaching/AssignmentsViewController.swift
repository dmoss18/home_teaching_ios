//
//  AssignmentsViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/1/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit
import PromiseKit

class AssignmentsViewController: BaseMenuViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView : UITableView!
    let httpService : HttpService = HttpService.sharedInstance
    let userStore : UserStore = UserStore.sharedInstance
    var assignments : [Assignment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AssignmentsViewController.presentLogin), name: NSNotification.Name(rawValue: "logoutEvent"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !userStore.isLoggedIn() {
            presentLogin()
        } else if !userStore.isLinkedToQuorum() {
            self.performSegue(withIdentifier: "ShowQuorumMembersViewController", sender: self)
        } else {
            fetchAssignments()
        }
    }
    
    func fetchAssignments() {
        firstly {
            httpService.getAssignments(quorumMember: (userStore.currentQuorumMember)!)
        }.then { [weak self] assignments -> Void in
            guard let wSelf = self else { return }
            wSelf.assignments = assignments
            wSelf.tableView.reloadData()
        }.catch { error in
            var x = 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentTableViewCell
        cell.assignment = assignments[indexPath.item]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReportingViewController" {
            if let cell = sender as? AssignmentTableViewCell {
                if let nextViewController = segue.destination as? ReportingViewController {
                    nextViewController.assignment = cell.assignment
                }
            }
            
        }
    }
    
    func presentLogin() {
        self.performSegue(withIdentifier: "ShowLoginViewController", sender: self)
    }
}

extension AssignmentsViewController : UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if toVC is LoginViewController {
            return SlideUpAnimator()
        } else if fromVC is LoginViewController && toVC is AssignmentsViewController {
            return SlideDownAnimator()
        }
        return nil
    }
}
