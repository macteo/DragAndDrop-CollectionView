//
//  ListManager.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class ListManager {
    var listControllers = [ListController]()
}

extension ListManager: ListDelegate {
    
    /// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView, listController: ListController)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                listController.removeItem(at: sourceIndexPath.row)
                listController.insert(item: item.dragItem.localObject as! Cell, at: dIndexPath.row)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }
    
    /// This method copies a cell from source indexPath in 1st collection view to destination indexPath in 2nd collection view. It works for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView, listController: ListController)
    {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated()
            {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                listController.insert(item: item.dragItem.localObject as! Cell, at: indexPath.row)
                indexPaths.append(indexPath)
            }
            collectionView.insertItems(at: indexPaths)
        })
    }
    
    /// This method should transfer cells from source indexPath in one collection view to destination indexPath to another collection view, removing them from the source collection view. It should work for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    func transferItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView, listController: ListController)
    {
        for (index, item) in coordinator.items.enumerated()
        {
            let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
            var newObject = item.dragItem.localObject as? Cell
            var sourceListIndex : Int?
            
            if newObject == nil {
                guard item.dragItem.itemProvider.canLoadObject(ofClass: NSString.self) else { return }
                newObject = Cell("temp-\(index)")
                item.dragItem.itemProvider.loadObject(ofClass: NSString.self, completionHandler: { (object, error) in
                    if let string = object as? String {
                        DispatchQueue.main.async {
                            newObject?.name = string
                            collectionView.reloadItems(at: [indexPath])
                        }
                    }
                })
                newObject?.list = listController.index
            } else {
                sourceListIndex = newObject!.list
            }
            
            guard let localObject = newObject else { return }
            
            if let sourceIndex = sourceListIndex, listControllers.count > sourceIndex {
                let sourceController = listControllers[sourceIndex]
                if let indexOf = sourceController.items.index(where: { $0 == localObject }) {
                    sourceController.listOperations.removeItems.append(localObject)
                    sourceController.listOperations.removeIndexPaths.append(IndexPath(item: indexOf, section: 0))
                }
            }
            
            localObject.list = listController.index
            listController.listOperations.addItems[indexPath.row] = localObject
            listController.listOperations.addIndexPaths.append(indexPath)
        }
        
        // Call performOperations on evary managed list controller
        listControllers.forEach { (controller) in
            controller.performOperations()
        }
    }
}
