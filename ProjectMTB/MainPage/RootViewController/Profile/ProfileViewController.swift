//
//  ProfileViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/6/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit
import Alamofire

protocol ProfileDelegate: class{
    func createNewDirectMessage(data: PrivateRoom)
    func loadTable(type: String)
}

class ProfileViewController: UIViewController {

    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    weak var delegate: ProfileDelegate?
    @IBOutlet var name: UILabel!
    @IBOutlet var sendmessage: UIButton!
    @IBOutlet var option2: UIButton!
    @IBOutlet var option1: UIButton!
    @IBOutlet var profileimage: UIImageView!
    @IBOutlet var tableview: UITableView!
    var statusBar:UIView!
    var user:userLogin!
    var row=0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(nib: UINib(nibName: "ProfileTitleMenuViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfileTitleMenuCell")
        menuViewController?.registerFocusView(nib: UINib(nibName: "ProfileUnderLineView", bundle: nil))
        contentViewController?.scrollView.isScrollEnabled = false
        
        tableview.dataSource=self
        tableview.delegate=self
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        switch row {
        case 0,1:
            ListBlockedID(downloadString: Link.link+"/Friends/ListBlockedID", param: ["userid":sk.user.userid!,"otheruserid":user.userid!])
            option1.isHidden=true
        case 2:
            option2.isHidden=false
            option2.setTitle("Accept", for: .normal)
            option1.isHidden=false
            option1.setTitle("Ignore", for: .normal)
        default:
            option2.isHidden=false
            option2.setTitle("Unlock", for: .normal)
            option1.isHidden=true
        }
        name.text = user.username!+"#"+String(describing: user.userid!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        firstLoad?()
        profileimage.layer.cornerRadius = profileimage.frame.width/2
        option1.layer.cornerRadius = 7
        option1.layer.borderColor = UIColor.white.cgColor
        option1.layer.borderWidth = 1
        option2.layer.cornerRadius = 7
        option2.layer.borderColor = UIColor.white.cgColor
        option2.layer.borderWidth = 1
        sendmessage.layer.cornerRadius = 7
        sendmessage.layer.borderColor = UIColor.white.cgColor
        sendmessage.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if user.userimage != nil {profileimage.kf.setImage(with: URL(string: user.userimage!)!)}else{ (profileimage.image=UIImage(named: "Tudou"))}
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

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
    }
    
    func setupbutton(row: Int){
        self.row=row
    }
    
    @IBAction func option1btnpressed(_ sender: Any) {//Ignore
        option1.isHidden=true
        option2.isHidden=true
    }
    
    @IBAction func option2btnpressed(_ sender: Any) {//Accept
        switch option2.titleLabel?.text {
        case "Block":
            BlockUnlock(downloadString: Link.link+"/Friends/Block", param: ["userid":sk.user.userid!,"otheruserid":user.userid!], type: "Block")
        case "Unlock":
            BlockUnlock(downloadString: Link.link+"/Friends/Unlock", param: ["userid":sk.user.userid!,"otheruserid":user.userid!], type: "Unlock")
        default:
            RequestAccept(downloadString: Link.link+"/Friends/FriendAccept", param: ["userid":sk.user.userid!,"otheruserid":user.userid!])
        }
    }
    
    @IBAction func sendmessagebtnpressed(_ sender: Any) {
        LoadPrivateMessageID(downloadString: Link.link+"/Mainpage/LoadPrivateMessageID", param: ["userid":sk.user.userid!,"otheruserid":user.userid!]) { [weak self](pr) in
            if pr == nil{
                self?.CreatePrivateMessage(downloadString: Link.link+"/Mainpage/CreatePrivateMessage", param: ["userid":sk.user.userid!,"otheruserid":self!.user.userid!,"roomname":self!.user.username!+","+sk.user.username!,"membercount":2])
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
    }
}

extension ProfileViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "ProfileTitleMenuCell", for: index) as! ProfileTitleMenuViewCell
        switch index {
        case 0:
            cell.name.text = "Groups"
            cell.name.textColor = .darkGray
        default:
            cell.name.text = "Friends"
            cell.name.textColor = .lightGray
        }
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        let width = UIScreen.main.bounds.width / 2
        (menuViewController?.focusView.subviews[0] as! ProfileUnderLineView).widthConstraintLine.constant = width
        return width
    }
    
    var insets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }
    
    func numberOfItemsForMenuViewController(viewController: PagingMenuViewController) -> Int {
        return 2
    }
}

extension ProfileViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return 1
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return UIStoryboard(name: "ProfileContentStoryboard", bundle: nil).instantiateInitialViewController() as! ProfileContentViewController
    }
}

extension ProfileViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        
        (menuViewController?.cellForItem(at: page) as! ProfileTitleMenuViewCell).name.textColor = UIColor.darkGray
        (menuViewController?.cellForItem(at: previousPage) as! ProfileTitleMenuViewCell).name.textColor = UIColor.lightGray
//        let contentView=contentViewController?.childViewControllers[0] as! ProfileContentViewController
        
    }
}

extension ProfileViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        
    }
}

extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "ratingcell", for: indexPath) as! RatingTableViewCell
        switch indexPath.row {
        case 0:
            cell.name.text = "Powerpoint"
        case 1:
            cell.name.text = "Public Speaking"
        case 2:
            cell.name.text = "Word"
        default:
            cell.name.text = "Negotiation"
        }
        return cell
    }
}

extension ProfileViewController{
    func RequestAccept(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self](response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        self?.option2.setTitle("Block", for: .normal)
                        self?.option1.isHidden=true
                        self?.delegate?.loadTable(type: "2")
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
    
    func CreatePrivateMessage(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseArray { [weak self](response: DataResponse<[PrivateRoom]>) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    
                    self?.delegate?.createNewDirectMessage(data: data[0])
                    
                    //socket join room
                    let jsonRoom:[String:Any]=[
                        "room":data[0].uuid!,
                        "userid":sk.user.userid!,
                    ]
                    sk.socket.defaultSocket.emit("join", with: [jsonRoom])
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
    
    func BlockUnlock(downloadString:String, param: [String:Any], type: String){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { [weak self](response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["status"] as! String) == "200"{
                        switch type{
                        case "Block":
                            self?.option2.setTitle("Unlock", for: .normal)
                        default:
                            self?.option2.setTitle("Block", for: .normal)
                            if self?.row == 3{
                                self?.delegate?.loadTable(type: "3")
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
    
    func ListBlockedID(downloadString:String, param: [String:Any]){
        Alamofire.request(downloadString, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result{
            case .success( _):
                if let data=response.result.value{
                    let json=data as! Dictionary<String,Any>
                    if (json["isblocked"] as! String) == "true"{
                        self.option2.isHidden=false
                        self.option2.setTitle("Unlock", for: .normal)
                    }else{
                        self.option2.isHidden=false
                        self.option2.setTitle("Block", for: .normal)
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
    
    func LoadPrivateMessageID(downloadString:String, param: [String:Any],complete: @escaping ([PrivateRoom]?) -> ()){
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
