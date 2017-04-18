//
//  RootViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/16/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {
    
    @IBOutlet open var navMenuRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerRightConstraint: NSLayoutConstraint!
    @IBOutlet open var navMenu: UIView!
    var navMenuShowing = false
    var navController: UINavigationController!
    let userStore: UserStore = UserStore.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(RootViewController.toggleMenu), name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is UINavigationController {
            self.navController = segue.destination as! UINavigationController
        }
    }
    
    func toggleMenu() {
        self.view.layoutIfNeeded()
        
        self.navMenuShowing ? hideMenu() : showMenu()
    }
    
    func hideMenu(animated: Bool = true) {
        moveMenu(0, menuShowing: false, animated: animated)
    }
    
    func showMenu(animated: Bool = true) {
        moveMenu(self.navMenu.bounds.width, menuShowing: true, animated: animated)
    }
    
    func moveMenu(_ constraintConstant: CGFloat, menuShowing: Bool, animated: Bool) {
        self.view.layoutIfNeeded()
        
        self.navMenuRightConstraint.constant = constraintConstant
        self.containerRightConstraint.constant = constraintConstant
        self.navMenuShowing = menuShowing
            
        if animated {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func logout() {
        userStore.delete()
        hideMenu(animated: false)
        if self.navController.topViewController is AssignmentsViewController {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "logoutEvent"), object: nil)
        } else {
            self.navController.popToRootViewController(animated: false)
        }
    }

}
