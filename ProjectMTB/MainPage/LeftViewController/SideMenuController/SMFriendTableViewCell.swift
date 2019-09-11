//
//  SMFriendTableViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/4/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class SMFriendTableViewCell: UITableViewCell {

    @IBOutlet var message: UILabel!
    @IBOutlet var status: UIView!
    @IBOutlet var name: UILabel!
    @IBOutlet var imageview: UIImageView!
    var statusColor:UIColor!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        status.layer.cornerRadius = status.frame.width/2
        status.clipsToBounds = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
