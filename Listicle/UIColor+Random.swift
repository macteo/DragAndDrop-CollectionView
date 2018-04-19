//
//  UIColor+Random.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit


// TODO: move to a UIColor extension
// Credits https://gist.github.com/asarode/7b343fa3fab5913690ef
extension UIColor {
    class var random: UIColor {
        let hue : CGFloat = CGFloat(arc4random() % 256) / 256 // use 256 to get full range from 0.0 to 1.0
        let saturation : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from white
        let brightness : CGFloat = CGFloat(arc4random() % 128) / 256 + 0.5 // from 0.5 to 1.0 to stay away from black
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
}
