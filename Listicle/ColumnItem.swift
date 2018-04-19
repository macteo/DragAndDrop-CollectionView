//
//  ColumnItem.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit

public class ColumnItem<Item: DraggableItem, Provider:NSItemProviderReading> : DraggableItem {
    public var name : String
    public var index : Int
    // TODO: track the cells of this element as they're added, removed or reordered
    // public var manager : ListManager<Item, Provider>?
    
    public required init() {
        self.name = "Section ?"
        self.index = 0
    }
    
    public init(_ name: String, index: Int) {
        self.name = name
        self.index = index
    }
    
    public static func == (lhs: ColumnItem, rhs: ColumnItem) -> Bool {
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
                // TODO: set the correct index for the object
                // Need to understand who to incapsulate informations in NSItemProvider
                // https://developer.apple.com/videos/play/wwdc2017/227/
                // Related to NSItemProviderReading and Writing
                completionHandler(true, nil)
            } else {
                let error = NSError(domain: "Listicle", code: 404, userInfo: [NSLocalizedDescriptionKey: "Cannot extract a the right object from the dropped object"])
                completionHandler(false, error)
            }
        })
    }
}
