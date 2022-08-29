//
//  ExtensionNSObject.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 26.10.21.
//

import Foundation
public extension NSObject {
    /**
     A function that returns all the classes in memory. 
    */
    func allClasses<R>(_ body: (UnsafeBufferPointer<AnyClass>) throws -> R) rethrows -> R {
        var count: UInt32 = 0
        let classListPtr = objc_copyClassList(&count)
        defer {
            free(UnsafeMutableRawPointer(classListPtr))
        }
        let classListBuffer = UnsafeBufferPointer(start: classListPtr, count: Int(count))
        return try body(classListBuffer)
    }
}
