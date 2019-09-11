//
//  RVFriendsTableViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/8/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class RVFriendsTableViewCell: UITableViewCell {

    @IBOutlet var status: UIView!
    @IBOutlet var name: UILabel!
    @IBOutlet var imageview: UIImageView!
    @IBOutlet var id: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageview.layer.cornerRadius = 7
        status.layer.cornerRadius = 2
        imageview.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
