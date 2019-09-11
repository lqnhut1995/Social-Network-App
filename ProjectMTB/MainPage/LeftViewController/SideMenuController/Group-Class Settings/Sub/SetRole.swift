//
//  RoleViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/10/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Foundation
import Eureka
import Alamofire
import AlamofireObjectMapper
import ColorPickerRow

class SetRole {
    
    var role:Role!
    var colorpicker:InlineColorPickerRow!
    
    init(vc: SubDetailViewController, role: Role) {
        self.role=role
        initSetRole(vc: vc, role: role)
    }
    
    func initSetRole(vc: SubDetailViewController, role: Role){
        vc.form +++ Section(){ section in
            section.header = Link.customHeader(text: "Role Name", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
            }
            <<< TextRow(){
                $0.title = $0.tag
                $0.tag = "0"
                $0.value = role.rolename!
                if role.originrole != nil{
                    $0.disabled = Condition(booleanLiteral: true)
                    $0.evaluateDisabled()
                }
                }.cellUpdate({ (cell, row) in
                    cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                    if vc.isreloading{
                        row.value = role.rolename!
                    }
                }).onChange({ (row) in
                    if row.value != role.rolename!{
                        if let text=row.value,text != ""{
                            if vc.changedRole != nil{
                                vc.changedRole?.rolename = row.value!
                            }else{
                                vc.changedRole = Role(roleid: role.roleid!, rolename: row.value!, rolecolor: role.rolecolor!, subgroupid: role.subgroupid!)
                            }
                        }
                    }else{
                        if vc.changedRole != nil{
                            vc.changedRole = nil
                        }
                    }
                    if vc.changedRole == nil{
                        vc.navigationItem.rightBarButtonItem = nil
                        vc.navigationItem.leftBarButtonItem = nil
                        return
                    }
                    if vc.navigationItem.rightBarButtonItem != nil {return}
                    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.savechange))
                    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.cancelchange))
                })
            +++ Section("Role Color"){ section in
                section.header = Link.customHeader(text: "Role Color", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
                section.tag = "colorsection"
            }
            colorpicker=InlineColorPickerRow(){
                $0.title = "Choose Color"
                $0.value = UIColor(hex: role.rolecolor!)
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.tag = "1"
                if role.originrole != nil{
                    $0.disabled = Condition(booleanLiteral: true)
                    $0.evaluateDisabled()
                }
                }.cellUpdate({ (cell, row) in
                    if vc.isreloading{
                        row.value = UIColor(hex: role.rolecolor!)
                    }
                }).onChange({ (row) in
                    if let hex=row.value?.toHexString(),hex != role.rolecolor!{
                        if vc.changedRole != nil{
                            vc.changedRole?.rolecolor = hex
                        }else{
                            vc.changedRole = Role(roleid: role.roleid!, rolename: role.rolename!, rolecolor: hex, subgroupid: role.subgroupid!)
                        }
                    }else{
                        if vc.changedRole != nil{
                            vc.changedRole = nil
                        }
                    }
                    if vc.changedRole == nil{
                        vc.navigationItem.rightBarButtonItem = nil
                        vc.navigationItem.leftBarButtonItem = nil
                        return
                    }
                    if vc.navigationItem.rightBarButtonItem != nil {return}
                    vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.savechange))
                    vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.cancelchange))
                })
        vc.form.last! <<< colorpicker
        for item in role.settinggroup{
            if item.settinggroupname!.contains("Settings"){
                vc.form +++ Section(){ section in
                    section.header = Link.customHeader(text: item.settinggroupname!, size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                    section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
                }
                for subitem in item.settingdescription[0].settingdetail{
                    vc.form.last! <<< SwitchRow(){
                        $0.title = subitem.settingname!
                        $0.value = subitem.isactive == 0 ? false : true
                        $0.tag = String(describing: subitem.settingdetailid!)
                        $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                        $0.cell.textLabel?.numberOfLines = 0
                        if role.originrole != nil{
                            $0.disabled = Condition(booleanLiteral: true)
                            $0.evaluateDisabled()
                        }
                        }.cellUpdate({ (cell, row) in
                            if vc.isreloading{
                                row.value = subitem.isactive == 0 ? false : true
                            }
                        }).onChange({ (row) in
                            let bool = subitem.isactive == 0 ? false : true
                            if row.value != bool{
                                vc.changedSettingDetail.append(SettingDetail(settingdetailid: subitem.settingdetailid!, isactive: subitem.isactive! == 0 ? 1 : 0))
                            }else{
                                let index=vc.changedSettingDetail.index(where: { (detail) -> Bool in
                                    detail.settingdetailid == subitem.settingdetailid
                                })
                                vc.changedSettingDetail.remove(at: index!)
                            }
                            if vc.changedSettingDetail.count == 0{
                                vc.navigationItem.rightBarButtonItem = nil
                                vc.navigationItem.leftBarButtonItem = nil
                                return
                            }
                            if vc.navigationItem.rightBarButtonItem != nil {return}
                            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.savechange))
                            vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.cancelchange))
                        })
                }
                vc.form +++ Section(){ section in
                    section.header = Link.customHeader(text: "Permissions", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                    section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
                }
                continue
            }
                vc.form.last! <<< ButtonRow(item.settinggroupname!){
                    $0.title = $0.tag
                    $0.tag = String(describing: item.settinggroupid!)
                    $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                    $0.presentationMode = .segueName(segueName: "tosubsub", onDismiss: nil)
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = .black
                    })
        }
    }
    
}

extension SetRole{
    func SaveRole(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
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
