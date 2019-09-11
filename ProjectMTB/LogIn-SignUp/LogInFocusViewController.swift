//
//  LogInFocusViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import SwiftEntryKit
import KRProgressHUD
import Alamofire
import AlamofireObjectMapper
import SocketIO

class sk{
    static var socket=SocketManager(socketURL: URL(string: Link.link)!)
    static var user:userLogin!
    static var permission=[SettingDetail]()
}

class LogInFocusViewController: UIViewController {

    @IBOutlet var loginbtn: UIButton!
    @IBOutlet var validation: UILabel!
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    var customView:EKFormMessageView!
    var attr:EKAttributes!
    var alertCustomView:EKNotificationMessageView!
    var attrAlert:EKAttributes!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        username.delegate = self
        password.delegate = self
        username.text = "lqnhut1995@gmail.com"
        password.text = "lamquangnhut"
        
        username.attributedPlaceholder = NSAttributedString(string: "Your Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        password.attributedPlaceholder = NSAttributedString(string: "Your Pass", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        username.clearButtonMode = .whileEditing
        password.clearButtonMode = .whileEditing
        loginbtn.layer.cornerRadius = 6
        
        let paddingView1 = UIView(frame: CGRect(x: 0,y: 0,width: 20,height: self.username.frame.height))
        let imageview1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: paddingView1.frame.height))
        imageview1.image = UIImage(named: "icons8-new-post-100")
        imageview1.contentMode = .scaleAspectFit
        paddingView1.addSubview(imageview1)
        username.leftView = paddingView1
        username.leftViewMode = UITextFieldViewMode.always
        let paddingView2 = UIView(frame: CGRect(x: 0,y: 0,width: 20,height: self.username.frame.height))
        let imageview2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: paddingView2.frame.height))
        imageview2.image = UIImage(named: "icons8-lock-filled-100")
        imageview2.contentMode = .scaleAspectFit
        paddingView2.addSubview(imageview2)
        password.leftView = paddingView2
        password.leftViewMode = UITextFieldViewMode.always
        
        resetPassword()
        confirmPassword()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if sk.socket.defaultSocket.status == .connected{
            sk.socket.defaultSocket.disconnect()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if username.layer.sublayers != nil{
            for layer in username.layer.sublayers!{
                if layer.name == "customLayer"{
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        if password.layer.sublayers != nil{
            for layer in password.layer.sublayers!{
                if layer.name == "customLayer"{
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        
        loginbtn.layer.addShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), offset: CGSize(width: 0.0, height: 2.0), opacity: 1, radius: 0)
        username.layer.addBorder(toSide: .Bottom, withColor: UIColor(hex: "#3AD29F").cgColor, andThickness: 0.7)
        password.layer.addBorder(toSide: .Bottom, withColor: UIColor(hex: "#3AD29F").cgColor, andThickness: 0.7)
    }
    
    @IBAction func loginpressed(_ sender: Any) {
        if username.text != nil || password.text != nil{
            if username.text == "" || password.text == ""{
                validation.text = "Check Your Email And Password"
                validation.isHidden = false
                validation.textColor = UIColor(hex: "#FF696C")
                return
            }else{
                validation.text = "Good"
                validation.textColor = UIColor.green
            }
        }else {
            validation.text = "Check Your Email And Password"
            validation.isHidden = false
            validation.textColor = UIColor(hex: "#FF696C")
            return
        }
        KRProgressHUD.show(withMessage: "Loading...") {
            self.Login(downloadString: "\(Link.link)/Login/userLogin", param: ["email":self.username.text!,"password":self.password.text!], complete: {
                [weak self](user) in
                if user != nil{
                    DispatchQueue.main.async {
                        sk.user=user
                        sk.socket = SocketManager(socketURL: URL(string: Link.link)!)
                        sk.socket.defaultSocket.on("construct", callback: { (data, ack) in
                            sk.socket.defaultSocket.emit("userconnect", with: [["userid":sk.user.userid!]])
                        })
                        sk.socket.defaultSocket.connect()
                        UserDefaults.standard.setValue(user?.toJSONString(prettyPrint: true), forKey: "user")
                        let mainpage=UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainPage") as! MainPageViewController
                        let leftview=mainpage.leftViewController as! LeftViewController
                        leftview.userId.text = "#\(user!.userid!)"
                        leftview.userName.text = user!.username
                        if user!.userimage != nil{
                            leftview.userImage.kf.setImage(with: URL(string: user!.userimage!)!)
                        }
                        leftview.loadGroup(userid: user!.userid!)
                        self?.present(mainpage, animated: false, completion: nil)
                    }
                    KRProgressHUD.dismiss()
                }else{
                    KRProgressHUD.showError(withMessage: "Check Your Connection Again!")
                    DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                        KRProgressHUD.dismiss()
                    })
                }
            })
        }
    }
    
    @IBAction func forgotpasspressed(_ sender: Any) {
        SwiftEntryKit.display(entry: customView, using: attr)
    }
    
    func resetPassword(){
        attr=EKAttributes.centerFloat
        let style=FormStyle.light
        let btn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Submit", style: style.buttonTitle), backgroundColor: UIColor(hex: "#FF696C"), highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            
            SwiftEntryKit.display(entry: self.alertCustomView, using: self.attrAlert)
        })
        let textFields = FormFieldPresetFactory.fields(by: [.email], style: style)
        let label=EKProperty.LabelContent(text: "Reset Your Password", style: style.title)
        attr.popBehavior = EKAttributes.PopBehavior.overridden
        attr.entryBackground = .color(color: UIColor.white)
        attr.screenBackground = .color(color: .dimmedDarkBackground)
        attr.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 0.7, initialVelocity: 0)),
                                             scale: .init(from: 0.7, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attr.positionConstraints.maxSize = .init(width: EKAttributes.PositionConstraints.Edge.constant(value: self.view.frame.width-50), height: .intrinsic)
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.displayDuration = .infinity
        attr.roundCorners = .all(radius: 8)
        customView=EKFormMessageView(with: label, textFieldsContent: textFields, buttonContent: btn)
    }
    
    func confirmPassword(){
//        let style=FormStyle.light
        let alertImage=EKProperty.ImageContent(image: UIImage(named: "ic_done_all_light_48pt")!, size: CGSize(width: 48, height: 48), contentMode: UIViewContentMode.scaleAspectFit, makeRound: false)
        let font:EKProperty.LabelStyle = .init(font: UIFont(name: "Helvetica Neue", size: CGFloat(14))!, color: UIColor.white, alignment: .center)
        let title=EKProperty.LabelContent(text: "Congrats", style: font)
        let description=EKProperty.LabelContent(text: "Please check your email on how to reset your password", style: font)
//        let btn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Dismiss!", style: EKProperty.LabelStyle(font: UIFont(name: "Helvetica Neue", size: 14)!, color: UIColor.black)), backgroundColor: UIColor.white, highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
//
//        })
//        alertCustomView=EKPopUpMessageView(with: EKPopUpMessage(themeImage: EKPopUpMessage.ThemeImage(image: alertImage), title: title, description: description, button: btn, action: {
//            SwiftEntryKit.dismiss()
//        }))
//        alertCustomView=EKNotificationMessageView(with: EKNotificationMessage(simpleMessage: EKSimpleMessage(title: title, description: description)))
        alertCustomView=EKNotificationMessageView(with: EKNotificationMessage(simpleMessage: EKSimpleMessage(image: alertImage, title: title, description: description), auxiliary: nil, insets: EKNotificationMessage.Insets.default))
        attrAlert=EKAttributes.topToast
        attrAlert.entryBackground = .gradient(gradient: .init(colors: [UIColor(hex: "#FF696C"), UIColor(hex: "#EF473A")], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attrAlert.screenBackground = .color(color: .dimmedDarkBackground)
        attrAlert.entranceAnimation = .translation
//        attrAlert.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attrAlert.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attrAlert.screenInteraction = .dismiss
        attrAlert.entryInteraction = .absorbTouches
        attrAlert.displayDuration = 5
//        attrAlert.roundCorners = .all(radius: 20)
    }
}

extension LogInFocusViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LogInFocusViewController{
    func Login(downloadString:String, param: [String:Any], complete: @escaping (userLogin?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[userLogin]>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    data.count > 0 ? complete(data[0]) : complete(nil)
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
