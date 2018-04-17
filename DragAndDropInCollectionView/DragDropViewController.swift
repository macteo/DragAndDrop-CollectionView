//
//  DragDropViewController.swift
//  DragAndDropInCollectionView
//
//  Created by Payal Gupta on 06/11/17.
//  Copyright © 2017 Payal Gupta. All rights reserved.
//

import UIKit

class Cell : Equatable {
    var name : String
    var list : Int = 0
    
    init(_ name: String) {
        self.name = name
    }
    
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.name == rhs.name
    }
}

// FIXME: still need to fix an issue related to sorting with a phantom cell appearing while dragging, causing a crash

class DragDropViewController: UIViewController
{
    @IBAction func reloadData(_ sender: UIBarButtonItem) {
        collectionView1.reloadData()
        collectionView2.reloadData()
    }
    //MARK: Private Properties
    //Data Source for CollectionView-1
    
    private var items1 = [Cell("none"), Cell("chrome"), Cell("fade"), Cell("falseColor"), Cell("instant"), Cell("mono"), Cell("noir"), Cell("process"), Cell("sepia"), Cell("tonal"), Cell("transfer")]
    
    //Data Source for CollectionView-2
    private var items2 = [Cell]()

    //MARK: Outlets
    @IBOutlet weak var collectionView1: UICollectionView!
    @IBOutlet weak var collectionView2: UICollectionView!
    
    //MARK: View Lifecycle Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //CollectionView-1 drag and drop configuration
        self.collectionView1.dragInteractionEnabled = true
        self.collectionView1.dragDelegate = self
        self.collectionView1.dropDelegate = self
        let layout =  self.collectionView1.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.collectionView1.bounds.width, height: 100)
        //CollectionView-2 drag and drop configuration
        self.collectionView2.dragInteractionEnabled = true
        self.collectionView2.dropDelegate = self
        self.collectionView2.dragDelegate = self
        self.collectionView2.reorderingCadence = .immediate //default value - .immediate
        let layout2 =  self.collectionView2.collectionViewLayout as! UICollectionViewFlowLayout
        layout2.itemSize = CGSize(width: self.collectionView2.bounds.width, height: 100)
    }
    
    //MARK: Private Methods
    
    /// This method moves a cell from source indexPath to destination indexPath within the same collection view. It works for only 1 item. If multiple items selected, no reordering happens.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
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
                if collectionView === self.collectionView2
                {
                    self.items2.remove(at: sourceIndexPath.row)
                    self.items2.insert(item.dragItem.localObject as! Cell, at: dIndexPath.row)
                }
                else
                {
                    self.items1.remove(at: sourceIndexPath.row)
                    self.items1.insert(item.dragItem.localObject as! Cell, at: dIndexPath.row)
                }
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            })
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        } else {
            print("Multiple items")
        }
    }
    
    /// This method copies a cell from source indexPath in 1st collection view to destination indexPath in 2nd collection view. It works for multiple items.
    ///
    /// - Parameters:
    ///   - coordinator: coordinator obtained from performDropWith: UICollectionViewDropDelegate method
    ///   - destinationIndexPath: indexpath of the collection view where the user drops the element
    ///   - collectionView: collectionView in which reordering needs to be done.
    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for (index, item) in coordinator.items.enumerated()
            {
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                if collectionView === self.collectionView2
                {
                    self.items2.insert(item.dragItem.localObject as! Cell, at: indexPath.row)
                }
                else
                {
                    self.items1.insert(item.dragItem.localObject as! Cell, at: indexPath.row)
                }
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
    private func transferItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView)
    {
        var coll1IndexPathsTBR = [IndexPath]()
        var coll1IndexPathsTBA = [IndexPath]()
        var items1TBR = [Cell]()
        var items1TBA = [Int: Cell]()
        var coll2IndexPathsTBR = [IndexPath]()
        var coll2IndexPathsTBA = [IndexPath]()
        var items2TBR = [Cell]()
        var items2TBA = [Int: Cell]()
        for (index, item) in coordinator.items.enumerated()
        {
            let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
            var newObject = item.dragItem.localObject as? Cell
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
                if collectionView == collectionView2 {
                    newObject?.list = 1
                }
            }
            
            guard let localObject = newObject else { return }
            
            if localObject.list == 0 {
                if let indexOf = items1.index(where: { $0.name == localObject.name }) {
                    items1TBR.append(localObject)
                    coll1IndexPathsTBR.append(IndexPath(item: indexOf, section: 0))
                }
            } else {
                if let indexOf = items2.index(where: { $0.name == localObject.name }) {
                    items2TBR.append(localObject)
                    coll2IndexPathsTBR.append(IndexPath(item: indexOf, section: 0))
                }
            }
            
            if collectionView === self.collectionView2
            {
                let editedObject = localObject
                editedObject.list = 1
                items2TBA[indexPath.row] = editedObject
                coll2IndexPathsTBA.append(indexPath)
            }
            else
            {
                let editedObject = localObject
                editedObject.list = 0
                items1TBA[indexPath.row] = editedObject
                coll1IndexPathsTBA.append(indexPath)
            }
        }
        
        items1 = items1.filter { !items1TBR.contains($0) }
        items1TBA.forEach { (index, cell) in
            if items1.count < index {
                items1.append(cell)
            } else {
                items1.insert(cell, at: index)
            }
            
        }
        // FIXME: crashed here with Array index out of range
        items2 = items2.filter { !items2TBR.contains($0) }
        items2TBA.forEach { (index, cell) in
            if items2.count < index {
                items2.append(cell)
            } else {
                items2.insert(cell, at: index)
            }
        }
        
        collectionView1.performBatchUpdates({
            collectionView1.deleteItems(at: coll1IndexPathsTBR)
            collectionView1.insertItems(at: coll1IndexPathsTBA)
        })
        collectionView2.performBatchUpdates({
            collectionView2.deleteItems(at: coll2IndexPathsTBR)
            collectionView2.insertItems(at: coll2IndexPathsTBA)
        })
    }
}

// MARK: - UICollectionViewDataSource Methods
extension DragDropViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return collectionView == self.collectionView1 ? self.items1.count : self.items2.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.collectionView1
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell1", for: indexPath) as! DragDropCollectionViewCell
            cell.customImageView?.image = UIImage(named: self.items1[indexPath.row].name)
            cell.customLabel.text = self.items1[indexPath.row].name.capitalized
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as! DragDropCollectionViewCell
            cell.customImageView?.image = UIImage(named: self.items2[indexPath.row].name)
            cell.customLabel.text = self.items2[indexPath.row].name.capitalized
            return cell
        }
    }
}

// MARK: - UICollectionViewDragDelegate Methods
extension DragDropViewController : UICollectionViewDragDelegate
{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        let item = collectionView == collectionView1 ? self.items1[indexPath.row] : self.items2[indexPath.row]
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem]
    {
        let item = collectionView == collectionView1 ? self.items1[indexPath.row] : self.items2[indexPath.row]
        let itemProvider = NSItemProvider(object: item.name as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?
    {
//        if collectionView == collectionView1
//        {
//            let previewParameters = UIDragPreviewParameters()
//            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 25, y: 25, width: 120, height: 120))
//            return previewParameters
//        }
        return nil
    }
}

// MARK: - UICollectionViewDropDelegate Methods
extension DragDropViewController : UICollectionViewDropDelegate
{
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
    {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal
    {
        if collectionView.hasActiveDrag
        {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        else
        {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator)
    {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath
        {
            destinationIndexPath = indexPath
        }
        else
        {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation
        {
        case .move:
            self.reorderItems(coordinator: coordinator, destinationIndexPath:destinationIndexPath, collectionView: collectionView)
            break

        case .copy:
            // Those are mutually exclusive, you can copy or move between collectionViews
            // self.copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            self.transferItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
            
        default:
            return
        }
    }
}

