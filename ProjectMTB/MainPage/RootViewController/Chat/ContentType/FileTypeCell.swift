//
//  FileTypeCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/16/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Lightbox
import SafariServices

class FileTypeCell: UICollectionViewCell {
    
    @IBOutlet var name: UILabel!
    @IBOutlet var size: UILabel!
    @IBOutlet var uiview: UIView!
    var lightBoxImage=[LightboxImage]()
    var lightBox:CustomLightBox!
    var url:URL?
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
        
//        uiview.layer.borderColor = UIColor.lightGray.cgColor
//        uiview.layer.borderWidth = 1
//        uiview.layer.cornerRadius = 7
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filetap(sender:))))
    }
    
    @objc func filetap(sender: UITapGestureRecognizer){
        lightBoxImage.removeAll()
        lightBoxImage.append(LightboxImage(image: UIImage(named: "tudou-logo (1)")!, text: "", videoURL: url))
        lightBox=CustomLightBox(images: lightBoxImage, startIndex: 0)
        parentViewController?.present(lightBox, animated: true, completion: nil)

    }
    
}
