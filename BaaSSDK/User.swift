//
//  UserInfo.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya
import Result

public class UserRecord {
    public init() {}
    var allRequests: [Cancellable] = []

    open var userId: String?
    open var username: String?
    open var phone: String?
    open var email: String?
    open var token: String?

    public func resetPassword(completion: @escaping BOOLResultHandler) {
        let request = userProvider.request(.resetPassword(parameters: ["email": UserStorge.email!])) { result in
            self.handleBoolResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    public func updateUsername(username: String, completion: @escaping OBJECTResultHandler) {
        let request = userProvider.request(.updateAccount(parameters: ["username": username])) { result in
            self.handleObjectResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    public func updateEmail(email: String, sendVerification: Bool = false, completion: @escaping OBJECTResultHandler) {
        let request = userProvider.request(.updateAccount(parameters: ["email": email])) { result in
            self.handleObjectResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    public func updatePassword(password: String, newPassword: String, completion: @escaping OBJECTResultHandler) {
        let request = userProvider.request(.updateAccount(parameters: ["password": password, "new_password": newPassword])) { result in
            self.handleObjectResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    public func updateUserInfo(userInfo: [String: Any], completion: @escaping OBJECTResultHandler) {
        let request = userProvider.request(.updateUserInfo(parameters: userInfo)) { result in
            self.handleObjectResult(result: result, completion: completion)
        }
        allRequests.append(request)
    }

    public func requestEmailVerification(completion: @escaping BOOLResultHandler) {
        let request = userProvider.request(.requestEmailVerify) { result in
            self.handleBoolResult(result: result, completion: completion)
        }
        allRequests.append(request)
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

    fileprivate func handleBoolResult(result: Result<Moya.Response, MoyaError>, completion: BOOLResultHandler) {
        if case let .success(response) = result {
            let data = try? response.mapJSON()
            print("response = \(String(describing: data))")
            if response.statusCode >= 200 && response.statusCode <= 299 {
                completion(true, nil)
            } else {
                let dict = data as? NSDictionary
                let errorMsg = dict?.getString("error_msg")
                completion(false, HError(code: HError.InternalErrorCode(rawValue: response.statusCode)!, errorDescription: errorMsg))
            }
        } else if case let .failure(error) = result {
            completion(false, error)
        }
    }
}
