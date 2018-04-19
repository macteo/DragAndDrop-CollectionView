//
//  ListManager.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

class ListManager<Item:DraggableItem> {
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
        // TODO: convert to list operations and remove direct access to the collectionView
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= collectionView.numberOfItems(inSection: 0)
            {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }
            collectionView.performBatchUpdates({
                if let draggableItem = item.dragItem.localObject as? DraggableItem {
                    listController.removeItem(at: sourceIndexPath.row)
                    listController.insert(item: draggableItem, at: dIndexPath.row)
                    
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [dIndexPath])
                }
                
            })
            coordinator.drop(item.dragItem, toItemAt: dIndexPath)
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
        // TODO: convert to list operations and remove direct access to the collectionView
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated()
            {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                if let draggableItem = item.dragItem.localObject as? DraggableItem {
                    listController.insert(item: draggableItem, at: indexPath.row)
                    indexPaths.append(indexPath)
                }
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
            var newObject = item.dragItem.localObject as? Item
            var sourceListIndex : Int?
            
            if newObject == nil {
                guard item.dragItem.itemProvider.canLoadObject(ofClass: NSString.self) else { return }
                newObject = Item()
                item.dragItem.itemProvider.loadObject(ofClass: NSString.self, completionHandler: { (object, error) in
                    // TODO: we should support dropping from other apps and choose the appropriate cell or at least associate the correct object
                    // An approach would be to associate an itemProvider to the DraggableItem and let it extract the value.
                    // Every subclass could then specify what to do with the extract item
                    // We should also make DraggableItem a generic on ListManager so it can support different cell subclasses
                    if let string = object as? String {
                        DispatchQueue.main.async {
                            // TODO: replace with some generic cell management
                            // newObject?.name = string
                            collectionView.reloadItems(at: [indexPath])
                        }
                    }
                })
                newObject?.listIndex = listController.index
            } else {
                sourceListIndex = newObject!.listIndex
            }
            
            guard let localObject = newObject else { return }
            
            if let sourceIndex = sourceListIndex, listControllers.count > sourceIndex {
                let sourceController = listControllers[sourceIndex]
                if let indexOf = sourceController.items.index(where: { $0 == localObject }) {
                    sourceController.listOperations.removeItems.append(localObject)
                    sourceController.listOperations.removeIndexPaths.append(IndexPath(item: indexOf, section: 0))
                }
            }
            
            localObject.listIndex = listController.index
            listController.listOperations.addItems[indexPath.row] = localObject
            listController.listOperations.addIndexPaths.append(indexPath)
        }
        
        // Call performOperations on evary managed list controller
        listControllers.forEach { (controller) in
            controller.performOperations()
        }
    }
}
