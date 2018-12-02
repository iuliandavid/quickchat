//
//  FriendTableViewCell.swift
//  QuickChat
//
//  Created by iulian david on 12/2/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
//swiftlint:disable trailing_whitespace
class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    func bindData(friend: BackendlessUser) {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        //download user avatar
        guard let withUserId = friend.objectId else {
            return
        }
        
        let whereClause = "objectId = '\(withUserId)'"
        let queryBuilder = DataQueryBuilder()
        queryBuilder?.setWhereClause(whereClause)
        
        let dataStore = backendless?.data.of(BackendlessUser.ofClass())
        dataStore?.find(queryBuilder, response: { users in
            guard let user = (users as? [BackendlessUser])?.first,
                let avatarUrl = user.getProperty("Avatar") as? String else {
                return
            }
            BackendlessUtils.getAvatarFromURL(url: avatarUrl, result: { image in
                self.avatarImageView.image = image
            })
        }, error: { fault in
            if let err = fault {
                ProgressHUD.showError("Server reported an error: \(err)")
            }
        })
        
        nameLabel.text = friend.name as String
    }
}
