//
//  GroupSettingViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/29/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import DKImagePickerController
import Alamofire
import AlamofireObjectMapper
import NVActivityIndicatorView

enum GroupType{
    case CreateGroup
    case JoinGroup
}

class GroupCreatingViewController: FormViewController {

    var profile:ProfileRow!
    var name:TextRow!
    var leftView:LeftViewController!
    var userid=0
    var isimagepicked=false
    var originRightBar:UIBarButtonItem!
    var indicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20), type: .ballSpinFadeLoader, color: .white, padding: nil)
    var grouptype:GroupType!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }
    
    func setupCreateGroup(){
        navigationItem.title = "Create Group"
        navigationItem.rightBarButtonItem?.title = "Create"
        grouptype = .CreateGroup
        profile = ProfileRow(){
            $0.tag = "0"
            $0.value = User(name: "CHOOSE IMAGE", id: "", image: nil)
            $0.cell.imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
            
            }.cellUpdate({ (cell, row) in
                cell.height = ({return 140})
                cell.imageview.tintColor = .white
            })
        name=TextRow(){
            $0.tag = "1"
            $0.placeholder = "Enter Name Here"
            }.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            })
        
        form +++ Section(){ section in
            section.header = Link.customHeader(text: "Profile Image", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            }
            <<< profile
            +++ Section(){ section in
                section.header = Link.customHeader(text: "Nickname", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                
            }
            <<< name
    }
    
    func setupJoinGroup(){
        navigationItem.title = "Join Group"
        navigationItem.rightBarButtonItem?.title = "Join"
        grouptype = .JoinGroup
        name=TextRow(){
            $0.tag = "1"
            $0.placeholder = "Enter Group ID"
            }.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            })
        
        form +++ Section(){ section in
                section.header = Link.customHeader(text: "Group ID", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                
            }
            <<< name
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
    
    @objc func chooseImage(){
        let picker=DKImage()
        picker.UIDelegate=CustomUIDelegate()
        picker.allowMultipleTypes=false
        picker.showsCancelButton=true
        picker.maxSelectableCount=1
        picker.assetType = .allPhotos
        
        picker.didSelectAssets = { [weak self](assets: [DKAsset]) in
            self?.isimagepicked=true
            for item in assets{
                    item.fetchOriginalImageWithCompleteBlock({ [weak self](image, info) in
                        self?.profile.cell.imageview.image = image
                    })
            }
        }
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func createGroup(_ sender: Any) {
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
        
        switch grouptype {
        case .CreateGroup:
            if isimagepicked{
                self.Upload(downloadString: "\(Link.link)/Mainpage/uploadsGroup", image: [self.profile.cell.imageview.image!]) { (upload) in
                    if let upload = upload{
                        if upload.count > 0{
                            self.CreateGroup(downloadString: "\(Link.link)/Mainpage/CreateGroup", param: ["userid":self.userid,"groupname":self.name.value!,"groupimage":upload[0].filepath!])
                        }
                    }
                }
            }else{
                self.CreateGroup(downloadString: "\(Link.link)/Mainpage/CreateGroup", param: ["userid":self.userid,"groupname":self.name.value!])
            }
        default:
            if !CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: name.value!)){
                return
            }
            JoinGroup(downloadString: "\(Link.link)/Mainpage/JoinGroup", param: ["userid":self.userid,"groupid":self.name.value!])
        }
        
    }
    
}

extension GroupCreatingViewController{
    func CreateGroup(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Group>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    if data.status == "200"{
                        DispatchQueue.main.async {
                            self.isimagepicked=false
                            self.leftView.group.append(data)
                            self.leftView.menuViewController?.reloadData()
                            self.dismiss(animated: true, completion: nil)
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
                self.indicator.stopAnimating()
                self.navigationItem.setRightBarButton(self.originRightBar, animated: true)
            }
        }
    }
    
    func JoinGroup(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseObject { (response: DataResponse<Group>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    DispatchQueue.main.async {
                        self.leftView.group.append(data)
                        self.leftView.menuViewController?.reloadData()
                        self.dismiss(animated: true, completion: nil)
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
                self.indicator.stopAnimating()
                self.navigationItem.setRightBarButton(self.originRightBar, animated: true)
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
