//
//  ContentGroupAPI.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/23.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

let CcontentGroupProvider = MoyaProvider<ContentGroupAPI>()

enum ContentGroupAPI {
    case conentDetail(id: String)
    case contentList(prameters: [String: Any]) // 某个内容库全部内容，或某个分类的内容
    case contentListInCategory(prameters: [String: Any]) // 某个分类的内容列表
    case categoryList(bodyParameters: [String: Any], urlParameters: [String: Any]) // 某个内容库分类列表
    case categoryDetail(id: String) // 内容详情
}

extension ContentGroupAPI: TargetType {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .conentDetail(let contentId):
            return Config.ContentGroup.contentDetail(contentId: contentId)
        case .contentList:
            return Config.ContentGroup.contentList
        case .contentListInCategory:
            return Config.ContentGroup.contentList
        case .categoryList:
            return Config.ContentGroup.categoryList
        case .categoryDetail(let categoryId):
            return Config.ContentGroup.categoryDetail(categoryID: categoryId)

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
        case .categoryList(let bodyParameters, let urlParameters):
            return .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: JSONEncoding.default, urlParameters: urlParameters)
        case .categoryDetail, .conentDetail:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return Config.HTTPHeaders
    }
}
