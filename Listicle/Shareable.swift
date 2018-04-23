//
//  Shareable.swift
//  Listicle
//
//  Created by Matteo Gavagnin on 23/04/2018.
//  Copyright © 2018 Dolomate. All rights reserved.
//

import Foundation

// Credits: https://www.netguru.co/codestories/drag-drop-in-ios-11

protocol Shareable where Self: NSObject {
    static var shareIdentifier: String { get }
    init?(data: Data)
    var data: Data? { get }
}

extension Shareable {
    static var shareIdentifier: String {
        let bundle = Bundle.main.bundleIdentifier!
        let typeString = String(describing: type(of: self))
        return "\(bundle).\(typeString)"
    }
}
