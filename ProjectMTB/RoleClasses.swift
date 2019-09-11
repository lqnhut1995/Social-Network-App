//
//  Role.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/13/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class Role:Mappable{
    var roleid:Int?
    var rolename:String?
    var rolecolor:String?
    var subgroupid:Int?
    var originrole:Int?
    var settinggroup=[SettingGroup]()
    
    init(roleid: Int, rolename: String, rolecolor: String, subgroupid: Int?) {
        self.roleid=roleid
        self.rolename=rolename
        self.rolecolor=rolecolor
        self.subgroupid=subgroupid
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        roleid <- map["roleid"]
        rolename <- map["rolename"]
        rolecolor <- map["rolecolor"]
        subgroupid <- map["subgroupid"]
        originrole <- map["originrole"]
        settinggroup <- map["items"]
    }
}

class SettingGroup:Mappable{
    var settinggroupid:Int?
    var settinggroupname:String?
    var settinggroupdescription:String?
    var settingdescription=[SettingDescription]()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        settinggroupid <- map["settinggroupid"]
        settinggroupname <- map["settinggroupname"]
        settinggroupdescription <- map["settinggroupdescription"]
        settingdescription <- map["items"]
    }
}

class SettingDescription:Mappable{
    var settingdescriptionid:Int?
    var settingdescriptionname:String?
    var settingdetail=[SettingDetail]()
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        settingdescriptionid <- map["settingdescriptionid"]
        settingdescriptionname <- map["settingdescriptionname"]
        settingdetail <- map["items"]
    }
}

class SettingDetail:Mappable{
    var settingdetailid:Int?
    var settingname:String?
    var value:Int?
    var isactive:Int?
    var settingsection:String?
    var settingtypeid:Int?
    var settingtypename:String?
    
    init(settingdetailid: Int, isactive: Int) {
        self.settingdetailid=settingdetailid
        self.isactive=isactive
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        settingdetailid <- map["settingdetailid"]
        settingname <- map["settingname"]
        value <- map["value"]
        isactive <- map["isactive"]
        settingsection <- map["settingsection"]
        settingtypeid <- map["settingtypeid"]
        settingtypename <- map["settingtypename"]
    }
}
