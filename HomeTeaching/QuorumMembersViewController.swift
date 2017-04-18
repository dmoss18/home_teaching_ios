//
//  QuorumMembersViewController.swift
//  HomeTeaching
//
//  Created by Devin Moss on 4/8/17.
//  Copyright © 2017 Devin Moss. All rights reserved.
//

import UIKit
import PromiseKit

class QuorumMembersViewController: BaseMenuViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    var quorumMembersMeta : PaginatedList<QuorumMember> = PaginatedList<QuorumMember>() {
        didSet {
            if self.quorumMembersMeta.data == nil {
                return
            }
            self.allQuorumMembers += self.quorumMembersMeta.data!
            self.quorumMembers = self.allQuorumMembers
        }
    }
    var quorumMembers : [QuorumMember] = []
    var allQuorumMembers : [QuorumMember] = []
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
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        // Hide the navigation bar on the this view controller
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quorumMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : QuorumMemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "QuorumMemberCell") as! QuorumMemberTableViewCell
        cell.quorumMember = self.quorumMembers[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isDisplayingSearchResults() {
            return
        }
        if self.quorumMembers.count - indexPath.row == 5 && self.quorumMembersMeta.hasNextPage() {
            fetchQuorumMembers()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let quorumMember : QuorumMember = self.quorumMembers[indexPath.row]
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
            wSelf.presentAlert((error as! HTError).message)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            self.quorumMembers = allQuorumMembers
            self.tableView.reloadData()
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
    
    func fetchQuorumMembers(_ page : Int? = nil) {
        firstly {
            httpService.getQuorumMembers(quorumId: 1, page: (page ?? quorumMembersMeta.nextPage()))
        }.then { [weak self] members -> Void in
            guard let wSelf = self else { return }
            wSelf.quorumMembersMeta = members
            wSelf.tableView.reloadData()
        }.catch { [weak self] error in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Something went wrong trying to retrieve quorum members")
        }
    }
    
    func isDisplayingSearchResults() -> Bool {
        return self.quorumMembers as AnyObject !== self.allQuorumMembers as AnyObject
    }
    
    func presentAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

}
