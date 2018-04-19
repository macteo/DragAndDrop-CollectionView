//
//  ListController.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 18/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

protocol ListController : class {
    // TODO: this needs to be managed in a better way to control access
    var items : [DraggableItem] { get set }
    var listOperations : ListOperations<DraggableItem> { get set }
    var index : Int { get set }
    // TODO: once everything is converted to use ListOperations
    // remove those two items as they become useless
    func removeItem(at index: Int)
    func insert(item: DraggableItem, at index: Int)
    func performOperations()
    var delegate : ListDelegate? { get set }
}
