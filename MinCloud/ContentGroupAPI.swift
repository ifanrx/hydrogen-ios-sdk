//
//  ContentGroupAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

enum ContentGroupAPI {
    case conentDetail(id: String, parameters: [String: Any])
    case contentList(parameters: [String: Any]) // 某个内容库全部内容，或某个分类的内容
    case contentListInCategory(prameters: [String: Any]) // 某个分类的内容列表
    case categoryList(parameters: [String: Any]) // 某个内容库分类列表
    case categoryDetail(id: String) // 内容详情
}

extension ContentGroupAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .conentDetail(let contentId, _):
            return Config.ContentGroup.contentDetail(contentId: contentId)
        case .contentList:
            return Config.ContentGroup.contentList
        case .contentListInCategory:
            return Config.ContentGroup.contentList
        case .categoryList:
            return Config.ContentGroup.categoryList
        case .categoryDetail(let categoryId):
            return Config.ContentGroup.categoryDetail(categoryId: categoryId)

        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }

    var task: Task {
        switch self {
        case .contentList(let parameters), .contentListInCategory(let parameters):
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .categoryList(let parameters), .conentDetail(_, let parameters):
            return.requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .categoryDetail:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
