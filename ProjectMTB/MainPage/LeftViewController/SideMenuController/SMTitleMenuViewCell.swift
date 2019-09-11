//
//  SMTitleMenuView.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/1/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit

class SMTitleMenuViewCell: PagingMenuViewCell {
    
    @IBOutlet var unreadView: UIView!
    @IBOutlet var imageview: UIImageView!
    @IBOutlet var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadView.layer.cornerRadius = 7
        unreadView.clipsToBounds = true
    }
}
