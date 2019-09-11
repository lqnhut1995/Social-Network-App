//
//  SubSubDetailViewController.swift
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

class SubSubDetailViewController: FormViewController {

    var permission:Permission!
    var approverequest:SetApproveClassRequest!
    var assignrole:AssignRoleView!
    var roleid:Int!
    var navTitle=""
    var isreloading=false
    var indicator=NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20), type: .ballSpinFadeLoader, color: .white, padding: nil)
    var changedSettingDetail=[SettingDetail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = navTitle
        tableView?.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
    }

    func setupPermission(settinggroup: SettingGroup){
        permission=Permission(vc: self, settinggroup: settinggroup)
    }
    
    func setupApproveClassRequest(request: ClassRequest){
        approverequest = SetApproveClassRequest(vc: self, request: request)
    }
    
    @objc func savechange(){
        let barbutton=UIBarButtonItem(customView: indicator)
        navigationItem.rightBarButtonItem = barbutton
        indicator.startAnimating()
        navigationItem.leftBarButtonItem?.isEnabled=false
        permission.SaveRole(downloadString: "\(Link.link)/Role/SaveRole", param: ["roleid":roleid,"json":changedSettingDetail.toJSONString(prettyPrint: true)!]) { [weak self](string) in
            if string != nil{
                if let settingdescription=self?.permission.settinggroup.settingdescription{
                    for item in settingdescription{
                        for subitem in item.settingdetail{
                            if let index=self?.changedSettingDetail.index(where: { (detail) -> Bool in
                                detail.settingdetailid == subitem.settingdetailid
                            }){
                                subitem.isactive = self?.changedSettingDetail[index].isactive
                            }
                        }
                    }
                }
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
        changedSettingDetail.removeAll()
        isreloading=true
        tableView.reloadData{
            self.isreloading=false
        }
    }
    
    func setupAssignRoleView(member: Member){
        assignrole=AssignRoleView(vc: self, member: member)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
