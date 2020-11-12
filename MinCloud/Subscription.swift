//
//  Subscription.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/11.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

/// Subscription
/// 表示一个订阅事件
/// 通过调用 unsubscribe 可以取消订阅该事件
@objc(BaaSSubscription)
open class Subscription: NSObject {
    internal let key: Int32
    internal var subscription: WampSubscription
    internal let topic: String
    internal let options: [String: Any]
    internal let callbackQueue: DispatchQueue?
    internal let onInit: SubscribeCallback
    internal let onError: ErrorSubscribeCallback
    internal let onEvent: EventCallback
    
    internal init(key: Int32,
         subscription: WampSubscription,
         topic: String,
         options: [String: Any],
         callbackQueue: DispatchQueue?,
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
        self.callbackQueue = callbackQueue
    }
    
    
    /// 取消当前订阅
    /// - Parameters:
    ///   - callbackQueue： 指定回调函数运行的队列。默认为当前队列
    ///   - onSuccess: 取消订阅成功回调
    ///   - onError:   取消订阅失败回调
    open func unsubscribe(callbackQueue: DispatchQueue? = nil,
                          onSuccess: @escaping UnsubscribeCallback,
                          onError: @escaping ErrorUnsubscribeCallback) {

        self.subscription.cancel { [weak self] in
            guard let self = self else { return }
            SubscriptionManager.shared.delete(self)
            
            // 当前无订阅，关闭连接
            if SubscriptionManager.shared.isEmpty {
                WampSessionManager.shared.disconnect()
            }
            self.execteCallback(callbackQueue, callback: {
                onSuccess()
            })
            
        } onError: { (result, message) in
            let error = HError.init(code: 604, description: message)
            printErrorInfo(error)
            self.execteCallback(callbackQueue, callback: {
                onError(error as NSError)
            })
        }
    }
    
    private func execteCallback(_ callbackQueue: DispatchQueue?, callback: @escaping () -> Void) {
        if let callbackQueue = callbackQueue {
            callbackQueue.async {
                callback()
            }
        } else {
            callback()
        }
    }
}
