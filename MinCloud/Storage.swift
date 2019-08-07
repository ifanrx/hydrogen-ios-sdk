//
//  Storage.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/4/9.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

let tokenIdentity = "com.ifanr.current.user.token"
let openIdIdentity = "com.ifanr.current.user.openid"
let expiresInIdentity = "com.ifanr.current.user.expiresin"
let userIdIdentity = "com.ifanr.current.user.userId"

class Storage {

    static let shared = Storage()

    private init() {}

    /**
     *  用户 Token
     */
    var token: String? {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: tokenIdentity)
        }

        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: tokenIdentity)
        }
    }

    /**
     *  openid
     */
    var openid: String? {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: openIdIdentity)
        }

        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: openIdIdentity)
        }
    }

    /**
     *  Token 过期时间
     */
    var expiresIn: TimeInterval? {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.double(forKey: expiresInIdentity)
        }

        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: expiresInIdentity)
        }
    }

    /**
     *  userId
     */
    var userId: String? {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: userIdIdentity)
        }

        set {
            let userDefaults = UserDefaults.standard
            userDefaults.set(newValue, forKey: userIdIdentity)
        }
    }

    func reset() {
        token = nil
        openid = nil
        expiresIn = nil
        userId = nil
    }
}
