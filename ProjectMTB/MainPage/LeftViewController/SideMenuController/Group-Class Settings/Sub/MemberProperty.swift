//
//  MemberProperty.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/23/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Foundation
import Eureka
import Alamofire
import AlamofireObjectMapper

class MemberPropertyView{
    
    var member: Member!
    
    init(vc: SubDetailViewController, member: Member) {
        self.member=member
        LoadUserRoles(downloadString: "\(Link.link)/Role/LoadUserRoles", param: ["userid":member.userid!,"subgroupid":member.subgroupid!]) { [weak self](roles) in
            if let roles=roles{
                self?.setupMemberPropertyView(vc: vc, roles: roles)
            }else{
                self?.setupMemberPropertyView(vc: vc)
            }
        }
    }
    
    func setupMemberPropertyView(vc: SubDetailViewController, roles: [Role]=[Role]()){
        vc.form +++ Section(){ section in
            section.header = Link.customHeader(text: "Nickname", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
        }
        vc.form.last! <<< TextRow(){
            $0.title = $0.tag
            $0.tag = "nickname"
            $0.placeholder = "nickname"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                if vc.isreloading{
                    row.value = self.member.nickname
                }
            }).onChange({ (row) in
                if row.value != self.member.nickname{
                    if let text=row.value,text != ""{
                        vc.changedNickname = text
                    }
                }else{
                    if vc.changedNickname != nil{
                        vc.changedNickname = nil
                    }
                }
                if vc.changedNickname == nil{
                    vc.navigationItem.rightBarButtonItem = nil
                    vc.navigationItem.leftBarButtonItem = nil
                    return
                }
                if vc.navigationItem.rightBarButtonItem != nil {return}
                vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.saveNickname))
                vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: vc, action: #selector(vc.cancelNickname))
            })
        vc.form +++ Section(){ section in
            section.tag = "assignroles"
            section.header = Link.customHeader(text: "User Roles", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
        }
        for item in roles{
            vc.form.last! <<< ButtonRow(){
                $0.title = $0.tag
                $0.tag = String(describing: item.roleid!)
                if item.rolename != "everyone"{
                    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, row, completionHandler) in
                        self.ExecuteUser(downloadString: "\(Link.link)/Role/DeleteUserRole", param: ["userid":self.member.userid!,"roleid":item.roleid!], complete: { (string) in
                            if string != nil{
                                
                            }
                        })
                        completionHandler?(true)
                    }
                    $0.trailingSwipe.actions = [deleteAction]
                }
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    cell.textLabel?.text = item.rolename!
                })
        }
        vc.form.last! <<< ButtonRow("Assign Roles"){
            $0.title = $0.tag
            $0.tag = "Assign Roles"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.presentationMode = .segueName(segueName: "tosubsub", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            })
        vc.form +++ Section()
        vc.form.last! <<< ButtonRow("Ban"){
            $0.title = $0.tag
            $0.tag = "Ban"
            if self.member.ban == 1{
                $0.disabled = Condition(booleanLiteral: true)
                $0.evaluateDisabled()
                $0.cell.isUserInteractionEnabled=false
            }
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
                cell.backgroundColor = UIColor(hex: "#FF696C")
                
            }).onCellSelection({ (cell, row) in
                self.ExecuteUser(downloadString: "\(Link.link)/Role/BanUser", param: ["userclassid":self.member.userclassid!], complete: { (string) in
                    if string != nil{
                        row.disabled = Condition(booleanLiteral: true)
                        row.evaluateDisabled()
                        cell.isUserInteractionEnabled=false
                        row.reload()
                    }
                })
            })
        vc.form +++ Section()
        vc.form.last! <<< ButtonRow("Kick"){
            $0.title = $0.tag
            $0.tag = "4"
            if self.member.kick == 1{
                $0.disabled = Condition(booleanLiteral: true)
                $0.evaluateDisabled()
                $0.cell.isUserInteractionEnabled=false
            }
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
                cell.backgroundColor = UIColor(hex: "#FF696C")
            }).onCellSelection({ (cell, row) in
                self.ExecuteUser(downloadString: "\(Link.link)/Role/KickUser", param: ["userclassid":self.member.userclassid!], complete: { (string) in
                    if string != nil{
                        row.disabled = Condition(booleanLiteral: true)
                        row.evaluateDisabled()
                        cell.isUserInteractionEnabled=false
                        row.reload()
                    }
                })
            })
    }
}

extension MemberPropertyView{
    func LoadUserRoles(downloadString:String, param: [String:Any], complete: @escaping ([Role]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[Role]>) in
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
    
    func ExecuteUser(downloadString:String, param: [String:Any], complete: @escaping (String?) -> ()){
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
