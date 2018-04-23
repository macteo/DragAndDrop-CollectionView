//
//  ColumnItem.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 19/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import UIKit
import MobileCoreServices

final public class ColumnItem : DraggableItem {
    public var name : String
    public var index : Int
    public var childs : [ColoredItem]
    
    public required init() {
        self.name = "Section ?"
        self.index = 0
        self.childs = []
    }
    
    public init(_ name: String, index: Int) {
        self.name = name
        self.index = index
        self.childs = []
    }
    
    public init(_ name: String, index: Int, childs: [ColoredItem]) {
        self.name = name
        self.index = index
        self.childs = childs
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

extension ColumnItem : NSItemProviderReading {
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [ColumnItem.shareIdentifier]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ColumnItem {
        let newDraggableItem = ColumnItem()
        if typeIdentifier == ColumnItem.shareIdentifier {
            if let item = ColumnItem(data: data) {
                return item
            } else {
                throw DraggableItemError.invalidItemContent
            }
        } else if typeIdentifier == kUTTypeUTF8PlainText as String {
            let name = String(data: data, encoding: .utf8)!
            newDraggableItem.name = name

            // TODO: add other informations
        } else {
            throw DraggableItemError.invalidTypeIdentifier
        }
        return newDraggableItem
    }
}

extension ColumnItem : NSItemProviderWriting {
    
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [ColumnItem.shareIdentifier]
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        if typeIdentifier == ColumnItem.shareIdentifier {
            completionHandler(data, nil)
        } else if typeIdentifier == kUTTypeUTF8PlainText as String {
            completionHandler(name.data(using: .utf8), nil)
        } else {
            completionHandler(nil, DraggableItemError.invalidTypeIdentifier)
        }
        return nil
    }
}

extension ColumnItem : Shareable {
    var data: Data? {
        do {
            let data = try JSONSerialization.data(withJSONObject: ["name": name, "childs": childs], options: .prettyPrinted)
            return data
        } catch _ {
            return nil
        }
    }
    
    convenience init?(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            guard let jsonName = json["name"] as? String else { return nil }
            self.init()
            name = jsonName
            childs = [ColoredItem]()
            if let jsonChilds = json["childs"] as? [[String: Any]] {
                // TODO:
                jsonChilds.forEach { (jsonChild) in
                    if let coloredItem = ColoredItem(dictionary: jsonChild) {
                        childs.append(coloredItem)
                    }
                }
            }
        } catch _ {
            return nil
        }
    }
}
