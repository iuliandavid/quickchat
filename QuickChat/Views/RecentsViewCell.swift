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
    
    

}
