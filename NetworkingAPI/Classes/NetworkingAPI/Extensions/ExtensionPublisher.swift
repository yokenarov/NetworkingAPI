//
//  ExtensionPublisher.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 25.10.21.
//

import Foundation
import Combine

extension Publisher where Output == ResponseWithDataInterface {
    /**
     An operator that prints a predifined status of the incoming response.
     
     - Parameters:
     - file:  points to the file in which the function is called. It would be enough to provide #file as a pameter here.
     - function:  points to the name of the function. It would be enough to provide #function as a pameter here.
     - lline:  points to the line in the file in which the function is called. It would be enough to provide #line as a pameter here.
     - ofItem: Consider using this if you have a custom implementation of the ResponseAndDataInteface and you need to do something extra with your custom item.
     */
    public func printNetworkResponseInfo(
        file: String,
        function: String,
        line: Int,
        _ ofItem: ((Output) -> Void)? = nil)  ->  Publishers.Map<Self, Output> {
            map { item in
                ofItem?(item)
                item.printResponseStatus(file: file, function: function, line: line)
                return  item
            }
        }
    
    
}

 

