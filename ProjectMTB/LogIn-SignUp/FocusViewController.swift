//
//  FocusViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Validator
import Device
import SwiftEntryKit
import KRProgressHUD
import Alamofire
import AlamofireObjectMapper

class FocusViewController: UIViewController {

    @IBOutlet var signupTopConstraint: NSLayoutConstraint!
    @IBOutlet var signupBottomConstraint: NSLayoutConstraint!
    @IBOutlet var validateemail: UILabel!
    @IBOutlet var validateconfirmpass: UILabel!
    @IBOutlet var validatepass: UILabel!
    @IBOutlet var validateusername: UILabel!
    @IBOutlet var email: UITextField!
    @IBOutlet var confirmpass: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var username: UITextField!
    @IBOutlet var btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        username.delegate = self
        password.delegate = self
        confirmpass.delegate = self
        email.delegate = self
        
        btn.layer.cornerRadius = 2.34
        
        username.attributedPlaceholder = NSAttributedString(string: "At least 7 characters", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        password.attributedPlaceholder = NSAttributedString(string: "Be Creative", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        confirmpass.attributedPlaceholder = NSAttributedString(string: "Retype Your Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        email.attributedPlaceholder = NSAttributedString(string: "Your Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        username.clearButtonMode = .whileEditing
        password.clearButtonMode = .whileEditing
        confirmpass.clearButtonMode = .whileEditing
        email.clearButtonMode = .whileEditing
        btn.layer.cornerRadius = 6
        
        let paddingView1 = UIView(frame: CGRect(x: 0,y: 0,width: 20,height: self.username.frame.height))
        let imageview1 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: paddingView1.frame.height))
        imageview1.image = UIImage(named: "icons8-name-filled-100")
        imageview1.contentMode = .scaleAspectFit
        paddingView1.addSubview(imageview1)
        username.leftView = paddingView1
        username.leftViewMode = UITextFieldViewMode.always
        let paddingView2 = UIView(frame: CGRect(x: 0,y: 0,width: 20,height: self.password.frame.height))
        let imageview2 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: paddingView2.frame.height))
        imageview2.image = UIImage(named: "icons8-lock-filled-100")
        imageview2.contentMode = .scaleAspectFit
        paddingView2.addSubview(imageview2)
        password.leftView = paddingView2
        password.leftViewMode = UITextFieldViewMode.always
        let paddingView3 = UIView(frame: CGRect(x: 0,y: 0,width: 20,height: self.confirmpass.frame.height))
        let imageview3 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: paddingView3.frame.height))
        imageview3.image = UIImage(named: "icons8-lock-filled-100")
        imageview3.contentMode = .scaleAspectFit
        paddingView3.addSubview(imageview3)
        confirmpass.leftView = paddingView3
        confirmpass.leftViewMode = UITextFieldViewMode.always
        let paddingView4 = UIView(frame: CGRect(x: 0,y: 0,width: 20,height: self.email.frame.height))
        let imageview4 = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: paddingView4.frame.height))
        imageview4.image = UIImage(named: "icons8-new-post-100")
        imageview4.contentMode = .scaleAspectFit
        paddingView4.addSubview(imageview4)
        email.leftView = paddingView4
        email.leftViewMode = UITextFieldViewMode.always
        
        SignUpScreenSize()
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
        if confirmpass.layer.sublayers != nil{
            for layer in confirmpass.layer.sublayers!{
                if layer.name == "customLayer"{
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        if email.layer.sublayers != nil{
            for layer in email.layer.sublayers!{
                if layer.name == "customLayer"{
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        
        btn.layer.addShadow(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), offset: CGSize(width: 0.0, height: 2.0), opacity: 1, radius: 0)
        username.layer.addBorder(toSide: .Bottom, withColor: UIColor(hex: "#3AD29F").cgColor, andThickness: 0.7)
        password.layer.addBorder(toSide: .Bottom, withColor: UIColor(hex: "#3AD29F").cgColor, andThickness: 0.7)
        confirmpass.layer.addBorder(toSide: .Bottom, withColor: UIColor(hex: "#3AD29F").cgColor, andThickness: 0.7)
        email.layer.addBorder(toSide: .Bottom, withColor: UIColor(hex: "#3AD29F").cgColor, andThickness: 0.7)
    }
    
    @IBAction func signuppressed(_ sender: Any) {
        validateusername.isHidden = false
        validatepass.isHidden = false
        validateconfirmpass.isHidden = false
        validateemail.isHidden = false
        if checkUsername() &&
        checkPassword() &&
        checkConfirmPassword() &&
            checkEmail(){
            KRProgressHUD.show(withMessage: "Loading...") {
                self.Signin(downloadString: "\(Link.link)/Login/userSignin", param: ["username":self.username.text!,"email":self.email.text!,"password":self.password.text!]) { (status) in
                    if let status = status{
                        if status == "200"{
                            self.username.text=""
                            self.password.text=""
                            self.email.text=""
                            self.confirmpass.text=""
                            KRProgressHUD.showSuccess(withMessage: "Registration Success!")
                            DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                                KRProgressHUD.dismiss()
                            })
                        }else{
                            KRProgressHUD.showError(withMessage: "Email Already Used!")
                            DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                                KRProgressHUD.dismiss()
                            })
                        }
                    }else{
                        KRProgressHUD.showError(withMessage: "Check Your Connection Again!")
                        DispatchQueue.main.asyncAfter(deadline: .now()+4, execute: {
                            KRProgressHUD.dismiss()
                        })
                    }
                }
            }
        }
    }
    
}

extension FocusViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FocusViewController{
    func checkUsername() -> Bool{
        var validationRules=ValidationRuleSet<String>()
        let lengthRule = ValidationRuleLength(min: 3, max: 30, lengthType: .characters, error: ValidationError(name: "Range from 3 - 30 characters"))
        validationRules.add(rule: lengthRule)
        let result = username.text?.validate(rules: validationRules)
        switch result {
        case .valid?:
            validateusername.text = "Good"
            validateusername.textColor = UIColor.green
            return true
        case .invalid(let failures)?:
            validateusername.text = (failures.first as! ValidationError).name
            validateusername.textColor = UIColor(hex: "#FF696C")
            return false
        case .none:
            return false
        }
    }
    func checkPassword() -> Bool{
        var validationRules=ValidationRuleSet<String>()
        let lengthRule = ValidationRuleLength(min: 3, max: 30, lengthType: .characters, error: ValidationError(name: "Range from 3 - 30 characters"))
        validationRules.add(rule: lengthRule)
        let result = password.text?.validate(rules: validationRules)
        switch result {
        case .valid?:
            validatepass.text = "Good"
            validatepass.textColor = UIColor.green
            return true
        case .invalid(let failures)?:
            validatepass.text = (failures.first as! ValidationError).name
            validatepass.textColor = UIColor(hex: "#FF696C")
            return false
        case .none:
            return false
        }
    }
    func checkConfirmPassword() -> Bool{
        var validationRules=ValidationRuleSet<String>()
        let lengthRule = ValidationRuleLength(min: 3, max: 30, lengthType: .characters, error: ValidationError(name: "Range from 3 - 30 characters"))
        validationRules.add(rule: lengthRule)
        let equalRule = ValidationRuleEquality(dynamicTarget: {
            return self.password.text ?? ""
        }, error: ValidationError(name: "Password does not match"))
        validationRules.add(rule: equalRule)
        let result = confirmpass.text?.validate(rules: validationRules)
        switch result {
        case .valid?:
            validateconfirmpass.text = "Good"
            validateconfirmpass.textColor = UIColor.green
            return true
        case .invalid(let failures)?:
            validateconfirmpass.text = (failures.first as! ValidationError).name
            validateconfirmpass.textColor = UIColor(hex: "#FF696C")
            return false
        case .none:
            return false
        }
    }
    func checkEmail() -> Bool{
        var validationRules=ValidationRuleSet<String>()
        let requireRule = ValidationRuleRequired<String>(error: ValidationError(name: "Field Required"))
        validationRules.add(rule: requireRule)
        let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: ValidationError(name: "Invalid Email"))
        validationRules.add(rule: emailRule)
        let result = email.text?.validate(rules: validationRules)
        switch result {
        case .valid?:
            validateemail.text = "Good"
            validateemail.textColor = UIColor.green
            return true
        case .invalid(let failures)?:
            validateemail.text = (failures.first as! ValidationError).name
            validateemail.textColor = UIColor(hex: "#FF696C")
            return false
        case .none:
            return false
        }
    }
}

extension FocusViewController {
    func SignUpScreenSize() {
        switch Device.size() {
        case .screen4Inch:
            signupBottomConstraint.constant = 10
            signupTopConstraint.constant = 20
            break
        case .screen4_7Inch:
            signupBottomConstraint.constant = 30
            signupTopConstraint.constant = 35
            break
        case .screen5_5Inch,.screen5_8Inch:
            signupBottomConstraint.constant = 55
            signupTopConstraint.constant = 40
            break
        default:
            print("Unknown size")
        }
    }
}

extension FocusViewController{
    func Signin(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String, Any>
                    complete(json["status"] as? String)
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
