//
//  ActionSheetMultiSelectToggleItemAppearance.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2018-03-31.
//  Copyright © 2018 Daniel Saidi. All rights reserved.
//

import UIKit

public class ActionSheetMultiSelectToggleItemAppearance: ActionSheetItemAppearance {
    
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
    }
    
    public override init(copy: ActionSheetItemAppearance) {
        super.init(copy: copy)
        if let copy = copy as? ActionSheetMultiSelectToggleItemAppearance {
            deselectAllTextColor = copy.deselectAllTextColor
            selectAllTextColor = copy.selectAllTextColor
        }
    }
    
    
    // MARK: - Properties
    
    public var deselectAllTextColor: UIColor?
    public var selectAllTextColor: UIColor?
}
