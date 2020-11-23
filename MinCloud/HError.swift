//
//  HError.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/18.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation

struct HError: CustomNSError {

    var code: Int
    var kind: ErrorKind!
    var description: String?

    enum ErrorKind: Int {
        case badRequest             = 400
        case unauthorized           = 401
        case paymentRequired        = 402
        case forbidden              = 403
        case notFound               = 404
        case internalServerError    = 500
        case unknownError           = 520
        case networkDisconnected    = 600
        case requestTimeout         = 601
        case unintialized           = 602
        case userUnauthorized       = 603
        case sessionMissing         = 604
        case incorrectParameterType = 605
        case paymentCancelled       = 607
        case paymentFailed          = 608
        case paying                 = 609
        case orderInfoError         = 610
    }

    init(code: Int, description: String? = nil) {
        self.code = code
        self.kind = HError.ErrorKind(rawValue: code)
        if let description = description, description != "" {
            self.description = description
        }
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.code = kind.rawValue
        self.kind = kind
        if let description = description, description != "" {
            self.description = description
        }
    }
    
    // wamp error
    init(reason: String) {
        switch reason {
        case "wamp.close.session_destory":
            code = 401
        case "wamp.close.disable_connection":
            code = 402
        case "wamp.close.server_erro":
            code = 500
        case "wamp.error.not_authorized":
            code = 401
        case "wamp.error.invalid_message":
            code = 400
            description = "invalid message"
        case "wamp.error.duplicate_subscription":
            code = 400
            description = "duplicate subscription"
        case "wamp.error.invalid_topic_format":
            code = 400
            description = "invalid topic format"
        case "wamp.error.invalid_event":
            code = 400
            description = "invalid event"
        case "not_allow_to_subscribe_builtin_schema":
            code = 400
            description = "not allow to subscribe builtin schema"
        case "wamp.error.schema_does_not_exists":
            code = 400
            description = "schema does not exists"
        case "wamp.error.connection_timeout":
            code = 601
            description = "request timeout"
        case "wamp.error.invalid_options":
            code = 400
            description = "invalid options"
        case "wamp.error.no_such_subscription":
            code = 400
            description = "no such subscription"
        default:
            code = 520
        }
        kind = HError.ErrorKind(rawValue: code)!
    }

    static var errorDomain: String = "baas.ifanr.error.domain"
    var errorCode: Int {
        switch self.kind {
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
        case .unknownError:
            return 520
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
        case .paying?:
            return 609
        case .orderInfoError?:
            return 610
        default:
            return self.code
        }
    }

    var errorUserInfo: [String: Any] {
        var description: String = self.description ?? "unknown"
        switch self.kind {
        case .badRequest?:
            description = self.description ?? "bad request"
        case .unauthorized?:
            description = self.description ?? "unauthorized"
        case .paymentRequired?:
            description = self.description ?? "payment required"
        case .forbidden?:
            description = self.description ?? "forbidden"
        case .notFound?:
            description = self.description ?? "not found"
        case .internalServerError?:
            description = self.description ?? "internal server error"
        case .networkDisconnected?:
            description = self.description ?? "network disconnected"
        case .requestTimeout?:
            description = self.description ?? "request timeout"
        case .unintialized?:
            description = self.description ?? "unintialized"
        case .userUnauthorized?:
            description = self.description ?? "user unauthorized"
        case .sessionMissing?:
            description = self.description ?? "session missing"
        case .incorrectParameterType?:
            description = self.description ?? "incorrect parameter type"
        case .paymentCancelled?:
            description = self.description ?? "payment cancelled"
        case .paymentFailed?:
            description = self.description ?? "payment failed"
        case .paying?:
            description = self.description ?? "paying now, please wait"
        case .orderInfoError?:
            description = self.description ?? "order info error"
        case .unknownError:
            description = self.description ?? "unknown error"
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
