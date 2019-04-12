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

@objc(BaaSCurrentUser)
open class CurrentUser: User {

    override init(Id: Int64) {
        super.init(Id: Id)
    }

    /// 使用邮件重置密码
    ///
    /// - Parameters:
    ///   - email: 用户已验证的邮箱地址
    ///   - completion: 结果回调
    @discardableResult
    @objc open func resetPassword(email: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(false, error as NSError)
            return nil
        }

        let request = UserProvider.request(.resetPassword(parameters: ["email": email])) { result in
            let (_, error) = ResultHandler.handleResult(result)
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
    @objc open func updateUsername(_ username: String, completion: @escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(nil, error as NSError)
            return nil
        }

        let request = UserProvider.request(.updateAccount(parameters: ["username": username])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(userInfo, nil)
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
    @objc open func updateEmail(_ email: String, sendVerification: Bool = false, completion: @escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(nil, error as NSError)
            return nil
        }

        let request = UserProvider.request(.updateAccount(parameters: ["email": email])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(userInfo, nil)
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
    @objc open func updatePassword(_ password: String, newPassword: String, completion: @escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(nil, error as NSError)
            return nil
        }

        let request = UserProvider.request(.updateAccount(parameters: ["password": password, "new_password": newPassword])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(userInfo, nil)
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
    @objc open func updateUserInfo(_ userInfo: [String: Any], completion: @escaping OBJECTResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(nil, error as NSError)
            return nil
        }

        let request = UserProvider.request(.updateUserInfo(parameters: userInfo)) { result in
            let (userInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(userInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 请求发送邮箱认证
    ///
    /// - Parameter completion: 结果回调
    @discardableResult
    @objc open func requestEmailVerification(_ completion: @escaping BOOLResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            let error = HError.init(code: 604, description: "please login in")
            printErrorInfo(error)
            completion(false, error as NSError)
            return nil
        }

        let request = UserProvider.request(.requestEmailVerify) { result in
            let (_, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
