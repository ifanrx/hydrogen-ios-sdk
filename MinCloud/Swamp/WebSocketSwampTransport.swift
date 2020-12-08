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
    private let underlyingQueue: DispatchQueue
    
    fileprivate var disconnectionReason: String?
    
    public init(underlyingQueue: DispatchQueue) {
        self.mode = .text
        self.underlyingQueue = underlyingQueue
    }
    
    fileprivate func setupSockect() {
        let url = URL(string: Config.Wamp.wsURLString)
        assert(url != nil)
        
        var request = URLRequest(url: url!)
        request.timeoutInterval = 5.0
        request.addValue("wamp.2.json", forHTTPHeaderField: "Sec-WebSocket-Protocol")
        self.socket = WebSocket(request: request)
        socket.callbackQueue = underlyingQueue
        socket.delegate = self
        self.socket.connect()
    }
    
    // MARK: Transport
    
    open func connect() {
        self.setupSockect()
    }
    
    private func clearConnection() {
        self.socket?.disconnect()
        self.socket = nil
    }
    
    open func disconnect(_ reason: String) {
        self.disconnectionReason = reason
        self.socket.disconnect()
    }
    
    open func sendData(_ data: Data) {
        if self.mode == .text {
            self.socket.write(string: String(data: data, encoding: String.Encoding.utf8)!)
        } else {
            self.socket.write(data: data)
        }
    }
}

extension WebSocketSwampTransport: WebSocketDelegate {
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
            case .connected(let headers):
                printDebugInfo("websocket is connected: \(headers)")
                delegate?.swampTransportDidConnectWithSerializer(JSONSwampSerializer())
            case .disconnected(let reason, let code):
                printDebugInfo("websocket is disconnected: \(reason) with code: \(code)")
            case .text(let string):
                printDebugInfo("Received text: \(string)")
                if let data = string.data(using: String.Encoding.utf8) {
                    delegate?.swampTransportReceivedData(data)
                }
            case .binary(let data):
                printDebugInfo("Received data: \(data.count)")
                delegate?.swampTransportReceivedData(data)
            case .ping(_):
                printDebugInfo("Received Ping")
                delegate?.swampTransportReceivedPing()
                // 内部已默认实现向 server 发送 pong 作为回应。
                break
            case .pong(_):
                break
            case .viabilityChanged(_):
                break
            case .reconnectSuggested(_):
                break
            case .cancelled:
                break
            case .error(let error):
                delegate?.swampTransportConnectFailed(error as NSError?, reason: nil)
            }
    }
}
