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
        }
    }

    var method: Moya.Method {
        switch self {
        case .register, .login, .logout:
            return .post
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .register(_, let parameters), .login(_, let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .logout:
            return .requestParameters(parameters: [:], encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
