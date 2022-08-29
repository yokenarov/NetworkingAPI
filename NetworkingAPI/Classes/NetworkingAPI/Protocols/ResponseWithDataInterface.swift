//
//  ResponseAndDataInterface.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 25.10.21.
//

import Foundation
/**
 This protocol defince a base line interface for providing the custom object that will be passed down the stream of a dataTaskPublisher, dataTaskWithClosure or dataTaskWithDelegate. You can provide your own custom implementation of this protocol, if you don't, then the default one of ResponseAndData will be used. It will contain the urlResponse object and the data, which you will need to decode into your custom model.
 */
public protocol ResponseWithDataInterface {
    var response  : URLResponse { get set }
    var data      : Data        { get set }
    init (response: URLResponse, data: Data)
    func printResponseStatus(file: String, function: String, line: Int)
}
