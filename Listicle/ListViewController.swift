//
//  ListViewController.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

fileprivate let listReuseIdentifier = "listCell"

class ListViewController: UIViewController {
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: UICollectionViewFlowLayout())
    
    var items = [DraggableItem]()
    var index : Int = 0
    
    var listOperations = ListOperations()
    
    var delegate : ListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.frame = view.bounds
        collectionView.backgroundColor = .white
        collectionView.clipsToBounds = false
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.backgroundColor = .clear // TODO: should be set the same color of the container
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            layout.minimumLineSpacing = 4
            layout.minimumInteritemSpacing = 4
        }
        
        resetOperations()
        
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: listReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collectionView.bounds.size.width - 8, height: 100)
    }
}

extension ListViewController : ListController {

    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func insert(item: DraggableItem, at index: Int) {
        items.insert(item, at: index)
    }
    
    func performOperations() {
        // Actually perform the operations
        items = items.filter { !listOperations.removeItems.contains($0) }
        
        listOperations.addItems.forEach { (index, cell) in
            if items.count < index {
                items.append(cell)
            } else {
                items.insert(cell, at: index)
            }
        }
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: listOperations.removeIndexPaths)
            collectionView.insertItems(at: listOperations.addIndexPaths)
            collectionView.reloadItems(at: listOperations.reloadPaths)
        })

        defer {
            resetOperations()
        }
    }
    
    func resetOperations() {
        listOperations = ListOperations()
    }
}

extension ListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: listReuseIdentifier, for: indexPath) as! ListCell
        if let item = items[indexPath.row] as? ColoredItem {
            cell.backgroundColor = item.color
            cell.customLabel.text = item.name.capitalized
        }
        return cell
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    
}

extension ListViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        if let item = items[indexPath.row] as? ColoredItem {
            let itemProvider = NSItemProvider(object: item.name as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        } else {
            return []
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        if let item = items[indexPath.row] as? ColoredItem {
            let itemProvider = NSItemProvider(object: item.name as NSString)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        } else {
            return []
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return nil
    }
}

extension ListViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        guard let delegate = self.delegate else { return }

        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation
        {
        case .move:
            delegate.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, listController: self)
            break
        case .copy:
            // Those are mutually exclusive, you can copy or move between collectionViews
            // delegate.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, listController: self)
            delegate.transferItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, listController: self)
            break
        default:
            return
        }
    }
}
