//
//  DraggableItem.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

public class DraggableItem : NSObject {
    var identifier = UUID()
    var listIndex : Int = 0
    
    public static func == (lhs: DraggableItem, rhs: DraggableItem) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public var itemProvider : NSItemProvider {
        get {
            return NSItemProvider(object: identifier.uuidString as NSString)
        }
    }
    
    public func loadObject(from itemProvider: NSItemProvider, completionHandler: @escaping (Bool, Error?) -> Void) {
        itemProvider.loadObject(ofClass: NSString.self, completionHandler: { (object, error) in
            if let error = error {
                completionHandler(false, error)
                return
            }
            completionHandler(true, nil)
        })
    }
    
    required public override init() {}
}

//extension DraggableItem : NSItemProviderReading {
//    public static var readableTypeIdentifiersForItemProvider: [String] {
//        return []
//    }
//
//    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> DraggableItem {
//        return DraggableItem() as! DraggableItem
//    }
//}
