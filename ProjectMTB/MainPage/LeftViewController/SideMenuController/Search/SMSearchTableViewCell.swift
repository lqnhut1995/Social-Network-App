//
//  SMSearchTableViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/19/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class SMSearchTableViewCell: UITableViewCell {

    @IBOutlet var imageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        imageview.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.mainColor
        bgView.layer.cornerRadius = 7
        selectedBackgroundView = bgView
    }
}
