//
//  SwampContants.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/19.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

let GOODBYE = "wamp.close.goodbye_and_out"

// MARK: Call callbacks
internal typealias CallCallback = (_ details: [String: Any], _ results: [Any]?, _ kwResults: [String: Any]?) -> Void
internal typealias ErrorCallCallback = (_ details: [String: Any], _ error: String, _ args: [Any]?, _ kwargs: [String: Any]?) -> Void
// MARK: Callee callbacks

// MARK: Subscribe callbacks
internal typealias WampSubscribeCallback = (_ subscription: SwampSubscription) -> Void
public typealias SubscribeCallback = (_ subscription: Subscription) -> Void
internal typealias WampErrorSubscribeCallback = (_ details: [String: Any], _ error: String) -> Void
public typealias ErrorSubscribeCallback = (_ error: NSError?) -> Void
internal typealias WampEventCallback = (_ details: [String: Any], _ results: [Any]?, _ kwResults: [String: Any]?) -> Void
public typealias EventCallback = (_ result: [String: Any]?) -> Void
public typealias UnsubscribeCallback = () -> Void
internal typealias WampErrorUnsubscribeCallback = (_ details: [String: Any], _ error: String) -> Void
public typealias ErrorUnsubscribeCallback = (_ error: NSError?) -> Void

// MARK: Publish callbacks
internal typealias PublishCallback = () -> Void
internal typealias ErrorPublishCallback = (_ details: [String: Any], _ error: String) -> Void
