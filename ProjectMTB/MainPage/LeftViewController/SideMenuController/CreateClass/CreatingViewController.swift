//
//  ClassCreatingViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/30/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import AlamofireObjectMapper
import DKImagePickerController
import Kingfisher
import NVActivityIndicatorView
import SwiftEntryKit

enum MultipleClassType{
    case ClassCreatingClass
    case ChannelCreatingClass
    case SubChannelCreatingClass
    case ClassSettingCLass
    case GroupSettingClass
    case RequestClass
}

class CreatingViewController: FormViewController {

    var name:TextRow!
    var classType:MultipleClassType!
    var subView:SubViewController!
    var smContent:SMContentViewController!
    var topic:[Topic]!
    var subgroup:[subGroup]!
    var group:Group!
    var thissubgroup:subGroup!
    var topicid=0
    
    var chooseChannel:SelectableSection<ImageCheckRow<String>>!
    var profile:ProfileRow!
    
    var originRightBar:UIBarButtonItem!
    var indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20), type: .ballSpinFadeLoader, color: .white, padding: nil)
    var groupPermissionView:EKAlertMessageView!
    var attr:EKAttributes!
    var tag=""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        groupPermission()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toclasssettingdetail"{
            let vc=segue.destination as! CatagoryChannelViewController
            let buttonrow=sender as! CustomButtonRow
            let text = buttonrow.cell.textLabel?.text
            vc.navTitle = text!
            if let topic=topic{
                vc.topic=topic
            }
            if let smContent=smContent{
                vc.smContent=smContent
            }
            if let subgroup=subgroup{
                vc.subgroup=subgroup
            }
            if let subView=subView{
                vc.subView=subView
            }
        }
        if segue.identifier == "tosettingdetail"{
            let vc=segue.destination as! SettingDetailViewController
            if let group=group{
                let buttonrow=sender as! CustomButtonRow
                let text = buttonrow.cell.textLabel?.text
                vc.navTitle = text!
                switch text{
                case "Overview":
                    vc.group=group
                    vc.setupOverview(type: .GroupOverview)
                case "Requests":
                    vc.setupRequests(groupid: group.groupid!)
                    break
                default:
                    break
                }
                
            }else{
                let buttonrow=sender as! CustomButtonRow
                let text = buttonrow.cell.textLabel?.text
                vc.navTitle = text!
                vc.subgroup=thissubgroup
                switch text{
                case "Overview":
                    vc.setupOverview(type: .ClassOverview)
                case "Members":
                    vc.setupMembers(subgroupid: thissubgroup.subgroupid!)
                    break
                case "Roles":
                    vc.setupRole(subgroupid: thissubgroup.subgroupid!)
                    break
                case "Bans":
                    break
                default:
                    break
                }
            }
            
        }
    }
    
    func initCustomClass(classType: MultipleClassType){
        self.classType=classType
        switch classType {
        case .ClassCreatingClass:
            self.navigationItem.title = "Create Class"
            initOtherCreatingClass()
        case .ChannelCreatingClass:
            self.navigationItem.title = "Create Channel's Catagory"
            initOtherCreatingClass()
        case .SubChannelCreatingClass:
            self.navigationItem.title = "Create Channel"
            initOtherCreatingChannel()
        case .GroupSettingClass:
            self.navigationItem.title = "Group Settings"
            self.navigationItem.rightBarButtonItem?.isEnabled=false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            initGroupSetting()
        case .RequestClass:
            self.navigationItem.title = "Request Class"
            self.navigationItem.rightBarButtonItem?.isEnabled=false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            initRequestClass()
        default:
            self.navigationItem.title = "Class Settings"
            self.navigationItem.rightBarButtonItem?.isEnabled=false
            self.navigationItem.rightBarButtonItem?.tintColor = .clear
            initClassSetting()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    @IBAction func createClass(_ sender: Any) {
        if let text=name.value{
            if text == ""{
                return
            }
        }else{
            return
        }
        let barbutton=UIBarButtonItem(customView: indicator)
        originRightBar=navigationItem.rightBarButtonItem
        navigationItem.setRightBarButton(barbutton, animated: true)
        indicator.startAnimating()
        switch classType {
        case .ClassCreatingClass:
            self.CreateClass(downloadString: "\(Link.link)/Mainpage/CreateSubGroup", param: ["groupid":self.group.groupid!,"subgroupname":self.name.value!])
        case .ChannelCreatingClass:
            self.CreateChannel(downloadString: "\(Link.link)/Mainpage/CreateTopic", param: ["subgroupid":self.thissubgroup.subgroupid!,"topicname":self.name.value!])
        case .SubChannelCreatingClass:
            if let row: ImageCheckRow<String>=chooseChannel.selectedRow(){
                self.CreateSubChannel(downloadString: "\(Link.link)/Mainpage/CreateSubTopic", param: ["topicid":self.topicid,"subtopicname":self.name.value!,"channeltype":Int(row.tag!)!])
            }
        default:
            break
        }
        
    }
    
    @IBAction func closebtnpressed(_ sender: Any) {
        switch classType {
        case .ClassCreatingClass,.GroupSettingClass,.RequestClass:
            performSegue(withIdentifier: "unwindtosubview", sender: self)
        default:
            performSegue(withIdentifier: "unwindtosmcontent", sender: self)
            
        }
    }
    
    //Create Channel
    func initOtherCreatingChannel(){
        chooseChannel = SelectableSection<ImageCheckRow<String>>("Choose Channel", selectionType: .singleSelection(enableDeselection: false)){ section in
            section.header = Link.customHeader(text: "Choose Channel", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
        }
        form +++ chooseChannel
        let continents = ["Text Channel", "Voice Channel", "Notification Channel"]
        for index in 0..<continents.count {
            form.last! <<< ImageCheckRow<String>(continents[index]){ listRow in
                listRow.title = continents[index]
                listRow.selectableValue = continents[index]
                listRow.value = nil
                listRow.tag=String(describing: index)
                listRow.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }
        }
        if let row: ImageCheckRow<String>=chooseChannel.rowBy(tag: "0"){
            row.didSelect()
        }
        
        name=TextRow(){
            $0.tag = "3"
            $0.placeholder = "Enter Channel Name Here"
            }.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            })
        form +++ Section(){ section in
            section.header = Link.customHeader(text: "Nickname", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            
            }
            <<< name
    }
    
    //Create Catagory's Channel
    func initOtherCreatingClass(){
        name=TextRow(){
            $0.tag = "3"
            $0.placeholder = "Enter Name Here"
            }.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            })
        form +++ Section(){ section in
            section.header = Link.customHeader(text: "Nickname", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            
            }
            <<< name
    }
    
    //Class Setting
    func initClassSetting(){
        form
            +++ Section(){ section in
                section.header = Link.customHeader(text: "Catagory's Channel Settings", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
        }
        let btn1 = CustomButtonRow("Overview") {
            $0.title = $0.tag
            $0.tag = "1"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.presentationMode = .segueName(segueName: "tosettingdetail", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.imageView?.image = UIImage(named: "overview")
                cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                row.updateSize(size: CGSize(width: 30, height: 30))
            })
        form.last!.append(btn1)
        
        if SubViewController.isadmin == 1 || sk.permission.contains(where: {$0.settingdetailid==60}){
            let btn2 = CustomButtonRow("Catagory") {
                $0.title = $0.tag
                $0.tag = "2"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "toclasssettingdetail", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.imageView?.image = UIImage(named: "catagory")
                    cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                    row.updateSize(size: CGSize(width: 30, height: 30))
                })
            form.last!.append(btn2)
        }

        form
            +++ Section(){ section in
                section.header = Link.customHeader(text: "User Management", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
        }
        let btn3 = CustomButtonRow("Members") {
            $0.title = $0.tag
            $0.tag = "3"
            $0.cell.textLabel?.font = UIFont(name: "icons8-checked-user-male-29", size: 15)
            $0.presentationMode = .segueName(segueName: "tosettingdetail", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.imageView?.image = UIImage(named: "member")
                cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                row.updateSize(size: CGSize(width: 30, height: 30))
            })
        form.last!.append(btn3)
        
        if SubViewController.isadmin == 1 || sk.permission.contains(where: {$0.settingdetailid==57}) || sk.permission.contains(where: {$0.settingdetailid==59}){
            let btn4 = CustomButtonRow("Roles") {
                $0.title = $0.tag
                $0.tag = "4"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "tosettingdetail", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.imageView?.image = UIImage(named: "role")
                    cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                    row.updateSize(size: CGSize(width: 30, height: 30))
                })
            form.last!.append(btn4)
        }
        if SubViewController.isadmin == 1 || !sk.permission.contains(where: {$0.settingdetailid==60}){
            let btn5 = CustomButtonRow("Bans") {
                $0.title = $0.tag
                $0.tag = "5"
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "tosettingdetail", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.imageView?.image = UIImage(named: "ban")
                    cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                    row.updateSize(size: CGSize(width: 30, height: 30))
                })
            form.last!.append(btn5)
        }
        
    }
    
    //Group Setting
    func initGroupSetting(){
        profile = ProfileRow(){
            $0.tag = "0"
            $0.value = User(name: group.groupname!, id: "", image: group.groupimage == nil ? nil : group.groupimage!)
            $0.cell.imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
            
            }.cellUpdate({ (cell, row) in
                cell.height = ({return 160})
                cell.imageview.tintColor = UIColor.mainColor
            })
        let btn1 = CustomButtonRow("Overview") {
            $0.title = $0.tag
            $0.tag = "1"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.presentationMode = .segueName(segueName: "tosettingdetail", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.imageView?.image = UIImage(named: "overview")
                cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                row.updateSize(size: CGSize(width: 30, height: 30))
            })
        let btn2 = CustomButtonRow("Catagory") {
            $0.title = $0.tag
            $0.tag = "2"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.presentationMode = .segueName(segueName: "toclasssettingdetail", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.imageView?.image = UIImage(named: "catagory")
                cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                row.updateSize(size: CGSize(width: 30, height: 30))
            })
        let btn6 = CustomButtonRow("Requests") {
            $0.title = $0.tag
            $0.tag = "6"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.presentationMode = .segueName(segueName: "tosettingdetail", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.imageView?.image = UIImage(named: "request")
                cell.imageView?.tintColor = UIColor(hex: "#3AD29F")
                row.updateSize(size: CGSize(width: 30, height: 30))
            })
        form
        +++ profile
        form
            +++ Section(){ section in
                section.header = Link.customHeader(text: "Settings", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            }
            <<< btn1
            <<< btn2
        form
            +++ Section(){ section in
                section.header = Link.customHeader(text: "User Management", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            }
            <<< btn6
        
    }
    
    //pick image
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
                    self?.profile.cell.imageview.image = image
                })
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    func initRequestClass(){
        var section = Section()
        form +++ section
        self.LoadSubGroup(downloadString: "\(Link.link)/Mainpage/LoadRequestClassFromUser", param: ["groupid":group.groupid!,"userid":sk.user.userid!]) { (subGroup) in
            DispatchQueue.main.async {
                if let subGroup = subGroup{
                    if subGroup.count > 0{
                        for item in subGroup{
                            section.insert(ButtonRow(item.subgroupname!){
                                $0.title = $0.tag
                                $0.tag = String(describing: item.subgroupid!)
                                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                                }.cellUpdate({ (cell, row) in
                                    cell.textLabel?.textColor = .black
                                    cell.textLabel?.textAlignment = .left
                                    if item.isaccepted != nil{
                                        let label=UILabel()
                                        label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
                                        cell.accessoryView = label
                                        switch item.isaccepted!{
                                        case 0:
                                            label.text = "Requesting..."
                                            label.sizeToFit()
                                        case 1:
                                            label.textColor = UIColor(hex: "#3AD29F")
                                            label.text = "Accepted"
                                            label.sizeToFit()
                                        default:
                                            label.textColor = UIColor(hex: "#FF696C")
                                            label.text = "Denied"
                                            label.sizeToFit()
                                        }
                                    }else{
                                        let image=UIImageView(image: UIImage(named: "icons8-lock-filled-100"))
                                        image.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                                        cell.accessoryView = image
                                    }
                                }).onCellSelection({ (cell, row) in
                                    if self.group.isadmin! != 1{
                                        if item.isaccepted != nil {
                                            if item.isaccepted! != 0 && item.isaccepted! != 1{
                                                self.tag=String(describing: item.subgroupid!)
                                                SwiftEntryKit.display(entry: self.groupPermissionView, using: self.attr)
                                            }
                                        }else{
                                            self.tag=String(describing: item.subgroupid!)
                                            SwiftEntryKit.display(entry: self.groupPermissionView, using: self.attr)
                                        }
                                    }
                                }), at: 0)
                        }
                    }
                }
            }
        }
    }
    
    func groupPermission(){
        attr=EKAttributes.centerFloat
        let style=FormStyle.light
        var font:EKProperty.LabelStyle = .init(font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat(16))!, color: UIColor.white, alignment: .center)
        let acceptBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Request Join", style: style.buttonTitle), backgroundColor: UIColor(hex: "#3AD29F"), highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            if let btn:ButtonRow=self.form.last!.rowBy(tag: self.tag){
                let label=UILabel()
                label.text = "Requesting"
                label.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
                label.sizeToFit()
                btn.cell.accessoryView = label
                self.RequestClass(downloadString: "\(Link.link)/Mainpage/RequestClass", param: ["userid":sk.user.userid!,"subgroupid":Int(self.tag)!], complete: { (string) in
                    if string != nil{
                        
                    }
                })
            }
            SwiftEntryKit.dismiss()
        })
        let canceltBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Cancel", style: style.buttonTitle), backgroundColor: UIColor(hex: "#FF696C"), highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            SwiftEntryKit.dismiss()
        })
        font.color = .white
        let description=EKProperty.LabelContent(text: "", style: font)
        let label=EKProperty.LabelContent(text: "Request Class Permission", style: style.title)
        
        attr.popBehavior = EKAttributes.PopBehavior.overridden
        attr.entryBackground = .color(color: UIColor.white)
        attr.screenBackground = .color(color: .dimmedDarkBackground)
        attr.entranceAnimation = .none
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attr.positionConstraints.maxSize = .init(width: EKAttributes.PositionConstraints.Edge.constant(value: self.view.frame.width-50), height: .intrinsic)
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.displayDuration = .infinity
        attr.roundCorners = .all(radius: 8)
        groupPermissionView=EKAlertMessageView(with: EKAlertMessage(simpleMessage: EKSimpleMessage(title: label, description: description), buttonBarContent: EKProperty.ButtonBarContent(with: acceptBtn,canceltBtn, separatorColor: EKColor.Gray.light, buttonHeight: 50, expandAnimatedly: true)))
    }
}

extension CreatingViewController{
    func CreateClass(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseObject { [weak self](response: DataResponse<subGroup>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    if data.status == "200"{
                        DispatchQueue.main.async {
                            self?.subView.loadnewSubGroup(subgroup: data)
                            self?.dismiss(animated: true, completion: nil)
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
    
    func CreateChannel(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseObject { [weak self](response: DataResponse<Topic>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    if data.status == "200"{
                        DispatchQueue.main.async {
                            self?.smContent.loadnewTopic(topic: data)
                            self?.dismiss(animated: true, completion: nil)
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
    
    func CreateSubChannel(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseObject { [weak self](response: DataResponse<TopicItem>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    if data.status == "200"{
                        DispatchQueue.main.async {
                            self?.smContent.loadnewSubTopic(subtopic: data)
                            self?.dismiss(animated: true, completion: nil)
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
    
    func LoadSubGroup(downloadString:String, param: [String:Any], complete: @escaping ([subGroup]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[subGroup]>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    data.count > 0 ? complete(data) : complete(nil)
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
    
    func RequestClass(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result{
            case .success( _):
                if response.result.value != nil{
                    complete("")
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
}
