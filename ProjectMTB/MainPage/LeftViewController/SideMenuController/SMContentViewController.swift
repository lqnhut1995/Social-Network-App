//
//  SMContentViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/1/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import XLActionController
import SwiftEntryKit

class SMContentViewController: UIViewController {

    @IBOutlet var loading: UILabel!
    @IBOutlet var tableview: UITableView!
    var topic=[Topic]()
    var subgroup:subGroup!
    var subView:SubViewController!
    var leaveClassView:EKAlertMessageView!
    var attr:EKAttributes!
    override func viewDidLoad() {
        super.viewDidLoad()

        let addButton = UIButton(type: .custom)
        addButton.setImage(UIImage(named: "Icon-App-20x20-1")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addButton.tintColor = .lightGray
        addButton.addTarget(self, action: #selector(addbtn), for: .touchUpInside)
        addButton.frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        self.navigationItem.title = subgroup?.subgroupname
        
        tableview.dataSource=self
        tableview.delegate=self
        tableview.separatorStyle = .none
        tableview.backgroundColor = .clear
        tableview.tableFooterView = UIView()
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSMContent), name: NSNotification.Name("reloadSMContent"), object: nil)
        
        loading.isHidden=false
        
        leaveClass()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tocreatechannel"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! CreatingViewController
            vc.initCustomClass(classType: MultipleClassType.ChannelCreatingClass)
            vc.smContent = self
            vc.thissubgroup = subgroup
        }
        if segue.identifier == "tocreatesubchannel"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! CreatingViewController
            vc.initCustomClass(classType: MultipleClassType.SubChannelCreatingClass)
            vc.smContent = self
            if let btn = sender as? UIButton{
                vc.topicid = topic[btn.tag].topicid!
            }
        }
        if segue.identifier == "toclasssetting"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! CreatingViewController
            vc.initCustomClass(classType: MultipleClassType.ClassSettingCLass)
            vc.smContent = self
            vc.topic = topic
            vc.thissubgroup = subgroup
        }
        if segue.identifier == "showgroupchat"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! GroupChatViewController
            vc.subtopic=sender as! TopicItem
        }
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
    
    @IBAction func unwindToSMContent(segue:UIStoryboardSegue) {
    }
    
    func loadTopic(subgroupid: Int){
        self.LoadTopic(downloadString: "\(Link.link)/Mainpage/LoadTopic", param: ["subgroupid":subgroupid]) { (topic) in
            DispatchQueue.main.async {
                if let topic = topic{
                    if topic.count > 0{
                        if SubViewController.isadmin != 1,!sk.permission.contains(where: {$0.settingdetailid==66}){
                            for item in topic{
                                item.items = item.items?.filter({ (topicitem) -> Bool in
                                    topicitem.channeltype == 0 || topicitem.channeltype == 1
                                })
                            }
                        }
                        self.topic = topic
                        self.tableview.reloadData()
                    }
                }
                self.loading.isHidden=true
            }
        }
    }
    
    func loadnewTopic(topic: Topic){
        self.topic.append(topic)
        tableview.beginUpdates()
        tableview.insertSections(IndexSet(integer: self.topic.count-1), with: .automatic)
        tableview.endUpdates()
    }
    
    func loadnewSubTopic(subtopic: TopicItem){
        let index=topic.index { (tp) -> Bool in
            tp.topicid == subtopic.topicid
        }
        if topic[index!].items == nil{
            topic[index!].items = [subtopic]
        }else{
            topic[index!].items?.append(subtopic)
        }
        tableview.beginUpdates()
        tableview.insertRows(at: [IndexPath(row: topic[index!].items!.count > 0 ? topic[index!].items!.count - 1 : 0, section: index!)], with: .automatic)
        tableview.endUpdates()
    }
    
    func reloadDeletedSubtopic(subtopic: TopicItem){
        let topicIndex=topic.index { (tp) -> Bool in
            tp.topicid == subtopic.topicid
        }
        let subtopicIndex=topic[topicIndex!].items?.index(where: { (subtp) -> Bool in
            subtp.subtopicid == subtopic.subtopicid
        })
        topic[topicIndex!].items!.remove(at: subtopicIndex!)
        tableview.beginUpdates()
        tableview.deleteRows(at: [IndexPath(row: subtopicIndex!, section: topicIndex!)], with: .automatic)
        tableview.endUpdates()
    }
    
    @objc func addbtn(){
        present(createStandardActionSheet(), animated: true, completion: nil)
    }
    
    func leaveClass(){
        attr=EKAttributes.centerFloat
        let style=FormStyle.light
        var font:EKProperty.LabelStyle = .init(font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat(16))!, color: UIColor.white, alignment: .center)
        let acceptBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Leave", style: style.buttonTitle), backgroundColor: UIColor(hex: "#FF696C"), highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            self.DeleteSubGroup(downloadString: Link.link+"/Mainpage/DeleteSubGroup", param: ["subgroupid":self.subgroup.subgroupid!])
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
        attr.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 0.7, initialVelocity: 0)),
                                       scale: .init(from: 0.7, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attr.positionConstraints.maxSize = .init(width: EKAttributes.PositionConstraints.Edge.constant(value: self.view.frame.width-50), height: .intrinsic)
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.displayDuration = .infinity
        attr.roundCorners = .all(radius: 8)
        leaveClassView=EKAlertMessageView(with: EKAlertMessage(simpleMessage: EKSimpleMessage(title: label, description: description), buttonBarContent: EKProperty.ButtonBarContent(with: acceptBtn,canceltBtn, separatorColor: EKColor.Gray.light, buttonHeight: 50, expandAnimatedly: true)))
    }
}

extension SMContentViewController: UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return topic.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView=UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label=UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.width-40, height: 30))
        label.text = topic[section].topicname
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = UIColor(hex: "#E6DADA")
        sectionView.backgroundColor = self.view.backgroundColor
        sectionView.addSubview(label)
        if SubViewController.isadmin == 1 || sk.permission.contains(where: {$0.settingdetailid==57 || $0.settingdetailid==60}){
            let btn=UIButton(type: .contactAdd)
            btn.frame = CGRect(x: tableView.frame.width-36, y: 0, width: 30, height: 30)
            btn.tintColor = .white
            btn.tag=section
            btn.removeTarget(self, action: #selector(addSubtopic(sender:)), for: .touchUpInside)
            btn.addTarget(self, action: #selector(addSubtopic(sender:)), for: .touchUpInside)
            sectionView.addSubview(btn)
        }
        return sectionView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topic[section].items != nil ? topic[section].items!.count : 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentcell", for: indexPath) as! SMContentTableViewCell
        cell.title.text = """
        \(topic[indexPath.section].items![indexPath.row].subtopicname!)
        """
        cell.title.textColor = .white
        switch topic[indexPath.section].items![indexPath.row].channeltype! {
        case 0:
            cell.imageview.image = UIImage(named: "icons8-hashtag-filled-50")
        case 1:
            cell.imageview.image = UIImage(named: "icons8-speaker-filled-50")
        default:
            cell.imageview.image = UIImage(named: "icons8-alarm-filled-50")
        }
        cell.channel=topic[indexPath.section].items![indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channeltype=topic[indexPath.section].items![indexPath.row].channeltype!
        if channeltype == 1 {tableView.deselectRow(at: indexPath, animated: false)}
        switch channeltype {
        case 0,2:
            if let bool=sideMenuController?.rootViewController?.childViewControllers[0].isKind(of: ChatViewController.self),!bool{
                sideMenuController?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "additionView") as! UINavigationController
            }
            (sideMenuController?.rightViewController as? MemberTableViewController)?.loadMembers(subgroupid: topic[indexPath.section].subgroupid!)
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).label.text = "#"+topic[indexPath.section].items![indexPath.row].subtopicname!
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).subtopic = topic[indexPath.section].items![indexPath.row]
            if topic[indexPath.section].items![indexPath.row].channeltype! == 0{
                (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).setupChatType(type: .PublicType)
            }else{
                (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).setupChatType(type: .NotificationType)
            }
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).loadMessage(roomid: topic[indexPath.section].items![indexPath.row].subtopicid!)
            
            let jsonRoom=[
                "room":topic[indexPath.section].items![indexPath.row].subtopicid!,
                "userid":sk.user.userid!,
                ]
            sk.socket.defaultSocket.emit("join", with: [jsonRoom])
            sideMenuController?.isRightViewEnabled=true
            sideMenuController?.hideLeftViewAnimated(self)
        default:
            performSegue(withIdentifier: "showgroupchat", sender: topic[indexPath.section].items![indexPath.row])
        }
    }
    
    @objc func addSubtopic(sender: UIButton){
        performSegue(withIdentifier: "tocreatesubchannel", sender: sender)
    }
}

extension SMContentViewController{
    func LoadTopic(downloadString:String, param: [String:Any], complete: @escaping ([Topic]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[Topic]>) in
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
    
    func DeleteSubGroup(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        DispatchQueue.main.async {
                            let index = self.subView.subgroup.index(where: { (sg) -> Bool in
                                sg.subgroupid == self.subgroup.subgroupid
                            })
                            self.subView.deleteSubGroup(index: index!)
                            self.navigationController?.popViewController(animated: true)
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

extension SMContentViewController{
    func createStandardActionSheet() -> SkypeActionController {
        let actionsheet=SkypeActionController()
        //Administrator
        if SubViewController.isadmin == 1 || sk.permission.contains(where: {$0.settingdetailid==57}){
            actionsheet.addAction(Action(ActionData(title: "Create Catagory's Channel", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                self.performSegue(withIdentifier: "tocreatechannel", sender: self)
            }))
            actionsheet.addAction(Action(ActionData(title: "Class Setting", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                self.performSegue(withIdentifier: "toclasssetting", sender: self)
            }))
            actionsheet.addAction(Action(ActionData(title: "Delete Class", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                SwiftEntryKit.display(entry: self.leaveClassView, using: self.attr)
            }))
        }else {
            if sk.permission.contains(where: {$0.settingdetailid==60}){
                actionsheet.addAction(Action(ActionData(title: "Create Catagory's Channel", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                    self.performSegue(withIdentifier: "tocreatechannel", sender: self)
                }))
            }
            if sk.permission.contains(where: {$0.settingdetailid==58 || $0.settingdetailid==60}){
                actionsheet.addAction(Action(ActionData(title: "Class Setting", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                    self.performSegue(withIdentifier: "toclasssetting", sender: self)
                }))
            }
            actionsheet.addAction(Action(ActionData(title: "Leave Class", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
                SwiftEntryKit.display(entry: self.leaveClassView, using: self.attr)
            }))
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

extension SMContentViewController{
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
    }
    
    @objc func reloadSMContent(){
        loadTopic(subgroupid: subgroup.subgroupid!)
    }
}
