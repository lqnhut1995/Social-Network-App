//
//  RootViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/31/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit
import SocketIO

class RootViewController: UIViewController {

    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(nib: UINib(nibName: "RVTitleMenuViewCell", bundle: nil), forCellWithReuseIdentifier: "RVTitleMenuCell")
        menuViewController?.registerFocusView(nib: UINib(nibName: "RVUnderLineView", bundle: nil))
        contentViewController?.scrollView.isScrollEnabled = false
        let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hex: "#3AD29F")
        }
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        
        sk.socket.defaultSocket.on("notifyconnect") { (data, ack) in
            let vc=UIStoryboard(name: "VoiceChatStoryboard", bundle: nil).instantiateViewController(withIdentifier: "voicechat") as! VoiceChatViewController
            var data=data[0] as! Dictionary<String,Any>
            vc.chat=data["type"] as! String
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sideMenuController?.isRightViewEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sideMenuController?.isRightViewEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        if segue.identifier == "toaddfriend"{
            let navView = segue.destination as! UINavigationController
            let vc = navView.viewControllers[0] as! ChannelInfoViewController
            vc.initType(type: .AddFriendType)
        }
    }
    
    @IBAction func unwindtoRootView(segue:UIStoryboardSegue) {
    }
    
    @IBAction func addfriendbtnpressed(_ sender: Any) {
    }
    
}

extension RootViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "RVTitleMenuCell", for: index)  as! RVTitleMenuViewCell
        switch index {
        case 0:
            cell.name.text = "All"
            cell.name.textColor = .darkGray
        case 1:
            cell.name.text = "Onlines"
            cell.name.textColor = .lightGray
        case 2:
            cell.name.text = "Requests"
            cell.name.textColor = .lightGray
        default:
            cell.name.text = "Blocks"
            cell.name.textColor = .lightGray
        }
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        let width = viewController.view.bounds.width / 3
        (menuViewController?.focusView.subviews[0] as! RVUnderLineView).widthConstraintLine.constant = width
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
        return 4
    }
}

extension RootViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return 1
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        return UIStoryboard(name: "RVFriendsStoryboard", bundle: nil).instantiateInitialViewController() as! RVFriendsViewController
    }
}

extension RootViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        
        (menuViewController?.cellForItem(at: page) as! RVTitleMenuViewCell).name.textColor = UIColor.darkGray
        (menuViewController?.cellForItem(at: previousPage) as! RVTitleMenuViewCell).name.textColor = UIColor.lightGray
        let contentView=contentViewController?.childViewControllers[0] as! RVFriendsViewController
        contentView.loadTable(row: page)
    }
}

extension RootViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {

    }
}
