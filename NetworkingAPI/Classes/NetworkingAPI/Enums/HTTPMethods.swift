//
//  HTTPMethods.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 24.10.21.
//

import Foundation
public enum HTTPMethod: MethodsInterface {
    case post
    case put
    case get
    case delete
    case patch
    
    public var method: String {
        switch self {
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .get:
           return "GET"
        case .delete:
            return "DELETE"
        case .patch:
            return "PATCH"
        }
    }
    
}
public enum DataType {
    case JSON
    case Data
}
public enum ParameterLocation {
    case body
    case url 
}
