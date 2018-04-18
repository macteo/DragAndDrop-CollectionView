//
//  ListCollectionViewControllerManager.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class ColumnsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let listManager = ListManager()
    
    @IBAction func reload(_ sender: UIBarButtonItem) {
        listManager.listControllers.forEach { (controller) in
            (controller as! ListViewController).collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.backgroundColor = .white
        self.collectionView?.clipsToBounds = false
        
        let forged = forgeController()
        forged.items = [Cell("orange"), Cell("red"), Cell("green"), Cell("cyan"), Cell("green"), Cell("orange"), Cell("brown"), Cell("blue"), Cell("orange")]
        
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
        
        let color = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
        
        let header = UILabel(frame: CGRect(x: 0, y: 0, width: cell.bounds.width, height: 44))
        header.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        header.layer.masksToBounds = true
        header.layer.cornerRadius = 4
        header.textColor = .darkGray
        header.textAlignment = .center
        header.backgroundColor = color
        header.text = "Section \(indexPath.row)"
        cell.contentView.addSubview(header)
        
        guard let controller = listManager.listControllers[indexPath.row] as? ListViewController else { return cell }
        controller.index = indexPath.row
        controller.view.frame = CGRect(x: 0, y: 44, width: cell.bounds.width, height: cell.bounds.height - 44)
        cell.contentView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        
        cell.contentView.bringSubview(toFront: header)
        cell.clipsToBounds = true
        
        cell.layer.borderColor = color.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 4
        // TODO: choose an appropriate color
        cell.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        return cell
    }
}
