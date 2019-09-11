//
//  CustomUIDelegate.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import DKImagePickerController

open class CustomUIDelegate: DKImagePickerControllerDefaultUIDelegate {

    override open func imagePickerController(_ imagePickerController: DKImagePickerController, showsCancelButtonForVC vc: UIViewController) {
        let btnA=UIButton(type: .custom)
        btnA.setTitle("Cancel", for: .normal)
        btnA.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        btnA.setTitleColor(UIColor.white, for: .normal)
        btnA.addTarget(imagePickerController, action: #selector(imagePickerController.dismiss as () -> Void), for: .touchUpInside)
        btnA.sizeToFit()
        let leftbtn=UIBarButtonItem(customView: btnA)
        vc.navigationItem.leftBarButtonItem = leftbtn
        
        let btnB=UIButton(type: .custom)
        btnB.setTitle("Done", for: .normal)
        btnB.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)!
        btnB.setTitleColor(UIColor.white, for: .normal)
        btnB.sizeToFit()
        btnB.addTarget(imagePickerController, action: #selector(imagePickerController.done as () -> Void), for: .touchUpInside)
        let rightbtn=UIBarButtonItem(customView: btnB)
        vc.navigationItem.rightBarButtonItem = rightbtn
    }
    
    override open func layoutForImagePickerController(_ imagePickerController: DKImagePickerController) -> UICollectionViewLayout.Type {
        return CustomFlowLayout.self
    }
}

open class CustomFlowLayout: UICollectionViewFlowLayout {
    
    open override func prepare() {
        super.prepare()
        
        let contentWidth = self.collectionView!.bounds.width/4-4
        self.itemSize = CGSize(width: contentWidth, height: contentWidth)
        
        self.minimumInteritemSpacing = 4
        self.minimumLineSpacing = 4
    }
    
}
