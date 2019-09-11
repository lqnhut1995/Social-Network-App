//
//  UIViewController+RootViewController.swift
//  Sheeeeeeeeet
//
//  Created by Daniel Saidi on 2017-12-01.
//  Copyright © 2017 Daniel Saidi. All rights reserved.
//

import UIKit

extension UIViewController {

    var rootViewController: UIViewController {
        guard let parent = self.parent else { return self }
        return parent.rootViewController
    }
}
