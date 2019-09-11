//
//  OverviewView.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/11/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import Eureka
import Alamofire
import AlamofireObjectMapper

enum OverviewType{
    case GroupOverview
    case ClassOverview
}

class Overview{
    
    var notificationSetting:SelectableSection<ImageCheckRow<String>>!
    
    init(type: OverviewType, group: Group?, subgroup:subGroup?, vc: SettingDetailViewController) {
        switch type {
        case .GroupOverview:
            initGroup(group: group!, vc: vc)
        default:
            initClass(subgroup: subgroup!, vc: vc)
        }
    }
    
    func initGroup(group: Group, vc: SettingDetailViewController){
        let btn1 = TextRow() {
            $0.title = $0.tag
            $0.tag = "2"
            $0.value = group.groupname!
            }.cellUpdate({ (cell, row) in
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            })
        vc.form
            +++ Section(){ section in
                section.header = Link.customHeader(text: "Group Name", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
            }
            <<< btn1
        
        let delete = ButtonRow("Delete Group"){
            $0.title = $0.tag
            $0.tag = "3"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.onCellSelection(self.deletebtnpressed)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
                cell.backgroundColor = UIColor(hex: "#FF696C")
            })
        vc.form +++ Section()
            <<< delete
    }
    
    func initClass(subgroup: subGroup, vc: SettingDetailViewController){
        let btn1 = TextRow() {
            $0.title = $0.tag
            $0.tag = "2"
            $0.value = subgroup.subgroupname!
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .black
                cell.textField.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            })
        vc.form
            +++ Section(){ section in
                section.header = Link.customHeader(text: "Class Name", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
            }
            <<< btn1
        if SubViewController.isadmin != 1,!sk.permission.contains(where: {$0.settingdetailid==57}),sk.permission.contains(where: {$0.settingdetailid==58 || $0.settingdetailid==60}){return}
        notificationSetting = SelectableSection<ImageCheckRow<String>>("Notification Type", selectionType: .singleSelection(enableDeselection: false)){ section in
            section.header = Link.customHeader(text: "Notification Type", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            section.footer = Link.customHeader(text: "The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKit/UIView.h> may also be helpful.", size: CGSize(width: vc.view.frame.width - 10, height: 60), font: UIFont(name: "HelveticaNeue-Medium", size: 12)!)
        }
        vc.form +++ notificationSetting
        let continents = ["All Messages", "Only @mentions"]
        for index in 0..<continents.count {
            vc.form.last! <<< ImageCheckRow<String>(continents[index]){ listRow in
                listRow.title = continents[index]
                listRow.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                listRow.selectableValue = continents[index]
                listRow.value = nil
                listRow.tag=String(describing: index)
            }
        }
        if let row: ImageCheckRow<String>=notificationSetting.rowBy(tag: "0"){
            row.didSelect()
        }
        
        let delete = ButtonRow("Delete Class"){
            $0.title = $0.tag
            $0.tag = "3"
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.onCellSelection(self.deletebtnpressed)
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
                cell.backgroundColor = UIColor(hex: "#FF696C")
            })
        vc.form +++ Section()
            <<< delete
    }
    
    func deletebtnpressed(cell: ButtonCellOf<String>, row: ButtonRow){
        //        self.DeleteGroup(downloadString: Link.link+"/Mainpage/DeleteGroup", param: ["groupid":self.group.groupid!])
    }
}

extension Overview{
    func DeleteGroup(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            
                        }
                    }
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
            }
        }
    }
}
