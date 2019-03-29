//
//  BaseQuery.swift
//  BaaSSDK
//
//  Created by pengquanhua on 2019/3/19.
//  Copyright © 2019 ifanr. All rights reserved.
//

import Foundation
import Moya

protocol RecordClearer {
    func clear()
}

open class BaseQuery: NSObject, RecordClearer {

    lazy var queryArgs: [String: Any] = [:]

    public func setQuery(query: Query) {
        // TODO: 错误处理
        let conditon = query.conditon as NSDictionary
        queryArgs["where"] = conditon.toJsonString
    }

    public func select(_ args: [String]) {
        queryArgs["keys"] = args.joined(separator: ",") // TODO: 查询条件检查
    }

    public func expand(_ args: [String]) {
        queryArgs["expand"] = args.joined(separator: ",")
    }

    public func limit(_ value: Int) {
        queryArgs["limit"] = value
    }

    public func offset(_ value: Int) {
        queryArgs["offset"] = value
    }

    public func orderBy(_ args: [String]) {
        queryArgs["order_by"] = args.joined(separator: ",")
    }

    func clear() {
        queryArgs = [:]
    }
}
