//
//  ChooseUserViewController.swift
//  QuickChat
//
//  Created by iulian david on 12/2/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace
class ChooseUserViewController: UIViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    var users: [BackendlessUser] = []
    var filteredUsers: [BackendlessUser] = []
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadUsers()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        //add the searchbar as tableview's header
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.delegate = self
    }
    

    // MARK: - Load Users
    func loadUsers() {
        
        guard let withUserId = backendless?.userService.currentUser.objectId else {
            return
        }
        let whereClause = "objectId != '\(withUserId)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder?.setWhereClause(whereClause)
        
        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
        dataStore?.find(queryBuilder, response: {[weak self] users in
            guard let users = users as? [BackendlessUser] else {
                    return
            }
            self?.users = users
            self?.tableView.reloadData()
        }, error: { fault in
            if let err = fault {
                ProgressHUD.showError("Server reported an error: \(err)")
            }
        })
    }

}

extension ChooseUserViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return users.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseUserCell", for: indexPath)
            as? FriendTableViewCell else {
            return FriendTableViewCell()
        }
        
        // Configure the cell...
        let user: BackendlessUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        cell.bindData(friend: user)
        
        return cell
    }
    
    
}

extension ChooseUserViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user: BackendlessUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        
        let chatRoomID = startChat(user1: backendless!.userService.currentUser, user2: user)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


extension ChooseUserViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchText: searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String) {
        filteredUsers = users.filter { user in
            return user.name.lowercased.contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}

//Creating a Scope Bar to Filter Results
extension ChooseUserViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!)
    }
}
