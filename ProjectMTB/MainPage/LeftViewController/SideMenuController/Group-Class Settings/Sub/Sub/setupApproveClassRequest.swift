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

class SetApproveClassRequest {
    
    var classrequest:ClassRequest!
    
    init(vc: SubSubDetailViewController, request: ClassRequest) {
        classrequest=request
        initApproveRequest(vc: vc, classrequest: request)
    }
    
    func initApproveRequest(vc: SubSubDetailViewController, classrequest: ClassRequest){
        let notificationSetting = SelectableSection<ImageCheckRow<String>>("Approve Type", selectionType: .singleSelection(enableDeselection: false)){ section in
            section.header = Link.customHeader(text: "Approve Type", size: CGSize(width: vc.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
            
        }
        vc.form +++ notificationSetting
        let continents = ["Approve", "Deny", "Ignore"]
        for index in 0..<continents.count {
            vc.form.last! <<< ImageCheckRow<String>(continents[index]){ listRow in
                listRow.title = continents[index]
                listRow.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                listRow.selectableValue = continents[index]
                listRow.value = nil
                listRow.tag=String(describing: index+1)
            }
        }
        if let row: ImageCheckRow<String>=notificationSetting.rowBy(tag: "1"){
            row.didSelect()
        }
        
        let confirm = ButtonRow("Confirm"){
            $0.title = $0.tag
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
            $0.onCellSelection({ (cell, row) in
                row.disabled = Condition(booleanLiteral: true)
                row.evaluateDisabled()
                vc.navigationItem.hidesBackButton=true
                cell.textLabel?.text = ""
                let loading=NVActivityIndicatorView(frame: CGRect(x: cell.frame.width/2-10, y: cell.frame.height/2-10, width: 20, height: 20), type: NVActivityIndicatorType.ballSpinFadeLoader, color: .white, padding: nil)
                cell.addSubview(loading)
                loading.startAnimating()
                var selectedrow=0
                if let row: ImageCheckRow<String>=notificationSetting.selectedRow(){
                    selectedrow = Int(row.tag!)!
                }
                self.ApproveRequest(downloadString: "\(Link.link)/Mainpage/AcceptRequestClass", param: ["requestid":classrequest.requestid!,"userid":classrequest.userid!,"groupid":classrequest.groupid!,"subgroupid":classrequest.subgroupid!,"approvetype":selectedrow], complete: { (string) in
                    if string != nil{
                        vc.performSegue(withIdentifier: "tosubdetailview", sender: nil)
                    }
                    loading.stopAnimating()
                    row.disabled = Condition(booleanLiteral: false)
                    row.evaluateDisabled()
                    vc.navigationItem.hidesBackButton=false
                })
            })
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .white
                cell.backgroundColor = UIColor(hex: "#3AD29F")
            })
        vc.form +++ Section()
            <<< confirm
    }
    
}

extension SetApproveClassRequest{
    func ApproveRequest(downloadString:String, param: [String:Any], complete: @escaping (String?)->()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result{
            case .success( _):
                if response.result.value != nil{
                    complete("")
                }
                complete(nil)
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
