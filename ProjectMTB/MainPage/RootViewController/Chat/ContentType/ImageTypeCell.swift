//
//  ImageTypeCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 10/16/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import UIKit
import Lightbox

class ImageTypeCell: UICollectionViewCell {
    
    var widthConstraint: NSLayoutConstraint!
    var image: UIButton!
    var lightBoxImage=[LightboxImage]()
    var lightBox:CustomLightBox!
    var url:URL!
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
        
        image=UIButton(type: .custom)
        image.imageView?.contentMode = .scaleAspectFit
        image.adjustsImageWhenHighlighted=false
        image.layer.borderColor = UIColor(hex: "#D8D8D8").cgColor
        image.layer.borderWidth = 0.7
        image.addTarget(self, action: #selector(buttonimage(_:)), for: .touchUpInside)
        self.contentView.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 52).isActive=true
        image.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0).isActive=true
        image.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0).isActive=true
        widthConstraint=image.widthAnchor.constraint(equalToConstant: 0)
        widthConstraint.isActive=true
    }
    
    @objc func buttonimage(_ sender: Any) {
        lightBoxImage.removeAll()
        lightBoxImage.append(LightboxImage(imageURL: url!))
        lightBox=CustomLightBox(images: lightBoxImage, startIndex: 0)
        let btn=UIButton(frame: CGRect(x: 15, y: 7, width: lightBox.headerView.closeButton.frame.width-20, height: lightBox.headerView.closeButton.frame.height-10))
        btn.setImage(UIImage(named: "icons8-ellipsis-filled-100"), for: .normal)
        btn.addTarget(self, action: #selector(share(sender:)), for: .touchUpInside)
        lightBox.headerView.addSubview(btn)
        parentViewController?.present(lightBox, animated: true, completion: nil)
    }
    
    @objc func share(sender: UIButton){
        let ac=UIActivityViewController(activityItems: [image.image(for: .normal)!], applicationActivities: nil)
        lightBox.present(ac, animated: true, completion: nil)
    }
}
