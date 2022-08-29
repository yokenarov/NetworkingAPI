//
//  ExtensionApiCallerInterface.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 26.10.21.
//

import Foundation
import Combine

extension APICallerInterface {
    /**
     A function that returns starts a data task publisher with a custom object, conforiming to the Request protocol and returns an Anypublisher with custom output type with the response and the raw data from the response.
     
     - Parameters:
     - request: This parrameter accepts a type that conforms to the protocl Request. You will have to provide your own custom implementation of that type. See more on the Request protocol definition.
     - wtihResponseAndData: This parameter is  ResponseAndDataInterface object, which has some printing functionality, to communicate how the response was returned. It already has a default value, you only need to use it if you need a custom implemenattion of the ResponseAndDataInterface.
     */
    public func makeURLRequesWithPublisher(for request: Request,
                                           with providedResponseAndData: ResponseWithDataInterface? = ResponseAndData(response: URLResponse(), data: Data()), cancellableBagProvider: CancellableBagProvider) -> AnyPublisher<ResponseWithDataInterface, NetworkingAPIError> {
        var mutableResponseAndData = providedResponseAndData
        var unwrappedRequest: URLRequest?
        
        do { try unwrappedRequest = request.fullRequest } catch {
            print(error)
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        
        let publisher = URLSession.shared.dataTaskPublisher(for: unwrappedRequest!)
            .tryMap() { incomingURLResponse -> ResponseWithDataInterface in
                mutableResponseAndData?.response = incomingURLResponse.response
                mutableResponseAndData?.data = incomingURLResponse.data
                return mutableResponseAndData!
            }
            .mapError({ error -> NetworkingAPIError in
                return NetworkingAPIError.badRequest(error: error.localizedDescription)
            })
            .eraseToAnyPublisher()
        return publisher
    }
    /**
     A function that  starts a URLSessionDataTask with a custom object, conforiming to the Request protocol and returns an escaping closure with custom output type that must conform to the codable protocol. The provided clousure returns the decoded model . 
     
     - Parameters:
     - for: This parrameter accepts a type that conforms to the protocl Request. You will have to provide your own custom implementation of that type. See more on the Request protocol definition.
     - with: You need to pass your model's type as a parameter here. Your model needs to conform to Codable. Example MyModel.Type.
     - wtihResponseAndData: This parameter is an escaping closure where you will receive the decoded model type, already cast to the provided model type and an optional ResponseAndDataInterface, which has some printing functionality, to communicate how the response was returned.
     */
    public func makeURLRequestWithClosure<ModelType: Codable>(for request: Request,
                                                              with modelType: ModelType.Type,
                                                              withResponseAndData completion: @escaping (ModelType?, ResponseWithDataInterface?) -> Void) {
        var unwrappedRequest: URLRequest?
        var responseAndData: ResponseAndData?
        do { try unwrappedRequest = request.fullRequest } catch { print(error) }
        URLSession.shared.dataTask(with: unwrappedRequest!) { data, response, error in
            guard error == nil else {
                print(NetworkingAPIError.networkError(error: "❌ A networking error occured \(error?.localizedDescription ?? "No error received"). Default Data() and URLResponse() will be returned."))
                responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                DispatchQueue.main.async {
                    completion(nil,responseAndData)
                }
                return
            }
            if data == nil {
                print(NetworkingAPIError.nilData(error: "❌ The incoming data is nil. A default Data() will be returned"))
            }else if response == nil {
                print(NetworkingAPIError.nilResponse(error: "❌ The incoming response is nil. A default URLResponse() will be returned"))
            }
            let jsonDecoder = JSONDecoder()
            var decodedData: ModelType?
            do {
                decodedData = try jsonDecoder.decode(modelType.self, from: data!)
            } catch {
                print(NetworkingAPIError.jsonDecodingError( "❌ Could not parse the model you have provided. Check if your keys match the ones coming from the response."))
                responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                completion(nil, responseAndData)
                return
            }
            DispatchQueue.main.async {
                responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                completion(decodedData, responseAndData)
            }
        }.resume()
    }
    
    /**
     A function that  starts a URLSessionDataTask with a custom object, conforiming to the Request protocol and returns a delegate callback with custom output type that must conform to the codable protocol. The provided clousure returns the decoded model but needs to be cast to the desired type, in order to be used in your code.
     NOTE: This is very unlikely to be used out in the wild, but it doesn't hurt to have an extra way to make network calls.
     
     - Parameters:
     - for: This parrameter accepts a type that conforms to the protocl Request. You will have to provide your own custom implementation of that type. See more on the Request protocol definition.
     - with: You need to pass your model's type as a parameter here. Your model needs to conform to Codable. Example MyModel.Type.
     - dataTaskDelegateImplementor: This parameter is an escaping auto closure, you will have to appoint who the delegate will be when calling this function. No memory leaks are created.
     */
    public func makeURLRequestWithDelegate<ModelType: Codable>(for request: Request,
                                                                with modelType: ModelType.Type,
                                                                dataTaskDelegateImplementor: @escaping @autoclosure (() -> DataTaskWithDelegate?)) {
        var unwrappedRequest: URLRequest?
        var responseAndData: ResponseAndData?
        do { try unwrappedRequest = request.fullRequest } catch { print(error) }
        URLSession.shared.dataTask(with: unwrappedRequest!) { data, response, error in
            guard error == nil else {
                print(NetworkingAPIError.networkError(error: "❌ A networking error occured \(error?.localizedDescription ?? "No error received"). Default Data() and URLResponse() will be returned."))
                responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                DispatchQueue.main.async {
                    dataTaskDelegateImplementor()?.resultFromURLRequestWithDelegate(model: nil, responseAndData: responseAndData)
                }
                return
            }
            if data == nil {
                print(NetworkingAPIError.nilData(error: "❌ The incoming data is nil. A default Data() will be returned"))
            }else if response == nil {
                print(NetworkingAPIError.nilResponse(error: "❌ The incoming response is nil. A default URLResponse() will be returned"))
            }
            let jsonDecoder = JSONDecoder()
            var decodedData: ModelType?
            do {
                decodedData = try jsonDecoder.decode(modelType.self, from: data!)
            } catch {
                print(NetworkingAPIError.jsonDecodingError( "❌ Could not parse the model you have provided. Check if your keys match the ones coming from the response."))
                responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                dataTaskDelegateImplementor()?.resultFromURLRequestWithDelegate(model: nil, responseAndData: responseAndData)
                return
            }
            DispatchQueue.main.async {
                responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                dataTaskDelegateImplementor()?.resultFromURLRequestWithDelegate(model: decodedData, responseAndData: responseAndData)
            }
        }.resume()
    }
    
    public func makeConcurrentCallWithClosures(concurrentRequests: [Request], qos: DispatchQoS,attributes: DispatchQueue.Attributes, completedRequests: @escaping ([(Int, ResponseWithDataInterface)]) -> ()) {
        let concurrencyManager = ConcurencyManager(qos: qos, attributes: attributes, queue: .global())
        concurrencyManager.makeConcurrentCallClosures(concurrentRequests: concurrentRequests) { arrayOfTuples in
                completedRequests(arrayOfTuples)
        }
    }
}
