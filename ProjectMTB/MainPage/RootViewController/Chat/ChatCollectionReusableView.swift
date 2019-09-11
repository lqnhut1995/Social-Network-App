//
//  ChatCollectionReusableView.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/15/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class ChatCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet var imageview: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var messageTime: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var timeview: UIView!
    @IBOutlet var channel: UILabel!
    @IBOutlet var classname: UILabel!
    @IBOutlet var group: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageview.layer.cornerRadius = 7
    }
}
