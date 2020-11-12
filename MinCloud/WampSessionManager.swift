//
//  WampSessionManager.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/10.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

// 连接状态
internal enum SessionState {
    case connected      // 已连接
    case disconnected  // 未连接
    case connecting    // 连接中
    case failture      // 连接失败
}

internal class WampSessionManager {
    
    typealias SubscriptionKey = Int32
    
    static let shared = WampSessionManager()
    private let session: SwampSession
    
    // 读写 sessionState/subscribingCallbacks 可能在不同线程，需加锁
    private var sessionState: SessionState = .disconnected
    
    // 等待建立连接的订阅回调
    typealias SubscribingCallback = () -> Void
    private var subscribingCallbacks = [SubscribingCallback]()
    
    private init() {
        
        let transport = WebSocketSwampTransport(wsEndpoint: URL(string: Config.Wamp.wsURLString)!)
        self.session = SwampSession(realm: Config.Wamp.realm, transport: transport)
        self.session.delegate = self
    }
    
    func connect() {
        
        objc_sync_enter(self)
        guard sessionState != .connected && sessionState != .connecting else {
            return
        }
        sessionState = .connecting
        session.connect()
        objc_sync_exit(self)
    }
    
    func disconnect() {
        session.disconnect("wamp.disconnect")
    }
    
    func subscribe(_ topic: String,
                   options: [String: Any]=[:],
                   callbackQueue: DispatchQueue? = nil,
                   onInit: @escaping SubscribeCallback,
                   onError: @escaping ErrorSubscribeCallback,
                   onEvent: @escaping EventCallback) {
        
        self.waitingForConnection { [weak self] in
            self?.subscribing(topic, options: options, callbackQueue: callbackQueue, subscriptionKey: nil, onInit: onInit, onError: onError, onEvent: onEvent)
        }
    }
    
    // 等待 wamp 建立连接
    fileprivate func waitingForConnection(_ callback: @escaping (() -> Void)) {
        objc_sync_enter(self)
        // 若未连接，先建立连接
        switch sessionState {
        case .disconnected, .failture:
            connect()
        case .connecting, .connected:
            break
        }
        
        switch sessionState {
        case .disconnected, .failture, .connecting:
            // 未建立连接，先保存 callback，等待建立后再调用
            subscribingCallbacks.append(callback)
        case .connected:
            // 已建立连接，直接调用 callback
            callback()
        }
        objc_sync_exit(self)
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
                let error = HError.init(code: 604, description: message)
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
        
        objc_sync_enter(self)
        sessionState = .connected
        
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
        objc_sync_exit(self)
    }
    
    func swampSessionEnded(_ reason: String) {
        objc_sync_enter(self)
        sessionState = .disconnected
        objc_sync_exit(self)
    }
}
