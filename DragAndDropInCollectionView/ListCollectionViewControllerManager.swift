//
//  ListCollectionViewControllerManager.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ListCollectionViewControllerManager: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let listManager = ListManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.clipsToBounds = false
        
        let forged = forgeController()
        forged.items = [Cell("orange"), Cell("red"), Cell("green"), Cell("cyan"), Cell("green"), Cell("red"), Cell("orange"), Cell("magenta"), Cell("purple"), Cell("purple"), Cell("orange")]
        
        for _ in 1...3 {
            let _ = forgeController()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.size.width - 100) / 3, height: collectionView.bounds.size.height - 100)
    }

    func forgeController() -> ListViewController {
        let controller = ListViewController()
        addChildViewController(controller)
        controller.delegate = listManager
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listManager.listControllers.append(controller)
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
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: 44))
        header.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        header.layer.masksToBounds = true
        header.layer.cornerRadius = 8
        header.textColor = .white
        header.textAlignment = .center
        header.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        header.text = "Section \(indexPath.row)"
        cell.contentView.addSubview(header)
        
        guard let controller = listManager.listControllers[indexPath.row] as? ListViewController else { return cell }
        controller.index = indexPath.row
        controller.view.frame = CGRect(x: 0, y: 54, width: cell.bounds.width, height: cell.bounds.height - 54)
        cell.contentView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        
        return cell
    }
}
