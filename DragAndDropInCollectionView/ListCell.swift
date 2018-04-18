//
//  ListCell.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class ListCell: UICollectionViewCell {
    let customLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit() {
        layer.masksToBounds = true
        layer.cornerRadius = 8
        
        customLabel.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        customLabel.textAlignment = .center
        customLabel.frame = CGRect(x: 0, y: bounds.size.height - 22, width: bounds.size.width, height: 22)
        customLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        customLabel.text = "tmp"
        addSubview(customLabel)
        
        backgroundColor = .orange
    }
}
