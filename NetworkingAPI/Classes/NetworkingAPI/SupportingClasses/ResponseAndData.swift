//
//  ResponseAndData.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 25.10.21.
//

import Foundation

/**
This is a helper struct meant to encapsulate the incoming response and data from a networkcall and print some usefull information about the status of the network call itself. 
*/
public struct ResponseAndData: ResponseWithDataInterface {
public var statusCode: Int?
public var url: String?
public var data: Data
    public var response: URLResponse {
        didSet{
            guard let unwrappedResponse = response as? HTTPURLResponse else {
                print("Could not cast response as HTTPURLResponse.")
                return }
            self.statusCode = unwrappedResponse.statusCode
            self.url = unwrappedResponse.url?.absoluteString
        }
    }
public init(response: URLResponse, data: Data) {  
         guard let response = response as? HTTPURLResponse else {
             self.data = Data()
             self.response = URLResponse()
             return }
    self.response = response
        self.statusCode = response.statusCode
        self.url = response.url?.absoluteString
        self.data = data
    }

    public func printResponseStatus(file: String, function: String, line: Int) {
        print("""
              ⏤⏤⏤⏤⏤⏤
              \(GetSourceOfString().forNetworkCall(file: file, function: function, line: line)) \n\(validateStatusCode) \(statusCode ?? 0) - \(url ?? "")
              """)
    }
   
    private var validateStatusCode: String {
        switch statusCode ?? 0 {
        case 200...300:
            return "✅"
        case 300...400:
            return "⚠️"
        case 400...600:
            return "❌"
        default: return "❌"
        }
        
    }
}
 
