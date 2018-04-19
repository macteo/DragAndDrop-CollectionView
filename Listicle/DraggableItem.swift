//
//  DraggableItem.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

class DraggableItem : Equatable {
    var identifier = UUID()
    var listIndex : Int = 0
    
    public static func == (lhs: DraggableItem, rhs: DraggableItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
