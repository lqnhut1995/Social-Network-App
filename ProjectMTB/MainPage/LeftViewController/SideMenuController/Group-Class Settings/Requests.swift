//
//  Requests.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/17/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Foundation
import Eureka
import Alamofire
import AlamofireObjectMapper
import NVActivityIndicatorView

class RequestView {
    
    var subgroups:[subGroup]!
    
    init(vc: SettingDetailViewController, groupid: Int) {
        LoadSubGroup(downloadString: "\(Link.link)/Mainpage/LoadSubGroup", param: ["groupid":groupid,"userid":sk.user.userid!,"isadmin":1]) { [weak self](subGroup) in
            DispatchQueue.main.async {
                if let subGroup = subGroup{
                    if subGroup.count > 0{
                        self?.subgroups = subGroup
                        self?.initRequestView(vc: vc, subgroups: subGroup)
                    }
                }
            }
        }
    }
    
    func initRequestView(vc: SettingDetailViewController, subgroups: [subGroup]){
        let section=Section()
        vc.form +++ section
        for item in subgroups{
            section <<< ButtonRow(item.subgroupname!){
                $0.title = $0.tag
                $0.tag = String(describing: item.subgroupid!)
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "tosubdetail", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
        }
    }
    
}

extension RequestView{
    func AcceptRequest(downloadString:String, param: [String:Any], complete: @escaping ([Role]?) -> ()){
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
    
    func LoadSubGroup(downloadString:String, param: [String:Any], complete: @escaping ([subGroup]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[subGroup]>) in
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
