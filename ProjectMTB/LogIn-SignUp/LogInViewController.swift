//
//  ViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import PagingKit

class LogInViewController: UIViewController {

    var menuViewController: PagingMenuViewController?
    var contentViewController: PagingContentViewController?
    let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
    
    lazy var firstLoad: (() -> Void)? = { [weak self, menuViewController, contentViewController] in
        menuViewController?.reloadData()
        contentViewController?.reloadData()
        self?.firstLoad = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuViewController?.register(nib: UINib(nibName: "TitleMenuView", bundle: nil), forCellWithReuseIdentifier: "TitleMenuCell")
        menuViewController?.registerFocusView(nib: UINib(nibName: "UnderLineView", bundle: nil))
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        firstLoad?()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .clear
        }
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hex: "#3AD29F")
        }
        self.navigationController?.navigationBar.barStyle = .default
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
    
    @IBAction func unwindToLogin(segue:UIStoryboardSegue) {
    }
}

extension LogInViewController: PagingMenuViewControllerDataSource {
    func menuViewController(viewController: PagingMenuViewController, cellForItemAt index: Int) -> PagingMenuViewCell {
        let cell = viewController.dequeueReusableCell(withReuseIdentifier: "TitleMenuCell", for: index)  as! TitleMenuViewCell
        switch index {
        case 0:
            cell.title.text = "LOGIN"
        default:
            cell.title.text = "SIGNUP"
        }
        switch index {
        case 0:
            cell.title.textColor = UIColor.darkGray
        default:
            cell.title.textColor = UIColor.lightGray
        }
        cell.backgroundColor = UIColor(hex: "#F4F4F6")
        return cell
    }
    
    func menuViewController(viewController: PagingMenuViewController, widthForItemAt index: Int) -> CGFloat {
        return viewController.view.bounds.width / 2
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

extension LogInViewController: PagingContentViewControllerDataSource {
    func numberOfItemsForContentViewController(viewController: PagingContentViewController) -> Int {
        return 2
    }
    
    func contentViewController(viewController: PagingContentViewController, viewControllerAt index: Int) -> UIViewController {
        switch index {
        case 1:
            return UIStoryboard(name: "FocusStoryboard", bundle: nil).instantiateInitialViewController() as! FocusViewController
        default:
            return UIStoryboard(name: "LogInFocusStoryboard", bundle: nil).instantiateInitialViewController() as! LogInFocusViewController
        }
    }
}

extension LogInViewController: PagingMenuViewControllerDelegate {
    func menuViewController(viewController: PagingMenuViewController, didSelect page: Int, previousPage: Int) {
        contentViewController?.scroll(to: page, animated: true)
        
        (menuViewController?.cellForItem(at: page) as! TitleMenuViewCell).title.textColor = UIColor.darkGray
        if page == 0{
            (menuViewController?.cellForItem(at: 1) as! TitleMenuViewCell).title.textColor = UIColor.lightGray
        }else{
            (menuViewController?.cellForItem(at: 0) as! TitleMenuViewCell).title.textColor = UIColor.lightGray
        }
    }
}

extension LogInViewController: PagingContentViewControllerDelegate {
    func contentViewController(viewController: PagingContentViewController, didManualScrollOn index: Int, percent: CGFloat) {
        menuViewController?.scroll(index: index, percent: percent, animated: false)
        
        if index == 0{
            if percent == 0{
                (menuViewController?.cellForItem(at: index) as! TitleMenuViewCell).title.textColor = UIColor.darkGray
                (menuViewController?.cellForItem(at: 1) as! TitleMenuViewCell).title.textColor = UIColor.lightGray
            }
        }else{
            if percent == 0{
                (menuViewController?.cellForItem(at: index) as! TitleMenuViewCell).title.textColor = UIColor.darkGray
                (menuViewController?.cellForItem(at: 0) as! TitleMenuViewCell).title.textColor = UIColor.lightGray
            }
        }
    }
}

