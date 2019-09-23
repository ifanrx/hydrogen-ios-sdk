//
//  BaaSAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/26.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum BaaSAPI {
    case invokeFunction(parameters: [String: Any])
    case sendSmsCode(parameters: [String: Any])
    case verifySmsCode(parameters: [String: Any])
}

extension BaaSAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .invokeFunction:
            return Config.BaaS.cloudFunction
        case .sendSmsCode:
            return Config.BaaS.sendSmsCode
        case .verifySmsCode:
            return Config.BaaS.verifySmsCode
        }
    }

    var method: Moya.Method {
        switch self {
        case .invokeFunction, .sendSmsCode, .verifySmsCode:
            return .post
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .invokeFunction(let parameters), .sendSmsCode(let parameters), .verifySmsCode(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
