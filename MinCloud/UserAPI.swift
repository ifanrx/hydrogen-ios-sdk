//
//  UserAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum UserAPI {
    case getUserInfo(userId: String, parameters: [String: Any])
    case updateAccount(parameters: [String: Any])
    case updateUserInfo(parameters: [String: Any])
    case resetPassword(parameters: [String: Any])
    case requestEmailVerify
    case getUserList(parameters: [String: Any])
    case verifyPhone(parameters: [String: Any])
}

extension UserAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .getUserInfo(let userId, _):
            return Config.User.getUserInfo(userId: userId)
        case .updateAccount:
            return Config.User.updateAccount
        case .updateUserInfo:
            return Config.User.updateUserInfo
        case .resetPassword:
            return Config.User.resetPassword
        case .requestEmailVerify:
            return Config.User.requestEmailVerify
        case .getUserList:
            return Config.User.getUserList
        case .verifyPhone:
            return Config.User.verifyPhone
        }
    }

    var method: Moya.Method {
        switch self {
        case .getUserInfo, .getUserList:
            return .get
        case .resetPassword, .requestEmailVerify, .verifyPhone:
            return .post
        case .updateAccount, .updateUserInfo:
            return .put
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .requestEmailVerify:
            return .requestPlain
        case .updateAccount(let parameters), .resetPassword(let parameters), .updateUserInfo(let parameters), .verifyPhone(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getUserList(let parameters), .getUserInfo(_, let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
