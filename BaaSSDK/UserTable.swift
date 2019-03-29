//
//  User.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/22.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

@objc public class User: BaseQuery {
    var allRequests: [Cancellable] = []

    // TODO: 批量查询用户
    public func find(completion:@escaping OBJECTResultHandler) {
        let request = userProvider.request(.getUserList(parameters: queryArgs)) { result in
            self.handleObjectResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    public func get(userId: Int, completion:@escaping OBJECTResultHandler) {
        let request = userProvider.request(.getUserInfo(userId: userId)) { result in
            self.handleObjectResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    // 获取当前用户
    public func getCurrentUserInfo(completion: @escaping OBJECTResultHandler) {
        get(userId: UserStorge.userId!, completion: completion)
    }

    // MARK: - Private

    fileprivate func handleObjectResult(result: Result<Moya.Response, MoyaError>, completion: OBJECTResultHandler) {
        if case let .success(response) = result {
            let data = try? response.mapJSON()
            print("response = \(String(describing: data))")
            if response.statusCode >= 200 && response.statusCode <= 299 {
                let dict = data as? NSDictionary
                completion(dict, nil)
            } else {
                let dict = data as? NSDictionary
                let errorMsg = dict?.getString("error_msg")
                completion(nil, HError(code: HError.InternalErrorCode(rawValue: response.statusCode)!, errorDescription: errorMsg))
            }
        } else if case let .failure(error) = result {
            completion(nil, error)
        }
    }

}
