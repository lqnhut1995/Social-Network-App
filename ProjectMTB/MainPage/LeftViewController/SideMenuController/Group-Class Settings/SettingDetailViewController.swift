//
//  OverviewViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/10/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import AlamofireObjectMapper
import NVActivityIndicatorView

class SettingDetailViewController: FormViewController {

    var searchbar:UISearchBar!
    var checksearchbar=false
    var group:Group!
    var subgroup:subGroup!
    var members:MembersView!
    
    var overview:Overview!
    var roleview:RoleView!
    var requestview:RequestView!
    
    var editbutton:UIButton!
    var loadingview:NVActivityIndicatorView?
    var navTitle=""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView?.contentInset = UIEdgeInsetsMake(18, 0, 0, 0)
        tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        navigationItem.title = navTitle
        
        if checksearchbar {
            initSearchBar()
            searchbar.isHidden=false
        }
        
        if roleview != nil{
            loadingview = NVActivityIndicatorView(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 30), type: .ballSpinFadeLoader, color: UIColor.gray, padding: nil)
            tableView.tableHeaderView = loadingview
            loadingview?.startAnimating()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tosubdetail"{
            if members != nil{
                let vc=segue.destination as! SubDetailViewController
                let btn=sender as! CustomButtonRow
                let index=members.members.index { (member) -> Bool in
                    member.userid == Int(btn.tag!)!
                }
                vc.navTitle = members.members[index!].username!
                vc.setupMember(member: members.members[index!])
                return
            }
            let vc=segue.destination as! SubDetailViewController
            let btn=sender as! ButtonRow
            if roleview != nil{
                let index=roleview.roles.index { (role) -> Bool in
                    role.roleid == Int(btn.tag!)!
                }
                vc.navTitle = roleview.roles[index!].rolename!
                vc.setupSetRole(role: roleview.roles[index!])
            }else{
                let index=requestview.subgroups.index { (request) -> Bool in
                    request.subgroupid == Int(btn.tag!)!
                }
                vc.navTitle = requestview.subgroups[index!].subgroupname!
                vc.setupRequestMember(subgroupid: requestview.subgroups[index!].subgroupid!)
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let section=form.last{
            section.reload()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Overview
    func setupOverview(type: OverviewType){
        overview = Overview(type: type, group: group, subgroup: subgroup, vc: self)
    }
    
    //Role
    func setupRole(subgroupid: Int){
        roleview = RoleView(vc: self, subgroupid: subgroupid)
    }
    
    func setupRequests(groupid: Int){
        requestview = RequestView(vc: self, groupid: groupid)
    }
    
    func setupMembers(subgroupid: Int){
        checksearchbar=true
        members = MembersView(vc: self, subgroupid: subgroupid)
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
    
    func initSearchBar(){
        searchbar=UISearchBar(frame: CGRect(x: 0, y: navigationController!.navigationBar.frame.height+UIApplication.shared.statusBarFrame.height, width: UIScreen.main.bounds.width, height: 45))
        searchbar.setBackgroundImage(UIImage(), for: .top, barMetrics: .default)
        searchbar.backgroundColor = view.backgroundColor
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .white
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolBar.backgroundColor = UIColor(hex: "#3AD29F")
        toolBar.sizeToFit()
        
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(searchbarinputdone))
        
        toolBar.setItems([spaceButton,cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        searchbar.inputAccessoryView = toolBar
        view.addSubview(searchbar)
    }
    
    @objc func searchbarinputdone(){
        searchbar.resignFirstResponder()
        view.endEditing(true)
    }

}
