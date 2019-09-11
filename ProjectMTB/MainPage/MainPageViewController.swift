//
//  MainPageViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/31/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import LGSideMenuController

class MainPageViewController: LGSideMenuController {

    @IBOutlet var uiview: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leftViewPresentationStyle = .slideBelow
        self.leftViewWidth = UIScreen.main.bounds.width-90
        self.rightViewPresentationStyle = .slideBelow
        self.rightViewWidth = UIScreen.main.bounds.width-100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
