//
//  VerticalColumnController.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

fileprivate let coloredCellReuseIdentifier = "coloredCellReuseIdentifier"

class VerticalColumnController : ListViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(ListCell.self, forCellWithReuseIdentifier: coloredCellReuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.backgroundColor = .clear
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.itemSize = CGSize(width: collectionView.bounds.size.width - 8, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: coloredCellReuseIdentifier, for: indexPath) as! ListCell
        if let item = items[indexPath.row] as? ColoredItem {
            cell.backgroundColor = item.color
            cell.customLabel.text = item.name.capitalized
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return self.collectionView(collectionView, itemsForAddingTo: session, at: indexPath, point: CGPoint(x: 0, y: 0))
    }
    
    override func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        if let item = items[indexPath.row] as? ColoredItem {
            let itemProvider = NSItemProvider(object: item)
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = item
            return [dragItem]
        } else {
            return []
        }
    }
}
