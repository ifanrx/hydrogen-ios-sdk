//
//  User.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/22.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc(BaaSUserManager)
open class UserManager: NSObject {

    /// 查询用户
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func find(query: Query? = nil, completion:@escaping UserListResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = UserProvider.request(.getUserList(parameters: queryArgs)) { result in
            let (usersInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let userListResult = ResultHandler.dictToUserListResult(dict: usersInfo)
                completion(userListResult, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    /// 获取用户详细信息
    ///
    /// - Parameters:
    ///   - userId: 用户 Id
    ///   - completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc open func get(_ userId: Int, query: Query? = nil, completion:@escaping UserResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let queryArgs: [String: Any] = query?.queryArgs ?? [:]
        let request = UserProvider.request(.getUserInfo(userId: userId, parameters: queryArgs)) { result in
            let (userInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUser(dict: userInfo)
                completion(user, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    // 获取当前用户
    @discardableResult
    @objc open func getCurrentUserInfo(_ completion: @escaping CurrentUserResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin && Storage.shared.userId != nil else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = UserProvider.request(.getUserInfo(userId: Storage.shared.userId!, parameters: [:])) { result in
            let (userInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            }
            let user = ResultHandler.dictToCurrentUser(dict: userInfo)
            completion(user, nil)
        }
        return RequestCanceller(cancellable: request)
    }

}
