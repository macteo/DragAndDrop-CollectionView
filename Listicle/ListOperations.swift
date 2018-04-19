//
//  ListOperations.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

struct ListOperations {
    weak var listController : ListController?
    var addItems = [Int: ColoredCell]()
    var removeItems = [ColoredCell]()
    var addIndexPaths = [IndexPath]()
    var removeIndexPaths = [IndexPath]()
    var listIndex : Int = 0
    
    init() { }
    
    init(list: ListController, index: Int) {
        self.listController = list
        self.listIndex = index
    }
}
