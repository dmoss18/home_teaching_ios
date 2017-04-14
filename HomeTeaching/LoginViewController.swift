//
//  LoginViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/1/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit
import PromiseKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    let httpService : HttpService = HttpService.sharedInstance
    let userStore : UserStore = UserStore.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if email.isFirstResponder {
            password.becomeFirstResponder()
        } else {
            login()
        }
        return true
    }
    
    @IBAction func login() {
        guard let emailText = self.email.text else {
            presentAlert("Please enter an email address")
            return
        }
        guard let passwordText = self.password.text else {
            presentAlert("Please enter a password")
            return
        }
        
        submitButton.isEnabled = false
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        firstly {
            httpService.login(email: emailText, password: passwordText)
        }.then { [weak self] user -> Void in
            guard let wSelf = self else { return }
            if wSelf.userStore.isLinkedToQuorum() {
                wSelf.navigationController?.popToRootViewController(animated: true)
            } else {
                wSelf.performSegue(withIdentifier: "ShowQuorumMembersViewController", sender: wSelf)
            }
        }.catch { [weak self] error in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Invalid username or password")
        }.always { [weak self] in
            guard let wSelf = self else { return }
            wSelf.submitButton.isEnabled = true
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    func presentAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}
