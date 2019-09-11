//
//  IntroductionViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/16/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class IntroductionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

class LoadingViewCell:UICollectionViewCell{
    
    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        label.layer.borderColor = UIColor(white: 1, alpha: 0.5).cgColor
        label.layer.borderWidth = 1
    }
}
