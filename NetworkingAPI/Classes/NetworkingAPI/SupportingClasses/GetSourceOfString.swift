//
//  GetSourceOfString.swift
//  Essentials
//
//  Created by Jordan Kenarov on 25.10.21.
//

import Foundation
/**
 This is a helper struct meant to print out some usefull information about a function or a property. 
*/
public struct GetSourceOfString {
      public func forNetworkCall(file: String, function: String, line: Int) -> String {
        var caller = ""
        var fileName = file.components(separatedBy: "/").last!
        fileName.removeLast(6)
        
        caller = "Function: \(function) - called in: \(fileName) on line: \(line)"
        
        return caller
    }
      public func forProperty(file: String, function: String, line: Int) -> String {
        var caller = ""
        var fileName = file.components(separatedBy: "/").last!
        fileName.removeLast(6)
        
        caller = "Property: \(function) - located in: \(fileName) file, on line: \(line)"
        
        return caller
    }
}
