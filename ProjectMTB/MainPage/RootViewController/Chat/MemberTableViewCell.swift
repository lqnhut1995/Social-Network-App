//
//  MemberTableViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/18/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class MemberTableViewCell: UITableViewCell {

    @IBOutlet var status: UIView!
    @IBOutlet var imageview: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageview.layer.cornerRadius = 7
        status.layer.cornerRadius = status.frame.width/2
        textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        textLabel?.textColor = .white
        let bgView = UIView()
        bgView.backgroundColor = UIColor(hex: "#232323")
        selectedBackgroundView = bgView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
