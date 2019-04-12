//
//  BaaS.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc public class BaaS: NSObject {
    @objc public static func register(clientID: String) {
        Config.clientID = clientID
    }

    @objc public static var isDebug: Bool = false

    @objc public static func invoke(name: String, data: Any, sync: Bool, completion: @escaping OBJECTResultCompletion) {
        BaasProvider.request(.invokeFunction(parameters: ["function_name": name, "data": data, "sync": sync])) { result in
            if case let .success(response) = result {
                let data = try? response.mapJSON()
                print("response = \(String(describing: data))")
                if response.statusCode >= 200 && response.statusCode <= 299 {
                    let dict = data as? [String: Any]
                    completion(dict, nil)
                } else {
                    let dict = data as? NSDictionary
                    let errorMsg = dict?.getString("error_msg")
                    completion(nil, HError(code: response.statusCode, description: errorMsg) as NSError)
                }
            } else if case let .failure(error) = result {
                completion(nil, error as NSError)
            }
        }
    }
}
