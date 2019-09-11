//
//  SubDetailViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/11/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import AlamofireObjectMapper
import NVActivityIndicatorView
import ColorPickerRow

class SubDetailViewController: FormViewController {

    var setrole:SetRole!
    var setrequestmember:SetRequestMember!
    var memberproperty:MemberPropertyView!
    var changedSettingDetail=[SettingDetail]()
    var changedRole:Role?
    var changedNickname:String?
    var navTitle=""
    var isreloading=false
    var indicator=NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20), type: .ballSpinFadeLoader, color: .white, padding: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        navigationItem.title = navTitle
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tosubsub"{
            if memberproperty != nil{
                let vc=segue.destination as! SubSubDetailViewController
                vc.navTitle = "Roles"
                vc.setupAssignRoleView(member: memberproperty.member)
                return
            }
            let btn=sender as! ButtonRow
            let vc=segue.destination as! SubSubDetailViewController
            if setrole != nil{
                vc.roleid=setrole.role.roleid!
                let index=setrole.role.settinggroup.index { (role) -> Bool in
                    role.settinggroupid == Int(btn.tag!)!
                }
                vc.navTitle=setrole.role.settinggroup[index!].settinggroupname!
                vc.setupPermission(settinggroup: setrole.role.settinggroup[index!])
            }else{
                let index=setrequestmember.classrequest.index { (request) -> Bool in
                    request.requestid == Int(btn.tag!)!
                }
                vc.navTitle="\(setrequestmember.classrequest[index!].username!) - \(setrequestmember.classrequest[index!].subgroupname!)"
                vc.setupApproveClassRequest(request: setrequestmember.classrequest[index!])
            }
        }
    }
    
    func setupSetRole(role: Role){
        setrole=SetRole(vc: self, role: role)
    }
    
    func setupRequestMember(subgroupid: Int){
        setrequestmember=SetRequestMember(vc: self, subgroupid: subgroupid)
    }
    
    @objc func savechange(){
        let barbutton=UIBarButtonItem(customView: indicator)
        navigationItem.rightBarButtonItem = barbutton
        indicator.startAnimating()
        navigationItem.leftBarButtonItem?.isEnabled=false
        var dic:[String:Any]=["roleid":setrole.role.roleid!]
        if changedSettingDetail.count != 0{
            dic.updateValue(changedSettingDetail.toJSONString(prettyPrint: true)!, forKey: "detailjson")
        }
        if changedRole != nil{
            dic.updateValue(changedRole!.toJSONString(prettyPrint: true)!, forKey: "nondetailjson")
        }
        setrole.SaveRole(downloadString: "\(Link.link)/Role/SaveRole", param: dic) { [weak self](string) in
            if string != nil{
                if self?.changedRole != nil{
                    self?.setrole.role.rolename = self?.changedRole?.rolename
                    self?.setrole.role.rolecolor = self?.changedRole?.rolecolor
                }
                if let settinggroup = self?.setrole.role.settinggroup{
                    for item in settinggroup{
                        if item.settinggroupname!.contains("Settings"){
                            for subitem in item.settingdescription[0].settingdetail{
                                if let index = self?.changedSettingDetail.index(where: { (detail) -> Bool in
                                    detail.settingdetailid == subitem.settingdetailid
                                }){
                                    subitem.isactive = self?.changedSettingDetail[index].isactive
                                }
                            }
                            break
                        }
                    }
                }
                self?.changedRole = nil
                self?.changedSettingDetail.removeAll()
            }
            self?.indicator.stopAnimating()
            self?.navigationItem.rightBarButtonItem = nil
            self?.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func cancelchange(){
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        changedRole = nil
        changedSettingDetail.removeAll()
        isreloading=true
        setrole.colorpicker.updateCell()
        tableView.reloadData {
            self.isreloading=false
        }
    }
    
    @objc func saveNickname(){
        let barbutton=UIBarButtonItem(customView: indicator)
        navigationItem.rightBarButtonItem = barbutton
        indicator.startAnimating()
        navigationItem.leftBarButtonItem?.isEnabled=false
        memberproperty.ExecuteUser(downloadString: "\(Link.link)/Role/SaveNickName", param: ["userclassid":memberproperty.member.userclassid!,"nickname":changedNickname!]) { [weak self](string) in
            if string != nil{
                if self?.changedNickname != nil{
                    self?.memberproperty.member.nickname = self?.changedNickname
                }
                self?.changedNickname=nil
            }
            self?.indicator.stopAnimating()
            self?.navigationItem.rightBarButtonItem = nil
            self?.navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func cancelNickname(){
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        changedNickname=nil
        isreloading=true
        tableView.reloadData {
            self.isreloading=false
        }
    }
    
    func setupMember(member: Member){
        memberproperty=MemberPropertyView(vc: self, member: member)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToSubDetailView(segue:UIStoryboardSegue) {
        if let requestid=(segue.source as? SubSubDetailViewController)?.approverequest?.classrequest.requestid{
            let row=form.last!.index { (row) -> Bool in
                row.tag == String(describing: requestid)
            }
            form.last!.remove(at: row!)
        }else if let role=(segue.source as? SubSubDetailViewController)?.assignrole?.selectedrole,let userid=(segue.source as? SubSubDetailViewController)?.assignrole?.member.userid{
            AssignRoles(downloadString: "\(Link.link)/Role/AssignRoles", param: ["userid":userid,"roleid":role.roleid!]) { [weak self](string) in
                if string != nil{
                    if var section=self?.form.sectionBy(tag: "assignroles"){
                        section.insert(ButtonRow(){
                            $0.title = $0.tag
                            $0.tag = String(describing: role.roleid!)
                            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .black
                                cell.textLabel?.textAlignment = .left
                                cell.textLabel?.text = role.rolename!
                            }), at: 0)
                    }
                }
            }
        }
    }
}

extension SubDetailViewController{
    func AssignRoles(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
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
}
