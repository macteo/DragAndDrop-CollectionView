//
//  ListController.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 18/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

public protocol ListController : class {
    func index(of item: AnyObject) -> Int?
    var numberOfItems: Int { get }
    var listOperations : ListOperations<DraggableItem> { get set }
    var index : Int { get set }
    var delegate : ListDelegate? { get set }
    func reloadData()
    func performOperations()
}
