//
//  ColumnCell.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 23/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

class ColumnCell: UICollectionViewCell {
    let color = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1)
    let header = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
    let deleteButton = UIButton(frame: CGRect(x: 100 - 32 - 6, y: 6, width: 32, height: 32))
    let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        header.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth]
        header.layer.masksToBounds = true
        header.layer.cornerRadius = 4
        header.textColor = .darkGray
        header.textAlignment = .center
        header.backgroundColor = color
        header.text = ""
        header.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: 44)
        
        contentView.addSubview(header)
        
        deleteButton.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        deleteButton.setTitle(NSLocalizedString("Ⓧ", comment: "Delete column button title"), for: .normal)
        deleteButton.setTitleColor(header.textColor, for: .normal)
        deleteButton.frame = CGRect(x: header.bounds.size.width - 32 - 6, y: 6, width: 32, height: 32)
        
        contentView.addSubview(deleteButton)
        
        clipsToBounds = true
        
        layer.borderColor = color.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 4
        backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        containerView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        containerView.frame = CGRect(x: 0, y: 44, width: bounds.size.width, height: bounds.size.height - 44)
        contentView.addSubview(containerView)
        
        contentView.bringSubview(toFront: header)
        contentView.bringSubview(toFront: deleteButton)
    }
    
    override func prepareForReuse() {
        containerView.subviews.forEach { (subview) in
            subview.removeFromSuperview()
        }
        deleteButton.removeTarget(nil, action: nil, for: .allEvents)
        header.text = ""
    }
    
}
