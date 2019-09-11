//
//  CustomLightBox.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/22/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import Lightbox

class CustomLightBox: LightboxController{
    
    let statusBar = UIApplication.shared.value(forKey: "statusBar") as! UIView
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = .clear
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(hex: "#3AD29F")
        }
    }
}
