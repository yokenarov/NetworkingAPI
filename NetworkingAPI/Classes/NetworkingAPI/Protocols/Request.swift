//
//  Protocols.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 24.10.21.
//

import Foundation
import Combine 
/**
 This protocol defince a base line interface for constructing a URLResponse, that can be passed to the APICallerInterface functions. You will need to provide your custom implementation of this interface for your network layer APIs.
 
 */
public protocol Request {
    var scheme:     SchemesInterface        { get }
    var baseURL:    BaseUrlInterface        { get }
    var path:       PathInterface           { get }
    var method:     MethodsInterface        { get }
    var parameters: RequestParamsInterface? { get }
    var headers:    HeadersInterface        { get } 
}
/**
 This protocol defince a base line interface for providing the scheme of your URL. (http / https).
 */
public protocol SchemesInterface {
    var scheme: String  { get }
}
/**
 This protocol defince a base line interface for providing the baseURL.
 */
public protocol BaseUrlInterface {
    var baseUrl: String  { get }
}
/**
 This protocol defince a base line interface for providing the path of your URL.
 */
public protocol PathInterface  {
    var path: String { get }
}
/**
 This protocol defince a base line interface for providing the httpMethod of your URL.
 */
public protocol MethodsInterface {
    var method: String { get }
}
/**
 This protocol defince a base line interface for providing the parameters of your request. Note that you can encode them directly in the url or in the body. For this you will have to provide a ParameterLocation as the first item in the tuple.
 */
public protocol RequestParamsInterface {
    var params: (ParameterLocation, [String: String])? { get }
}
/**
 This protocol defince a base line interface for providing the headers for the request.
 */
public protocol HeadersInterface  {
    var defaultHeaders: [String: String] { get }
    var headers: [String: String] { get }
}


public extension Request {
    var fullUrl: String {
        return "\(scheme.scheme)://\(baseURL.baseUrl)\(path.path)"
    }
    
    var fullRequest: URLRequest {
        get throws {
            var urlComponents = URLComponents()
            urlComponents.scheme = scheme.scheme
            urlComponents.host = baseURL.baseUrl
            urlComponents.path = path.path
            var bodyData: Data?
            
            if let location = parameters?.params?.0, let params = parameters?.params?.1 {
                var components = [URLQueryItem]()
                switch location {
                case .body:
                    guard method.method == "POST" || method.method == "PUT" else {
                        throw NetworkingAPIError.badBody("❌ You are trying encode a httpBody and your method is not POST or PUT. Change HttpMethod to either POST or PUT. Error located in: \(GetSourceOfString().forProperty(file: #file, function: #function, line: #line))")}
                    let encoder = JSONEncoder()
                    do {
                        bodyData = try encoder.encode(params)
                    }catch {
                        throw NetworkingAPIError.jsonEncodingError("❌ Encoding of parameters failed. Expecting a codable object for parameters, but \(params) was passed.")
                    }
                case .url:
                    params.forEach { key, value in
                        let component = URLQueryItem(name: key, value: value)
                        components.append(component)
                    }
                    urlComponents.queryItems = components
                }
            }
            guard let url = urlComponents.url else {
                print("""
                  ❌ Could not make a url. Check your custom implementation of the Request protocol.
                  Scheme: \(scheme.scheme)
                  Host: \(baseURL.baseUrl)
                  Path: \(path.path)
                  Body: \(bodyData ?? Data())
                  HTTPMethod: \(method.method)
                  """)
                return  URLRequest(url: URL(string: fullUrl)!)
            }
            var request = URLRequest(url: url)
            request.httpMethod = method.method
            request.allHTTPHeaderFields = headers.headers
            request.httpBody = bodyData ?? Data()
            return request
        }
    }
}
