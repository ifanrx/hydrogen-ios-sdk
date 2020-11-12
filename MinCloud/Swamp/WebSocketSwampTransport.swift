//
//  WebSocketTransport.swift
//  swamp
//
//  Created by Yossi Abraham on 18/08/2016.
//  Copyright © 2016 Yossi Abraham. All rights reserved.
//

import Foundation
import Starscream
import Alamofire

open class WebSocketSwampTransport: SwampTransport {
    
    enum WebsocketMode {
        case binary, text
    }
    
    open var delegate: SwampTransportDelegate?
    var socket: WebSocket!
    let mode: WebsocketMode
    public var isConnected: Bool = false
    
    fileprivate var disconnectionReason: String?
    fileprivate let wsEndpoint: URL
    fileprivate let manager = NetworkReachabilityManager()
    
    // MARK: - HeartBeat
    fileprivate var heartBeat: Timer?
    fileprivate var reconnectTime: Int = 0
    fileprivate var heartBeatActive: Bool = false
    
    public init(wsEndpoint: URL) {
        self.wsEndpoint = wsEndpoint
        self.mode = .text
    }
    
    fileprivate func setupSockect() {
        var request = URLRequest(url: wsEndpoint)
        request.addValue("wamp.2.json", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        self.socket = WebSocket(request: request)
        
        socket.delegate = self
        
    }
    
    // MARK: Transport
    
    open func connect() {
        self.socket = nil
        setupSockect()
        self.socket.connect()
    }
    
    open func disconnect(_ reason: String) {
        self.disconnectionReason = reason
        self.socket.disconnect()
    }
    
    open func sendPing(_ data: Data) {
        self.socket.write(ping: data)
    }
    
    open func sendData(_ data: Data) {
        if self.mode == .text {
            self.socket.write(string: String(data: data, encoding: String.Encoding.utf8)!)
        } else {
            self.socket.write(data: data)
        }
    }
    
    // MARK: - HeartBeat
    fileprivate func sessionConnected() {
        // 启动心跳
        setupHeartBeat()
    }
    
    fileprivate func sessionDisConnected() {
        // 关闭心跳
        destoryHeartBeat()
    }
    
    // 建立心跳
    fileprivate func setupHeartBeat() {
        destoryHeartBeat()
        heartBeatActive = true
        heartBeat = Timer(timeInterval: 20, repeats: true, block: { [weak self] (_) in
            // sendPing
            dPrint("Send ping!")
            // 无网络不发送
            let isReachable = self?.manager?.isReachable ?? false
            let heartBeatActive = self?.heartBeatActive ?? false
            if isReachable && heartBeatActive {
                self?.sendPing(Data())
            }
        })
        
        RunLoop.current.add(heartBeat!, forMode: .common)
        heartBeat?.fire()
    }
    
    // 取消心跳
    fileprivate func destoryHeartBeat() {
        self.heartBeatActive = false
        self.heartBeat?.invalidate()
        self.heartBeat = nil
    }
    
    fileprivate func reconnect() {
        self.disconnect("wamp.error.goodbye_and_out")
        
        if reconnectTime > 64 {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(10)) {
            self.connect()
        }
        
        reconnectTime = (reconnectTime == 0) ? 2 : reconnectTime*2
    }
}

extension WebSocketSwampTransport: WebSocketDelegate {
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                DispatchQueue.main.async {
                    self.isConnected = true
                }
                printDebugInfo("websocket is connected: \(headers)")
                delegate?.swampTransportDidConnectWithSerializer(JSONSwampSerializer())
                sessionConnected()
            case .disconnected(let reason, let code):
                printDebugInfo("websocket is disconnected: \(reason) with code: \(code)")
                DispatchQueue.main.async {
                    self.isConnected = false
                }
                delegate?.swampTransportDidDisconnect(nil, reason: reason)
                sessionDisConnected()
            case .text(let string):
                printDebugInfo("Received text: \(string)")
                if let data = string.data(using: String.Encoding.utf8) {
                    delegate?.swampTransportReceivedData(data)
                }
            case .binary(let data):
                printDebugInfo("Received data: \(data.count)")
                delegate?.swampTransportReceivedData(data)
            case .ping(_):
                dPrint("Received ping!")
                // 内部已默认实现向 server 发送 pong 作为回应。
                break
            case .pong(_):
                dPrint("Received pong!")
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                DispatchQueue.main.async {
                    self.isConnected = false
                }
            case .error(let error):
                DispatchQueue.main.async {
                    self.isConnected = false
                }
                if let error = error {
                    delegate?.swampTransportDidDisconnect(error as NSError, reason: nil)
                }
                // 重新连接
                reconnect()
            }
    }
}
