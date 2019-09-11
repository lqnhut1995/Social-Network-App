//
//  LoadingScreenViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/7/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class LoadingScreenViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
}
