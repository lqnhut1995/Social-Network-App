//
//  ProfileMenuViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/6/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit

class ProfileTitleMenuViewCell: PagingMenuViewCell {

    @IBOutlet var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        name.layer.borderWidth = 0.7
    }

}
