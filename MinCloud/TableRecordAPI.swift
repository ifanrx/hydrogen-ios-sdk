//
//  TableRecordAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum TableRecordAPI {
    case save(tableId: String, parameters: [String: Any])
    case update(tableId: String, recordId: String, parameters: [String: Any])
    case delete(tableId: String, recordId: String)
}

extension TableRecordAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .save(let tableId, _):
            return Config.Table.saveRecord(tableId: tableId)
        case .update(let tableId, let recordId, _):
            return Config.Table.recordDetail(tableId: tableId, recordId: recordId)
        case .delete(let tableId, let recordId):
            return Config.Table.recordDetail(tableId: tableId, recordId: recordId)
        }
    }

    var method: Moya.Method {
        switch self {
        case .update:
            return .put
        case .delete:
            return .delete
        case .save:
            return .post
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .update(_, _, let parameters), .save(_, let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .delete:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
