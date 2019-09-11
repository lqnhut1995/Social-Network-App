//
//  SMFriendViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/4/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Hero
import Kingfisher
import Alamofire
import AlamofireObjectMapper

class SMFriendViewController: UIViewController {

    @IBOutlet var searchbarView: UIView!
    @IBOutlet var searchbar: UIButton!
    @IBOutlet var tableview: UITableView!
    var privaterooms=[PrivateRoom]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource=self
        tableview.delegate=self
        tableview.separatorStyle = .none
        tableview.backgroundColor = .clear
        tableview.tableFooterView = UIView()
        tableview.reloadData()
        searchbar.hero.id = "search"
        
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDM), name: NSNotification.Name(rawValue: "reloadDM"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSMFriend), name: NSNotification.Name(rawValue: "reloadSMFriend"), object: nil)
        
        reloadMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        searchbar.layer.cornerRadius = 3
    }
    
    @IBAction func searchbtnpressed(_ sender: Any) {
        let searchController=UIStoryboard(name: "SMFriendStoryboard", bundle: nil).instantiateViewController(withIdentifier: "searchid") as! SMSearchViewController
        present(searchController, animated: true, completion: nil)
    }

    func reloadMessage(){
        LoadPrivateMessage(downloadString: Link.link+"/Mainpage/LoadPrivateMessage", param: ["userid":sk.user.userid!]) { [weak self](pr) in
            if let vc=self{
                if let pr=pr{
                    if pr.count > 0{
                        DispatchQueue.main.async {
                            vc.privaterooms = pr
                            vc.tableview.reloadData()
                            
                            //socket join rooms
                            for index in 0..<vc.privaterooms.count{
                                let jsonRoom:[String:Any]=[
                                    "room":vc.privaterooms[index].privateroomid!,
                                    "userid":sk.user.userid!,
                                    "uuid":vc.privaterooms[index].uuid!
                                    ]
                                sk.socket.defaultSocket.emit("join", with: [jsonRoom])
                            }
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        vc.privaterooms.removeAll()
                        vc.tableview.reloadData()
                    }
                }
            }
        }
    }
    
    func loadnewMessage(data: [PrivateRoom]){
        let index=privaterooms.count
        privaterooms.append(contentsOf: data)
        var indexpath=[IndexPath]()
        for index in index..<privaterooms.count{
            indexpath.append(IndexPath(row: index, section: 1))
        }
        tableview.beginUpdates()
        tableview.insertRows(at: indexpath, with: .automatic)
        tableview.endUpdates()
    }
}

extension SMFriendViewController: UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView=UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label=UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.width, height: 30))
        switch section {
        case 0:
            label.text = "Users"
        default:
            label.text = "Direct Messages"
        }
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = UIColor(hex: "#E6DADA")
        sectionView.backgroundColor = self.view.backgroundColor
        sectionView.addSubview(label)
        return sectionView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return privaterooms.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendcell", for: indexPath) as! SMFriendTableViewCell
        if indexPath.section == 0{
            cell.name.text="Friends"
            cell.message.text = "Friend Collection"
            cell.status.backgroundColor = .clear
            cell.statusColor = .clear
            cell.imageview.image = UIImage(named: "icons8-communication-128")
            cell.imageview.backgroundColor = UIColor.clear
        }else{
            cell.name.text=privaterooms[indexPath.row].privateroomname!
            cell.message.text = "I have to go back to school"
            cell.status.backgroundColor = .red
            cell.statusColor = .red
            if privaterooms[indexPath.row].privateroomimage != nil{
                cell.imageview.kf.setImage(with: URL(string: privaterooms[indexPath.row].privateroomimage!)!)
            }else{
                cell.imageview.image = UIImage(named: "chat")
            }
            cell.imageview.backgroundColor = .white
        }
        cell.name.textColor = .white
        cell.imageview.layer.cornerRadius = 7
        cell.imageview.clipsToBounds = true
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if (sideMenuController?.rootViewController as! UINavigationController).viewControllers[0].isKind(of: ChatViewController.self) || (sideMenuController?.rootViewController as! UINavigationController).viewControllers[0].isKind(of: NoChannelViewController.self){
                sideMenuController?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "friendsView") as! UINavigationController
            }
            sideMenuController?.hideLeftViewAnimated(self)
        }else{
            if !(sideMenuController?.rootViewController as! UINavigationController).viewControllers[0].isKind(of: ChatViewController.self){
                sideMenuController?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "additionView") as! UINavigationController
            }
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).label.text = privaterooms[indexPath.row].privateroomname!
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).setupChatType(type: .PrivateType)
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).privateRoom=self.privaterooms[indexPath.row]
            (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).loadMessage(roomid: privaterooms[indexPath.row].privateroomid!)
            sideMenuController?.isRightViewEnabled=false
            sideMenuController?.hideLeftViewAnimated(self)
        }
        
    }
}

extension SMFriendViewController{
    func LoadPrivateMessage(downloadString:String, param: [String:Any],complete: @escaping ([PrivateRoom]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[PrivateRoom]>) in
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

extension SMFriendViewController{
    @objc func reloadDM(notification: Notification) {
        reloadMessage()
        guard let data=notification.userInfo?["data"] as? PrivateRoom else{return}
        if !(sideMenuController?.rootViewController as! UINavigationController).viewControllers[0].isKind(of: ChatViewController.self){
            sideMenuController?.rootViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "additionView") as! UINavigationController
        }
        (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).label.text = data.privateroomname!
        (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).setupChatType(type: .PrivateType)
        (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).privateRoom=data
        (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).loadMessage(roomid: data.privateroomid!)
        (sideMenuController?.rootViewController?.childViewControllers[0] as! ChatViewController).viewWillAppear(true)
        sideMenuController?.isRightViewEnabled=false
    }
    
    @objc func reloadSMFriend(){
        reloadMessage()
    }
}
