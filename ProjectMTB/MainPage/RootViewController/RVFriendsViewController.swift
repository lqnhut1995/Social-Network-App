//
//  RVFriendsViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/7/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import AlamofireObjectMapper

class RVFriendsViewController: UIViewController {

    @IBOutlet var tableview: UITableView!
    var friend=[userLogin]()
    var row=0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.delegate=self
        tableview.dataSource=self
        tableview.backgroundColor = .clear
        tableview.tableFooterView = UIView()
        tableview.separatorStyle = .none
        loadTable(row: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toprofileview"{
            let navView=segue.destination as! UINavigationController
            let vc=navView.viewControllers[0] as! ProfileViewController
            vc.delegate=self
            if let cell=sender as? RVFriendsTableViewCell{
                let index=friend.index { (fr) -> Bool in
                    fr.userid == cell.tag
                }
                vc.user = friend[index!]
                vc.setupbutton(row: row)
            }
        }
    }
    
    @IBAction func unwindtoRVFriends(segue:UIStoryboardSegue) {
    }

    func loadTable(row: Int){
        friend.removeAll()
        tableview.reloadData()
        self.row=row
        var string=""
        switch row{
        case 0:
            string="ListAllFriend"
        case 1:
            string=""
            return
        case 2:
            string="ListAllRequest"
        default:
            string="ListFriendBlocked"
        }
        LoadFriend(downloadString: Link.link+"/Friends/\(string)", param: ["userid":sk.user.userid!]) { [weak self](friend) in
            if let vc=self{
                if let friend=friend{
                    if friend.count > 0{
                        DispatchQueue.main.async {
                            vc.friend = friend
                            vc.tableview.reloadData()
                        }
                    }
                }else{
                    DispatchQueue.main.async {
                        vc.friend.removeAll()
                        vc.tableview.reloadData()
                    }
                }
            }
        }
    }
}

extension RVFriendsViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friend.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "rvfriendscell", for: indexPath) as! RVFriendsTableViewCell
        if friend[indexPath.row].userimage != nil{
            cell.imageview.kf.setImage(with: URL(string: friend[indexPath.row].userimage!)!)
        }
        cell.name.text = friend[indexPath.row].username!
        cell.id.text = "#\(String(describing: friend[indexPath.row].userid!))"
        cell.status.backgroundColor = .red
        cell.selectionStyle = .none
        cell.tag = friend[indexPath.row].userid!
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toprofileview", sender: tableView.cellForRow(at: indexPath))
    }
}

extension RVFriendsViewController{
    func LoadFriend(downloadString:String, param: [String:Any], complete: @escaping ([userLogin]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { (response: DataResponse<[userLogin]>) in
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

extension RVFriendsViewController: ProfileDelegate{
    func createNewDirectMessage(data: PrivateRoom) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDM"), object: nil, userInfo: ["data":data])
    }
    
    func loadTable(type: String) {
        switch type {
        case "2":
            loadTable(row: 2)
        default:
            loadTable(row: 3)
        }
    }
}
