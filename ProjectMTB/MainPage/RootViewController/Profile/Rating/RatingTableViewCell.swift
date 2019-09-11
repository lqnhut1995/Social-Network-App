//
//  RatingTableViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/6/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet var answer: UILabel!
    @IBOutlet var rank: UILabel!
    @IBOutlet var star: UILabel!
    @IBOutlet var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
