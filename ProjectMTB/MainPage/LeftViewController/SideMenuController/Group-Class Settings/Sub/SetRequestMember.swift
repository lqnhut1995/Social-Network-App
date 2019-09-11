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

class SetRequestMember {
    
    var classrequest:[ClassRequest]!
    
    init(vc: SubDetailViewController, subgroupid: Int) {
        LoadRequest(downloadString: "\(Link.link)/Mainpage/LoadRequestClass", param: ["subgroupid":subgroupid]) { [weak self](classrequest) in
            DispatchQueue.main.async {
                if let classrequest = classrequest{
                    if classrequest.count > 0{
                        self?.classrequest = classrequest
                        self?.initLoadRequest(vc: vc, classrequest: classrequest)
                    }
                }
            }
        }
    }
    
    func initLoadRequest(vc: SubDetailViewController, classrequest: [ClassRequest]){
        let section=Section()
        vc.form +++ section
        for item in classrequest{
            section <<< ButtonRow(item.username){
                $0.title = $0.tag
                $0.tag = String(describing: item.requestid!)
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                $0.presentationMode = .segueName(segueName: "tosubsub", onDismiss: nil)
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.textAlignment = .left
                })
        }
    }
    
}

extension SetRequestMember{
    func LoadRequest(downloadString:String, param: [String:Any], complete: @escaping ([ClassRequest]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[ClassRequest]>) in
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
