//
//  BaseMenuViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/16/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit

class BaseMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Make only the chevron appear on next VC's back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        //Hamburger menu icon
        self.navigationItem.leftItemsSupplementBackButton = true
        let menuButton = UIBarButtonItem(title: "☰", style: .plain, target: self, action: #selector(BaseMenuViewController.menuButtonClicked))
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
    func menuButtonClicked() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "toggleMenu"), object: nil)
    }
}
