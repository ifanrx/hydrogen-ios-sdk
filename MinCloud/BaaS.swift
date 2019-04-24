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

    @discardableResult
    @objc public static func invoke(name: String, data: Any, sync: Bool, completion: @escaping OBJECTResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.invokeFunction(parameters: ["function_name": name, "data": data, "sync": sync])) { result in
            let (resultInfo, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(nil, error)
            } else {
                completion(resultInfo, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc public static func sendSmsCode(phone: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.sendSmsCode(parameters: ["phone": phone])) { result in
            let (_, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }

    @discardableResult
    @objc public static func verifySmsCode(phone: String, code: String, completion: @escaping BOOLResultCompletion) -> RequestCanceller {
        let request = BaasProvider.request(.verifySmsCode(parameters: ["phone": phone, "code": code])) { result in
            let (_, error) = ResultHandler.handleResult(result)
            if error != nil {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
        return RequestCanceller(cancellable: request)
    }
}
