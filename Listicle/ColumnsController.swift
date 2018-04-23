//
//  ColumnsController.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "columnCell"

class ColumnsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ListController {
    var items = [ColumnItem]()
    
    var listOperations = ListOperations<DraggableItem>()
    
    var index: Int = 0
    
    var delegate: ListDelegate?
    
    var numberOfItems: Int {
        get {
            return items.count
        }
    }
    
    func index(of item: AnyObject) -> Int? {
        if let castedItem = item as? ColumnItem {
            if let index = items.index(where: { $0 == castedItem }) {
                return index
            }
        }
        return nil
    }
    
    func removeItem(at index: Int) {
        items.remove(at: index)
    }
    
    func insert(item: DraggableItem, at index: Int) {
        if let columnItem = item as? ColumnItem {
            items.insert(columnItem, at: index)
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
    
    let columnManager = ListManager<ColumnItem, ColoredItem>()
    
    let listManager = ListManager<ColoredItem, ColoredItem>()
    fileprivate var didLoad = false
    
    @IBAction func appendColumn(with item: ColumnItem) {
        addColumn(at: listManager.listControllers.count, with: item)
    }
    
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
    
    func deleteColumn(at index: Int) {
        let listController = listManager.listControllers[index]
        guard let controller = listController as? UIViewController else { return }
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
        listManager.listControllers.remove(at: index)
        items.remove(at: index)
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

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.clipsToBounds = false
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        collectionView?.dragInteractionEnabled = true
//        collectionView?.dragDelegate = self
//        collectionView?.dropDelegate = self
        
        delegate = columnManager
        
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let color = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: 44))
        header.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        header.layer.masksToBounds = true
        header.layer.cornerRadius = 4
        header.textColor = .darkGray
        header.textAlignment = .center
        header.backgroundColor = color
        // FIXME: this won't update as the colums are added, deleted or sorted
        header.text = "Section \(indexPath.row)"
        cell.contentView.addSubview(header)
        
        let deleteButton = UIButton(frame: CGRect(x: header.frame.size.width - 32 - 6, y: 6, width: 32, height: 32))
        deleteButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        deleteButton.setTitle(NSLocalizedString("Ⓧ", comment: "Delete column button title"), for: .normal)
        deleteButton.setTitleColor(header.textColor, for: .normal)
        deleteButton.add(for: .touchUpInside) {
            // FIXME: this should be updated to reflect the current index of the row (it won't update automatically)
            // otherwise it will crash
            self.deleteColumn(at: indexPath.row)
        }
        
        cell.contentView.addSubview(deleteButton)
        
        guard let controller = listManager.listControllers[indexPath.row] as? VerticalColumnController else { return cell }
        controller.index = indexPath.row
        controller.view.frame = CGRect(x: 0, y: 44, width: cell.bounds.width, height: cell.bounds.height - 44)
        cell.contentView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        
        cell.contentView.bringSubview(toFront: header)
        cell.clipsToBounds = true
        
        cell.layer.borderColor = color.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 4
        cell.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        cell.contentView.bringSubview(toFront: deleteButton)
        return cell
    }
}
//
//extension ColumnsController: UICollectionViewDragDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        let item = items[indexPath.row]
//            let itemProvider = NSItemProvider(object: item)
//            let dragItem = UIDragItem(itemProvider: itemProvider)
//            dragItem.localObject = item
//            return [dragItem]
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
//        let item = items[indexPath.row]
//        let itemProvider = NSItemProvider(object: item)
//        let dragItem = UIDragItem(itemProvider: itemProvider)
//        dragItem.localObject = item
//        return [dragItem]
//    }
//
//    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
//        return nil
//    }
//}
//
//extension ColumnsController: UICollectionViewDropDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
//        return session.canLoadObjects(ofClass: NSString.self)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
//    {
//        if collectionView.hasActiveDrag {
//            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//        } else {
//            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
//    {
//        guard let delegate = self.delegate else { return }
//
//        let destinationIndexPath: IndexPath
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            // Get last index path of table view.
//            let section = collectionView.numberOfSections - 1
//            let row = collectionView.numberOfItems(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//
//        switch coordinator.proposal.operation
//        {
//        case .move:
//            delegate.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, listController: self)
//            break
//        case .copy:
//            // Those are mutually exclusive, you can copy or move between collectionViews
//            // delegate.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, listController: self)
//            delegate.transferItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, listController: self)
//            break
//        default:
//            return
//        }
//    }
//}
