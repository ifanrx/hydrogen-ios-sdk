//
//  WampSessionManager.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/10.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

/// 对 wamp session 的封装和管理
/// 对外接口为 subscribe(_:options:onInit:onError:onEvent:)
/// 主要流程：
/// 1. 发起订阅：如果未建立，先建立连接，连接成功后再发起订阅；如果已连接，直接发起订阅
/// 2. 订阅成功后，将订阅保存起来，并回调 onInit
/// 3. 连接发生错误，向所有已保存的订阅回调 onError 连接错误
/// 4. 事件发生时，回调 onEvent
/// 5. 当连接意外断开时（app 进入后台，网络无连接），当 app 恢复正常时，SwampSession 会自动重连，
///    重连成功后（swampSessionConnected），会重新订阅之前的事件。
internal class WampSessionManager {
    
    typealias SubscriptionKey = Int32
    
    static let shared = WampSessionManager()
    private let session: SwampSession
    
    // 处理所有内部回调以及状态更新
    private let rootQueue = DispatchQueue(label: "com.ifanr.mincloud.websocket.rootqueue")
        
    // 等待建立连接的订阅回调
    private var connectionRequestCallbacks = [() -> Void]()
    
    private init() {
        
        let transport = WebSocketSwampTransport(underlyingQueue: rootQueue)
        self.session = SwampSession(realm: Config.Wamp.realm, transport: transport, underlyingQueue: rootQueue)
        self.session.delegate = self
    }
    
    func connect() {
        session.tryConnecting()
    }
    
    func disconnect() {
        session.tryDisconnecting()
    }
    
    func subscribe(_ topic: String,
                   options: [String: Any] = [:],
                   onInit: @escaping SubscribeCallback,
                   onError: @escaping ErrorSubscribeCallback,
                   onEvent: @escaping EventCallback) {
        
        rootQueue.async {
            let key = SubscriptionManager.shared.generateKey()
            let subscripting = SubscriptingTask(key: key, onError: onError)
            SubscriptingTaskManager.shared.save(subscripting)
            
            self.requestForConnection { [weak self] in
                self?.resume(topic, options: options, subscriptionKey: key, onInit: onInit, onError: onError, onEvent: onEvent)
            }
        }
    }
    
    // 等待 wamp 建立连接
    private func requestForConnection(_ callback: @escaping (() -> Void)) {
        dispatchPrecondition(condition: .onQueue(rootQueue))
        
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
            connectionRequestCallbacks.append(callback)
        case .connected:
            // 已建立连接，直接调用 callback
            callback()
        }
    }
    
    private func resume(_ topic: String,
                        options: [String: Any] = [:],
                        subscriptionKey: SubscriptionKey,
                        onInit: @escaping SubscribeCallback,
                        onError: @escaping ErrorSubscribeCallback,
                        onEvent: @escaping EventCallback) {
        
        dispatchPrecondition(condition: .onQueue(rootQueue))
        
        session.subscribe(topic, options: options) { (subscription) in
            
            dispatchPrecondition(condition: .onQueue(self.rootQueue))
            // 删除正在订阅的事件
            SubscriptingTaskManager.shared.delete(for: subscriptionKey)
            
            // 保存订阅成功的事件
            let subscription = Subscription(key: subscriptionKey, subscription: subscription, topic: topic, options: options, onInit: onInit, onError: onError, onEvent: onEvent)
            SubscriptionManager.shared.save(subscription)
            
            onInit(subscription)
        } onError: { (_, message) in
            dispatchPrecondition(condition: .onQueue(self.rootQueue))
            // 删除正在订阅的事件
            SubscriptingTaskManager.shared.delete(for: subscriptionKey)
            
            self.rootQueue.asyncAfter(deadline: .now() + .seconds(5)) {
                if SubscriptionManager.shared.isEmpty {
                    WampSessionManager.shared.disconnect()
                }
            }
            
            let error = HError(reason: message)
            printErrorInfo(error)
            onError(error as NSError)
            
        } onEvent: { (_, _, result) in
            
            onEvent(result)
        }
    }
}

extension WampSessionManager: SwampSessionDelegate {
    func swampSessionHandleChallenge(_ authMethod: String, extra: [String : Any]) -> String {
        return ""
    }
    
    func swampSessionConnected(_ session: SwampSession, sessionId: Int) {
        dispatchPrecondition(condition: .onQueue(self.rootQueue))
        
        // wamp 未连接前发起的订阅，再次发起订阅
        for callback in connectionRequestCallbacks {
            callback()
        }
        connectionRequestCallbacks.removeAll()
        
        // 之前已成功的订阅，连接成功（意外断开连接），重新订阅
        let subscriptions = SubscriptionManager.shared.subscriptions
        for (key, subscription) in subscriptions {
            resume(subscription.topic, options: subscription.options, subscriptionKey: key, onInit: subscription.onInit, onError: subscription.onError, onEvent: subscription.onEvent)
        }
    }
    
    func swampSessionFailed(_ reason: String) {
        dispatchPrecondition(condition: .onQueue(self.rootQueue))
        
        connectionRequestCallbacks.removeAll()
        
        // 正在订阅中的事件
        let subscriptingTasks = SubscriptingTaskManager.shared.tasks
        for (_, task) in subscriptingTasks {
            let error =  HError(reason: reason)
            task.onError(error as NSError?)
        }
        SubscriptingTaskManager.shared.removeAll()
        
        // 给所有订阅发送断开连接的错误
        let subscriptions = SubscriptionManager.shared.subscriptions
        for (_, subscription) in subscriptions {
            let error =  HError(reason: reason)
            subscription.onError(error as NSError?)
        }
        SubscriptionManager.shared.removeAll()
    }
    
    func swampSessionIsActive() -> Bool {
        return !SubscriptionManager.shared.isEmpty
    }
}
