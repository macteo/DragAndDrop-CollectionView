//
//  ColoredItem.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 17/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit
import MobileCoreServices

final public class ColoredItem : DraggableItem {
    public var name : String
    public var color : UIColor?
    
    public required init() {
        self.name = "Random"
        self.color = .white
    }
    
    public init(_ name: String) {
        self.name = name
        if let color = UIColor.named(name) {
            self.color = color
        } else {
            self.color = .white
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

extension ColoredItem : Shareable {
    var data: Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: ["name": name, "color": color?.hex], options: .prettyPrinted)
            return data
        } catch _ {
            return nil
        }
    }
    
    convenience init?(data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return nil }
            self.init(dictionary: json)
        } catch _ {
            return nil
        }
    }
    
    convenience init?(dictionary: [String: Any]) {
        guard let jsonName = dictionary["name"] as? String else { return nil }
        self.init()
        name = jsonName
        
        if let jsonColor = dictionary["color"] as? String {
            color = UIColor(hex: jsonColor)
        }
    }
}

extension ColoredItem : NSItemProviderReading {
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [ColoredItem.shareIdentifier, kUTTypeUTF8PlainText as String]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ColoredItem {
        let newDraggableItem = ColoredItem()
        if typeIdentifier == ColoredItem.shareIdentifier {
            if let item = ColoredItem(data: data) {
                return item
            } else {
                throw DraggableItemError.invalidItemContent
            }
        } else if typeIdentifier == kUTTypeUTF8PlainText as String {
            let name = String(data: data, encoding: .utf8)!
            newDraggableItem.name = name
            if let color = UIColor.named(name) {
                newDraggableItem.color = color
            }
        } else {
            throw DraggableItemError.invalidTypeIdentifier
        }
        return newDraggableItem
    }
}

extension ColoredItem : NSItemProviderWriting {
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [ColoredItem.shareIdentifier, kUTTypeUTF8PlainText as String]
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        if typeIdentifier == ColoredItem.shareIdentifier {
            completionHandler(data, nil)
        } else if typeIdentifier == kUTTypeUTF8PlainText as String {
            completionHandler(name.data(using: .utf8), nil)
        } else {
            completionHandler(nil, DraggableItemError.invalidTypeIdentifier)
        }
        return nil
    }
}
