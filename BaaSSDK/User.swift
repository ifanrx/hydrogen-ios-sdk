//
//  UserInfo.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc(BAASUser)
open class User: NSObject, NSCoding {
    @objc public static var currentUser: User?
    /**
     *  用户 ID
     */
    @objc open var userId: Int = -1

    /**
     *  用户昵称
     */
    @objc open var nickname: String?

    /**
     *  性别
     *  -1: 未知
     *   0: 男
     *   1: 女
     */
    @objc open var gender: Int = -1

    /**
     *  国家
     */
    @objc open var country: String?

    /**
     *  省
     */
    @objc open var province: String?

    /**
     *  城市
     */
    @objc open var city: String?

    /**
     *  语言
     */
    @objc open var language: String?

    /**
     *  openid
     */
    @objc open var openid: String?

    /**
     *  unionid
     */
    @objc open var unionid: String?

    /**
     *  用户头像 URL
     */
    @objc open var avatar: String?

    /**
     *  用户信息
     */
    @objc open var userInfo: [String: Any] = [:]

    /**
     *  是否授权
     */

    @objc open var isAuthorized: Bool = false

    /**
     *  用户名
     */
    @objc open var username: String?

    /**
     *  用户手机号
     */
    @objc open var phone: String?

    /**
     *  用户邮箱
     */
    @objc open var email: String?

    /**
     *  用户 Token
     */
    @objc open var token: String?

    /**
     *  邮箱是否验证
     */
    @objc open var emailVerified: Bool = false

    /**
     *
     */
    @objc open var provider: [String: Any]?

    /**
     *  创建者
     */
    @objc open var createdBy: Int = -1

    /**
     *  创建时间
     */
    @objc open var createdAt: TimeInterval = -1

    /**
     *  更新时间
     */
    @objc open var updatedAt: TimeInterval = -1

    /**
     *  Token 过期时间
     */
    @objc open var expiresIn: TimeInterval = -1

    @objc open var hadLogin: Bool {
        return false
    }

    convenience required public init?(coder aDecoder: NSCoder) {
        self.init()

        for child in Mirror(reflecting: self).children {
            if let key = child.label {
                setValue(aDecoder.decodeObject(forKey: key), forKey: key)
            }
        }
    }

    public func encode(with aCoder: NSCoder) {
        for child in Mirror(reflecting: self).children {
            if let key = child.label {
                aCoder.encode(value(forKey: key))
            }
        }
    }

    @objc public func get(key: String) -> Any? {
        return userInfo[key]
    }

    // 获取当前用户
    @discardableResult
    func getCurrentUserInfo(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.getUserInfo(userId: User.currentUser!.userId)) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            }
            if let userInfo = userInfo {
                User.currentUser?.userInfo = userInfo
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 使用邮件重置密码
    ///
    /// - Parameters:
    ///   - email: 用户已验证的邮箱地址
    ///   - completion: 结果回调
    @discardableResult
    @objc open func resetPassword(email: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.resetPassword(parameters: ["email": email])) { result in
            let (_, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 更新用户名
    ///
    /// - Parameters:
    ///   - username: 新的用户名，不能和旧用户一样
    ///   - completion: 结果回调
    @discardableResult
    @objc open func updateUsername(username: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.updateAccount(parameters: ["username": username])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else if let userInfo = userInfo {
                User.currentUser?.username = userInfo.getString("username")
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 更新用户邮箱地址
    ///
    /// - Parameters:
    ///   - email: 用户邮箱地址
    ///   - sendVerification: 是否发送邮箱认证
    ///   - completion: 结果回调
    @discardableResult
    @objc open func updateEmail(email: String, sendVerification: Bool = false, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.updateAccount(parameters: ["email": email])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else if let userInfo = userInfo {
                User.currentUser?.email = userInfo.getString("email")
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 更新用户密码
    ///
    /// - Parameters:
    ///   - password: 旧的用户密码
    ///   - newPassword: 新的用户密码
    ///   - completion: 结果回调
    @discardableResult
    @objc open func updatePassword(password: String, newPassword: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.updateAccount(parameters: ["password": password, "new_password": newPassword])) { result in
            let (_, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 更新自定义用户信息
    ///
    /// - Parameters:
    ///   - userInfo: 用户信息
    ///   - completion: 结果回调
    @discardableResult
    @objc open func updateUserInfo(userInfo: [String: Any], completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.updateUserInfo(parameters: userInfo)) { result in
            let (userInfo, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else if let userInfo = userInfo {
                User.currentUser?.userInfo.merge(userInfo)
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 请求发送邮箱认证
    ///
    /// - Parameter completion: 结果回调
    @discardableResult
    @objc open func requestEmailVerification(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = UserProvider.request(.requestEmailVerify) { result in
            let (_, error) = ResultHandler.handleResult(result: result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
