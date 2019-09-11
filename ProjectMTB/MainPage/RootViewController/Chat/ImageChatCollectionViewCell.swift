//
//  ImageChatCollectionViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/12/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class ImageChatCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var close: UIButton!
    @IBOutlet var imageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        close.layer.cornerRadius = close.frame.width/2
    }
}
