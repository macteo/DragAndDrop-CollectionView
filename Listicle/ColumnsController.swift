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
    let columnManager = ListManager<ColumnItem<ColoredItem,ColoredItem>, ColoredItem>()
    
    let listManager = ListManager<ColoredItem, ColoredItem>()
    fileprivate var didLoad = false
    
    @IBAction func appendColumn() {
        addColumn(at: listManager.listControllers.count)
    }
    
    func addColumn(at index: Int) {
        let controller = forgeController()
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
        
        let forged = forgeController()
        forged.items = [ColoredItem("orange"), ColoredItem("red"), ColoredItem("green"), ColoredItem("cyan"), ColoredItem("green"), ColoredItem("orange"), ColoredItem("brown"), ColoredItem("blue"), ColoredItem("orange"), ColoredItem()]
        listManager.listControllers.append(forged)
        
        for _ in 1...2 {
            appendColumn()
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
