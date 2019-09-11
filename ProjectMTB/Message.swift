//
//  Message.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/21/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper

enum MessageType{
    case TextType
    case ImageType
    case VideoType
    case PreviewType
}

class TransactionSerializationTransform: TransformType {
    typealias Object = MessageItem
    typealias JSON = [String: AnyObject]
    
    init() {}
    
    public func transformFromJSON(_ value: Any?) -> MessageItem? {
        guard
            let json = value as? JSON,
            let typeString = json["datatype"] as? String
            else { return nil }
        
        if typeString == "text"{
            return Mapper<TextItem>().map(JSON: json)
        }else if typeString.contains("image"){
            return Mapper<ImageItem>().map(JSON: json)
        }else if typeString.contains("video"){
            return Mapper<VideoItem>().map(JSON: json)
        }else if typeString == "preview"{
            return Mapper<PreviewItem>().map(JSON: json)
        }
        return nil
    }
    
    func transformToJSON(_ value: Object?) -> JSON? {
        assertionFailure("Not implemented")
        return nil
    }
}

protocol MessageItem {
    var type:MessageType {get set}
    var id:Int {get set}
}

class TextItem: MessageItem,Mappable {
    var id: Int
    var type: MessageType
    var conversation:String
    
    init(type: MessageType,id: Int,conversation: String) {
        self.type=type
        self.id=id
        self.conversation=conversation
    }
    
    required init(map: Map) {
        id = 0
        type = .TextType
        conversation = ""
    }
    
    func mapping(map: Map) {
        id <- map["dataid"]
        conversation <- map["message"]
    }
}

class ImageItem: MessageItem,Mappable {
    var id: Int
    var type: MessageType
    var localImage:UIImage?
    var globalImage:String?
    var thumbnail:String?
    var name:String
    var size:CGSize
    
    init(type: MessageType,id: Int,localImage: UIImage?,globalImage: String?,thumbnail: String?,name: String,size: CGSize) {
        self.type=type
        self.id=id
        self.localImage=localImage
        self.globalImage=globalImage
        self.thumbnail=thumbnail
        self.name=name
        self.size=size
    }
    
    required init?(map: Map) {
        id=0
        type = .ImageType
        name=""
        size = .zero
    }
    
    func mapping(map: Map) {
        id <- map["dataid"]
        globalImage <- map["dataurl"]
        name <- map["dataname"]
        thumbnail <- map["datathumbnail"]
        size = CGSize(width: map.JSON["width"] as! Int, height: map.JSON["height"] as! Int)
    }
}

class VideoItem: MessageItem,Mappable {
    var id: Int
    var type: MessageType
    var name:String
    var url:URL?
    var size:Double
    
    init(type: MessageType,id: Int,name: String,url: URL?,size: Double) {
        self.type=type
        self.id=id
        self.name=name
        self.url=url
        self.size=size
    }
    
    required init?(map: Map) {
        id=0
        type = .VideoType
        name=""
        size = 0
    }
    
    func mapping(map: Map) {
        id <- map["dataid"]
        url = URL(string: (map.JSON["dataurl"] as! String))
        name <- map["dataname"]
        size <- map["size"]
    }
}

class PreviewItem: MessageItem,Mappable {
    var id: Int
    var type: MessageType
    var url:URL?
    var title:String?
    var description:String?
    var image:String?
    var icon:String?

    init(type: MessageType,id: Int,url: URL?,title: String?, description: String?,image: String?,icon: String?) {
        self.type=type
        self.id=id
        self.url=url
        self.title=title
        self.description=description
        self.image=image
        self.icon=icon
    }
    
    required init?(map: Map) {
        id=0
        type = .PreviewType
        url=nil
        title=nil
        description=nil
        image=nil
        icon=nil
    }
    
    func mapping(map: Map) {
        id <- map["dataid"]
        url = URL(string: (map.JSON["dataurl"] as! String))
        title <- map["title"]
        description <- map["description"]
        image <- map["image"]
        icon <- map["icon"]
    }
}
