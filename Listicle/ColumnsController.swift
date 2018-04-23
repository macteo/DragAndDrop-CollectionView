//
//  ColumnsController.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "columnCell"

class ColumnsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var items = [ColumnItem]()

    var listOperations = ListOperations<DraggableItem>()
    
    var numberOfItems: Int {
        get {
            return listManager.listControllers.count
        }
    }
    
    func performOperations() {
        // Actually perform the operations
        items = items.filter { !listOperations.removeItems.contains($0) }
        
        listOperations.addItems.forEach { (index, cell) in
            if let item = cell as? ColumnItem {
                if items.count < index {
                    items.append(item)
                } else {
                    items.insert(item, at: index)
                }
            }
        }
        guard let collectionView = collectionView else { return }
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
    
    func reloadData() {
        collectionView?.reloadData()
    }
    
    let listManager = ListManager<ColoredItem, ColoredItem>()
    fileprivate var didLoad = false
    
    @IBAction func appendColumn() {
        appendColumn(with: ColumnItem("Section ?", index: listManager.listControllers.count))
    }
    
    @IBAction func appendColumn(with item: ColumnItem) {
        addColumn(at: listManager.listControllers.count, with: item)
    }
    
    // TODO: shoud invert parameters
    func addColumn(at index: Int, with item: ColumnItem) {
        let controller = forgeController()
        controller.items = item.childs
        items.insert(item, at: index)
        listManager.listControllers.append(controller)
        guard didLoad else { return }
        collectionView?.performBatchUpdates({
            collectionView?.insertItems(at: [IndexPath(row: index, section: 0)])
        })
    }
    
    func deleteColumn(of cell: UICollectionViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else { return }
        deleteColumn(at: indexPath.row)
    }
    
    func deleteColumn(at index: Int) {
        let listController = listManager.listControllers[index]
        guard let controller = listController as? UIViewController else { return }
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        items.remove(at: index)
        listManager.listControllers.remove(at: index)
        guard didLoad else { return }
        collectionView?.performBatchUpdates({
          collectionView?.deleteItems(at: [IndexPath(row: index, section: 0)])
        })
    }
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        listManager.listControllers.forEach { (controller) in
            controller.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(ColumnCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.clipsToBounds = false
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.dragInteractionEnabled = true
        collectionView?.dragDelegate = self
        collectionView?.dropDelegate = self
        
        for i in 0...2 {
            if i == 0 {
                let cells = [ColoredItem("orange"), ColoredItem("red"), ColoredItem("green"), ColoredItem("cyan"), ColoredItem("green"), ColoredItem("orange"), ColoredItem("brown"), ColoredItem("blue"), ColoredItem("orange"), ColoredItem()]
                let columnItem = ColumnItem("Section \(i)", index: i, childs: cells)
                appendColumn(with: columnItem)
            } else {
                appendColumn(with: ColumnItem("Section \(i)", index: i))
            }
        }
        
        didLoad = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width - 100) / 3, height: collectionView.bounds.size.height - 100)
    }

    func forgeController() -> VerticalColumnController {
        let controller = VerticalColumnController()
        addChildViewController(controller)
        controller.delegate = listManager
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return controller
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listManager.listControllers.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ColumnCell
        // FIXME: this won't update as the colums are added, deleted or sorted
        cell.header.text = "Section \(indexPath.row)"
        cell.deleteButton.add(for: .touchUpInside) {
            self.deleteColumn(of: cell)
        }
        guard let controller = listManager.listControllers[indexPath.row] as? VerticalColumnController else { return cell }
        controller.index = indexPath.row
        controller.view.frame = cell.containerView.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cell.containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        
        controller.reloadData()
        return cell
    }
}

extension ColumnsController: UICollectionViewDragDelegate {

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = items[indexPath.row]
        if listManager.listControllers.count > indexPath.row, let viewController = listManager.listControllers[indexPath.row] as? VerticalColumnController, let childs = viewController.items as? [ColoredItem] {
            item.childs = childs
        }
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard session.hasItemsConforming(toTypeIdentifiers: [ColumnItem.shareIdentifier]) else { return [] }
        let item = items[indexPath.row]
        if listManager.listControllers.count > indexPath.row, let viewController = listManager.listControllers[indexPath.row] as? VerticalColumnController, let childs = viewController.items as? [ColoredItem] {
            item.childs = childs
        }
        let itemProvider = NSItemProvider(object: item)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return nil
    }
}

extension ColumnsController: UICollectionViewDropDelegate {

    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: ColumnItem.self)
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
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        switch coordinator.proposal.operation {
        case .move:
            reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath)
            break
        case .copy:
            // Those are mutually exclusive, you can copy or move between collectionViews
            // delegate.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, listController: self)
            // transferItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath)
            break
        default:
            return
        }
    }
}

extension ColumnsController {
    public func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath)
    {
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath
        {
            var dIndexPath = destinationIndexPath
            if dIndexPath.row >= numberOfItems {
                dIndexPath.row = numberOfItems - 1
            }
            
            let sourceController = listManager.listControllers[sourceIndexPath.row]
            listManager.listControllers.remove(at: sourceIndexPath.row)
            listManager.listControllers.insert(sourceController, at: dIndexPath.row)
            
            if let draggableItem = item.dragItem.localObject as? ColumnItem {
                listOperations.removeItems.append(draggableItem)
                listOperations.addItems[dIndexPath.row] = draggableItem
                listOperations.removeIndexPaths.append(sourceIndexPath)
                listOperations.addIndexPaths.append(dIndexPath)
            }
            coordinator.drop(item.dragItem, toItemAt: dIndexPath)
            performOperations()
        }
    }
}
