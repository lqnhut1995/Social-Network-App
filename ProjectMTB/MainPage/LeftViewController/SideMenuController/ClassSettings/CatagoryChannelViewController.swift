//
//  CatagoryChannelViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/2/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import AlamofireObjectMapper

enum ClType{
    case ClassType
    case CatagoryChannelType
}

class CatagoryChannelViewController: FormViewController {

    var topic=[Topic]()
    var subgroup=[subGroup]()
    var smContent:SMContentViewController!
    var subView:SubViewController!
    var section:MultivaluedSection!
    var navTitle=""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = navTitle
        tableView?.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        section = MultivaluedSection(multivaluedOptions: [.Reorder],
                               header: "",
                               footer: "") {
                                if topic.count > 0{
                                    $0.header = Link.customHeader(text: "Catagory's Channel", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                                }else{
                                    $0.header = Link.customHeader(text: "Classes", size: CGSize(width: self.view.frame.width, height: 30), font: UIFont(name: "HelveticaNeue-Medium", size: 15)!)
                                }
                                for index in 0..<topic.count{
                                    $0 <<< CatagoryChannelRow(){
                                        $0.tag = "\(index)"
                                        $0.title = topic[index].topicname
                                        $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                                        }.cellUpdate({ (cell, row) in

                                        }).onExpandInlineRow({ (cell, row, subRow) in
                                            subRow.updateValue(value: self.topic[index].topicname!)
                                            subRow.updatecell(cataView: self,title: "Catagory's Channel", downloadString: Link.link+"/Mainpage/DeleteTopic", param: ["topicid":self.topic[index].topicid!], type: ClType.CatagoryChannelType)
                                        })
                                }
                                for index in 0..<subgroup.count{
                                    $0 <<< CatagoryChannelRow(){
                                        $0.tag = "\(index)"
                                        $0.title = subgroup[index].subgroupname
                                        $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)
                                        }.cellUpdate({ (cell, row) in

                                        }).onExpandInlineRow({ (cell, row, subRow) in
                                            subRow.updateValue(value: self.subgroup[index].subgroupname!)
                                            subRow.updatecell(cataView: self,title: "Class", downloadString: Link.link+"/Mainpage/DeleteSubGroup", param: ["subgroupid":self.subgroup[index].subgroupid!], type: ClType.ClassType)
                                        })
                                }
        }
        form +++ section
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

}

extension CatagoryChannelViewController{
    func DeleteTopic(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            let index = self.topic.index(where: { (tp) -> Bool in
                                tp.topicid == (param["topicid"] as! Int)
                            })
                            self.section.remove(at: index!)
                            self.smContent.topic.remove(at: index!)
                            self.smContent.tableview.beginUpdates()
                            self.smContent.tableview.deleteSections(IndexSet(integer: index!), with: .automatic)
                            self.smContent.tableview.endUpdates()
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
    
    func DeleteSubGroup(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            let index = self.subgroup.index(where: { (sg) -> Bool in
                                sg.subgroupid == (param["subgroupid"] as! Int)
                            })
                            self.section.remove(at: index!)
                            self.subView.deleteSubGroup(index: index!)
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
