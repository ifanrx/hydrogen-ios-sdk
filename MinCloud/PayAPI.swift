//
//  PayAPI.swift
//  MinCloud
//
//  Created by pengquanhua on 2019/5/14.
//  Copyright © 2019 ifanr. All rights reserved.
//

import UIKit
import Moya

enum PayAPI {
    case pay(parameters: [String: Any])
    case order(transactionID: String)
    case orderList(parameters: [String: Any])
}

extension PayAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .pay:
            return Config.Pay.pay
        case .order(let transactionID):
            return Config.Pay.order(transactionID: transactionID)
        case .orderList:
            return Config.Pay.orderList
        }
    }

    var method: Moya.Method {
        switch self {
        case .pay:
            return .post
        case .order, .orderList:
            return .get
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .pay(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .order:
            return .requestPlain
        case .orderList(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
