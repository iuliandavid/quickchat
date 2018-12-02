//
//  RecentsViewController.swift
//  QuickChat
//
//  Created by iulian david on 12/1/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit

//swiftlint:disable trailing_whitespace
//swiftlint:disable vertical_whitespace
class RecentsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var recents: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadRecents()
        guard let avatarUrl = backendless?.userService.currentUser.getProperty("Avatar") as? String else {
            return
        }
        BackendlessUtils.getAvatarFromURL(url: avatarUrl ) {[unowned self] (image) in
            guard let image = image else {
                return
            }
            self.profileImageView.image = image
            self.navigationItem.titleView = self.loadTitledView(text: "Recents")
        }
        
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage()
        imageView.layer.cornerRadius = 40 / 2
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private func loadTitledView(text: String) -> UIView {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        let label = UILabel()
        label.text = text
        containerView.addSubview(label)
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        label.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        return titleView
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    // MARK: - IBAction
    @IBAction func addButtonPressed(_ sender: Any) {
    }
   
    
    // MARK: Load Recents
    func loadRecents() {
        firebase.child(kRECENT)
            .queryOrdered(byChild: kUSERID)
            .queryEqual(toValue: backendless?.userService.currentUser.objectId)
            .observe(.value) { [weak self] snapshot in
                self?.recents.removeAll()
                if snapshot.exists() {
                    guard let sorted = ((snapshot.value as? NSDictionary)?.allValues as NSArray?)?.sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) else {
                        return
                    }
                    for recent in sorted {
                        guard let currentRecent = recent as? NSDictionary else {
                            continue
                        }
                        
                        self?.recents.append(currentRecent)
                        
                        // remember to get all recents for offilne use as well
                    }
                }
        }
    }
}

// MARK: UITable extension
extension RecentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsViewCell", for: indexPath) as? RecentsViewCell else {
            return RecentsViewCell()
        }
        
        let recent = recents[indexPath.row]
//        cell.counterLabel;
        return cell
    }
}
extension RecentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
