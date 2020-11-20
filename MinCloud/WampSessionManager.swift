//
//  WampSessionManager.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/10.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

// 连接状态
public enum SessionState {
    case connected      // 已连接
    case disconnected  // 未连接
    case connecting    // 连接中
}

internal class WampSessionManager {
    
    typealias SubscriptionKey = Int32
    
    static let shared = WampSessionManager()
    private let session: SwampSession
    
    // 读写 sessionState/subscribingCallbacks 可能在不同线程，需加锁
    
    // 等待建立连接的订阅回调
    typealias SubscribingCallback = () -> Void
    private var subscribingCallbacks = [SubscribingCallback]()
    
    private init() {
        
        let transport = WebSocketSwampTransport()
        self.session = SwampSession(realm: Config.Wamp.realm, transport: transport)
        self.session.delegate = self
    }
    
    func connect() {
        session.tryConnecting()
    }
    
    func disconnect() {
        session.disconnect()
    }
    
    func subscribe(_ topic: String,
                   options: [String: Any]=[:],
                   callbackQueue: DispatchQueue? = nil,
                   onInit: @escaping SubscribeCallback,
                   onError: @escaping ErrorSubscribeCallback,
                   onEvent: @escaping EventCallback) {
        
        serialQueue.async {
            self.waitingForConnection { [weak self] in
                self?.subscribing(topic, options: options, callbackQueue: callbackQueue, subscriptionKey: nil, onInit: onInit, onError: onError, onEvent: onEvent)
            }
        }
    }
    
    // 等待 wamp 建立连接
    fileprivate func waitingForConnection(_ callback: @escaping (() -> Void)) {
        // 若未连接，先建立连接
        switch session.sessionState {
        case .disconnected:
            connect()
        case .connecting, .connected:
            break
        }
        
        switch session.sessionState {
        case .disconnected, .connecting:
            // 未建立连接，先保存 callback，等待建立后再调用
            subscribingCallbacks.append(callback)
        case .connected:
            // 已建立连接，直接调用 callback
            callback()
        }
    }
    
    fileprivate func subscribing(_ topic: String,
                               options: [String: Any]=[:],
                               callbackQueue: DispatchQueue? = nil,
                               subscriptionKey: SubscriptionKey?,
                               onInit: @escaping SubscribeCallback,
                               onError: @escaping ErrorSubscribeCallback,
                               onEvent: @escaping EventCallback) {
        
        session.subscribe(topic, options: options) { [weak self] (subscription) in
            // 保存订阅
            let key = subscriptionKey ?? SubscriptionManager.shared.generateKey()
            let mcSubscription = Subscription(key: key, subscription: subscription, topic: topic, options: options, callbackQueue: callbackQueue, onInit: onInit, onError: onError, onEvent: onEvent)
            SubscriptionManager.shared.save(mcSubscription)
            
            self?.execteCallback(callbackQueue, callback: {
                onInit(mcSubscription)
            })
        } onError: { [weak self] (result, message) in
            
            self?.execteCallback(callbackQueue, callback: {
        
                let error = HError(reason: message)
                printErrorInfo(error)
                onError(error as NSError)
            })
            
        } onEvent: { [weak self] (result1, result2, result) in
            
            self?.execteCallback(callbackQueue, callback: {
                onEvent(result)
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

extension WampSessionManager: SwampSessionDelegate {
    func swampSessionHandleChallenge(_ authMethod: String, extra: [String : Any]) -> String {
        return ""
    }
    
    func swampSessionConnected(_ session: SwampSession, sessionId: Int) {
        // wamp 未连接前发起的订阅，再次发起订阅
        for callback in subscribingCallbacks {
            callback()
        }
        subscribingCallbacks.removeAll()
        
        // 之前已成功的订阅，连接成功（意外断开连接），重新订阅
        let subscriptions = SubscriptionManager.shared.subscriptions
        for (key, subscription) in subscriptions {
            subscribing(subscription.topic, options: subscription.options, callbackQueue: subscription.callbackQueue, subscriptionKey: key, onInit: subscription.onInit, onError: subscription.onError, onEvent: subscription.onEvent)
        }
    }
    
    func swampSessionFailed(_ reason: String) {
        
        // 给所有订阅发送断开连接的错误
        let subscriptions = SubscriptionManager.shared.subscriptions
        for (_, subscription) in subscriptions {
            let error =  HError(reason: reason)
            subscription.onError(error as NSError?)
        }
        SubscriptionManager.shared.removeAll()
    }
}
