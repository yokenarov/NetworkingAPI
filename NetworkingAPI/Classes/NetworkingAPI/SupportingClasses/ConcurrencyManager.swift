//
//  ConcurrencyManager.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 29.10.21.
//

import Foundation
import Combine
class ConcurencyManager {
    let concurrentQueue: DispatchQueue
    
    init(qos: DispatchQoS, attributes: DispatchQueue.Attributes, queue: DispatchQueue) {
        concurrentQueue = DispatchQueue(label: UUID(uuidString: "com.concurencyManagerQueue")?.uuidString ?? "", qos: qos, attributes: attributes, target: queue)
    }
    
    func makeConcurrentCallClosures(concurrentRequests: [Request],
    with providedResponseAndData: ResponseWithDataInterface? = ResponseAndData(response: URLResponse(), data: Data()), completionRequests: @escaping ([(Int, ResponseWithDataInterface)]) -> () ) {
        
        let dispathGroup: DispatchGroup = DispatchGroup()
        var completedRequests: [(Int, ResponseWithDataInterface)] = []
       
        for (requestIndex, request) in concurrentRequests.enumerated() {
            dispathGroup.enter()
            
           concurrentQueue.async(group: dispathGroup, qos: .userInitiated, execute: {
               print("Request \(requestIndex+1) has been sent to a concurrent background thread.")
            var unwrappedRequest: URLRequest?
            do { try unwrappedRequest = request.fullRequest } catch {
                let responseAndData = ResponseAndData(response: URLResponse(), data: Data())
                completedRequests.append((requestIndex, responseAndData))
                print(error)
                dispathGroup.leave()
                return
            }
            URLSession.shared.dataTask(with: unwrappedRequest!) { data, response, error in
                var responseAndData: ResponseAndData?
                guard error == nil else {
                    print(NetworkingAPIError.networkError(error: "❌ A networking error occured \(error?.localizedDescription ?? "No error received"). Default Data() and URLResponse() will be returned."))
                    responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                    completedRequests.append((requestIndex, responseAndData!))
                    dispathGroup.leave()
                    return
                }
                if data == nil {
                    print(NetworkingAPIError.nilData(error: "❌ The incoming data is nil. A default Data() will be returned"))
                }else if response == nil {
                    print(NetworkingAPIError.nilResponse(error: "❌ The incoming response is nil. A default URLResponse() will be returned"))
                }
            
                    responseAndData = ResponseAndData(response: response ?? URLResponse(), data: data ?? Data())
                completedRequests.append((requestIndex, responseAndData!))
                dispathGroup.leave()
            }.resume()
           })
        }
        dispathGroup.notify(queue: .main) {
            print("\(completedRequests.count) Requests have finished their work and are now returning to the main thread.")
            completionRequests(completedRequests)
        }
    }
     
    
    
}
