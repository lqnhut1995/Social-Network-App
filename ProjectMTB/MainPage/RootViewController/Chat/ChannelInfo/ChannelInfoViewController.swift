//
//  ChannelInfoViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/1/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import AlamofireObjectMapper
import NVActivityIndicatorView
import DKImagePickerController

enum FType{
    case AddFriendType
    case ChannelSettingType
    case DirectMessage
}

class ChannelInfoViewController: FormViewController {

    var profile:ProfileRow!
    var btn1:ButtonRow!
    var btn2:ButtonRow!
    var btn3:ButtonRow!
    var btn4:ButtonRow!
    var btn5:ButtonRow!
    var btn6:ButtonRow!
    var delete:ButtonRow!
    var noChannelView:UINavigationController!
    var smContent:SMContentViewController!
    var subtopic:TopicItem!
    var privateroom:PrivateRoom!
    
    var name:TextRow!
    var type:FType!
    
    var originRightBar:UIBarButtonItem!
    var indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20), type: .ballSpinFadeLoader, color: .white, padding: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(hex: "#EBEBF1")
        automaticallyAdjustsScrollViewInsets = false
        tableView?.contentInset = UIEdgeInsetsMake(42, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initType(type: FType){
        self.type=type
        switch type {
        case .ChannelSettingType:
            self.navigationItem.title = "Channel Setting"
            self.navigationItem.rightBarButtonItem?.isEnabled=false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            noChannelView=UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "nochangeview") as! UINavigationController
            
            name = TextRow() {
                $0.title = $0.tag
                $0.tag = "0"
                $0.placeholder = "Channel Name"
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                })
            btn1 = ButtonRow("Catagory") {
                $0.title = $0.tag
                $0.tag = "1"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            btn2 = ButtonRow("Notification Settings") {
                $0.title = $0.tag
                $0.tag = "2"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            btn3 = ButtonRow("Pinned Messages") {
                $0.title = $0.tag
                $0.tag = "3"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            btn4 = ButtonRow("Permissions") {
                $0.title = $0.tag
                $0.tag = "4"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            delete = ButtonRow("Delete Channel"){
                $0.title = $0.tag
                $0.tag = "6"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.onCellSelection(self.deletebtnpressed)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.backgroundColor = UIColor(hex: "#FF696C")
                })
            form
                +++ name
                +++ Section(){ section in
                    section.header = Link.customHeader(text: "Catagory", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                }
                <<< btn1
                +++ Section()
                <<< btn2
                <<< btn3
                +++ Section()
                <<< btn4
                +++ Section()
                <<< delete
        case .DirectMessage:
            self.navigationItem.title = "Private Room Setting"
            self.navigationItem.rightBarButtonItem?.isEnabled=false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            noChannelView=UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "nochangeview") as! UINavigationController
            profile = ProfileRow(){
                $0.tag = "4"
                $0.value = User(name: privateroom.privateroomname!, id: "#\(privateroom.privateroomid!)", image: privateroom.privateroomimage != nil ? privateroom.privateroomimage! : nil)
                $0.cell.imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
                }.cellUpdate({ (cell, row) in
                    cell.height = ({return 140})
                    cell.imageview.tintColor = .white
                })
            btn1 = ButtonRow("Start Voice Call") {
                $0.title = $0.tag
                $0.tag = "0"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            btn2 = ButtonRow("Start Video Call") {
                $0.title = $0.tag
                $0.tag = "1"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            btn3 = ButtonRow("View Profiles") {
                $0.title = $0.tag
                $0.tag = "2"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
            delete = ButtonRow("Delete Private Room"){
                $0.title = $0.tag
                $0.tag = "3"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.onCellSelection(self.deletebtnpressed)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .white
                    cell.backgroundColor = UIColor(hex: "#FF696C")
                })
            form
                +++ Section()
                <<< profile
                +++ Section()
                <<< btn1
                <<< btn2
                <<< btn3
                +++ Section()
                <<< delete
        default:
            self.navigationItem.title = "Add Friend"
            name=TextRow(){
                $0.tag = "0"
                $0.placeholder = "Enter User Tag"
                }.cellUpdate({ (cell, row) in
                    cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                })
            form +++ Section(){ section in
                
                }
                <<< name
        }
    }
    
    func deletebtnpressed(cell: ButtonCellOf<String>, row: ButtonRow){
        switch type{
        case .DirectMessage:
            self.DeleteRoom(downloadString: Link.link+"/Mainpage/DeletePrivateRoom", param: ["privateroomid":self.privateroom.privateroomid!])
        default:
            self.DeleteRoom(downloadString: Link.link+"/Mainpage/DeleteSubTopic", param: ["subtopicid":self.subtopic.subtopicid!])
        }
        
    }
    
    @IBAction func closebtnpressed(_ sender: Any) {
        switch self.type {
        case .ChannelSettingType,.DirectMessage:
            performSegue(withIdentifier: "unwindtochatview", sender: self)
        default:
            performSegue(withIdentifier: "unwindtorootview", sender: self)
        }
    }
    
    @IBAction func requestbtnpressed(_ sender: Any) {
        if let text=name.value{
            if Int(text) == nil{
                return
            }
        }else{
            return
        }
        let barbutton=UIBarButtonItem(customView: indicator)
        originRightBar=navigationItem.rightBarButtonItem
        navigationItem.setRightBarButton(barbutton, animated: true)
        indicator.startAnimating()
        self.AddFriend(downloadString: Link.link+"/Friends/FriendRequest", param: ["userid":sk.user.userid!,"requestuserid":self.name.value!])
    }
    
    @objc func chooseImage(){
        let picker=DKImage()
        picker.UIDelegate=CustomUIDelegate()
        picker.allowMultipleTypes=false
        picker.showsCancelButton=true
        picker.maxSelectableCount=1
        picker.assetType = .allPhotos
        
        picker.didSelectAssets = { [weak self](assets: [DKAsset]) in
            for item in assets{
                item.fetchOriginalImageWithCompleteBlock({ [weak self](image, info) in
                    guard let this=self else {return}
                    this.Upload(downloadString: "\(Link.link)/Mainpage/uploadsGroup", image: [image!], complete: { [weak self](upload) in
                        if let upload=upload{
                            if upload.count > 0{
                                self?.SavePrivateRoom(downloadString: "\(Link.link)/Login/SavePrivateRoomImage", param: ["privateroomid":self!.privateroom.privateroomid!,"privateroomimage":upload[0].filepath!]) { [weak self](string) in
                                    if string != nil{
                                        self?.profile.cell.imageview.image = image
                                        self?.privateroom.privateroomimage = upload[0].filepath!
                                    }
                                }
                            }
                        }
                    })
                })
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
}

extension ChannelInfoViewController{
    func DeleteRoom(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self](response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            switch self?.type{
                            case .DirectMessage?:
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"reloadSMFriend"), object: nil, userInfo: nil)
                            default:
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"reloadSMContent"), object: nil, userInfo: nil)
                            }
                            self?.sideMenuController?.rootViewController = self?.noChannelView
                            self?.performSegue(withIdentifier: "unwindtonochannel", sender: self)
                        }
                    }
                }
                break
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
            }
        }
    }
    
    func AddFriend(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self](response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            self?.performSegue(withIdentifier: "unwindtorootview", sender: self)
                        }
                    }
                }
                break
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
            }
            DispatchQueue.main.async {
                self?.indicator.stopAnimating()
                self?.navigationItem.setRightBarButton(self?.originRightBar, animated: true)
            }
        }
    }
    
    func SavePrivateRoom(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let data = data as! Dictionary<String,Any>
                    if data["status"] as! String == "200"{
                        complete("200")
                    }else{
                        complete(nil)
                    }
                }else{
                    complete(nil)
                }
                break
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
                complete(nil)
            }
        }
    }
    
    func Upload(downloadString:String,image: [UIImage], complete: @escaping ([Upload]?) -> ()){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for item in image{
                multipartFormData.append(UIImageJPEGRepresentation(item, 0.25)!, withName: "files", fileName: "image", mimeType: "image/jpeg")
            }
            
        }, usingThreshold: UInt64.init(), to: downloadString, method: .post, headers: ["Content-type": "multipart/form-data"]) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseArray { (response: DataResponse<[Upload]>) in
                    if let data=response.result.value{
                        data.count > 0 ? complete(data) : complete(nil)
                    }
                }
            case .failure(let error):
                if let err = error as? URLError, err.code == URLError.Code.notConnectedToInternet{
                    DispatchQueue.main.async
                        {
                            
                    }
                } else {
                    // other failures
                }
                complete(nil)
            }
        }
    }
}
