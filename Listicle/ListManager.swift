//
//  ListManager.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

public class ListManager<Item:DraggableItem, Provider:NSItemProviderReading> {
    public var listControllers = [ListController]()
}

extension ListManager: ListDelegate {
    
    public func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, listController: ListController)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= listController.items.count
            {
                dIndexPath.row = listController.items.count - 1
            }
            if let draggableItem = item.dragItem.localObject as? Item {
                listController.listOperations.removeItems.append(draggableItem)
                listController.listOperations.addItems[dIndexPath.row] = draggableItem
                listController.listOperations.removeIndexPaths.append(sourceIndexPath)
                listController.listOperations.addIndexPaths.append(dIndexPath)
            }
            listController.performOperations()
            coordinator.drop(item.dragItem, toItemAt: dIndexPath)
        }
    }

    public func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, listController: ListController)
    {
        for (index, item) in coordinator.items.enumerated()
        {
            let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
            if let draggableItem = item.dragItem.localObject as? DraggableItem {
                listController.listOperations.addItems[indexPath.row] = draggableItem
                listController.listOperations.addIndexPaths.append(indexPath)
            }
        }
        listController.performOperations()
    }

    public func transferItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, listController: ListController)
    {
        for (index, item) in coordinator.items.enumerated()
        {
            let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
            var newObject = item.dragItem.localObject as? Item
            var sourceListIndex : Int?
            
            if newObject == nil {
                guard item.dragItem.itemProvider.canLoadObject(ofClass: Provider.self) else { return }
                newObject = Item()
                newObject?.loadObject(from: item.dragItem.itemProvider, completionHandler: { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            listController.listOperations.reloadPaths.append(indexPath)
                            listController.performOperations()
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
