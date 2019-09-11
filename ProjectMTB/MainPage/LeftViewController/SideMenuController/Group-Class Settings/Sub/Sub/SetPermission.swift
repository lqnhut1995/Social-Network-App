//
//  SetPermission.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/11/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Foundation
import Eureka
import Alamofire
import AlamofireObjectMapper

class Permission{
    
    var settinggroup:SettingGroup!
    
    init(vc: SubSubDetailViewController, settinggroup: SettingGroup) {
        self.settinggroup=settinggroup
        initPermission(vc: vc, settinggroup: settinggroup)
    }
    
    func initPermission(vc: SubSubDetailViewController, settinggroup: SettingGroup){
        for i in 0..<settinggroup.settingdescription.count{
            vc.form +++ Section(){ section in
                section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
                }
            for j in 0..<settinggroup.settingdescription[i].settingdetail.count{
                vc.form.last! <<< SwitchRow(){
                    $0.title = settinggroup.settingdescription[i].settingdetail[j].settingname!
                    $0.value = settinggroup.settingdescription[i].settingdetail[j].isactive == 0 ? false : true
                    $0.tag = String(describing: settinggroup.settingdescription[i].settingdetail[j].settingdetailid!)
                    $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                    $0.cell.textLabel?.numberOfLines = 0
                    }.onChange({ (row) in
                        let settingdetail=settinggroup.settingdescription[i].settingdetail[j]
                        let bool = settingdetail.isactive == 0 ? false : true
                        if row.value != bool{
                            vc.changedSettingDetail.append(SettingDetail(settingdetailid: settingdetail.settingdetailid!, isactive: settingdetail.isactive! == 0 ? 1 : 0))
                        }else{
                            let index=vc.changedSettingDetail.index(where: { (detail) -> Bool in
                                detail.settingdetailid == settingdetail.settingdetailid
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
                    }).cellUpdate({ (cell, row) in
                        if vc.isreloading{
                            row.value = settinggroup.settingdescription[i].settingdetail[j].isactive == 0 ? false : true
                        }
                    })
            }
        }
    }

}

extension Permission{
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
