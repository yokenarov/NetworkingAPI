//
//  DataTaskWithDelegate.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 28.10.21.
//

import Foundation
public protocol DataTaskWithDelegate {
    /**
     A callback function that returns an optional codable model and an optional ResponseAndData. In order to use the model you will need to cast it to the model, that you will work with in your code. 
     */
    func resultFromURLRequestWithDelegate(model: Codable?, responseAndData: ResponseAndData?)
}
