//
//  ListOperations.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

public struct ListOperations<T:DraggableItem> {
    public var addItems = [Int: T]()
    public var removeItems = [T]()
    public var addIndexPaths = [IndexPath]()
    public var removeIndexPaths = [IndexPath]()
    public var reloadPaths = [IndexPath]()
}
