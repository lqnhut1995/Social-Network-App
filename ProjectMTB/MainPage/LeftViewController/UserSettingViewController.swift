//
//  UserSettingViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/27/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import DKImagePickerController
import NVActivityIndicatorView
import Alamofire
import AlamofireObjectMapper

class UserSettingViewController: FormViewController {

    var btn1:ButtonRow!
    var btn2:ButtonRow!
    var btn3:ButtonRow!
    var btn4:ButtonRow!
    var btn5:ButtonRow!
    var btn6:ButtonRow!
    var exit:ButtonRow!
    var profile:ProfileRow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(hex: "#EBEBF1")
        automaticallyAdjustsScrollViewInsets = false
        tableView?.contentInset = UIEdgeInsetsMake(62, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        profile = ProfileRow(){
            $0.tag = "7"
            $0.value = User(name: sk.user.username!, id: "#\(sk.user.userid!)", image: sk.user.userimage != nil ? sk.user.userimage! : nil)
            $0.cell.imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chooseImage)))
            }.cellUpdate({ (cell, row) in
                cell.height = ({return 140})
                cell.imageview.tintColor = .white
            })
        btn1 = ButtonRow("Account") {
            $0.title = $0.tag
            $0.tag = "0"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
//            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            })
        btn4 = ButtonRow("Privacy") {
            $0.title = $0.tag
            $0.tag = "3"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            //            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            })
        btn2 = ButtonRow("Voice") {
            $0.title = $0.tag
            $0.tag = "1"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
//            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            })
        btn3 = ButtonRow("Text & Image") {
            $0.title = $0.tag
            $0.tag = "2"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
//            $0.presentationMode = .segueName(segueName: "toSMContent", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            })
        exit = ButtonRow("Log Out"){
            $0.title = $0.tag
            $0.tag = "6"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.onCellSelection(self.exitbtnpressed)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
                cell.backgroundColor = UIColor(hex: "#FF696C")
            })
        form +++ Section(){ section in
            section.header = Link.customHeader(text: "Profile Image", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            }
            <<< profile
            +++ Section()
            <<< btn1
            <<< btn4
            +++ Section(){ section in
                section.header = Link.customHeader(text: "App Settings", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            }
            <<< btn2
            <<< btn3
            +++ Section()
            <<< exit
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
                    guard let this=self else {return}
                    this.Upload(downloadString: "\(Link.link)/Mainpage/uploadsGroup", image: [image!], complete: { [weak self](upload) in
                        if let upload=upload{
                            if upload.count > 0{
                                self?.SaveUser(downloadString: "\(Link.link)/Login/SaveUserImage", param: ["userid":sk.user.userid!,"imageurl":upload[0].filepath!]) { [weak self](string) in
                                    if string != nil{
                                        self?.profile.cell.imageview.image = image
                                        sk.user.userimage=upload[0].filepath!
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

    func exitbtnpressed(cell: ButtonCellOf<String>, row: ButtonRow){
        if let root=UIApplication.shared.keyWindow?.rootViewController,!root.isKind(of: LogInViewController.self){
            let loginview=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginview") as! LogInViewController
            UIApplication.shared.keyWindow?.rootViewController = loginview
            sk.socket.defaultSocket.disconnect()
        }
        UserDefaults.standard.removeObject(forKey: "user")
        performSegue(withIdentifier: "unwindToLogin", sender: nil)
    }
}

extension UserSettingViewController{
    func SaveUser(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
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
