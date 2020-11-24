//
//  SwampSession.swift
//

import Foundation
import Alamofire

let serialQueue = DispatchQueue(label: "com.mincloud.websocket")

enum AppState {
    case background
    case foreground
}

// 连接状态
internal enum SessionState {
    case connected      // 已连接
    case disconnected  // 未连接
    case connecting    // 连接中
}

internal protocol SwampSessionDelegate {
    func swampSessionHandleChallenge(_ authMethod: String, extra: [String: Any]) -> String
    func swampSessionConnected(_ session: SwampSession, sessionId: Int)
    func swampSessionFailed(_ reason: String)
    func swampSessionIsActive() -> Bool
}

/// SwampSession
/// 实现 wamp 协议以及心跳重连机制
/// 1. wamp 协议：connect() -> 收到connected，发送 hello -> 收到 welcome 建立连接
/// 2. 服务器 20 秒发送一次 ping，客户端立即回复 pong。服务器 30 秒收不到 pong，断开连接；客户端 30 秒收不到 ping，断开连接并发起重连。
/// 3. app 进入后台/网络断开，主动断开连接；app 进入前台/恢复网络发起重连。
final internal class SwampSession: SwampTransportDelegate {
    // MARK: delegate
    var delegate: SwampSessionDelegate?

    // MARK: Constants
    // No callee role for now
    private let supportedRoles: [SwampRole] = [SwampRole.Caller, SwampRole.Subscriber, SwampRole.Publisher]
    private let clientName = "Swamp-1.0.0"

    // MARK: Members
    private let realm: String
    private var transport: SwampTransport
    private let authmethods: [String]?
    private let authid: String?
    private let authrole: String?
    private let authextra: [String: Any]?

    // MARK: State members
    private var currRequestId: Int = 1
    private let requestIdLock: NSLock
    
    // MARK: Session state
    private var serializer: SwampSerializer?
    private var sessionId: Int?
    private var routerSupportedRoles: [SwampRole]?
    
    // MARK: - HeartBeat
    private var heartBeat: Timer?
    private var lastReceivedPingTimeInterval: TimeInterval = Date().timeIntervalSince1970 // 上次收到 ping 的时间戳
    private let receivedPingTimeout: TimeInterval = 30.0
    private let reachabilityManager = NetworkReachabilityManager()
    private var connectingDelayInterval = 0
    private var previousReachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    private var enterForegroundObserver: NSObjectProtocol?
    private var enterBackgroundObserver: NSObjectProtocol?

    // MARK: Call role
    //                           requestId
    private var callRequests: [Int: (callback: CallCallback, errorCallback: ErrorCallCallback)] = [:]

    // MARK: Subscriber role
    //                              requestId
    private var subscribeRequests: [Int: (callback: WampSubscribeCallback, errorCallback: WampErrorSubscribeCallback, eventCallback: WampEventCallback)] = [:]
    //                          subscription
    private var subscriptions: [Int: SwampSubscription] = [:]
    //                                requestId
    private var unsubscribeRequests: [Int: (subscription: Int, callback: UnsubscribeCallback, errorCallback: WampErrorUnsubscribeCallback)] = [:]

    // MARK: Publisher role
    //                            requestId
    private var publishRequests: [Int: (callback: PublishCallback, errorCallback: ErrorPublishCallback)] = [:]
    
    var sessionState: SessionState = .disconnected
    
    // MARK: C'tor
    required init(realm: String, transport: SwampTransport, authmethods: [String]?=nil, authid: String?=nil, authrole: String?=nil, authextra: [String: Any]?=nil){
        self.realm = realm
        self.transport = transport
        self.authmethods = authmethods
        self.authid = authid
        self.authrole = authrole
        self.authextra = authextra
        self.requestIdLock = NSLock()
        self.transport.delegate = self
        
        // app 状态及网络状态
        self.sessionStateObserving()
    }
    
    deinit {
        if let observer = self.enterForegroundObserver {
            NotificationCenter.default.removeObserver(observer)
            self.enterForegroundObserver = nil
        }
        
        if let observer = self.enterBackgroundObserver {
            NotificationCenter.default.removeObserver(observer)
            self.enterBackgroundObserver = nil
        }
        
        reachabilityManager?.stopListening()
        tryDisconnecting(reason: GOODBYE)
    }
    
}

// MARK: - app 状态及网络状态
extension SwampSession {
    
    /// app 进入后台/网络断开，主动断开 session
    /// app 进入前台/网络恢复，主动建立 session
    private func sessionStateObserving() {
        
        let operationQueue = OperationQueue()
        operationQueue.underlyingQueue = serialQueue
        self.enterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: operationQueue)
        { [weak self] _ in
            self?.applicationStateChanged(with: .background)
        }
        
        self.enterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: operationQueue)
        { [weak self] _ in
            self?.applicationStateChanged(with: .foreground)
        }
        
        self.reachabilityManager?.listenerQueue = serialQueue
        self.reachabilityManager?.startListening()
        self.reachabilityManager?.listener = { [weak self] newStatus in
            self?.networkReachabilityStatusChanged(with: newStatus)
        }
    }
    
    private func applicationStateChanged(with appState: AppState) {
        
        switch appState {
        case .background:
            resetConnectingDelayInterval()
            tryDisconnecting(reason: GOODBYE)
        case .foreground:
            resetConnectingDelayInterval()
            let isActive = delegate?.swampSessionIsActive() ?? false
            if isActive {
                tryConnecting()
            }
        }
    }
    
    private func networkReachabilityStatusChanged(
        with newStatus: NetworkReachabilityManager.NetworkReachabilityStatus)
    {
        let oldStatus = self.previousReachabilityStatus
        self.previousReachabilityStatus = newStatus
        let isActive = delegate?.swampSessionIsActive() ?? false
        if oldStatus != .notReachable
            &&  newStatus == .notReachable {
            resetConnectingDelayInterval()
            tryDisconnecting(reason: GOODBYE)
        } else if oldStatus != newStatus &&
            newStatus != .notReachable && isActive {
            self.resetConnectingDelayInterval()
            self.tryConnecting()
        }
    }
}

// MARK: - 连接/心跳
extension SwampSession {

    // MARK: SwampTransportDelegate
    func swampTransportConnectFailed(_ error: NSError?, reason: String?) {
        tryDisconnecting(reason: GOODBYE)
        tryConnecting()
    }
    
    func swampTransportReceivedPing() {
        lastReceivedPingTimeInterval = Date().timeIntervalSince1970
    }
    
    func swampTransportConnected() {
        sessionState = .connected
        resetConnectingDelayInterval()
        DispatchQueue.main.sync {
            self.setupHeartBeat()
        }
    }
    
    // 建立心跳
    private func setupHeartBeat() {
        lastReceivedPingTimeInterval = Date().timeIntervalSince1970
        
        heartBeat = Timer(timeInterval: 20, repeats: true, block: { [weak self] (_) in
            guard let self = self else { return }
            
            let currentInterval = Date().timeIntervalSince1970
            let shouldReceivePingNow = (currentInterval - self.lastReceivedPingTimeInterval) > self.receivedPingTimeout
            let isReachable = self.reachabilityManager?.isReachable ?? false
            
            if shouldReceivePingNow && isReachable {
                // 已超时，且网络正常，发起重连
                self.tryConnecting()
            }
        })
        
        RunLoop.current.add(heartBeat!, forMode: .common)
        heartBeat?.fire()
    }
    
    // 尝试连接
    func tryConnecting() {
        serialQueue.async {
            guard self.sessionState != .connecting else {
                return
            }

            self.sessionState = .connecting
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(self.connectingDelayInterval)) {
                self.transport.connect()
            }
            
            self.connectingDelayInterval = (self.connectingDelayInterval < 300) ? (15 + self.connectingDelayInterval) : 300
        }
    }
    
    // 取消连接
    func tryDisconnecting(reason: String = GOODBYE) {
        self.sendMessage(GoodbyeSwampMessage(details: [:], reason: reason))
        self.sessionState = .disconnected
        self.heartBeat?.invalidate()
        self.heartBeat = nil
    }
    
    private func resetConnectingDelayInterval() {
        self.connectingDelayInterval = 1
    }
}

// MARK: - wamp 协议
extension SwampSession {
    
    // MARK: Caller role
    func call(_ proc: String, options: [String: Any]=[:], args: [Any]?=nil, kwargs: [String: Any]?=nil, onSuccess: @escaping CallCallback, onError: @escaping ErrorCallCallback) {
        let callRequestId = self.generateRequestId()
        // Tell router to dispatch call
        self.sendMessage(CallSwampMessage(requestId: callRequestId, options: options, proc: proc, args: args, kwargs: kwargs))
        // Store request ID to handle result
        self.callRequests[callRequestId] = (callback: onSuccess, errorCallback: onError )
    }

    // MARK: Subscriber role

    func subscribe(_ topic: String, options: [String: Any]=[:], onSuccess: @escaping WampSubscribeCallback, onError: @escaping WampErrorSubscribeCallback, onEvent: @escaping WampEventCallback) {
        // TODO: assert topic is a valid WAMP uri
        let subscribeRequestId = self.generateRequestId()
        // Tell router to subscribe client on a topic
        self.sendMessage(SubscribeSwampMessage(requestId: subscribeRequestId, options: options, topic: topic))
        // Store request ID to handle result
        self.subscribeRequests[subscribeRequestId] = (callback: onSuccess, errorCallback: onError, eventCallback: onEvent)
    }

    // Internal because only a Subscription object can call this
    func unsubscribe(_ subscription: Int, onSuccess: @escaping UnsubscribeCallback, onError: @escaping WampErrorUnsubscribeCallback) {
        let unsubscribeRequestId = self.generateRequestId()
        // Tell router to unsubscribe me from some subscription
        self.sendMessage(UnsubscribeSwampMessage(requestId: unsubscribeRequestId, subscription: subscription))
        // Store request ID to handle result
        self.unsubscribeRequests[unsubscribeRequestId] = (subscription, onSuccess, onError)
    }

    // MARK: Publisher role
    // without acknowledging
    func publish(_ topic: String, options: [String: Any]=[:], args: [Any]?=nil, kwargs: [String: Any]?=nil) {
        // TODO: assert topic is a valid WAMP uri
        let publishRequestId = self.generateRequestId()
        // Tell router to publish the event
        self.sendMessage(PublishSwampMessage(requestId: publishRequestId, options: options, topic: topic, args: args, kwargs: kwargs))
        // We don't need to store the request, because it's unacknowledged anyway
    }

    // with acknowledging
    func publish(_ topic: String, options: [String: Any]=[:], args: [Any]?=nil, kwargs: [String: Any]?=nil, onSuccess: @escaping PublishCallback, onError: @escaping ErrorPublishCallback) {
        // add acknowledge to options, so we get callbacks
        var options = options
        options["acknowledge"] = true
        // TODO: assert topic is a valid WAMP uri
        let publishRequestId = self.generateRequestId()
        // Tell router to publish the event
        self.sendMessage(PublishSwampMessage(requestId: publishRequestId, options: options, topic: topic, args: args, kwargs: kwargs))
        // Store request ID to handle result
        self.publishRequests[publishRequestId] = (callback: onSuccess, errorCallback: onError)
    }

    func swampTransportDidConnectWithSerializer(_ serializer: SwampSerializer) {
        self.serializer = serializer
        // Start session by sending a Hello message!

        var roles = [String: Any]()
        for role in self.supportedRoles {
            // For now basic profile, (demands empty dicts)
            roles[role.rawValue] = [:]
        }

        var details: [String: Any] = [:]

        if let authmethods = self.authmethods {
            details["authmethods"] = authmethods
        }
        if let authid = self.authid {
            details["authid"] = authid
        }
        if let authrole = self.authrole {
            details["authrole"] = authrole
        }
        if let authextra = self.authextra {
            details["authextra"] = authextra
        }

        details["agent"] = self.clientName
        details["roles"] = roles
        self.sendMessage(HelloSwampMessage(realm: self.realm, details: details))
    }

    func swampTransportReceivedData(_ data: Data) {
        if let payload = self.serializer?.unpack(data), let message = SwampMessages.createMessage(payload) {
            self.handleMessage(message)
        }
    }

    private func handleMessage(_ message: SwampMessage) {
        switch message {
        // MARK: Auth responses
        case _ as ChallengeSwampMessage:
            // 没有使用这种认证方式
            break
        
        // MARK: Session responses
        case let message as WelcomeSwampMessage:
            self.sessionId = message.sessionId
            let routerRoles = message.details["roles"]! as! [String : [String : Any]]
            self.routerSupportedRoles = routerRoles.keys.map { SwampRole(rawValue: $0)! }
            self.delegate?.swampSessionConnected(self, sessionId: message.sessionId)
            self.swampTransportConnected()
        case let message as GoodbyeSwampMessage:
            
            // 如果 reason 为 wamp.close.goodbye_and_out，表示客户端主动断开：1. 当前无订阅 2. 网络无效 3. app 进入后台
            // 否则，表示服务器主动断开：1. 用户登出 2. 欠费 3. 服务器坏了，这时客户端需回应 goodbye，且断开连接。
            if message.reason != GOODBYE {
                self.delegate?.swampSessionFailed(message.reason)
                self.sendMessage(GoodbyeSwampMessage(details: [:], reason: message.reason))
                self.tryDisconnecting(reason: message.reason)
            }
            
        case let message as AbortSwampMessage:
            sessionId = nil
            
            // 收到 abort，连接结束
            self.delegate?.swampSessionFailed(message.reason)
            self.tryDisconnecting(reason: message.reason)
        // MARK: Call role
        case let message as ResultSwampMessage:
            let requestId = message.requestId
            if let (callback, _) = self.callRequests.removeValue(forKey: requestId) {
                callback(message.details, message.results, message.kwResults)
            } else {
                // TODO: log this erroneous situation
            }
        // MARK: Subscribe role
        case let message as SubscribedSwampMessage:
            let requestId = message.requestId
            if let (callback, _, eventCallback) = self.subscribeRequests.removeValue(forKey: requestId) {
                // Notify user and delegate him to unsubscribe this subscription
                let subscription = SwampSubscription(session: self, subscription: message.subscription, onEvent: eventCallback)
                callback(subscription)
                // Subscription succeeded, we should store event callback for when it's fired
                self.subscriptions[message.subscription] = subscription
            } else {
                // TODO: log this erroneous situation
            }
        case let message as EventSwampMessage:
            if let subscription = self.subscriptions[message.subscription] {
                subscription.eventCallback(message.details, message.args, message.kwargs)
            } else {
                // TODO: log this erroneous situation
            }
        case let message as UnsubscribedSwampMessage:
            let requestId = message.requestId
            if let (subscription, callback, _) = self.unsubscribeRequests.removeValue(forKey: requestId) {
                if let subscription = self.subscriptions.removeValue(forKey: subscription) {
                    subscription.invalidate()
                    callback()
                } else {
                    // TODO: log this erroneous situation
                }
            } else {
                // TODO: log this erroneous situation
            }
        case let message as PublishedSwampMessage:
            let requestId = message.requestId
            if let (callback, _) = self.publishRequests.removeValue(forKey: requestId) {
                callback()
            } else {
                // TODO: log this erroneous situation
            }

        ////////////////////////////////////////////
        // MARK: Handle error responses
        ////////////////////////////////////////////
        case let message as ErrorSwampMessage:
            sessionId = nil
            switch message.requestType {
            case SwampMessages.call:
                if let (_, errorCallback) = self.callRequests.removeValue(forKey: message.requestId) {
                    errorCallback(message.details, message.error, message.args, message.kwargs)
                } else {
                    // TODO: log this erroneous situation
                }
            case SwampMessages.subscribe:
                if let (_, errorCallback, _) = self.subscribeRequests.removeValue(forKey: message.requestId) {
                    errorCallback(message.details, message.error)
                } else {
                    // TODO: log this erroneous situation
                }
            case SwampMessages.unsubscribe:
                if let (_, _, errorCallback) = self.unsubscribeRequests.removeValue(forKey: message.requestId) {
                    errorCallback(message.details, message.error)
                } else {
                    // TODO: log this erroneous situation
                }
            case SwampMessages.publish:
                if let(_, errorCallback) = self.publishRequests.removeValue(forKey: message.requestId) {
                    errorCallback(message.details, message.error)
                } else {
                    // TODO: log this erroneous situation
                }
            default:
                return
            }
        default:
            return
        }
    }
    
    // MARK: Private methods

    private func sendMessage(_ message: SwampMessage){
        
        let marshalledMessage = message.marshal()
        if let data = self.serializer?.pack(marshalledMessage as [Any]) {
            self.transport.sendData(data)
        }
    }

    private func generateRequestId() -> Int {
        self.requestIdLock.lock()
        defer {
            self.requestIdLock.unlock()
        }
        self.currRequestId += 1
       
        return self.currRequestId
    }
}
