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
import NVActivityIndicatorView

class RoleView {
    
    var roles:[Role]!
    let loader = NVActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 20, height: 20)), type: NVActivityIndicatorType.ballSpinFadeLoader, color: .gray, padding: nil)
    let imageview = UIImageView()
    
    init(vc: SettingDetailViewController,subgroupid: Int) {
        ExecuteRole(downloadString: "\(Link.link)/Role/LoadRole", param: ["subgroupid":subgroupid]) { [weak self](roles) in
            guard let roles=roles else {
                vc.loadingview?.stopAnimating()
                return
            }
            self?.roles=roles
            self?.initRole(vc: vc, roles: roles, subgroupid: subgroupid)
            vc.loadingview?.stopAnimating()
        }
    }
    
    func initRole(vc: SettingDetailViewController, roles: [Role], subgroupid: Int){
        var section = Section()
        vc.form +++ section
        section.insert(ButtonRow("Add Role"){
            $0.title = $0.tag
            $0.tag = "0"
            imageview.frame = CGRect(origin: imageview.frame.origin, size: CGSize(width: 20, height: 20))
            imageview.image = UIImage(named: "icons8-add-new-100")
            $0.cell.accessoryType = .checkmark
            $0.cell.accessoryView = imageview
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.onCellSelection({ (cell, row) in
                cell.accessoryView = self.loader
                self.loader.startAnimating()
                self.ExecuteRole(downloadString: "\(Link.link)/Role/CreateRole", param: ["subgroupid":subgroupid]) { [weak self](roles) in
                    self?.loader.stopAnimating()
                    cell.accessoryView = self?.imageview
                    guard let roles=roles else {return}
                    self?.roles.append(roles[0])
                    self?.createNewRole(vc: vc, role: roles[0])
                }
            })
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textLabel?.textAlignment = .left
            }), at: 0)
        var secondsection = Section()
        vc.form +++ secondsection
        secondsection.insert(ButtonRow("everyone"){
            $0.title = $0.tag
            $0.tag = String(describing: roles[0].roleid!)
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.presentationMode = .segueName(segueName: "tosubdetail", onDismiss: nil)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
            }), at: 0)
        var multisection = Section{ section in
                                    section.tag = "lastsection"
        }
        vc.form +++ multisection
        for item in roles{
            if item.originrole == nil{
                let btn=ButtonRow(){
                    $0.title = $0.tag
                    $0.tag = String(describing: item.roleid!)
                    $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, row, completionHandler) in
                        self.ExecuteUser(downloadString: "\(Link.link)/Role/DeleteRole", param: ["roleid":item.roleid!], complete: { (string) in
                            if string != nil{
                                
                            }
                        })
                        completionHandler?(true)
                    }
                    $0.trailingSwipe.actions = [deleteAction]
                    $0.presentationMode = .segueName(segueName: "tosubdetail", onDismiss: nil)
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textColor = .black
                        cell.textLabel?.text = item.rolename!
                    })
                multisection.insert(btn, at: 0)
            }
        }
    }
    
    func createNewRole(vc: SettingDetailViewController, role: Role){
        guard var section = vc.form.sectionBy(tag: "lastsection") else {
            return
        }
        let btn=ButtonRow("new role"){
                $0.title = $0.tag
                $0.tag = String(describing: role.roleid!)
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "tosubdetail", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                })
        section.insert(btn, at: 0)
    }

}

extension RoleView{
    func ExecuteRole(downloadString:String, param: [String:Any], complete: @escaping ([Role]?) -> ()){
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
