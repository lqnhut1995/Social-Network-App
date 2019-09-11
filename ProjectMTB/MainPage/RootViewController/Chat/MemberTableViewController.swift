//
//  MemberTableViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/18/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper

class MemberTableViewController: UITableViewController {

    var members=[Member]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor(hex: "#232323")
        self.tableView.separatorColor = .lightGray
        
        self.tableView.tableFooterView = UIView()
    }
    
    func loadMembers(subgroupid: Int){
        LoadMembers(downloadString: "\(Link.link)/Mainpage/LoadMembers", param: ["subgroupid":subgroupid]) { [weak self](members) in
            DispatchQueue.main.async {
                if let members = members{
                    if members.count > 0{
                        self?.members=members
                        self?.tableView.reloadData()
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView=UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        let label=UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.width, height: 30))
        switch section {
        case 0:
            label.text = "Online"
        default:
            label.text = "Offline"
        }
        label.textColor = UIColor(hex: "#E6DADA")
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        sectionView.backgroundColor = UIColor(hex: "#232323")
        sectionView.addSubview(label)
        return sectionView
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return members.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "membercell", for: indexPath) as! MemberTableViewCell
        cell.textLabel?.text=members[indexPath.row].username!
        cell.imageview.image = UIImage(named: "Tudou")
        cell.status.backgroundColor = .red
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension MemberTableViewController{
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
