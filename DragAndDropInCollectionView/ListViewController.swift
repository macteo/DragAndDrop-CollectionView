//
//  ListViewController.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

protocol ListController : class {
    // TODO: this needs to be managed in a better way to control access
    var items : [Cell] { get set }
    var listOperations : ListOperations { get set }
    var index : Int { get set }
    func removeItem(at index: Int)
    func insert(item: Cell, at index: Int)
    func performOperations()
    var manager : ListViewControllerManager? { get set }
}

class ListViewController: UIViewController {
    private let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: UICollectionViewFlowLayout())
    
    var items = [Cell]()
    var index : Int = 0
    
    var listOperations = ListOperations()
    
    var manager : ListViewControllerManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.frame = view.bounds
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        
        resetOperations()
        
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: "listCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: collectionView.bounds.size.width, height: 100)
    }
}

extension ListViewController : ListController {

    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func insert(item: Cell, at index: Int) {
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
        })

        defer {
            resetOperations()
        }
    }
    
    func resetOperations() {
        listOperations = ListOperations(list: self, index: index)
    }
}

extension ListViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath) as! ListCell
        cell.customImageView.image = UIImage(named: items[indexPath.row].name)
        cell.customLabel.text = items[indexPath.row].name.capitalized
        return cell
    }
}

extension ListViewController: UICollectionViewDelegateFlowLayout {
    
}

extension ListViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = items[indexPath.row]
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let item = items[indexPath.row]
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
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
        guard let manager = self.manager else { return }

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
            manager.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView, listController: self)
            break
        case .copy:
            // Those are mutually exclusive, you can copy or move between collectionViews
            // manager.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView, listController: self)
            manager.transferItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView, listController: self)
            break
        default:
            return
        }
    }
}
