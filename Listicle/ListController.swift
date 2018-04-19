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
    func performOperations()
    var delegate : ListDelegate? { get set }
}
