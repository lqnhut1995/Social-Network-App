//
//  Classes.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/16/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import DKImagePickerController
import Eureka

class Link{
    public static var link="https://communicateserver.ddns.net"
    public static func customHeader(text: String,size: CGSize,font: UIFont)-> HeaderFooterView<UIView>{
        let height=text.height(withConstrainedWidth: size.width-10, font: font)+10
        var header = HeaderFooterView<UIView>(.callback({
            let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: height))
            let title = UILabel(frame: CGRect(x: 10, y: 0, width: size.width-10, height: height))
            title.numberOfLines=0
            title.lineBreakMode = .byWordWrapping
            title.text = text
            title.font = font
            title.textColor = .gray
            view.addSubview(title)
            return view
        }))
        if size.height > 40{
            header.height = { height+10 }
        }else{
            header.height = { height }
        }
        return header
    }
}

class Message:Mappable{
    var messageid:Int
    var subtopicid:Int?
    var privateroomid:Int?
    var uploadtime:Int64
    var data=[MessageItem]()
    
    var userid:Int
    var username:String
    var userimage:String?
    var page:Int?
    
    init(messageid: Int,userid: Int,username: String,userimage: String?,subtopicid: Int,uploadtime: Int64,data: [MessageItem]) {
        self.messageid=messageid
        self.userid=userid
        self.userimage=userimage
        self.data=data
        self.subtopicid=subtopicid
        self.uploadtime=uploadtime
        self.username=username
        self.userimage=userimage
    }
    
    init(messageid: Int,userid: Int,username: String,userimage: String?,privateroomid: Int,uploadtime: Int64,data: [MessageItem]) {
        self.messageid=messageid
        self.userid=userid
        self.userimage=userimage
        self.data=data
        self.privateroomid=privateroomid
        self.uploadtime=uploadtime
        self.username=username
    }
    
    required init(map: Map) {
        messageid=0
        uploadtime=0
        userid=0
        username=""
    }
    
    func mapping(map: Map) {
        messageid <- map["messageid"]
        uploadtime <- map["uploadtime"]
        subtopicid <- map["subtopicid"]
        privateroomid <- map["privateroomid"]
        data <- (map["items"],TransactionSerializationTransform())
        
        userid <- map["userid"]
        username <- map["username"]
        userimage <- map["userimage"]
        page <- map["page"]
    }
    
    func getShortDate()->String{
        return Date.convertdatetimetos(lastmodified: Date.init(milliseconds: uploadtime), dateFormat: "HH:mm:ss")
    }
    
    func getFullDate()->String{
        return Date.convertdatetimetos(lastmodified: Date.init(milliseconds: uploadtime), dateFormat: "E, d MMM yyyy")
    }
    
    func getDateDetail()->String{
        return Date.convertdatetimetos(lastmodified: Date.init(milliseconds: uploadtime), dateFormat: "E, d MMM yyyy, HH:mm:ss")
    }
}

class ImageInfo{
    var localImage:Data?
    var globalImage:String?
    var thumbnail:String?
    var filename:String
    var size:CGSize?
    
    init(localImage: Data?, globalImage: String?, thumbnail: String?, filename: String,size: CGSize?){
        self.localImage=localImage
        self.globalImage=globalImage
        self.thumbnail=thumbnail
        self.filename=filename
        self.size=size
    }
}

class VideoInfo{
    var name:String
    var message:String
    var url:URL
    var size:Double
    
    init(name: String, message: String, url: URL, size: Double){
        self.name=name
        self.message=message
        self.url=url
        self.size=size
    }
}

class SearchField{
    var fieldName:String
    var fieldDescription:String
    var fieldExtraInfo:String
    
    init(fieldName:String,fieldDescription:String,fieldExtraInfo:String) {
        self.fieldName=fieldName
        self.fieldDescription=fieldDescription
        self.fieldExtraInfo=fieldExtraInfo
    }
}

class IceCandidate: Mappable{
    var sdp:String?
    var sdpMLineIndex:Int32?
    var sdpMid:String?
    
    init(sdp:String?,sdpMLineIndex:Int32?,sdpMid:String?){
        self.sdp=sdp
        self.sdpMLineIndex=sdpMLineIndex
        self.sdpMid=sdpMid
    }
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        sdp <- map["sdp"]
        sdpMLineIndex <- map["sdpMLineIndex"]
        sdpMid <- map["sdpMid"]
    }
}
