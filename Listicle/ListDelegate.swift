//
//  ListDelegate.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

public protocol ListDelegate {
    
    /// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - listController: listController that is accepting the drop.
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, listController: ListController)
    
    /// This method copies a cell from source indexPath in 1st collection view to destination indexPath in 2nd collection view. It works for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - listController: listController that is accepting the drop.
    func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, listController: ListController)
    
    /// This method should transfer cells from source indexPath in one collection view to destination indexPath to another collection view, removing them from the source collection view. It should work for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - listController: listController that is accepting the drop.
    func transferItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, listController: ListController)
    
    /// The list of list controllers managed by the class
    var listControllers : [ListController] { get }
}
