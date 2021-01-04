//
//  ConnectionRetrier.swift
//  MinCloud
//
//  Created by quanhua on 2020/12/9.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

/// WebSocket 配置项
@objc(BaaSWebSocketConfiguration)
public class BaaSWebSocketConfiguration: NSObject {
    
    /// 最长连接时间
    @objc public static var connectionTimeOut: TimeInterval = 10.0
    /// websocket 重连策略
    @objc public static var retryPolicy: ConnectionRetrier = ConnectionRetryPolicy(delayLimit: 300.0) // 连接超时后的重试策略
    
}

/// websocket 重连策略，实现该协议自定义重连策略
@objc(BaaSConnectionRetrier)
public protocol ConnectionRetrier {
    
    // 返回 -1 表示不重连
    @objc func retry(retryCount: UInt) -> TimeInterval
    
}


/// 二进制退避算法重试策略
@objc(BaaSConnectionRetryPolicy)
public class ConnectionRetryPolicy: NSObject, ConnectionRetrier {
    
    /// 最大重连延时
    @objc public var delayLimit: TimeInterval

    public let exponentialBackoffBase: UInt = 2
    public let exponentialBackoffScale: Double = 0.5
    
    public init(delayLimit: TimeInterval) {
        self.delayLimit = delayLimit
        super.init()
    }
    
    public func retry(retryCount: UInt) -> TimeInterval {
        let _retryCount = min(retryCount, 15)
        let currentDelay = pow(Double(exponentialBackoffBase), Double(_retryCount)) * exponentialBackoffScale
        return min(currentDelay, delayLimit)
    }
}
