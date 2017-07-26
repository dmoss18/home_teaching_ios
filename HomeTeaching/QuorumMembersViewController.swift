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
    enum MainViewState {
        case quorumSelect
        case quorumMemberSelect
    }
    var quorumMembersMeta : PaginatedList<QuorumMember> = PaginatedList<QuorumMember>() {
        didSet {
            if self.quorumMembersMeta.data == nil {
                return
            }
            self.allQuorumMembers += self.quorumMembersMeta.data!
            self.quorumMembers = self.allQuorumMembers
        }
    }
    var quorums : [Quorum] = []
    var selectedQuorum : Quorum? {
        didSet {
            pickerButton.setTitle(selectedQuorum?.name, for: .normal)
            reset()
            fetchQuorumMembers()
        }
    }
    var quorumMembers : [QuorumMember] = []
    var allQuorumMembers : [QuorumMember] = []
    var indexTitles : [String:Int]?
    let httpService : HttpService = HttpService.sharedInstance
    let userStore : UserStore = UserStore.sharedInstance
    var viewState : MainViewState = .quorumSelect {
        didSet {
            handleViewStateChanged()
        }
    }
    
    @IBOutlet var tableView : UITableView!
    @IBOutlet var searchBar : UISearchBar!
    @IBOutlet var instructionLabel : UILabel!
    @IBOutlet var pickerButton : PickerButton!
    var quorumPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        quorumPicker = UIPickerView()
        quorumPicker.delegate = self
        quorumPicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(QuorumMembersViewController.doneButtonPressed))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        pickerButton.customInputView = quorumPicker
        pickerButton.customInputAccessoryView = toolBar
        
//        tableView.isHidden = true
//        searchBar.isHidden = true
        
        fetchQuorums()
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
    
    func handleViewStateChanged() {
        switch self.viewState {
        case .quorumMemberSelect:
            self.pickerButton.isHidden = true
            self.quorumPicker.isHidden = true
            self.searchBar.isHidden = false
            self.tableView.isHidden = false
            self.instructionLabel.text = "Please find your name below so we can look up your assignments"
        default:
            self.pickerButton.isHidden = false
            self.quorumPicker.isHidden = false
            self.searchBar.isHidden = true
            self.tableView.isHidden = true
            self.instructionLabel.text = "Please select your quorum"
        }
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
    
    func reset() {
        self.quorumMembersMeta = PaginatedList<QuorumMember>()
        self.allQuorumMembers = []
        self.quorumMembers = []
    }
    
    func fetchQuorumMembers(_ page : Int? = nil) {
        guard let quorumId = selectedQuorum?.id else { return } // TODO: Error?
        firstly {
            httpService.getQuorumMembers(quorumId: quorumId, page: (page ?? quorumMembersMeta.nextPage()))
        }.then { [weak self] members -> Void in
            guard let wSelf = self else { return }
            wSelf.quorumMembersMeta = members
            wSelf.tableView.reloadData()
        }.catch { [weak self] error in
            guard let wSelf = self else { return }
            wSelf.presentAlert("Something went wrong trying to retrieve quorum members")
        }
    }
    
    func fetchQuorums() {
        firstly {
            httpService.getQuorums()
        }.then { [unowned self] quorums -> Void in
            self.quorums = quorums
            self.quorumPicker.reloadAllComponents()
        }.catch { [unowned self] error in
            self.presentAlert("Something went wrong trying to retrieve quorum info")
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
    
    @IBAction func pickerButtonPressed() {
        pickerButton.becomeFirstResponder()
    }
    
    func doneButtonPressed() {
        self.selectedQuorum = quorums[quorumPicker.selectedRow(inComponent: 0)]
        self.pickerButton.resignFirstResponder()
    }
}

extension QuorumMembersViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return quorums[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedQuorum = quorums[row]
    }
}

extension QuorumMembersViewController : UIPickerViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return quorums.count
    }
}
