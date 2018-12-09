//
//  RecentsViewCell.swift
//  QuickChat
//
//  Created by iulian david on 12/1/18.
//  Copyright © 2018 iulian david. All rights reserved.
//

import UIKit
//swiftlint:disable trailing_whitespace
class RecentsViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bindData(recent: [String: Any]) {
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
        avatarImageView.layer.masksToBounds = true
        
        avatarImageView.image = UIImage(named: "avatarPlaceholder")
        
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.5
        
        if let type = recent[kTYPE] as? String, type == kPRIVATE,
            let withUserId = recent[kWITHUSERUSERID] {
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
        }
        
        nameLabel.text = recent[kWITHUSERUSERNAME] as? String
        lastMessageLabel.text = recent[kLASTMESSAGE] as? String
        counterLabel.text = ""
        if let count = recent[kCOUNTER] as? Int, count != 0 {
            counterLabel.text = "\(count) New"
        }
        
        if let strDate = recent[kDATE] as? String,
            let date = dateFormatter().date(from: strDate) {
            dateLabel.text = "\(timeElapsed(date: date))"
        }
    }
    
    private func timeElapsed(date: Date) -> String {
        let seconds = Date().timeIntervalSince(date)
        
        let elapsed: String
        
        if seconds < 60 {
            elapsed = "Just now"
        } else {
            let currrentDateFormater = dateFormatter()
            currrentDateFormater.dateFormat = "dd/MM"
            
            elapsed = "\(currrentDateFormater.string(from: date))"
        }
        
        return elapsed
    }
}
