//
//  TitleMenuViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit

class TitleMenuViewCell: PagingMenuViewCell {

    @IBOutlet var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        title.layer.borderWidth = 0.7
    }


}
