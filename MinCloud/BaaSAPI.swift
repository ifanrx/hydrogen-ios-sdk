//
//  BaaSAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/26.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

let BaasProvider = MoyaProvider<BaaSAPI>()

enum BaaSAPI {
    case invokeFunction(parameters: [String: Any])
}

extension BaaSAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .invokeFunction:
            return Config.cloudFunction
        }
    }

    var method: Moya.Method {
        switch self {
        case .invokeFunction:
            return .post
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .invokeFunction(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
