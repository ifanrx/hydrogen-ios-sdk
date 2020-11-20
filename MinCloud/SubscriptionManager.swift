//
//  SubscriptionManager.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/10.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

internal class SubscriptionManager {
    static let shared = SubscriptionManager()
    private var _key: Int32 = 0
    
    private(set) var subscriptions: [Int32: Subscription] = [:]
    
    var isEmpty: Bool {
        return subscriptions.isEmpty
    }
    
    func save(_ subscription: Subscription) {
        let key = subscription.key
        subscriptions[key] = subscription
    }
    
    func delete(_ subscription: Subscription) {
        let key = subscription.key
        subscriptions.removeValue(forKey: key)
    }
    
    func get(_ key: Int32) -> Subscription? {
        return subscriptions[key]
    }
    
    func removeAll() {
        subscriptions.removeAll()
    }
    
    func generateKey() -> Int32 {
        
        return OSAtomicIncrement32(&_key)
    }
}
