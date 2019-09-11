//
//  ImageCheckRow.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/10/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import Eureka

public final class ImageCheckRow<T: Equatable>: Row<ImageCheckCell<T>>, SelectableRowType, RowType {
    public var selectableValue: T?
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}

public class ImageCheckCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Image for selected state
    lazy public var trueImage: UIImage = {
        return UIImage(named: "icons8-checked-checkbox-50")!
    }()
    
    /// Image for unselected state
    lazy public var falseImage: UIImage = {
        return UIImage(named: "icons8-unchecked-checkbox-50")!
    }()
    
    public override func update() {
        super.update()
        checkImageView?.image = row.value != nil ? trueImage : falseImage
//        checkImageView?.sizeToFit()
        checkImageView?.tintColor = UIColor.mainColor
        
    }
    
    /// Image view to render images. If `accessoryType` is set to `checkmark`
    /// will create a new `UIImageView` and set it as `accessoryView`.
    /// Otherwise returns `self.imageView`.
    open var checkImageView: UIImageView?
    
    public override func setup() {
        super.setup()
        accessoryType = .checkmark
        checkImageView = UIImageView()
        checkImageView?.frame = CGRect(origin: (checkImageView?.frame.origin)!, size: CGSize(width: 20, height: 20))
        accessoryView = checkImageView
    }
    
    public override func didSelect() {
        row.reload()
        row.select()
        row.deselect()
    }
    
}
