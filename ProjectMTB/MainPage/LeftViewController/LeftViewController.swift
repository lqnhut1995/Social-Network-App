//
//  LeftViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/31/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit
import XLActionController
import Alamofire
import AlamofireObjectMapper
import Kingfisher

class LeftViewController: UIViewController {

    @IBOutlet var userinfo: UIView!
    @IBOutlet var banner: UIView!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var userName: UILabel!
    @IBOutlet var userId: UILabel!
    @IBOutlet var contentViewDown: UIView!
    @IBOutlet var contentViewUp: UIView!
    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    var group=[Group]()
    let underImage=UIImage(named: "icons8-sort-up-96")
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        menuViewController?.register(nib: UINib(nibName: "SMTitleMenuView", bundle: nil), forCellWithReuseIdentifier: "SMTitleMenuCell")
        menuViewController?.registerFocusView(nib: UINib(nibName: "SMUnderLineView", bundle: nil))
        contentViewController?.scrollView.isScrollEnabled = false
        
        group.append(Group(groupid: nil, groupname: nil, groupimage: "icons8-add-user-group-man-man-100 (1)"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if contentViewUp.layer.sublayers != nil{
            for layer in contentViewUp.layer.sublayers!{
                if layer.name == "customLayer"{
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        if userinfo.layer.sublayers != nil{
            for layer in userinfo.layer.sublayers!{
                if layer.name == "customLayer"{
                    layer.removeFromSuperlayer()
                    break
                }
            }
        }
        
        contentViewUp.layer.addBorder(toSide: .Bottom, withColor: UIColor.black.withAlphaComponent(0.1).cgColor, andThickness: 1)
        userinfo.layer.addBorder(toSide: .Top, withColor: UIColor.black.withAlphaComponent(0.1).cgColor, andThickness: 2)
        userImage.layer.cornerRadius = 7
        firstLoad?()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PagingMenuViewController {
            menuViewController = vc
            menuViewController?.dataSource = self
            menuViewController?.delegate = self
        } else if let vc = segue.destination as? PagingContentViewController {
            contentViewController = vc
            contentViewController?.delegate = self
            contentViewController?.dataSource = self
        }
        if segue.identifier == "tocreategroup"{
            let navView = segue.destination as! UINavigationController
            let groupView=navView.viewControllers[0] as! GroupCreatingViewController
            groupView.leftView = self
            groupView.userid = sk.user.userid!
            
            switch sender as! String{
            case "creategroup":
                groupView.setupCreateGroup()
            default:
                groupView.setupJoinGroup()
            }
            
        }
    }
    
    func loadGroup(userid: Int){
        if group.count > 1 {
            group.removeLast(group.count - 1)
        }
        self.LoadGroup(downloadString: "\(Link.link)/Mainpage/LoadGroup", param: ["userid":sk.user.userid!]) { (group) in
            if let group = group{
                if group.count > 0{
                    DispatchQueue.main.async {
                        self.group.insert(contentsOf: group, at: 1)
                        self.menuViewController?.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func unwindToLeftView(segue:UIStoryboardSegue) {
    }
    
    @IBAction func userinfobtnpressed(_ sender: Any) {
        
    }
    
    @IBAction func generalsettingbtnpressed(_ sender: Any) {
        present(createStandardActionSheet(), animated: true, completion: nil)
    }
    
}

extension LeftViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "SMTitleMenuCell", for: index)  as! SMTitleMenuViewCell
        if index == 0{
            cell.imageview.backgroundColor = UIColor.mainColor
            cell.imageview.image = UIImage(named: group[index].groupimage!)
            cell.unreadView.isHidden=false
            cell.name.isHidden=true
        }else{
            cell.imageview.backgroundColor = UIColor.mainColor
            cell.unreadView.isHidden=false
            cell.name.isHidden=false
            cell.name.text = group[index].groupname!
        }
        if let image=group[index].groupimage,image != "" && index != 0{
            cell.imageview.kf.indicatorType = .activity
            cell.imageview.kf.setImage(with: URL(string: image))
            cell.imageview.backgroundColor = .clear
            cell.name.isHidden=true
        }
        cell.imageview.layer.cornerRadius = 7
        cell.imageview.clipsToBounds = true
        
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return viewController.view.bounds.width / 4.2
    }
    
    var insets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return group.count
    }
}

extension LeftViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return 2
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        switch index {
        case 0:
            let smContent = UIStoryboard(name: "SMFriendStoryboard", bundle: nil).instantiateInitialViewController() as! SMFriendViewController
            return smContent
        default:
            let smContent = UIStoryboard(name: "SMContentStoryboard", bundle: nil).instantiateViewController(withIdentifier: "SubViewID") as! UINavigationController
            return smContent
        }
    }
}

extension LeftViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        if page != 0{
            if previousPage == 0{
                contentViewController?.scroll(to: 1, animated: false)
            }
            let navView=contentViewController?.childViewControllers[1] as! UINavigationController
            let subView=navView.viewControllers[0] as! SubViewController
            subView.navigationController?.popViewController(animated: true)
            subView.group=group[page]
            SubViewController.isadmin=group[page].isadmin
            subView.leftView=self
            subView.btnGroup.removeAll()
            subView.loadSubGroup(group: group[page])
        }else{
            let smFriendView=contentViewController?.childViewControllers[0] as! SMFriendViewController
            smFriendView.reloadMessage()
            contentViewController?.scroll(to: page, animated: false)
        }
    }
}

extension LeftViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        
    }
}

extension LeftViewController{
    func LoadGroup(downloadString:String, param: [String:Any], complete: @escaping ([Group]?) -> ()){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers:nil).responseArray { (response: DataResponse<[Group]>) in
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

extension LeftViewController: UIViewControllerTransitioningDelegate{
    func createStandardActionSheet() -> SkypeActionController {
        let actionsheet=SkypeActionController()
        actionsheet.addAction(Action(ActionData(title: "Create Group", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            self.performSegue(withIdentifier: "tocreategroup", sender: "creategroup")
        }))
        actionsheet.addAction(Action(ActionData(title: "Join Group", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            self.performSegue(withIdentifier: "tocreategroup", sender: "joingroup")
        }))
        actionsheet.addAction(Action(ActionData(title: "Privacy Settings", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Notification Settings", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Cancel"), style: .cancel, handler: nil))
        actionsheet.backgroundColor = UIColor(hex: "#3AD29F")
        actionsheet.settings.statusBar.showStatusBar=false
        return actionsheet
    }
}
