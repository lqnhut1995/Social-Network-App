//
//  Members.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/23/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class Member: Mappable{
    var userid:Int?
    var username:String?
    var subgroupid:Int?
    var groupid:Int?
    var userimage:String?
    var ban:Int?
    var kick:Int?
    var nickname:String?
    var userclassid:Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userid <- map["userid"]
        username <- map["username"]
        subgroupid <- map["subgroupid"]
        groupid <- map["groupid"]
        userimage <- map["userimage"]
        ban <- map["ban"]
        kick <- map["kick"]
        nickname <- map["nickname"]
        userclassid <- map["userclassid"]
    }
}
