//
//  Members.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/21/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Foundation
import Eureka
import Alamofire
import AlamofireObjectMapper
import NVActivityIndicatorView
import Kingfisher

class MembersView{
    
    var members:[Member]!
    
    init(vc: SettingDetailViewController, subgroupid: Int) {
        LoadMembers(downloadString: "\(Link.link)/Mainpage/LoadMembers", param: ["subgroupid":subgroupid]) { [weak self](members) in
            DispatchQueue.main.async {
                if let members = members{
                    if members.count > 0{
                        self?.members = members
                        self?.setupMembersView(vc: vc)
                    }
                }
            }
        }
    }
    
    func setupMembersView(vc: SettingDetailViewController){
        let section=Section()
        vc.form +++ section
        for item in members{
            section <<< CustomButtonRow(item.username!){
                $0.title = $0.tag
                $0.tag = String(describing: item.userid!)
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "tosubdetail", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                    if let image=item.userimage,image != ""{
                        cell.imageView!.kf.indicatorType = .activity
                        cell.imageView!.kf.setImage(with: URL(string: image)!)
                    }else{
                        cell.imageView!.image = UIImage(named: "Tudou")
                    }
                    cell.height = {50}
                })
        }
    }
}

extension MembersView{
    func LoadMembers(downloadString:String, param: [String:Any], complete: @escaping ([Member]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[Member]>) in
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
