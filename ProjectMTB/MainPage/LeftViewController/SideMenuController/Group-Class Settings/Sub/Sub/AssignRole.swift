//
//  AssignRole.swift
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

class AssignRoleView{
    
    var member: Member!
    var selectedrole:Role!
    
    init(vc: SubSubDetailViewController, member: Member) {
        self.member=member
        ExecuteRole(downloadString: "\(Link.link)/Role/LoadRole", param: ["subgroupid":member.subgroupid!]) { [weak self](roles) in
            if roles != nil{
                self?.setupAssignRoleView(vc: vc, roles: roles!)
            }
        }
    }
    
    func setupAssignRoleView(vc: SubSubDetailViewController, roles: [Role]){
        let section=Section()
        vc.form +++ section
        for item in roles{
            if item.rolename == "everyone" {continue}
            section <<< ButtonRow(item.rolename!){
                $0.title = $0.tag
                $0.tag = String(describing: item.roleid!)
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                }).onCellSelection({ (cell, row) in
                    self.selectedrole = item
                    vc.performSegue(withIdentifier: "tosubdetailview", sender: nil)
                })
        }
    }
}

extension AssignRoleView{
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
}
