//
//  HError.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

public struct HError: CustomNSError {

    var code: Int
    var internalErrorCode: InternalErrorCode!
    var errorDescription: String?

    enum InternalErrorCode: Int {
        case badRequest             = 400
        case unauthorized           = 401
        case paymentRequired        = 402
        case forbidden              = 403
        case notFound               = 404
        case internalServerError    = 500
        case networkDisconnected    = 600
        case requestTimeout         = 601
        case unintialized           = 602
        case userUnauthorized       = 603
        case sessionMissing         = 604
        case incorrectParameterType = 605
        case paymentCancelled       = 607
        case paymentFailed          = 608
    }

    init(code: Int, errorDescription: String? = nil) {
        self.code = code
        self.internalErrorCode = HError.InternalErrorCode(rawValue: code)
        self.errorDescription = errorDescription
    }

    public static var errorDomain: String = "baas.ifanr.error.domain"
    public var errorCode: Int {
        switch self.internalErrorCode {
        case .badRequest?:
            return 400
        case .unauthorized?:
            return 401
        case .paymentRequired?:
            return 402
        case .forbidden?:
            return 403
        case .notFound?:
            return 404
        case .internalServerError?:
            return 500
        case .networkDisconnected?:
            return 600
        case .requestTimeout?:
            return 601
        case .unintialized?:
            return 602
        case .userUnauthorized?:
            return 603
        case .sessionMissing?:
            return 604
        case .incorrectParameterType?:
            return 605
        case .paymentCancelled?:
            return 607
        case .paymentFailed?:
            return 608
        default:
            return self.code
        }
    }

    public var errorUserInfo: [String: Any] {
        var description: String = self.errorDescription ?? ""
        switch self.internalErrorCode {
        case .badRequest?:
            description = self.errorDescription ?? "bad request"
        case .unauthorized?:
            description = self.errorDescription ?? "unauthorized"
        case .paymentRequired?:
            description = self.errorDescription ?? "payment required"
        case .forbidden?:
            description = self.errorDescription ?? "forbidden"
        case .notFound?:
            description = self.errorDescription ?? "not found"
        case .internalServerError?:
            description = self.errorDescription ?? "internal server error"
        case .networkDisconnected?:
            description = self.errorDescription ?? "network disconnected"
        case .requestTimeout?:
            description = self.errorDescription ?? "request timeout"
        case .unintialized?:
            description = self.errorDescription ?? "unintialized"
        case .userUnauthorized?:
            description = self.errorDescription ?? "user unauthorized"
        case .sessionMissing?:
            description = self.errorDescription ?? "session missing"
        case .incorrectParameterType?:
            description = self.errorDescription ?? "incorrect parameter type"
        case .paymentCancelled?:
            description = self.errorDescription ?? "payment cancelled"
        case .paymentFailed?:
            description = self.errorDescription ?? "payment failed"
        default:
            break
        }
        return [NSLocalizedDescriptionKey: description]
    }
}

func dPrint(_ item: Any) {
    #if DEBUG
    print("--------------------")
    print(item)
    print("--------------------")
    #endif
}

func printDebugInfo(_ item: Any) {
    if BaaS.isDebug {
        #if DEBUG
        print("-----BAAS SDK RESULT-----")
        print("result: \(item)")
        print("-------------------------")
        #endif
    }
}

func printErrorInfo(_ item: Any) {
    if BaaS.isDebug {
        #if DEBUG
        print("-----BAAS SDK ERROR-----")
        if let error = item as? NSError {
            print("code: \(error.code)")
            print("description: \(error.localizedDescription)")
        } else {
            print(item)
        }
        print("-------------------------")
        #endif
    }
}
