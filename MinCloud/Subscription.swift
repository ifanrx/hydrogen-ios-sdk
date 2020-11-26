//
//  Subscription.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/11.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

// 正在订阅中，用于第一次连接时，超时后返回错误
class Subscripting: NSObject {
    internal let key: Int32
    internal let onError: ErrorSubscribeCallback
    
    init(key: Int32,
         onError: @escaping ErrorSubscribeCallback) {
        
        self.key = key
        self.onError = onError
    }
}

/// Subscription
/// 表示一个订阅事件
/// 通过调用 unsubscribe 可以取消订阅该事件
@objc(BaaSSubscription)
public class Subscription: NSObject {
    internal let key: Int32
    internal var subscription: SwampSubscription
    internal let topic: String
    internal let options: [String: Any]
    internal let onInit: SubscribeCallback
    internal let onError: ErrorSubscribeCallback
    internal let onEvent: EventCallback
    
    init(key: Int32,
         subscription: SwampSubscription,
         topic: String,
         options: [String: Any],
         onInit: @escaping SubscribeCallback,
         onError: @escaping ErrorSubscribeCallback,
         onEvent: @escaping EventCallback) {
        
        self.key = key
        self.subscription = subscription
        self.topic = topic
        self.options = options
        self.onInit = onInit
        self.onError = onError
        self.onEvent = onEvent
    }
    
    
    /// 取消当前订阅
    /// - Parameters:
    ///   - onSuccess: 取消订阅成功回调
    ///   - onError:   取消订阅失败回调
    @objc public func unsubscribe(onSuccess: @escaping UnsubscribeCallback,
                          onError: @escaping ErrorUnsubscribeCallback) {

        self.subscription.cancel { [weak self] in
            guard let self = self else { return }
            SubscriptionManager.shared.delete(self)

            if SubscriptionManager.shared.isEmpty {
                WampSessionManager.shared.disconnect()
            }
            onSuccess()
            
        } onError: { (_, message) in
            let error = HError(reason: message)
            printErrorInfo(error)
            onError(error as NSError)
        }
    }
    
}
