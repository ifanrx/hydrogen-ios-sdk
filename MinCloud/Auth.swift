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

@objc(BAASAuth)
open class Auth: NSObject {
    // MARK: - 注册

    /// 用户名注册
    ///
    /// - Parameters:
    ///   - username: 用户名
    ///   - password: 密码
    ///   - completion: 注册回调结果
    @discardableResult
    @objc public static func register(username: String, password: String, completion: @escaping UserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.register(.username, ["username": username, "password": password])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUser(dict: userInfo)
                completion(user, nil)
            }
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
    @objc public static func register(email: String, password: String, completion: @escaping UserResultCompletion) -> RequestCanceller {
        let request =  AuthProvider.request(.register(.email, ["email": email, "password": password])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUser(dict: userInfo)
                completion(user, nil)
            }
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
    @objc public static func login(username: String, password: String, completion: @escaping UserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.username, ["username": username, "password": password])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUser(dict: userInfo)
                completion(user, nil)
            }
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
    @objc public static func login(email: String, password: String, completion: @escaping UserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.email, ["email": email, "password": password])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUser(dict: userInfo)
                completion(user, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 匿名登录
    ///
    /// - Parameter completion: 登录结果回调
    @discardableResult
    @objc public static func anonymousLogin(_ completion: @escaping UserResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.login(.anonymous, [:])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUser(dict: userInfo)
                completion(user, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 用户登出
    ///
    /// - Parameter completion: 登出结果回调
    @discardableResult
    @objc public static func logout(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = AuthProvider.request(.logout) { result in
            let (_, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else {
                User.currentUser = nil
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
