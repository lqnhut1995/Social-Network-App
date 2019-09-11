//
//  UserSettingCustomCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/27/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import Eureka

struct User: Equatable {
    var name:String?
    var id:String?
    var image:String?
}

final class ProfileCell: Cell<User>, CellType {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var userid: UILabel!
    
    public override func setup() {
        super.setup()
        
        row.title = nil
        selectionStyle = .none
        imageview.layer.cornerRadius = 7
    }
    
    public override func update() {
        super.update()
        
        row.title = nil
        textLabel?.text = nil
        guard let user=row.value else {return}
        if let image = user.image, let url = URL(string: image){
            imageview.kf.setImage(with: url)
        }
        userid.text = "\(String(describing: user.name!))\(String(describing: user.id!))"
    }
    
}

final class ProfileRow: Row<ProfileCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ProfileCell>(nibName: "UserSettingCustomView")
    }

}
