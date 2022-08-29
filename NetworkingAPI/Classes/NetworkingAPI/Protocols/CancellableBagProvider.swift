//
//  CancellableBagProvider.swift
//  NetworkingAPI
//
//  Created by Jordan Kenarov on 28.10.21.
//

import Foundation
import Combine
/**
 This protocol forces users of makeURLRequesWithPublisher to provide a cancellableBag in their interface in case they forgot to appoint one. This is for memory management in combine. 
 */
public protocol CancellableBagProvider {
    var cancellableBag: Set<AnyCancellable> { get set }
}
