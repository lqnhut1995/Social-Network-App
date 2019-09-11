//
//  LoadClass.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/28/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

class userLogin: Mappable{
    var userid:Int?
    var username:String?
    var email:String?
    var password:String?
    var telephone:String?
    var usertype:String?
    var status:String?
    var secure:String?
    var userimage:String?
    var token:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userid <- map["userid"]
        username <- map["username"]
        email <- map["email"]
        password <- map["password"]
        telephone <- map["telephone"]
        usertype <- map["usertype"]
        status <- map["status"]
        secure <- map["secure"]
        userimage <- map["userimage"]
        token <- map["token"]
    }
}

class Group: Mappable{
    var userinfoid:Int?
    var groupid:Int?
    var groupname:String?
    var groupimage:String?
    var isadmin:Int?
    var status:String?
    
    required init?(map: Map) {
        
    }
    
    init(groupid:Int?,groupname:String?,groupimage:String?) {
        self.groupid=groupid
        self.groupname=groupname
        self.groupimage=groupimage
    }
    
    func mapping(map: Map) {
        userinfoid <- map["userinfoid"]
        groupid <- map["groupid"]
        groupname <- map["groupname"]
        groupimage <- map["groupimage"]
        isadmin <- map["isadmin"]
        status <- map["status"]
    }
}

class subGroup: Mappable{
    var subgroupid:Int?
    var subgroupname:String?
    var groupid:Int?
    var status:String?
    var settingdetail=[SettingDetail]()
    var isaccepted:Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        subgroupid <- map["subgroupid"]
        subgroupname <- map["subgroupname"]
        groupid <- map["groupid"]
        status <- map["status"]
        settingdetail <- map["items"]
        isaccepted <- map["isaccepted"]
    }
}

class Topic: Mappable{
    var topicid:Int?
    var topicname:String?
    var subgroupid:Int?
    var items:[TopicItem]?
    var status:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        topicid <- map["topicid"]
        topicname <- map["topicname"]
        subgroupid <- map["subgroupid"]
        items <- map["items"]
        status <- map["status"]
    }
}

class TopicItem: Mappable{
    var subtopicid:Int?
    var subtopicname:String?
    var topicid:Int?
    var channeltype:Int?
    var status:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        subtopicid <- map["subtopicid"]
        subtopicname <- map["subtopicname"]
        topicid <- map["topicid"]
        channeltype <- map["channeltype"]
        status <- map["status"]
    }
}

class Upload: Mappable{
    var filepath:String?
    var mimeType:String?
    var filename:String?
    var width:Int?
    var height:Int?
    var thumbnail:String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        filepath <- map["filepath"]
        mimeType <- map["mimeType"]
        filename <- map["filename"]
        width <- map["width"]
        height <- map["height"]
        thumbnail <- map["thumbnail"]
    }
}

class PrivateRoom: Mappable{
    var privateroomid:Int?
    var privateroomname:String?
    var membercount:Int?
    var privateroomimage:String?
    var uuid:String?
    var items=MemberInRoom()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        privateroomid <- map["privateroomid"]
        privateroomname <- map["privateroomname"]
        membercount <- map["membercount"]
        privateroomimage <- map["privateroomimage"]
        uuid <- map["uuid"]
        items <- map["items"]
    }
}

class MemberInRoom: Mappable{
    var userid:Int?
    var otheruserid:Int?
    
    init() {
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userid <- map["userid"]
        otheruserid <- map["otheruserid"]
    }
}

class ClassRequest: Mappable{
    var requestid:Int?
    var userid:Int?
    var subgroupid:Int?
    var subgroupname:String?
    var username:String?
    var groupid:Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        requestid <- map["requestid"]
        userid <- map["userid"]
        subgroupid <- map["subgroupid"]
        subgroupname <- map["subgroupname"]
        username <- map["username"]
        groupid <- map["groupid"]
    }
}
