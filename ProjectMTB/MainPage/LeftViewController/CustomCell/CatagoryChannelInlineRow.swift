//
//  UserSettingCustomCell.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 9/27/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation
import Eureka
import SwiftEntryKit

public class SubCatagoryChannelCell: Cell<String>, CellType {
    
    @IBOutlet var rowTitle: UILabel!
    @IBOutlet var name: UITextField!
    var cataView:CatagoryChannelViewController!
    var param=[String:Any]()
    var downloadString=""
    var type:ClType!
    var attr:EKAttributes!
    var leaveCatagoryChannelView:EKAlertMessageView!
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func setup() {
        super.setup()
        
        leaveCatagoryChannel()
    }
    
    open override func update() {
        super.update()
        
        height = {return 130}
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    @IBAction func deletecalled(_ sender: Any) {
        SwiftEntryKit.display(entry: leaveCatagoryChannelView, using: attr)
    }

}

public final class SubCatagoryChannelRow<T: Equatable> : Row<SubCatagoryChannelCell>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<SubCatagoryChannelCell>(nibName: "CatagoryChannelInlineView")
    }
    func updatecell(cataView: CatagoryChannelViewController,title: String, downloadString: String, param: [String:Any],type: ClType){
        self.cell.cataView = cataView
        self.cell.param = param
        self.cell.downloadString=downloadString
        self.cell.rowTitle.text = title
        self.cell.type = type
    }
    func updateValue(value: String){
        self.cell.name.text = value
    }
}

public typealias SubChannelRow = SubCatagoryChannelRow<String>

final class CatagoryChannelRow: Row<LabelCell>, RowType, InlineRowType{
    
    typealias InlineRow = SubChannelRow
    
    public func setupInlineRow(_ inlineRow: InlineRow) {
        inlineRow.cell.height = { UITableViewAutomaticDimension }
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
    
    required init(tag: String?) {
        super.init(tag: tag)
    }
    
}

extension SubCatagoryChannelCell{
    func leaveCatagoryChannel(){
        attr=EKAttributes.centerFloat
        let style=FormStyle.light
        var font:EKProperty.LabelStyle = .init(font: UIFont(name: "HelveticaNeue-Bold", size: CGFloat(16))!, color: UIColor.white, alignment: .center)
        let acceptBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Leave", style: style.buttonTitle), backgroundColor: UIColor(hex: "#FF696C"), highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            switch self.type{
            case .CatagoryChannelType:
                self.cataView.DeleteTopic(downloadString: self.downloadString, param: self.param)
            case .ClassType:
                self.cataView.DeleteSubGroup(downloadString: self.downloadString, param: self.param)
            default:
                break
            }
            
            SwiftEntryKit.dismiss()
        })
        font.color = .black
        let canceltBtn=EKProperty.ButtonContent(label: EKProperty.LabelContent(text: "Cancel", style: font), backgroundColor: EKColor.Gray.light, highlightedBackgroundColor: style.buttonBackground.withAlphaComponent(0.8), action: {
            
            SwiftEntryKit.dismiss()
        })
        font.color = .white
        let description=EKProperty.LabelContent(text: "", style: font)
        let label=EKProperty.LabelContent(text: "Are You Sure Want To Leave Group", style: style.title)
        attr.popBehavior = EKAttributes.PopBehavior.overridden
        attr.entryBackground = .color(color: UIColor.white)
        attr.screenBackground = .color(color: .dimmedDarkBackground)
        attr.entranceAnimation = .init(translate: .init(duration: 0.7, spring: .init(damping: 0.7, initialVelocity: 0)),
                                       scale: .init(from: 0.7, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attr.positionConstraints.maxSize = .init(width: EKAttributes.PositionConstraints.Edge.constant(value: UIScreen.main.bounds.width-50), height: .intrinsic)
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.displayDuration = .infinity
        attr.roundCorners = .all(radius: 8)
        leaveCatagoryChannelView=EKAlertMessageView(with: EKAlertMessage(simpleMessage: EKSimpleMessage(title: label, description: description), buttonBarContent: EKProperty.ButtonBarContent(with: acceptBtn,canceltBtn, separatorColor: EKColor.Gray.light, buttonHeight: 50, expandAnimatedly: true)))
    }
}
