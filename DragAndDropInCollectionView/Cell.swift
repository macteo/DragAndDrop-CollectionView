//
//  Cell.swift
//  DragAndDropInCollectionView
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class Cell : Equatable {
    var name : String
    var color : UIColor?
    var identifier: UUID
    var list : Int = 0
    
    init(_ name: String) {
        self.name = name
        self.identifier = UUID()
        if let color = color(with: name) {
            self.color = color
        } else {
            self.color = randomColor
        }
    }
    
    init(_ name: String, color: UIColor) {
        self.name = name
        self.color = color
        self.identifier = UUID()
    }
    
    public static func == (lhs: Cell, rhs: Cell) -> Bool {
        return lhs.name == rhs.name && lhs.color == rhs.color && lhs.identifier == rhs.identifier
    }
    
    // TODO: move to a UIColor extension
    // Credits https://gist.github.com/asarode/7b343fa3fab5913690ef
    var randomColor: UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    func color(with name: String) -> UIColor? {
        if name == "black" {
            return .black
        } else if name == "clear" {
            return .clear
        } else if name == "brown" {
            return .brown
        } else if name == "purple" {
            return .purple
        } else if name == "orange" {
            return .orange
        } else if name == "magenta" {
            return .magenta
        } else if name == "yellow" {
            return .yellow
        } else if name == "cyan" {
            return .cyan
        } else if name == "blue" {
            return .blue
        } else if name == "green" {
            return .green
        } else if name == "red" {
            return .red
        } else if name == "gray" {
            return .gray
        } else if name == "white" {
            return .white
        } else if name == "lightGray" {
            return .lightGray
        } else if name == "darkGray" {
            return .darkGray
        }
        
        return nil
    }
}
