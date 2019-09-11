//
//  LeftTableViewCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/1/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class SMContentTableViewCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var unreadView: UIView!
    @IBOutlet var unread: UILabel!
    @IBOutlet var imageview: UIImageView!
    var channel:TopicItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        unreadView.layer.cornerRadius = 7
        unreadView.clipsToBounds = true
        backgroundColor = .clear
        imageview.tintColor = .white
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if channel.channeltype == 1 {return}
        let bgView = UIView()
        bgView.backgroundColor = UIColor.mainColor
        bgView.layer.cornerRadius = 7
        selectedBackgroundView = bgView
        selectedBackgroundView?.frame = CGRect(x: 10, y: 5, width: self.frame.width-20, height: self.frame.height-8)
        unreadView.backgroundColor = UIColor(hex: "#E13731")
    }

}
