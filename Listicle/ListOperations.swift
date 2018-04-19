//
//  ListOperations.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

struct ListOperations {
    var addItems = [Int: ColoredCell]()
    var removeItems = [ColoredCell]()
    var addIndexPaths = [IndexPath]()
    var removeIndexPaths = [IndexPath]()    
}
