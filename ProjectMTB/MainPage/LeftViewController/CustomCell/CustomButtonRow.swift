//
//  CustomButtonRow.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 11/23/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import Eureka

open class CustomButtonCellOf<T: Equatable>: Cell<T>, CellType {
    
    open var size = CGSize(width: 40, height: 40)
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
        accessoryType = .none
        editingAccessoryType = accessoryType
        textLabel?.textAlignment = .center
        textLabel?.textColor = tintColor.withAlphaComponent(row.isDisabled ? 0.3 : 1.0)
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.bounds = CGRect(origin: CGPoint(x: imageView!.frame.origin.x-10, y: imageView!.frame.origin.y), size: size)
        imageView?.frame = CGRect(origin: CGPoint(x: imageView!.frame.origin.x-10, y: imageView!.frame.origin.y), size: size)
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds=true
        textLabel?.frame = CGRect(origin: CGPoint(x: textLabel!.frame.origin.x-10, y: textLabel!.frame.origin.y), size: textLabel!.frame.size)
    }
}

public typealias ButtonCell = CustomButtonCellOf<String>

// MARK: ButtonRow
open class _CustomButtonRowOf<T: Equatable> : Row<CustomButtonCellOf<T>> {
    open var presentationMode: PresentationMode<UIViewController>?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.makeController() {
                    presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
                } else {
                    presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    open override func customUpdateCell() {
        super.customUpdateCell()
        let leftAligmnment = presentationMode != nil
        cell.textLabel?.textAlignment = leftAligmnment ? .left : .center
        cell.accessoryType = !leftAligmnment || isDisabled ? .none : .disclosureIndicator
        cell.editingAccessoryType = cell.accessoryType
        cell.textLabel?.textColor = !leftAligmnment ? cell.tintColor.withAlphaComponent(isDisabled ? 0.3 : 1.0) : nil
    }
    
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        (segue.destination as? RowControllerType)?.onDismissCallback = presentationMode?.onDismissCallback
    }
}

/// A generic row with a button. The action of this button can be anything but normally will push a new view controller
public final class CustomButtonRowOf<T: Equatable> : _CustomButtonRowOf<T>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    func updateSize(size: CGSize){
        cell.size = size
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public typealias CustomButtonRow = CustomButtonRowOf<String>
