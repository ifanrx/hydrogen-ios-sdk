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
    @objc public internal(set) var userId: Int

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

    init(Id: Int) {
        self.userId = Id
        super.init()
    }
}
