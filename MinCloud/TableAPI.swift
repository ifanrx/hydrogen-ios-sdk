//
//  TableAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/22.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum TableAPI {
    case get(tableId: String, recordId: String, parameters: [String: Any])
    case find(tableId: String, parameters: [String: Any])
    case delete(tableId: String, parameters: [String: Any])
    case createRecords(tableId: String, recordData: Data, parameters: [String: Any])
    case update(tableId: String, urlParameters: [String: Any], bodyParameters: [String: Any])
}

extension TableAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .get(let tableId, let recordId, _):
            return Config.Table.recordDetail(tableId: tableId, recordId: recordId)
        case .find(let tableId, _):
            return Config.Table.recordList(tableId: tableId)
        case .delete(let tableId, _):
            return Config.Table.recordList(tableId: tableId)
        case .createRecords(let tableId, _, _):
            return Config.Table.recordList(tableId: tableId)
        case .update(let tableId, _, _):
            return Config.Table.recordList(tableId: tableId)
        }
    }

    var method: Moya.Method {
        switch self {
        case .get, .find:
            return .get
        case .delete:
            return .delete
        case .createRecords:
            return .post
        case .update:
            return .put
        }
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .get(_, _, let parameters), .find(_, let parameters), .delete(tableId: _, let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .createRecords(_, let recordData, let parameters):
                return .requestCompositeData(bodyData: recordData, urlParameters: parameters)
        case .update(_, let urlParameters, let bodyParametes):
            return .requestCompositeParameters(bodyParameters: bodyParametes, bodyEncoding: JSONEncoding.default, urlParameters: urlParameters)
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
