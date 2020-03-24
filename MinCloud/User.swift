//
//  User.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/4/9.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya

@objc(BaaSUser)
open class User: BaseRecord {
    
    static var UserProvider = MoyaProvider<UserAPI>(plugins: logPlugin)

    /**
     * 用户 Id
     */
    @objc public internal(set) var userId: String?

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
    
    /**
     * 是否匿名
     */
    @objc public internal(set) var isAnonymous: Bool = false
    
    /**
     *  用户信息
     */
    @objc public var userInfo: [String: Any] = [:]

    @objc public init(Id: String) {
        self.userId = Id
        super.init()
        self.Id = String(Id)
        self.userInfo["id"] = Id
    }

    @objc required public init?(dict: [String: Any]) {
        let Id = dict.getString("id", "user_id")
        self.userId = Id
        self.email = dict.getString("_email")
        self.avatar = dict.getString("avatar")
        self.isAuthorized = dict.getBool("is_authorized")
        self.username = dict.getString("_username")
        self.nickname = dict.getString("nickname")
        self.gender = dict.getInt("gender")
        self.country = dict.getString("country")
        self.province = dict.getString("province")
        self.city = dict.getString("city")
        self.language = dict.getString("language")
        self.unionid = dict.getString("unionid")
        self.emailVerified = dict.getBool("_email_verified")
        self.provider = dict.getDict("_provider") as? [String: Any]
        self.isAnonymous = dict.getBool("_anonymous")
        self.userInfo = dict
        super.init(dict: dict)
    }

    @objc override open var description: String {
        let dict = self.userInfo
        return dict.toJsonString
    }
    
    @objc override open var debugDescription: String {
        let dict = self.userInfo
        return dict.toJsonString
    }

    /// 通过 字段名 获取用户信息
    ///
    /// - Parameter key: 字段名称
    /// - Returns: 
    @objc public func get(_ key: String) -> Any? {
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
            ResultHandler.parse(result, handler: { (listResult: UserList?, error: NSError?) in
                completion(listResult, error)
            })
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
    @objc public static func get(_ userId: String, select: [String]? = nil, expand: [String]? = nil, completion:@escaping UserResultCompletion) -> RequestCanceller? {

        var parameters: [String: String] = [:]
        if let select = select {
            parameters["keys"] = select.joined(separator: ",")
        }
        if let expand = expand {
            parameters["expand"] = expand.joined(separator: ",")
        }
        let request = UserProvider.request(.getUserInfo(userId: userId, parameters: parameters)) { result in
            ResultHandler.parse(result, handler: { (user: User?, error: NSError?) in
                completion(user, error)
            })
        }
        return RequestCanceller(cancellable: request)
    }
}
