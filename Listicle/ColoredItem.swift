//
//  ColoredItem.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

public class ColoredItem : DraggableItem {
    public var name : String
    public var color : UIColor?
    
    public required init() {
        self.name = "Random"
        self.color = .random
    }
    
    public init(_ name: String) {
        self.name = name
        if let color = UIColor.named(name) {
            self.color = color
        } else {
            self.color = .random
        }
    }
    
    public init(_ name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
    
    public static func == (lhs: ColoredItem, rhs: ColoredItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public override func loadObject(from itemProvider: NSItemProvider, completionHandler: @escaping (Bool, Error?) -> Void) {
        itemProvider.loadObject(ofClass: NSString.self, completionHandler: { (object, error) in
            if let error = error {
                completionHandler(false, error)
                return
            }
            if let string = object as? String {
                self.name = string
                if let color = UIColor.named(string) {
                    self.color = color
                }
                completionHandler(true, nil)
            } else {
                let error = NSError(domain: "Listicle", code: 404, userInfo: [NSLocalizedDescriptionKey: "Cannot extract a string from the dropped object"])
                completionHandler(false, error)
            }
        })
    }
}
