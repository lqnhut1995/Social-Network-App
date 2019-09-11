//
//  ValidationError.swift
//  ProjectMTB
//
//  Created by Hell Rocky on 8/24/18.
//  Copyright © 2018 Hell Rocky. All rights reserved.
//

import Foundation

class ValidationError: Error{
    var name: String
    init(name: String) {
        self.name = name
    }
}
