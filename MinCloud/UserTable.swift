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

@objc(BAASUserTable)
open class UserTable: BaseQuery {

    /// 查询用户
    ///
    /// - Parameter completion: 结果回调
    /// - Returns:
    @discardableResult
    @objc open func find(_ completion:@escaping UsersResultCompletion) -> RequestCanceller? {
        guard User.currentUser != nil else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = UserProvider.request(.getUserList(parameters: queryArgs)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (usersInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
            if error != nil {
                completion(nil, error)
            } else {
                let user = ResultHandler.dictToUsers(dict: usersInfo)
                completion(user, nil)
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
    @objc open func get(_ userId: Int, completion:@escaping UserResultCompletion) -> RequestCanceller? {
        guard User.currentUser != nil else {
            completion(nil, HError.init(code: 604))
            return nil
        }

        let request = UserProvider.request(.getUserInfo(userId: userId)) { [weak self] result in
            guard let strongSelf = self else { return }
            let (userInfo, error) = ResultHandler.handleResult(clearer: strongSelf, result: result)
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
