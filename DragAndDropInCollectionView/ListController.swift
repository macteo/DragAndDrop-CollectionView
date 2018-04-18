//
//  Listable.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 18/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import Foundation

protocol ListController : class {
    // TODO: this needs to be managed in a better way to control access
    var items : [Cell] { get set }
    var listOperations : ListOperations { get set }
    var index : Int { get set }
    func removeItem(at index: Int)
    func insert(item: Cell, at index: Int)
    func performOperations()
    var delegate : ListDelegate? { get set }
}
