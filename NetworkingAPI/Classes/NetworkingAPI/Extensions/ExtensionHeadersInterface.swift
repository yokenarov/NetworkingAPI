//
//  ExtensionHeadersInterface.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 26.10.21.
//

import Foundation
public extension HeadersInterface {
    func combineHeaders(additionalHeaders: [String: String]) -> [String: String] {
        var defHeaders = defaultHeaders
        additionalHeaders.forEach { k,v in defHeaders[k] = v }
        return defHeaders
    }
    func createNewHeaders(newHeaders: [String: String]) -> [String: String] {
        return newHeaders
    }
}
