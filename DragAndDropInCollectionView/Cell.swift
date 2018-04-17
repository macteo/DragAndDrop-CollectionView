//
//  Cell.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class Cell : Equatable {
    var name : String
    var list : Int = 0
    
    init(_ name: String) {
        self.name = name
    }
    
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.name == rhs.name
    }
}
