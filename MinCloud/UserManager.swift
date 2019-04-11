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
        /// - Parameters:
        ///   - query: 查询条件，可选
        ///   - completion: 结果回调
        /// - Returns:
        @discardableResult
    @objc public static func find(query: Query? = nil, completion:@escaping UserListResultCompletion) -> RequestCanceller? {
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
    ///   - select: 筛选字段
    ///   - expand: 扩展字段
    ///   - completion: 结果回调
    /// - Returns: 
    @discardableResult
    @objc public static func get(_ userId: Int, select: [String]? = nil, expand: [String]? = nil, completion:@escaping UserResultCompletion) -> RequestCanceller? {
        guard Auth.hadLogin else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        if let expand = expand {
            parameters["expand"] = expand.joined(separator: ",")
        }
        let request = UserProvider.request(.getUserInfo(userId: userId, parameters: parameters)) { result in
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

}
