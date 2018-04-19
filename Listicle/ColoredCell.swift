//
//  ColoredCell.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

class ColoredCell : Equatable {
    var name : String
    var color : UIColor?
    var identifier = UUID()
    var list : Int = 0
    
    init() {
        self.name = "Random"
        self.color = .random
    }
    
    init(_ name: String) {
        self.name = name
        if let color = UIColor.named(name) {
            self.color = color
        } else {
            self.color = .random
        }
    }
    
    init(_ name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
    
    public static func == (lhs: ColoredCell, rhs: ColoredCell) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
