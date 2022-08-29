//
//  NetworkingApiError.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 25.10.21.
//

import Foundation

public enum NetworkingAPIError: Error {
    case jsonEncodingError(_ error: String)
    case jsonDecodingError(_ error: String)
    case badBody(_ error: String)
    case badRequest(error: String)
    case networkError(error: String)
    case nilData(error: String)
    case nilResponse(error: String)
}
