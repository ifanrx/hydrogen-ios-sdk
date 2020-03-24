//
//  ResultHandler.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/28.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

protocol Mappable {
    init?(dict: [String: Any])
}

class ResultHandler {

    static func parse<T: Mappable>(_ result: Result<Moya.Response, MoyaError>, handler: (T?, NSError?) -> Void) {
        switch result {
        case .success(let response):
            if response.statusCode == 401 {
                Storage.shared.reset()
            }

            if response.statusCode >= 200 && response.statusCode <= 299 {
                if let data = try? response.mapJSON(), let dict = data as? [String: Any] {
                    let model = T.init(dict: dict)
                    handler(model, nil)
                } else {
                    handler(nil, nil)
                }
            } else if let data = try? response.mapJSON(), let dict = data as? [String: Any] { // 内部定义网络错误
                let errorMsg = dict.getString("error_msg") ?? dict.getString("message")
                let error = HError(code: response.statusCode, description: errorMsg)
                handler(nil, error as NSError)
            } else if let message = try? response.mapString() {
                let error = HError(code: response.statusCode, description: message)
                handler(nil, error as NSError)
            } else {
                let error = HError(code: response.statusCode, description: nil)
                handler(nil, error as NSError)
            }
        case .failure(let error):
            handler(nil, error as NSError)
        }
    }
}

extension Bool: Mappable {
    init?(dict: [String: Any]) {
        self = true
    }
}

struct MappableDictionary: Mappable {
    var value: [String: Any]
    init?(dict: [String: Any]) {
        self.value = dict
    }
}
