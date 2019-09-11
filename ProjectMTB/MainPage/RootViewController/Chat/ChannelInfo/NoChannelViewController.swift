//
//  NoChannelViewController.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/1/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit

class NoChannelViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barStyle = .blackTranslucent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sideMenuController?.isRightViewEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sideMenuController?.isRightViewEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func unwindToNoChannel(segue:UIStoryboardSegue) {
    }
}
