//
//  UIColor+Literal.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

extension UIColor {
    class func named(_ name: String) -> UIColor? {
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
