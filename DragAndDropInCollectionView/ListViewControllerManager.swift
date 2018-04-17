//
//  ListManager.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class ListViewControllerManager : UIViewController {
    
    let listManager = ListManager()
    
    @IBOutlet weak var leadingContainerView: UIView!
    @IBOutlet weak var trailingContainerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leadingListViewController = ListViewController()
        leadingListViewController.view.frame = leadingContainerView.bounds
        addChildViewController(leadingListViewController)
        leadingListViewController.delegate = listManager
        leadingListViewController.index = 0
        leadingListViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        leadingContainerView.addSubview(leadingListViewController.view)
        leadingListViewController.didMove(toParentViewController: self)
        
        listManager.listControllers.append(leadingListViewController)
        
        leadingListViewController.items = [Cell("none"), Cell("chrome"), Cell("fade"), Cell("falseColor"), Cell("instant"), Cell("mono"), Cell("noir"), Cell("process"), Cell("sepia"), Cell("tonal"), Cell("transfer")]
        
        let trailingListViewController = ListViewController()
        trailingListViewController.view.frame = trailingContainerView.bounds
        trailingListViewController.delegate = listManager
        trailingListViewController.index = 1
        addChildViewController(trailingListViewController)
        trailingListViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        trailingContainerView.addSubview(trailingListViewController.view)
        trailingListViewController.didMove(toParentViewController: self)
        listManager.listControllers.append(trailingListViewController)
    }
}
