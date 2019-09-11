//
//  SkeletonViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/8/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import SkeletonView

class SkeletonViewCell: UICollectionViewCell {

    @IBOutlet var uiview3: UIView!
    @IBOutlet var uiview2: UIView!
    @IBOutlet var uiview1: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
                
        [uiview1,uiview2,uiview3].forEach{
            $0?.showAnimatedGradientSkeleton()
        }
    }
}
