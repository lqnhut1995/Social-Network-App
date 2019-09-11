//
//  SubViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/17/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import XLActionController
import Alamofire
import AlamofireObjectMapper
import SwiftEntryKit

class SubViewController: FormViewController {

    @IBOutlet var loading: UILabel!
    var subgroup=[subGroup]()
    var btnGroup=[ButtonRow]()
    var leftView:LeftViewController!
    var section:Eureka.Section!
    var group:Group!
    static var isadmin:Int!
    var leaveGroupView:EKAlertMessageView!
    var attr:EKAttributes!
    var accessBtn:ButtonRow!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.alpha = 0.0
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Medium", size: 14)!,NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        tableView.backgroundColor = .clear
        automaticallyAdjustsScrollViewInsets = false
        tableView?.contentInset = UIEdgeInsetsMake(10, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "Icon-App-20x20-1")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = .lightGray
        addButton.addTarget(self, action: #selector(settingbtnpressed), for: .touchUpInside)
        addButton.frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        navigationController?.navigationBar.backgroundColor = .clear
        
        section=Section()
        form +++ section
        
        leaveGroup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loading.layer.zPosition = 1
        loading.layer.borderWidth = 1.5
        loading.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToSubView(segue:UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSMContent"{
            if let btn=sender as? ButtonRow{
                let vc=segue.destination as! SMContentViewController
                let index = btnGroup.index { (bt) -> Bool in
                    bt.tag == btn.tag
                }
                vc.subgroup = subgroup[index!]
                sk.permission = subgroup[index!].settingdetail
                vc.subView = self
                vc.loadTopic(subgroupid: btn.cell.tag)
            }
        }
        if segue.identifier == "tocreateclass"{
            let navView=segue.destination as! UINavigationController
            let vc=navView.viewControllers[0] as! CreatingViewController
            vc.group=group
            vc.initCustomClass(classType: MultipleClassType.ClassCreatingClass)
            vc.subView = self
        }
        if segue.identifier == "toclasssetting"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! CreatingViewController
            vc.group=group
            vc.initCustomClass(classType: MultipleClassType.GroupSettingClass)
            vc.subgroup = subgroup
            vc.subView = self
        }
        if segue.identifier == "torequestclass"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! CreatingViewController
            vc.group=group
            vc.initCustomClass(classType: MultipleClassType.RequestClass)
            vc.subView = self
        }
    }
    
    @objc func settingbtnpressed(_ sender: Any) {
        present(createStandardActionSheet(), animated: true, completion: nil)
    }
    
    func loadSubGroup(group: Group){
        loading.isHidden=false
        section.removeAll()
        reloadTableview()
        let session = Alamofire.SessionManager.default.session
        session.getAllTasks() { tasks in
            tasks.forEach { $0.cancel() }
            self.loading.isHidden=false
        }
        self.LoadSubGroup(downloadString: "\(Link.link)/Mainpage/LoadSubGroup", param: ["groupid":group.groupid!,"userid":sk.user.userid!,"isadmin":group.isadmin!]) { (subGroup) in
            DispatchQueue.main.async {
                if let subGroup = subGroup{
                    if subGroup.count > 0{
                        self.subgroup = subGroup
                        self.loadButtonRow()
                    }
                }
                self.loading.isHidden=true
            }
        }
    }
    
    func loadButtonRow(){
        for index in 0..<subgroup.count{
            let btn = ButtonRow(subgroup[index].subgroupname) {
                $0.title = $0.tag
                $0.tag = String(describing: subgroup[index].subgroupid!)
                $0.cell.tag = subgroup[index].subgroupid!
                $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
                $0.cell.backgroundColor = .clear
                let bgView = UIView()
                bgView.backgroundColor = UIColor.mainColor
                $0.cell.selectedBackgroundView = bgView
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = UIColor(hex: "#6F7179")
                    cell.textLabel?.textAlignment = .left
                })
            btn.onCellSelection({ (cell, row) in
                self.accessBtn = btn
//                SwiftEntryKit.display(entry: self.groupPermissionView, using: self.attr)
                self.performSegue(withIdentifier: "toSMContent", sender: self.accessBtn)
            })
            btn.tag = String(describing: index)
            btnGroup.append(btn)
            section <<< btn
        }
        reloadTableview()
    }
    
    func loadnewSubGroup(subgroup: subGroup){
        self.subgroup.append(subgroup)
        let btn = ButtonRow(subgroup.subgroupname) {
            $0.title = $0.tag
            $0.tag = String(describing: subgroup.subgroupid!)
            $0.cell.tag = subgroup.subgroupid!
            $0.cell.textLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 15)!
            $0.cell.backgroundColor = .clear
            let bgView = UIView()
            bgView.backgroundColor = UIColor.mainColor
            $0.cell.selectedBackgroundView = bgView
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = UIColor(hex: "#6F7179")
                cell.textLabel?.textAlignment = .left
            })
        btn.onCellSelection({ (cell, row) in
            self.accessBtn = btn
//            SwiftEntryKit.display(entry: self.groupPermissionView, using: self.attr)
            self.performSegue(withIdentifier: "toSMContent", sender: self.accessBtn)
        })
        btn.tag = String(describing: self.subgroup.count-1)
        btnGroup.append(btn)
        section <<< btn
        reloadTableview()
    }
    
    func reloadTableview(){
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        section.reload(with: .none)
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func deleteSubGroup(index: Int){
        subgroup.remove(at: index)
        section.remove(at: index)
        btnGroup.remove(at: index)
    }
    
    func leaveGroup(){
        attr=EKAttributes.centerFloat
        let style=FormStyle.light
        var font:EKProperty.LabelStyle = .init(font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat(16))!, color: UIColor.white, alignment: .center)
        let acceptBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Leave", style: style.buttonTitle), backgroundColor: UIColor(hex: "#FF696C"), highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            if self.group.isadmin! == 1{
                self.DeleteGroup(downloadString: Link.link+"/Mainpage/DeleteGroup", param: ["groupid":self.group.groupid!])
            }
            SwiftEntryKit.dismiss()
        })
        font.color = .black
        let canceltBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Cancel", style: font), backgroundColor: EKColor.Gray.light, highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            
            SwiftEntryKit.dismiss()
        })
        font.color = .white
        let description=EKProperty.LabelContent(text: "", style: font)
        let label=EKProperty.LabelContent(text: "Are You Sure Want To Leave Group", style: style.title)
        attr.popBehavior = EKAttributes.PopBehavior.overridden
        attr.entryBackground = .color(color: UIColor.white)
        attr.screenBackground = .color(color: .dimmedDarkBackground)
        attr.entranceAnimation = .none
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attr.positionConstraints.maxSize = .init(width: EKAttributes.PositionConstraints.Edge.constant(value: self.view.frame.width-50), height: .intrinsic)
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.displayDuration = .infinity
        attr.roundCorners = .all(radius: 8)
        leaveGroupView=EKAlertMessageView(with: EKAlertMessage(simpleMessage: EKSimpleMessage(title: label, description: description), buttonBarContent: EKProperty.ButtonBarContent(with: acceptBtn,canceltBtn, separatorColor: EKColor.Gray.light, buttonHeight: 50, expandAnimatedly: true)))
    }
    
}

extension SubViewController{
    func createStandardActionSheet() -> SkypeActionController {
        let actionsheet=SkypeActionController()
        actionsheet.addAction(Action(ActionData(title: "Request Class", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            self.performSegue(withIdentifier: "torequestclass", sender: self)
        }))
        switch group.isadmin! {
        case 1:
            actionsheet.addAction(Action(ActionData(title: "Create Class", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                self.performSegue(withIdentifier: "tocreateclass", sender: self)
            }))
            actionsheet.addAction(Action(ActionData(title: "Group Setting", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                self.performSegue(withIdentifier: "toclasssetting", sender: self)
            }))
            actionsheet.addAction(Action(ActionData(title: "Delete Group", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                SwiftEntryKit.display(entry: self.leaveGroupView, using: self.attr)
            }))
        default:
            actionsheet.addAction(Action(ActionData(title: "Leave Group", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                SwiftEntryKit.display(entry: self.leaveGroupView, using: self.attr)
            }))
            break
        }
        actionsheet.addAction(Action(ActionData(title: "Notification Settings", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Cancel"), style: .cancel, handler: nil))
        actionsheet.backgroundColor = UIColor(hex: "#3AD29F")
        actionsheet.settings.statusBar.showStatusBar=false
        return actionsheet
    }
}

extension SubViewController{
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
    
    func DeleteGroup(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            let index = self.leftView.group.index(where: { (gr) -> Bool in
                                gr.groupid == self.group.groupid
                            })
                            self.leftView.group.remove(at: index!)
                            self.leftView.menuViewController?.scroll(index: index!-1)
                            self.leftView.menuViewController?.reloadData()
                            if self.leftView.group.count == 1 {
                                self.leftView.contentViewController?.scroll(to: 0, animated: false)
                            }else{
                                if index == 1{
                                    self.leftView.contentViewController?.scroll(to: 0, animated: false)
                                }else{
                                    self.loadSubGroup(group: self.leftView.group[index!-1])
                                }
                            }
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
