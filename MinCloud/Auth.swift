//
//  Auth.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc(BaaSAuth)
open class Auth: NSObject {

    /// 用户是否已经登录
    @objc public static var hadLogin: Bool {
        if Storage.shared.token != nil, let expiresIn = Storage.shared.expiresIn, expiresIn > Date().timeIntervalSince1970 {
            return true
        }
        return false
    }

    // MARK: - 注册

    /// 用户名注册
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - completion: 注册回调结果
    @discardableResult
    @objc public static func register(username: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.register(.username, ["username": username, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 邮箱注册
    ///
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - password: 密码
    ///   - completion: 注册回调结果
    @discardableResult
    @objc public static func register(email: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request =  AuthProvider.request(.register(.email, ["email": email, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // MARK: - 登录

    /// 用户名登录
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - completion: 登录回调结果
    @discardableResult
    @objc public static func login(username: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.username, ["username": username, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 邮箱登录
    ///
    /// - Parameters:
    ///   - email: 邮箱地址
    ///   - password: 密码
    ///   - completion: 登录结果回调
    @discardableResult
    @objc public static func login(email: String, password: String, completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.email, ["email": email, "password": password])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 匿名登录
    ///
    /// - Parameter completion: 登录结果回调
    @discardableResult
    @objc public static func anonymousLogin(_ completion: @escaping CurrentUserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.anonymous, [:])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                Storage.shared.userId = user?.userId
                Storage.shared.token = user?.token
                Storage.shared.expiresIn = user?.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }

    /// 用户登出
    ///
    /// - Parameter completion: 登出结果回调
    @discardableResult
    @objc public static func logout(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.logout) { result in
            ResultHandler.parse(result, handler: { (_: Bool?, error: NSError?) in
                if error != nil {
                    completion(false, error)
                } else {
                    Storage.shared.reset()
                    printDebugInfo("logout success!")
                    completion(true, nil)
                }
            })
        }
        return RequestCanceller(cancellable: request)
    }

    // 获取当前用户
    @discardableResult
    @objc public static func getCurrentUser(_ completion: @escaping CurrentUserResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin && Storage.shared.userId != nil else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(nil, error as NSError)
            return nil
        }

        let request = UserProvider.request(.getUserInfo(userId: Storage.shared.userId!, parameters: [:])) { result in
            ResultHandler.parse(result, handler: { (user: CurrentUser?, error: NSError?) in
                user?.token = Storage.shared.token
                user?.expiresIn = Storage.shared.expiresIn
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
