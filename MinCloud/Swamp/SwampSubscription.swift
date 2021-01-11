//
//  SwampSubscription.swift
//  MinCloud
//
//  Created by quanhua on 2020/11/19.
//  Copyright © 2020 ifanr. All rights reserved.
//

import Foundation

// TODO: Expose only an interface (like Cancellable) to user
internal class SwampSubscription {
    fileprivate let session: SwampSession
    internal let subscription: Int
    internal let eventCallback: WampEventCallback
    fileprivate var isActive: Bool = true

    internal init(session: SwampSession, subscription: Int, onEvent: @escaping WampEventCallback) {
        self.session = session
        self.subscription = subscription
        self.eventCallback = onEvent
    }

    internal func invalidate() {
        self.isActive = false
    }

    internal func cancel(_ onSuccess: @escaping UnsubscribeCallback, onError: @escaping WampErrorUnsubscribeCallback) {
        if !self.isActive {
            onError([:], "wamp.error.no_such_subscription")
            return
        }
        self.session.unsubscribe(self.subscription, onSuccess: onSuccess, onError: onError)
    }
}
