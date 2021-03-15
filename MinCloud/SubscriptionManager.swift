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

// 管理正在订阅的事件
internal class SubscriptingTaskManager {
    static let shared = SubscriptingTaskManager()
    
    private(set) var tasks: [Int32: SubscriptingTask] = [:] // 正在订阅
    
    func save(_ subscripting: SubscriptingTask) {
        let key = subscripting.key
        tasks[key] = subscripting
    }
    
    func delete(for key: Int32) {
        tasks.removeValue(forKey: key)
    }
    
    func removeAll() {
        tasks.removeAll()
    }
}
