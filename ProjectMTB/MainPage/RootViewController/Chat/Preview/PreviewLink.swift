//
//  PreviewLink.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/16/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import SafariServices

class PreviewLink: UICollectionViewCell {

    @IBOutlet var uiview: UIView!
    @IBOutlet var title: UILabel!
    @IBOutlet var link: UIButton!
    @IBOutlet var newDescription: UILabel!
    @IBOutlet var imageview: UIImageView!
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
        
        uiview.backgroundColor = UIColor.gray.withAlphaComponent(0.1)
        uiview.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        uiview.layer.borderWidth = 0.5
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(previewtap(sender:))))
    }

    @IBAction func linkpressed(_ sender: Any) {
        
    }
    
    @objc func previewtap(sender: UITapGestureRecognizer){
        if let string = link.titleLabel?.text {
            let safariVC = SFSafariViewController(url: URL(string: string)!)
            self.parentViewController?.present(safariVC, animated: true)
        }
    }
}
