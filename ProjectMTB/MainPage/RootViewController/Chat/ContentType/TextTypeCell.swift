//
//  TextTypeCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/16/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import XLActionController

class TextTypeCell: UICollectionViewCell {
    
    @IBOutlet var message: UILabel!
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longtap(sender:))))
    }
    
    @objc func longtap(sender: UITapGestureRecognizer){
        if sender.state == .began && sender.numberOfTouches == 1{
            parentViewController?.present(createStandardActionSheet(), animated: true, completion: nil)
        }
    }
    
    func createStandardActionSheet() -> SkypeActionController {
        let actionsheet=SkypeActionController()
        actionsheet.addAction(Action(ActionData(title: "User Settings", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Copy Text", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { (action) in
//            guard let vc=parentViewController else {return}
            
        }))
        actionsheet.addAction(Action(ActionData(title: "Add Reaction", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Edit Message", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Delete Message", image: UIImage(named: "icons8-add-user-group-man-man-100 (1)")!), style: .default, handler: { action in
            // do something useful
        }))
        actionsheet.addAction(Action(ActionData(title: "Close"), style: .cancel, handler: nil))
        actionsheet.backgroundColor = UIColor(hex: "#3AD29F")
        return actionsheet
    }
}
