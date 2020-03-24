//
//  AuthAPIManager.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum AuthAPI {
    case register(AuthType, [String: Any])
    case login(AuthType, [String: Any])
    case logout
    case apple([String: Any])
    case wechat([String: Any])
    case weibo([String: Any])
    case sms([String: Any])
    case associationForWechat([String: Any])
    case associationForWeibo([String: Any])
    case associationForApple([String: Any])
}

extension AuthAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .register(let authType, _):
            return Config.Auth.register(authType: authType)
        case .login(let authType, _):
            return Config.Auth.login(authType: authType)
        case .logout:
            return Config.Auth.logout
        case .apple:
            return Config.Auth.apple
        case .wechat:
            return Config.Auth.wechat
        case .weibo:
            return Config.Auth.weibo
        case .associationForWeibo:
            return Config.Auth.weiboAssociation
        case .associationForWechat:
            return Config.Auth.wechatAssociation
        case .associationForApple:
            return Config.Auth.appleAssociation
        case .sms:
            return Config.Auth.loginSms
        }
    }

    var method: Moya.Method {
        return .post
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .register(_, let parameters), .login(_, let parameters), .apple(let parameters), .wechat(let parameters), .weibo(let parameters), .associationForApple(let parameters), .associationForWechat(let parameters), .associationForWeibo(let parameters), .sms(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .logout:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
