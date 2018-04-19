//
//  UIControl+Closure.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

// Credits: https://stackoverflow.com/a/41438789/616964
class ClosureSleeve {
    let closure: ()->()
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }
    
    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func add (for controlEvents: UIControlEvents, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
