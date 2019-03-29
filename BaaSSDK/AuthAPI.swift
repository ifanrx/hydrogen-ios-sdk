//
//  AuthAPIManager.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

let AuthProvider = MoyaProvider<AuthAPIManager>()

enum AuthAPIManager {
    case register([String:Any])
    case login([String:Any])
}

extension AuthAPIManager: TargetType {
    var baseURL: URL {
        return URL(string: "https://viac2-p.eng-vm.can.corp.ifanr.com")!
    }
    
    var path: String {
        switch self {
        case .register(_):
            return "/hserve/v2.0/register/"
        case .login(_):
            return "/hserve/v2.0/login/"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register(_), .login(_):
            return .post
        }
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .register(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        case .login(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.httpBody)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/json", "X-Hydrogen-Client-ID":"f86c122f10f45d1152a1", "X-Hydrogen-Client-SDK-Type":"ios", "X-Hydrogen-Client-Version": "1.0.0"]
    }
}
