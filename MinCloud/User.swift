//
//  User.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/4/9.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit

@objc(BaaSUser)
open class User: BaseRecord {

    /**
     * 用户 Id
     */
    @objc public internal(set) var userId: Int64

    /**
     *  用户昵称
     */
    @objc public internal(set) var nickname: String?

    /**
     *  性别
     *  -1: 未知
     *   0: 男
     *   1: 女
     */
    @objc public internal(set) var gender: Int = -1

    /**
     *  国家
     */
    @objc public internal(set) var country: String?

    /**
     *  省
     */
    @objc public internal(set) var province: String?

    /**
     *  城市
     */
    @objc public internal(set) var city: String?

    /**
     *  语言
     */
    @objc public internal(set) var language: String?

    /**
     *  unionid
     */
    @objc public internal(set) var unionid: String?

    /**
     *  用户头像 URL
     */
    @objc public internal(set) var avatar: String?

    /**
     *  用户信息
     */
    @objc public internal(set) var userInfo: [String: Any] = [:]

    /**
     *  是否授权
     */

    @objc public internal(set) var isAuthorized: Bool = false

    /**
     *  用户名
     */
    @objc public internal(set) var username: String?

    /**
     *  用户手机号
     */
    @objc public internal(set) var phone: String?

    /**
     *  用户邮箱
     */
    @objc public internal(set) var email: String?

    /**
     *  邮箱是否验证
     */
    @objc public internal(set) var emailVerified: Bool = false

    /**
     *
     */
    @objc public internal(set) var provider: [String: Any]?

    init(Id: Int64) {
        self.userId = Id
        super.init()
        self.Id = String(Id)
    }

    /// 通过 字段名 获取用户信息
    ///
    /// - Parameter key: 字段名称
    /// - Returns: 
    @objc public func get(key: String) -> Any? {
        return userInfo[key]
    }

    /// 查询用户
    ///
    /// - Parameters:
    ///   - query: 查询条件，可选
    ///   - completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc public static func find(query: Query? = nil, completion:@escaping UserListResultCompletion) -> RequestCanceller? {

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
    @objc public static func get(_ userId: Int64, select: [String]? = nil, expand: [String]? = nil, completion:@escaping UserResultCompletion) -> RequestCanceller? {

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
