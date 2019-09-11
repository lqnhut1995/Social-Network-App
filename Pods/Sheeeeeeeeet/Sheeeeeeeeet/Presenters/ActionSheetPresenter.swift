//
//  ActionSheetPresenter.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-11-18.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

/*
 
 Action sheet presenters are used by Sheeeeeeeeet to present
 action sheets in different ways, e.g. with a default bottom
 slide, showing a popover from the tapped view etc.
 
 When implementing this protocol, `present(in:from:)` is the
 standard way to present an action sheet, while `dismiss` is
 the standard way to dismiss it.
 
 `isDismissableWithTapOnBackground` is used to specify if an
 action sheet can be dismissed by tapping on the background.
 
 */

import Foundation

public protocol ActionSheetPresenter: class {
    
    var isDismissableWithTapOnBackground: Bool { get set }
    
    func dismiss(completion: @escaping () -> ())
    func present(sheet: ActionSheet, in vc: UIViewController, from view: UIView?)
    func present(sheet: ActionSheet, in vc: UIViewController, from item: UIBarButtonItem)
    func presentationFrame(for sheet: ActionSheet, in view: UIView) -> CGRect?
}
