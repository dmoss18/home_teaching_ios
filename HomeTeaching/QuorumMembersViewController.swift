//
//  QuorumMembersViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/8/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit
import PromiseKit

class QuorumMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var quorumMembersMeta : PaginatedList<QuorumMember> = PaginatedList<QuorumMember>() {
        didSet {
            if self.quorumMembersMeta.data == nil {
                self.quorumMembers = []
            }
            self.quorumMembers = self.quorumMembersMeta.data
        }
    }
    var quorumMembers : [QuorumMember]? = []
    var indexTitles : [String:Int]?
    let httpService : HttpService = HttpService.sharedInstance
    let userStore : UserStore = UserStore.sharedInstance
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    
    // TODO: Some day we will have to provide a quorum selector

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchQuorumMembers()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.quorumMembers == nil {
            return 0
        }
        return self.quorumMembers!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : QuorumMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "QuorumMemberCell") as! QuorumMemberTableViewCell
        cell.quorumMember = self.quorumMembers![indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quorumMember : QuorumMember = self.quorumMembers![indexPath.row]
        let params : [String:String] = ["user_id": String(userStore.currentUser!.id!)]
        firstly {
            httpService.updateQuorumMember(member: quorumMember, parameters: params)
        }.then { [weak self] member -> Void in
            guard let wSelf = self else { return }
            wSelf.userStore.currentQuorumMember = quorumMember
            wSelf.userStore.write()
            wSelf.navigationController?.popToRootViewController(animated: true)
        }.catch { [weak self] error in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Something went wrong while trying to update quorum member")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            fetchQuorumMembers()
            return
        }

        firstly {
            httpService.searchQuorumMembers(quorumId: 1, name: searchText)
        }.then { [weak self] members -> Void in
            guard let wSelf = self else { return }
            wSelf.quorumMembers = members
            wSelf.tableView.reloadData()
        }.catch { [weak self] error in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Something went wrong trying to retrieve quorum members")
        }
    }
    
    func fetchQuorumMembers() {
        firstly {
            httpService.getQuorumMembers(quorumId: 1, page: self.quorumMembersMeta.nextPage())
        }.then { [weak self] members -> Void in
            guard let wSelf = self else { return }
            wSelf.quorumMembersMeta = members
            wSelf.tableView.reloadData()
        }.catch { [weak self] error in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Something went wrong trying to retrieve quorum members")
        }
    }
    
    func presentAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}
