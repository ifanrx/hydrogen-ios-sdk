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

    private static var _internalUser: User?

    @objc public static var currentUser: User? {
        get {
            if User._internalUser != nil {
                return User._internalUser
            } else {
                let userDefaults = UserDefaults.standard
                if let userData = userDefaults.object(forKey: "com.ifanr.current.user") as? Data {
                    if let user = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(userData) as? User {
                        User._internalUser = user
                        return user
                    }
                }
            }
            return nil
        }

        set {
            User._internalUser = newValue
            let userDefaults = UserDefaults.standard
            if let user = newValue {
                if #available(iOS 11.0, *) {
                    let userData = try? NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
                    userDefaults.set(userData, forKey: "com.ifanr.current.user")
                } else {
                    let userData = NSKeyedArchiver.archivedData(withRootObject: user)
                    userDefaults.set(userData, forKey: "com.ifanr.current.user")
                }
            } else {
                userDefaults.set(nil, forKey: "com.ifanr.current.user")
            }
        }
    }

    /**
     *  用户 ID
     */
    @objc public var Id: Int = -1

    /**
     *  用户昵称
     */
    @objc public var nickname: String?

    /**
     *  性别
     *  -1: 未知
     *   0: 男
     *   1: 女
     */
    @objc public var gender: Int = -1

    /**
     *  国家
     */
    @objc public var country: String?

    /**
     *  省
     */
    @objc public var province: String?

    /**
     *  城市
     */
    @objc public var city: String?

    /**
     *  语言
     */
    @objc public var language: String?

    /**
     *  openid
     */
    @objc public var openid: String?

    /**
     *  unionid
     */
    @objc public var unionid: String?

    /**
     *  用户头像 URL
     */
    @objc public var avatar: String?

    /**
     *  用户信息
     */
    @objc public var userInfo: [String: Any] = [:]

    /**
     *  是否授权
     */

    @objc public var isAuthorized: Bool = false

    /**
     *  用户名
     */
    @objc public var username: String?

    /**
     *  用户手机号
     */
    @objc public var phone: String?

    /**
     *  用户邮箱
     */
    @objc public var email: String?

    /**
     *  用户 Token
     */
    @objc public var token: String?

    /**
     *  邮箱是否验证
     */
    @objc public var emailVerified: Bool = false

    /**
     *
     */
    @objc public var provider: [String: Any]?

    /**
     *  创建者的 ID
     */
    @objc public var createdById: Int = 0

    /**
     *  创建者的信息
     */
    @objc public var createdBy: [String: Any]?

    /**
     *  创建时间
     */
    @objc public var createdAt: TimeInterval = 0

    /**
     *  更新时间
     */
    @objc public var updatedAt: TimeInterval = 0

    /**
     *  Token 过期时间
     */
    @objc public var expiresIn: TimeInterval = 0

    @objc open var hadLogin: Bool {

        if let user = User.currentUser, user.token != nil, user.expiresIn > Date().timeIntervalSince1970 {
            return true
        }
        return false
    }

    convenience required public init?(coder aDecoder: NSCoder) {
        self.init()

        forEachChildOfMirror(reflecting: self) { key in
            setValue(aDecoder.decodeObject(forKey: key), forKey: key)
        }
    }

    open func encode(with aCoder: NSCoder) {
        forEachChildOfMirror(reflecting: self) { key in
            aCoder.encode(value(forKey: key), forKey: key)
        }
    }

    func forEachChildOfMirror(reflecting subject: Any, handler: (String) -> Void) {
        var mirror: Mirror? = Mirror(reflecting: subject)
        while mirror != nil {
            for child in mirror!.children {
                if let key = child.label {
                    handler(key)
                }
            }

            // Get super class's properties.
            mirror = mirror!.superclassMirror
        }
    }

    override open func setNilValueForKey(_ key: String) {
        if value(forKey: key) is Int || value(forKey: key) is Bool || value(forKey: key) is Double {
            self.setValue(NSNumber.init(value: 0), forKey: key)
        } else {
            super.setNilValueForKey(key)
        }
    }

    @objc public func get(key: String) -> Any? {
        return userInfo[key]
    }

    // 获取当前用户
    @discardableResult
    @objc open func getCurrentUserInfo(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

        let request = UserProvider.request(.getUserInfo(userId: User.currentUser!.Id)) { result in
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
    @objc open func resetPassword(email: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

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
    @objc open func updateUsername(_ username: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

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
    @objc open func updateEmail(_ email: String, sendVerification: Bool = false, completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

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
    @objc open func updatePassword(_ password: String, newPassword: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

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
    @objc open func updateUserInfo(_ userInfo: [String: Any], completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

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
    @objc open func requestEmailVerification(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard (User.currentUser?.hadLogin)! else {
            completion(false, HError.init(code: 604))
            return nil
        }

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
